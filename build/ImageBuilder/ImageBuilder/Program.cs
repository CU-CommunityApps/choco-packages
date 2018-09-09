using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using chocolatey;
using chocolatey.infrastructure.app.configuration;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using WUApiLib;
using YamlDotNet.RepresentationModel;

namespace ImageBuilder
{
    class Program
    {

        void InstallUpdates()
        {
            // See http://www.nullskull.com/a/1592/install-windows-updates-using-c--wuapi.aspx

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
                        Console.WriteLine($"Installing {u.Title}");
                        uc.Add(u);
                        break;
                    }
                }
            }

            if (uc.Count == 0)
            {
                Console.WriteLine("No Windows Updates to Install");
                return;
            }

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
                    Console.WriteLine($"Installed: {uc[i].Title}");
                }
                else
                {
                    Console.WriteLine($"Failed: {uc[i].Title}");
                }
            }
        }

        void App()
        {
            this.InstallUpdates();
        }

        static void Main(string[] args)
        {
            new Program().App();
        }
    }
}
