$NETID = $env:AppStream_UserName


New-PSDrive -Name H -PSProvider FileSystem -Root "\\files.appsondemand.cucloud.net\share" -Credential CORNELL\$NETID