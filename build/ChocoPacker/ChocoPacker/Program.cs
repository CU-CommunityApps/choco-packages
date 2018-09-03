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
        private string temp_dir = Environment.GetEnvironmentVariable("TEMP");
        private string src_dir = Environment.GetEnvironmentVariable("CODEBUILD_SRC_DIR");
        private string src_version = Environment.GetEnvironmentVariable("CODEBUILD_SOURCE_VERSION");

        string RunGit(string args)
        {
            string git_path = temp_dir + "\\ChocoPackerBuild\\packages\\Git-Windows-Minimal.2.18.0\\tools\\cmd\\git.exe";

            Process git = new Process();

            git.StartInfo.FileName = git_path;
            git.StartInfo.WorkingDirectory = src_dir;
            git.StartInfo.Arguments = args; //"branch -a --contains " + src_version;
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
            string branch = branches.Trim().Split("\r\n".ToCharArray())[index];

            if (branch.Contains("/"))
            {
                branch = branch.Split('/').Last();
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

        void App()
        {
            string branches = this.RunGit("branch -a --contains " + this.src_version);
            string branch = this.GetBranch(branches, 0);
            string diffs = this.RunGit("show --name-only");
            List<string> packages = this.GetPackages(diffs);

            Console.WriteLine(branch);
            
            foreach (string package in packages)
            {
                Console.WriteLine("Package: " + package);
            }
        }

        static void Main(string[] args)
        {
            new Program().App();
        }
    }
}
