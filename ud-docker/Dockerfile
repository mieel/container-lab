# escape=`
ARG WIN_VER=2016
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc${WIN_VER}
RUN echo %WIN_VER%
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Write-Host %WIN_VER%
RUN Write-Host $WIN_VER

ENV WIN_VER ${WIN_VER}

RUN Write-Host $env:WIN_VER
RUN Write-Host $WIN_VER

#2.2.8
RUN Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/ba001109-03c6-45ef-832c-c4dbfdb36e00/e3413f9e47e13f1e4b1b9cf2998bc613/dotnet-hosting-2.2.8-win.exe`
 -OutFile c:/windows/temp/installer.exe
RUN Start-Process -FilePath c:/windows/temp/installer.exe -ArgumentList '/install','/quiet','/norestart' -Wait
RUN Remove-Item -Force c:/windows/temp/installer.exe

#2.1.8
RUN Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/86df96bb-384c-4d7a-82ce-2e4c2c871189/045870c1ab4004219cb312039c5a64d5/dotnet-hosting-2.1.5-win.exe`
 -OutFile c:/windows/temp/installer.exe
RUN Start-Process -FilePath c:/windows/temp/installer.exe -ArgumentList '/install','/quiet','/norestart' -Wait
RUN Remove-Item -Force c:/windows/temp/installer.exe

RUN Get-ChildItem c:/inetpub/wwwroot | Remove-Item -Force

RUN $path='C:\inetpub\wwwroot'; `
    $acl = Get-Acl $path; `
    $newOwner = [System.Security.Principal.NTAccount]('BUILTIN\IIS_IUSRS'); `
    $acl.SetOwner($newOwner); `
    dir -r $path | Set-Acl -aclobject  $acl

RUN Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force

RUN Save-Module -Name UniversalDashboard.Community -RequiredVersion 2.8.1 -Path C:\inetpub\wwwroot -Force
RUN Copy-Item -Path C:\inetpub\wwwroot\UniversalDashboard.Community\2.8.1\* -Destination C:\inetpub\wwwroot -Container -Recurse
RUN Get-ChildItem C:\windows\temp\UniversalDashboard.Community -Recurse -Force | `
        Sort-Object pspath -Descending -unique | Remove-Item -Force  -recurse

COPY ["dashboard.ps1", "c:/inetpub/wwwroot/dashboard.ps1"]

#COPY ["license.lic", "c:/inetpub/wwwroot/net451/license.lic"]
RUN Invoke-WebRequest http://localhost:80 -usebasicparsing
EXPOSE 80
