using chocolatey;
using log4net;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Concurrent;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using WUApiLib;

namespace ImageBuilder
{
    class Program
    {
        private const string BUCKET_PREFIX = "image-build-package-bucket";
        private const string CHOCO_REPO = "https://chocolatey.org/api/v2";
        private const string USER_DATA_URI = "http://169.254.169.254/latest/user-data";
        private const string DUMMY_USER_DATA = "{\"resourceArn\":\"arn:aws:appstream:us-east-1:530735016655:image-builder/custream.dev.mjs472\",\"Dummy\":\"true\"}";
        private const string DUMMY_BUILD_INFO = "{\"Packages\":[\"adobedcreader-cornell;2018.011.20055\"],\"Dummy\":\"true\"}";

        private static string TEMP_DIR = Path.Combine(Environment.GetEnvironmentVariable("TEMP"), "image-build");
        private static string PACKAGE_PATH = Path.Combine(TEMP_DIR, "packages");

        private static readonly ILog log = LogManager.GetLogger(System.Reflection.MethodBase.GetCurrentMethod().DeclaringType);

        private JObject user_data;
        private JObject build_info;

        private ConcurrentQueue<string> download_q = new ConcurrentQueue<string>();
        private ConcurrentDictionary<string, bool> downloaded = new ConcurrentDictionary<string, bool>();
        private ConcurrentQueue<string> install_q = new ConcurrentQueue<string>();

        private string aws_region;
        private string aws_account;
        private string build_id;
        private string build_bucket;
        private string build_branch;
        private string bucket_uri;
        private string api_uri;

        private string DownloadString(string uri)
        {
            string result;

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
            JObject result;

            var req = HttpWebRequest.Create(uri);
            req.Method = method;
            req.ContentType = "application/json";

            try
            {
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

                    try
                    {
                        result = JObject.Parse(results);
                    }
                    catch (JsonReaderException)
                    {
                        result = JObject.Parse(DUMMY_USER_DATA);
                    }
                }
            }
            catch (WebException)
            {
                result = JObject.Parse(DUMMY_BUILD_INFO);
            }

            return result;
        }

        private void ParseUserData()
        {
            this.user_data = this.CallRestService(USER_DATA_URI, "GET", null);
            string[] arn = ((string) user_data["resourceArn"]).Split(':');
            this.aws_region = arn[3];
            this.aws_account = arn[4];
            this.build_id = arn[5].Split('/')[1];
            this.build_bucket = $"{BUCKET_PREFIX}-{this.aws_account}-{this.aws_region}";
            this.build_branch = this.build_id.Split('.')[1];
            this.bucket_uri = $"https://{this.build_bucket}.s3.amazonaws.com";
            this.api_uri = this.DownloadString($"{this.bucket_uri}/api_endpoint.txt");

            string build_post = $"{{ \"BuildId\":\"{this.build_id}\" }}";
            this.build_info = this.CallRestService($"{this.api_uri}/get-build", "POST", build_post);
            JArray packages = (JArray) this.build_info["Packages"];
            
            foreach (string package in packages)
            {
                bool queued = false;

                while (!queued)
                {
                    queued = this.downloaded.TryAdd(package, false);
                }
                
                this.download_q.Enqueue(package);
            }
        }

        private void DownloadPackages()
        {
            while (true)
            {
                if (this.download_q.Count == 0)
                {
                    break;
                }

                string package;
                bool success = this.download_q.TryDequeue(out package);

                if (success)
                {
                    string package_name = package.Split(';')[0];
                    string package_version = package.Split(';')[1];
                    string package_uri = $"{this.bucket_uri}/packages/{this.build_branch}/{package_name}.{package_version}.nupkg";
                    string package_local = Path.Combine(PACKAGE_PATH, $"{package_name}.{package_version}.nupkg");

                    this.DownloadFile(package_uri, package_local);

                    while (!this.downloaded.TryUpdate(package, true, false));
                    this.install_q.Enqueue(package);
                }
            }
        }

        private void InstallPackages()
        {
            for (int i = 0; i < 3; i++)
            {
                ThreadStart sd = this.DownloadPackages;
                Thread td = new Thread(sd);
                td.Start();
            }

            while (true)
            {
                if (this.install_q.Count == 0 && this.downloaded.Count == 0)
                {
                    break;
                }

                string package;
                bool success = this.install_q.TryDequeue(out package);

                if (success)
                {
                    bool package_downloaded;
                    success = this.downloaded.TryGetValue(package, out package_downloaded);

                    if (!success)
                    {
                        this.install_q.Enqueue(package);
                        continue;
                    }

                    if (!package_downloaded)
                    {
                        this.install_q.Enqueue(package);

                        if (this.install_q.Count == 1)
                        {
                            Thread.Sleep(2000);
                        }

                        continue;
                    }

                    string package_name = package.Split(';')[0];
                    string package_version = package.Split(';')[1];
                    string package_local = Path.Combine(PACKAGE_PATH, $"{package_name}.{package_version}.nupkg");

                    log.Info($"Installing {package_name}.{package_version}");

                    var choco = new GetChocolatey();

                    choco.Set(c =>
                    {
                        c.CommandName = "install";
                        c.PackageNames = package_name;
                        c.Sources = $"{CHOCO_REPO};{PACKAGE_PATH}";
                        c.AcceptLicense = true;
                        //c.AdditionalLogFileLocation
                    }).Run();

                    File.Delete(package_local);
                    while(!this.downloaded.TryRemove(package, out package_downloaded));

                    log.Info($"{package_name}.{package_version} Installed!");
                }
            }
        }

        private void InstallUpdates()
        {
            // See http://www.nullskull.com/a/1592/install-windows-updates-using-c--wuapi.aspx

            log.Info("Checking for Windows Updates...");

            UpdateSession us = new UpdateSession();
            IUpdateSearcher uss = us.CreateUpdateSearcher();
            ISearchResult sr = uss.Search("IsInstalled=0");
            UpdateCollection uc = new UpdateCollection();
            
            foreach (IUpdate u in sr.Updates)
            {
                foreach (ICategory c in u.Categories)
                {
                    if (c.Name.ToLower().Contains("security") || c.Name.ToLower().contains("critical"))
                    {
                        uc.Add(u);
                        break;
                    }
                }
            }

            if (uc.Count == 0)
            {
                log.Info("No Windows Updates to Install");
                return;
            }

            log.Info($"Installing {uc.Count} Critical/Security Updates...");

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
                    log.Info($"Installed: {uc[i].Title}");
                }
                else
                {
                    log.Info($"Failed: {uc[i].Title}");
                }
            }
        }

        void App()
        {
            this.ParseUserData();
            this.InstallPackages();
            
            //this.InstallUpdates();
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
