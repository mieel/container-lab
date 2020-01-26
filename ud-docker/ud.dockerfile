# escape=`
ARG WIN_IMAGE=mcr.microsoft.com/dotnet/framework/aspnet
ARG BASE_TAG=4.8-windowsservercore-ltsc
ARG WIN_VER=2016

FROM ${WIN_IMAGE}:${BASE_TAG}${WIN_VER}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

#redeclare pre-FROM variables if you need them
ARG WIN_VER
ARG BASE_TAG
ARG WIN_IMAGE

RUN Write-Host "Building $Env:BASE_TAG$Env:WIN_VER"
RUN Get-PackageProvider   
#Install dotnetcore hosting bundle 2.2.8
RUN Invoke-WebRequest -Uri https://download.visualstudio.microsoft.com/download/pr/ba001109-03c6-45ef-832c-c4dbfdb36e00/e3413f9e47e13f1e4b1b9cf2998bc613/dotnet-hosting-2.2.8-win.exe`
 -OutFile c:/windows/temp/installer.exe
RUN Start-Process -FilePath c:/windows/temp/installer.exe -ArgumentList '/install','/quiet','/norestart' -Wait
RUN Remove-Item -Force c:/windows/temp/installer.exe

# verify dotnet runtime - IIS
RUN dotnet --list-runtimes;
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

RUN Invoke-WebRequest http://localhost:80 -usebasicparsing
EXPOSE 80
