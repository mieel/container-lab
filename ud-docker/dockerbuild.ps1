Param(
    [ValidateSet("2016","2019")]
    $WindowsVersion
)# BUILD IMAGE
# BUILD IMAGE(s)
$images = @()
Set-Location $PSScriptRoot
$dockerfiles = Get-ChildItem -Filter '*.dockerfile'
$dockerfiles
ForEach ($dockerfile in $dockerfiles) {
    Write-Host "Building: " $dockerfile.Name
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
ForEAch ($image in $images) {
    
    $container = docker run -d -p 80 $image

    $containerPort = docker port $container

    $PortNumber = $containerPort | ForEach-Object {
        $sc = $containerPort.IndexOf(':')+1
        $containerPort.Substring($sc,$containerPort.Length-$sc)
    }

    Write-Host "Image $image is running in $container on port $portNumber"

    $endpointUrl = "http://localhost:$PortNumber"
    # TEST
    Describe "Testing $image" {
        $Response = Invoke-WebRequest $endpointUrl
        $ExpectedContent = 'Universal Dashboard'
        it 'should return Expected content' {
            $Response.Content | Should -match "$ExpectedContent" 
        }
    }

    $endpointUrl
}
