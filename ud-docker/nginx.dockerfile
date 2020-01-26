# escape=`
# Install Downloader
FROM mcr.microsoft.com/windows/servercore:ltsc2016 AS installer
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV NGINX_VERSION="1.12.2"

RUN Invoke-WebRequest -OutFile nginx.zip -UseBasicParsing "http://nginx.org/download/nginx-$($env:NGINX_VERSION).zip"; `
    Expand-Archive nginx.zip -DestinationPath C:\ ; `
    Rename-Item "C:\nginx-$($env:NGINX_VERSION)" C:\nginx;

# NGINX
FROM mcr.microsoft.com/windows/servercore:ltsc2016

EXPOSE 80 443
WORKDIR C:\nginx
CMD ".\nginx"

RUN md C:\nginx\cache

COPY --from=installer C:\nginx\ .
COPY docker\nginx\conf .\conf