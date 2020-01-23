Import-Module UniversalDashboard.Community
Start-UDDashboard -Port 90 -Dashboard (
    New-UDDashboard -Title "Hello, IIS" -Content {
        New-UDCard -Title "Hello, IIS"
    }
) -force
