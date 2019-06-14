# Application Packaging Template
This repository contains application configuration settings for silent installations in a non-persistent environment

### Prerequisites
test system (Windows Server 2012R2 +)
7zip
git

## Getting Started
1. Test silent install switches for your new app on a test box (preferably Windows Server 2012R2 +) - including any registry settings or appdata configuration files to minimize user pop ups ```ie. accept EULA```
2. Use 7-zip to compress all installation files, custom scripts and any secrets, naming compressed file accordingly to application being packaged```ie. chrome-cornell.zip``` which includes ```setup.exe and/or activation.ps1```
3. Upload .zip to S3 bucket using current admin website

## Packaging
* Create a new package in choco-packages test branch using the same name from step 2. minus .zip ```ie. chrome-cornell```
* Add custom icon to [icons](./icons) directory in .png format
* Edit the [preinstall](./tools/preinstall.ps1) or [postinstall](./tools/postinstall.ps1) scripts to run commands respectively
* Add any custom scripts or files to the [tools directory](./tools) to be used during installation that are not private or known 'secrets' ```ie. startup.xml or eula.ini```
* Begin editing [config.yml](./config.yml) for current application, view template for additional references

### Deployment
* Commits to github will begin the build process using Chocolatey compressing installation .zip files and current package repo contents to a .nupkg file for installation on any Windows machine
* Test your package on a supported subnet with the [troubleshooting script](./troubleshooting.ps1)
* Create pull request once all testing is complete!
