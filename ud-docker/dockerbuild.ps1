Param(
    [ValidateSet("2016","2019")]
    $WindowsVersion
)# BUILD IMAGE
$tag = "$WindowsVersion-iis-ud"
Try {
    cd $PSScriptRoot
    docker build -t $tag --build-arg WIN_VER=$WindowsVersion .
} Catch {
    Throw $_
}

# CREATE CONTAINER
$container = docker run -d -p 80 $tag

$containerPort = docker port $container

$PortNumber = $containerPort | ForEach-Object {
    $sc = $containerPort.IndexOf(':')+1; $containerPort.Substring($sc,$containerPort.Length-$sc)
}

Write-Host "Container $container is running on port $portNumber"

# TEST
Describe 'response' {
    $Response = Invoke-WebRequest http://localhost:$PortNumber
    it 'should return Expected content' {
        $Response.Content | Should -match 'Universal Dashboard'
    }
}

