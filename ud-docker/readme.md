# Running Universal Dashboard in IIS, in a Docker Container.
## High level overview
1. Dockerfile
  * uses `mcr.microsoft.com/windows/servercore/iis` as starting image
  * installs dotnet, Nuget and Universal Dashboard  
  
2. Dashboard.ps1
3. dockerbuild.ps1
## Demo
1. go to `/ud-docker` directory
2. Run `dockerbuild.ps`
* A fresh windows-iis image is build, with Universal Dashboard installed
* A container is spun up with a random port
* A test request is run on the fresh container
