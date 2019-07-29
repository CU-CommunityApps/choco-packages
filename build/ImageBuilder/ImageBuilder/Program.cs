using Amazon.AppStream;
using Amazon.AppStream.Model;
using Amazon.CloudWatchLogs;
using Amazon.CloudWatchLogs.Model;
using Amazon.PhotonAgentProxy;
using Amazon.PhotonAgentProxy.Model;
using Amazon.Runtime;
using log4net;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Photon.PhotonAgentCommon.Utils;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using WUApiLib;

namespace ImageBuilder
{
    class Program
    {
        private const string BUCKET_PREFIX = "image-build";
        private const string CHOCO_REPO = "https://chocolatey.org/api/v2";
        private const string USER_DATA_URI = "http://169.254.169.254/latest/user-data";

        private static string PROGRAM_DATA = Environment.GetEnvironmentVariable("ALLUSERSPROFILE");
        private static string TEMP_DIR = Path.Combine(PROGRAM_DATA, "TEMP");
        private static string PACKAGE_PATH = Path.Combine(TEMP_DIR, "packages");
        private static string INSTALLED_LOCK = Path.Combine(TEMP_DIR, "INSTALLED.lock");
        private static string UPDATED_LOCK = Path.Combine(TEMP_DIR, "UPDATED.lock");
        private static string SNAPSHOT_LOCK = Path.Combine(TEMP_DIR, "SNAPSHOT.lock");

        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private JObject user_data;
        private JObject build_info;
        private JArray packages;

        private SessionAWSCredentials aws_credentials;
        private AmazonCloudWatchLogsClient cwl;
        private AmazonAppStreamClient appstream;

        private bool install_updates;

        private string aws_region;
        private string aws_account;
        private string build_arn;
        private string build_id;
        private string build_bucket;
        private string build_branch;
        private string image_name;
        private string bucket_uri;
        private string api_uri;
        private string log_stream_token;

        static IEnumerable<string> SplitString(string str, int maxChunkSize)
        {
            for (int i = 0; i < str.Length; i += maxChunkSize)
                yield return str.Substring(i, Math.Min(maxChunkSize, str.Length - i));
        }

        private string DownloadString(string uri)
        {
            log.Info($"Downloading String: {uri}");

            string result;

            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
            var req = HttpWebRequest.Create(uri);
            req.Method = "GET";

            using (var resp = req.GetResponse())
            {
                result = new StreamReader(resp.GetResponseStream()).ReadToEnd();
            }

            return result;
        }

        private void DownloadFile(string uri, string out_path)
        {
            log.Info($"Downloading: {uri} to {out_path}");

            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
            var req = HttpWebRequest.Create(uri);
            req.Method = "GET";

            using (var resp = req.GetResponse())
            {
                using (Stream s = File.Create(out_path))
                {
                    resp.GetResponseStream().CopyTo(s);
                }
            }

            log.Info($"{uri} Downloaded!");
        }

        private JObject CallRestService(string uri, string method, dynamic body)
        {
            log.Info($"Calling Rest Service {uri} with body {body}");

            JObject result;

            System.Net.ServicePointManager.SecurityProtocol = System.Net.SecurityProtocolType.Tls12;
            var req = HttpWebRequest.Create(uri);
            req.Method = method;
            req.ContentType = "application/json";

                if (body != null)
                {
                    byte[] bytes = UTF8Encoding.UTF8.GetBytes(body);
                    req.ContentLength = bytes.Length;

                    using (var stream = req.GetRequestStream())
                    {
                        stream.Write(bytes, 0, bytes.Length);
                    }
                }

                using (var resp = req.GetResponse())
                {
                    var results = new StreamReader(resp.GetResponseStream()).ReadToEnd();
                    result = JObject.Parse(results);
                }

            return result;
        }

        private void RebootSystem()
        {
            this.PutCloudWatchLog("Rebooting in 5 min");
            Thread.Sleep(300000);
            this.PutCloudWatchLog("Requesting Image Builder Stop...");

            StopImageBuilderRequest req = new StopImageBuilderRequest();
            req.Name = this.build_id;

            try
            {
                StopImageBuilderResponse resp = appstream.StopImageBuilder(req);
            }
            catch (Amazon.AppStream.Model.OperationNotPermittedException)
            {
                this.InitiateEnvironment();
                StopImageBuilderResponse resp = appstream.StopImageBuilder(req);
            }
            catch (Amazon.AppStream.AmazonAppStreamException)
            {
                this.InitiateEnvironment();
                StopImageBuilderResponse resp = appstream.StopImageBuilder(req);
            }
            catch (Exception ex)
            {
                this.PutCloudWatchLog($"Uncaught Image Builder Reboot Exception:\n\n{ex.StackTrace}");
                this.PutCloudWatchLog("Restarting using shutdown.exe");
                Process.Start("shutdown.exe", "/r /f /t 0");
            }
        }

        private void InitiateEnvironment()
        {
            this.user_data = this.CallRestService(USER_DATA_URI, "GET", null);
            this.build_arn = (string) user_data["resourceArn"];
            string[] arn = (this.build_arn).Split(':');
            this.aws_region = arn[3];
            this.aws_account = arn[4];
            this.build_id = arn[5].Split('/')[1];
            this.build_bucket = $"{BUCKET_PREFIX}-{this.aws_account}-{this.aws_region}";
            this.build_branch = this.build_id.Split('.')[1];
            List<string> build_ids = new List<string>();
            string[] temp_build_id = this.build_id.Split('.');

            for (int i = 2; i < temp_build_id.Length; i++) {
                build_ids.Add(temp_build_id[i]);
            }

            this.image_name = string.Join(".", build_ids);
            this.bucket_uri = $"https://{this.build_bucket}.s3.amazonaws.com";
            this.api_uri = this.DownloadString($"{this.bucket_uri}/api_endpoint.txt").Trim();

            string build_post = $"{{ \"BuildId\":\"{this.build_id}\" }}";
            this.build_info = this.CallRestService($"{this.api_uri}/image-build", "POST", $"{{\"BuildId\":\"{this.image_name}\"}}");
            this.install_updates = (bool)this.build_info["InstallUpdates"];
            this.packages = (JArray)this.build_info["Packages"];

            this.aws_credentials = new SessionAWSCredentials(
                (string) this.build_info["AwsSession"]["Credentials"]["AccessKeyId"],
                (string) this.build_info["AwsSession"]["Credentials"]["SecretAccessKey"],
                (string) this.build_info["AwsSession"]["Credentials"]["SessionToken"]
            );

            this.cwl = new AmazonCloudWatchLogsClient(this.aws_credentials);
            this.appstream = new AmazonAppStreamClient(this.aws_credentials);

            try
            {
                this.cwl.CreateLogGroup(new CreateLogGroupRequest(
                    logGroupName: "image-builds"
                ));
            }
            catch (Amazon.CloudWatchLogs.Model.ResourceAlreadyExistsException) { }

            try
            {
                DescribeLogStreamsRequest req = new DescribeLogStreamsRequest("image-builds");
                req.LogStreamNamePrefix = this.build_id;
                DescribeLogStreamsResponse resp = this.cwl.DescribeLogStreams(req);
                LogStream log_stream = resp.LogStreams[0];
                this.log_stream_token = log_stream.UploadSequenceToken;
            }
            catch (ArgumentOutOfRangeException) {
                this.cwl.CreateLogStream(new CreateLogStreamRequest(
                    logGroupName: "image-builds",
                    logStreamName: this.build_id
                ));

                InputLogEvent log_message = new InputLogEvent();
                log_message.Message = "Initialized Log Stream";
                log_message.Timestamp = DateTime.UtcNow;

                PutLogEventsResponse resp = this.cwl.PutLogEvents(new PutLogEventsRequest(
                    logGroupName: "image-builds",
                    logStreamName: this.build_id,
                    logEvents: new List<InputLogEvent>() { log_message }
                ));

                this.log_stream_token = resp.NextSequenceToken;
            }

            this.PutCloudWatchLog("Environment Initialized");
        }

        private void PutCloudWatchLog(string message)
        {
            if (message.Length < 1)
            {
                return;
            }

            log.Info(message);

            foreach (string chunk in SplitString(message, 260000))
            {
                InputLogEvent log_message = new InputLogEvent();
                log_message.Message = chunk;
                log_message.Timestamp = DateTime.UtcNow;

                try
                {
                    PutLogEventsRequest req = new PutLogEventsRequest(
                        logGroupName: "image-builds",
                        logStreamName: this.build_id,
                        logEvents: new List<InputLogEvent>() { log_message }
                    );

                    req.SequenceToken = this.log_stream_token;
                    PutLogEventsResponse resp = this.cwl.PutLogEvents(req);
                    this.log_stream_token = resp.NextSequenceToken;
                }
                catch (Amazon.CloudWatchLogs.AmazonCloudWatchLogsException ex)
                {
                    log.Warn($"Refreshing AWS Credentials: {ex.ErrorCode}");
                    this.InitiateEnvironment();
                    this.PutCloudWatchLog($"Refreshed AWS Credentials when hitting: {ex.ErrorCode}");

                    try
                    {
                        PutLogEventsRequest req = new PutLogEventsRequest(
                            logGroupName: "image-builds",
                            logStreamName: this.build_id,
                            logEvents: new List<InputLogEvent>() { log_message }
                        );

                        req.SequenceToken = this.log_stream_token;
                        PutLogEventsResponse resp = this.cwl.PutLogEvents(req);
                        this.log_stream_token = resp.NextSequenceToken;
                    }
                    catch(Exception ex2)
                    {
                        log.Error($"Uncaught CloudWatch Exception:\n\n{ex.StackTrace}\n\n{ex2.Message}");
                    }
                }
                catch (Exception ex)
                {
                    log.Error($"Uncaught CloudWatch Exception:\n\n{ex.StackTrace}\n\n{ex.Message}");
                }
            }
        }

        private void InstallPackages()
        {
            foreach (string package in this.packages)
            {
                string package_name = package.Split(';')[0];
                string package_version = package.Split(';')[1];
                string package_local = Path.Combine(PACKAGE_PATH, $"{package_name}.{package_version}.nupkg");
                string package_local_choco = Path.Combine(PROGRAM_DATA, "chocolatey", "lib", package_name, $"{package_name}.nupkg");
                string package_uri = $"{this.bucket_uri}/packages/{this.build_branch}/{package_name}.{package_version}.nupkg";
                string package_log = Path.Combine(PROGRAM_DATA, "chocolatey", "lib", package_name, $"{package_name}.{package_version}.log");
                string choco_path = Path.Combine(PROGRAM_DATA, "chocolatey", "bin", "choco.exe");

                this.PutCloudWatchLog($"Downloading {package_name}.{package_version}");
                this.DownloadFile(package_uri, package_local);

                this.PutCloudWatchLog($"Installing {package_name}.{package_version}");
                Process choco_process = new Process(); 
                choco_process.StartInfo.UseShellExecute = false;
                choco_process.StartInfo.FileName = choco_path;
                choco_process.StartInfo.Arguments = $"install {package_name} -y -r -s {CHOCO_REPO};{PACKAGE_PATH}";
                choco_process.StartInfo.RedirectStandardOutput = true;
                //choco_process.StartInfo.RedirectStandardError = true;
                choco_process.Start();

                string output = choco_process.StandardOutput.ReadToEnd();
                //string err = choco_process.StandardError.ReadToEnd();
                choco_process.WaitForExit();
                this.PutCloudWatchLog(output);
                //this.PutCloudWatchLog(err);
                this.PutCloudWatchLog($"{package_name}.{package_version} Installed! (perhaps, check the log above to be sure)");

                File.Delete(package_local);

                if (File.Exists(package_local_choco))
                {
                    File.Delete(package_local_choco);
                }
            }

            using (StreamWriter s = File.CreateText(INSTALLED_LOCK))
            {
                s.Write("PACKAGES INSTALLED");
                s.Close();
            }
        }

        private void InstallUpdates()
        {
            // See http://www.nullskull.com/a/1592/install-windows-updates-using-c--wuapi.aspx

            this.PutCloudWatchLog("Checking for Windows Updates...");

            UpdateSession us = new UpdateSession();
            IUpdateSearcher uss = us.CreateUpdateSearcher();
            ISearchResult sr = uss.Search("IsInstalled=0");
            UpdateCollection uc = new UpdateCollection();
            
            foreach (IUpdate u in sr.Updates)
            {
                foreach (ICategory c in u.Categories)
                {
                    if (c.Name.ToLower().Contains("security") || c.Name.ToLower().Contains("critical"))
                    {
                        uc.Add(u);
                        break;
                    }
                }
            }

            if (uc.Count == 0)
            {
                this.PutCloudWatchLog("No Windows Updates to Install");
                return;
            }

            this.PutCloudWatchLog($"Installing {uc.Count} Critical/Security Updates...");

            UpdateDownloader ud = us.CreateUpdateDownloader();
            ud.Updates = uc;
            ud.Download();

            IUpdateInstaller ui = us.CreateUpdateInstaller();
            ui.Updates = uc;
            IInstallationResult uir = ui.Install();

            for (int i = 0; i < uc.Count; i++)
            {
                if (uir.GetUpdateResult(i).HResult == 0)
                {
                    this.PutCloudWatchLog($"Installed: {uc[i].Title}");
                }
                else
                {
                    this.PutCloudWatchLog($"Failed: {uc[i].Title}");
                }
            }

            this.PutCloudWatchLog("Windows Update Completed!");

            using (StreamWriter s = File.CreateText(UPDATED_LOCK))
            {
                s.Write("WINDOWS UPDATES INSTALLED");
                s.Close();
            }
        }

        private void InitiateSnapshot()
        {
            this.PutCloudWatchLog("Initiating Snapshot in two minutes...");
            Thread.Sleep(120000);

            IEC2MetadataProvider metadataProvider = (IEC2MetadataProvider)new EC2MetadataProvider();
            CancellationTokenSource cancellationTokenSource = new CancellationTokenSource();

            Task<IAmazonPhotonAgentProxy> proxyClientAsync = metadataProvider.GetProxyClientAsync(cancellationTokenSource.Token);
            proxyClientAsync.Wait();
            IAmazonPhotonAgentProxy result = proxyClientAsync.Result;

            CreateImageRequest request = new CreateImageRequest();
            request.Name = this.image_name;
            request.DisplayName = this.image_name;
            request.Description = this.image_name;
            request.DynamicApplicationCatalogEnabled = false;
            request.PhotonSoftwareVersion = "LATEST";

            try
            {
                result.CreateImage(request);
                this.PutCloudWatchLog("Successfully initiated snapshot!");
            }
            catch (Exception ex)
            {
                this.PutCloudWatchLog("Error initiating snapshot!");
                this.PutCloudWatchLog(ex.ToString());
                this.RebootSystem();
            }
        }

        void App()
        {
            try
            {
                this.InitiateEnvironment();

                if (!File.Exists(INSTALLED_LOCK))
                {
                    this.InstallPackages();
                    this.RebootSystem();
                }
                else if (this.install_updates && !File.Exists(UPDATED_LOCK))
                {
                    this.InstallUpdates();
                    this.RebootSystem();
                }
                else
                {
                    this.InitiateSnapshot();
                }
            }
            catch (Exception ex)
            {
                this.PutCloudWatchLog($"[FATAL] Uncaught Exception:\n\n{ex.StackTrace}\n\n{ex.Message}");
                this.RebootSystem();
            }
        }

        static void Main(string[] args)
        {
            if (!Directory.Exists(PACKAGE_PATH))
            {
                Directory.CreateDirectory(PACKAGE_PATH);
            }

            new Program().App();
        }
    }
}
