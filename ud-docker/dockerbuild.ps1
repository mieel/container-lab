Param(
    [ValidateSet("2016","2019")]
    $WindowsVersion = 2016
)# BUILD IMAGE
# BUILD IMAGE(s)
$images = @()
Set-Location $PSScriptRoot
$dockerfiles = Get-ChildItem -Filter '*.dockerfile'
$dockerfiles
ForEach ($dockerfile in $dockerfiles) {
    Write-Host "`n`tBuilding: " $dockerfile.Name
    $tag = $dockerfile.BaseName + ':local'
    Try {
        # build docker image specifying the tag and dockerfile, with the current workdir as context
        docker build -t $tag --build-arg WIN_VER=$WindowsVersion -f $dockerfile.Name .
    } Catch {
        Throw $_
    }
    $images += $tag
}

# CREATE CONTAINER(s)
Write-Host "Create containers for:"
Write-Host $images

$containers = @()
ForEach ($image in $images) {
    
    Write-Host "Starting Container for $image"
    $container = docker run -d --rm -P $image
    $containers += $container
    $Ports = docker inspect $container | ConvertFrom-Json | %{$_.networksettings.Ports}

    $Host80Port = $Ports.'80/tcp'.HostPort
    $ContainterIp = docker inspect $container | ConvertFrom-Json | %{$_.networksettings.Networks.Nat.IPAddress}
    Write-Host "
        Image $image is running in Container $container
        With Port 80 exposed to $Host80Port
        IP : $ContainterIp
    "

    $LocalHostUrl = "http://localhost:$Host80Port"
    # TEST
    $test = Describe "connectivity $image"{
        
        it "should be responding to $LocalHostUrl" {
            $Response = Invoke-WebRequest "$LocalHostUrl" -UseBasicParsing          
            $Response.StatusCode | Should -be '200'
        }
        it "should be responding to $ContainterIp" {
            $Response = Invoke-WebRequest $ContainterIp -UseBasicParsing          
            $Response.StatusCode | Should -be '200'
        }
    } 6>&1
    $test 
    if ($test -like '*[-]*') { Throw 'Test failed'}
    
}

$containers | %{ docker container stop $_}
