
@ECHO OFF

:Win7

pushd %windir%\system32\inetsrv

REM ftproot is the location of the ftp data directory
set ftproot=%systemdrive%\inetpub\wwwroot

REM ftpsite is the name of the ftp site
set ftpsite=Default Web Site

if not exist "%ftproot%" (mkdir "%ftproot%")
@REM don't use the old style as it will give trouble for canocial order when command line deploying to %ftprot%: cacls "%ftproot%" /G IUSR:W /T /E
icacls "%ftproot%" /grant IUSR:(W,RC,X) /t

appcmd.exe set config -section:sites "/+[name='%ftpsite%'].bindings.[protocol='ftp',bindingInformation='*:21:']"
appcmd set config -section:system.applicationHost/sites "/[name='%ftpsite%'].ftpServer.security.ssl.controlChannelPolicy:SslAllow"
appcmd set config -section:system.applicationHost/sites "/[name='%ftpsite%'].ftpServer.security.ssl.dataChannelPolicy:SslAllow"
appcmd set config -section:system.applicationHost/sites "/[name='%ftpsite%'].ftpServer.security.authentication.basicAuthentication.enabled:true"
appcmd set config -section:system.applicationHost/sites "/[name='%ftpsite%'].ftpServer.security.authentication.anonymousAuthentication.enabled:true"

@REM Before adding all user read/write permission, remove all users in case it's there already
appcmd set config "%ftpsite%" /section:system.ftpserver/security/authorization /-[users='*'] /commit:apphost
appcmd set config "%ftpsite%" /section:system.ftpserver/security/authorization /+[accessType='Allow',permissions='Read,Write',roles='',users='*'] /commit:apphost

iisreset

@REM need to open 3 ftp firewall ports
netsh advfirewall firewall add rule name="FTP (non-SSL)" action=allow protocol=TCP dir=in localport=21
netsh advfirewall set global StatefulFtp disable
netsh advfirewall firewall add rule name="FTP for IIS7" service=ftpsvc action=allow protocol=TCP dir=in

Echo *** Share wwwroot ***
cmd.exe /C net share wwwroot$=%SystemDrive%\inetpub\wwwroot /GRANT:Everyone,FULL

Echo *** Config firewall ***
Call .\SetTierFirewall.bat

popd

:End


