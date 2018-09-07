using Amazon.S3;
using Amazon.S3.Model;
using Amazon.S3.Transfer;
using chocolatey;
using chocolatey.infrastructure.app.configuration;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using YamlDotNet.RepresentationModel;

namespace ImageBuilder
{
    class Program
    {
        void App()
        {
            Console.WriteLine("Goodbye World!");
        }

        static void Main(string[] args)
        {
            new Program().App();
        }
    }
}
