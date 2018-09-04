using Amazon.S3;
using Amazon.S3.Model;
using chocolatey;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ChocoPacker
{
    class Program
    {
        private string package_bucket = Environment.GetEnvironmentVariable("PACKAGE_BUCKET");
        private string temp_dir = Environment.GetEnvironmentVariable("TEMP");
        private string src_dir = Environment.GetEnvironmentVariable("CODEBUILD_SRC_DIR");
        private string src_version = Environment.GetEnvironmentVariable("CODEBUILD_SOURCE_VERSION");

        string RunGit(string args)
        {
            string git_path = temp_dir + "\\ChocoPackerBuild\\packages\\Git-Windows-Minimal.2.18.0\\tools\\cmd\\git.exe";

            Process git = new Process();

            git.StartInfo.FileName = git_path;
            git.StartInfo.WorkingDirectory = src_dir;
            git.StartInfo.Arguments = args;
            git.StartInfo.CreateNoWindow = true;
            git.StartInfo.UseShellExecute = false;
            git.StartInfo.RedirectStandardOutput = true;
            git.StartInfo.RedirectStandardError = true;

            git.Start();
            git.WaitForExit();
            string git_out = git.StandardOutput.ReadToEnd();
            string git_err = git.StandardError.ReadToEnd();

            if (git_err.Length > 0)
                Console.Error.WriteLine(git_err);

            return git_out;
        }

        string GetBranch(string branches, int index)
        {
            string branch = branches.Split("\r\n".ToCharArray())[index].Trim();

            if (branch.Contains("/"))
            {
                branch = branch.Split('/').Last().Trim();
            }

            return branch;
        }

        List<string> GetPackages(string diffs)
        {
            List<string> packages = new List<string>();

            using (StringReader reader = new StringReader(diffs))
            {
                string line = string.Empty;

                while (line != null)
                {
                    line = reader.ReadLine();

                    if (line != null && line.StartsWith("packages/"))
                    {
                        string package = line.Split('/')[1];

                        if (!package.StartsWith("_"))
                        {
                            packages.Add(package);
                        }
                    }
                }
            }

            return packages;
        }

        bool PackageInstallerExists(string branch, string package)
        {
            bool exists;

            string package_prefix = $"installers/{branch}/{package}.zip";
            Console.WriteLine("Package: " + package_prefix);
            AmazonS3Client s3 = new AmazonS3Client();

            ListObjectsV2Request req = new ListObjectsV2Request();
            req.BucketName = this.package_bucket;
            req.Prefix = package_prefix;

            ListObjectsV2Response resp =  s3.ListObjectsV2(req);
            exists = (resp.KeyCount > 0) ? true : false;

            return exists;
        }

        void App()
        {
            string branches = this.RunGit("branch -a --contains " + this.src_version);
            string branch = this.GetBranch(branches, 1);
            string diffs = this.RunGit("show --name-only");
            List<string> packages = this.GetPackages(diffs);

            Console.WriteLine(branch);
            
            foreach (string package in packages)
            {
                bool exists = this.PackageInstallerExists(branch, package);

                if (exists)
                {
                    Console.WriteLine("hello");
                }
                else
                {
                    Console.WriteLine("goodbye");
                }
            }
        }

        static void Main(string[] args)
        {
            new Program().App();
        }
    }
}
