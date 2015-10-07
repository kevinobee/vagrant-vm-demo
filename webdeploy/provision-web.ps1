Import-Module ServerManager

$features = @(
    "Web-WebServer", 
    "Web-Static-Content",
    "Web-Http-Errors",
    "Web-Http-Redirect",
    "Web-Stat-Compression",
    "Web-Filtering",
    "Web-Asp-Net45",
    "Web-Net-Ext45",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Mgmt-Console",
    "Web-Mgmt-Tools",
    "NET-Framework-45-ASPNET")

Add-WindowsFeature $features -Verbose
# TODO choco install IIS -source windowsfeatures

iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# TODO choco install boxstarter -y

# TODO choco install puppet -y

choco install webdeploy -y

# TODO choco install sim --version 1.4 -y

# TODO choco install mongodb -y

# TODO install SQL Server - choco install mssqlserver2012express

# TODO add shortcuts to taskbar and desktop
#    - ref  http://stackoverflow.com/questions/9739772/how-to-pin-to-taskbar-using-powershell
# $system32Path = $env:windir + "\system32"
# $sa = new-object -c shell.application
# $pn = $sa.namespace($system32Path).parsename('notepad.exe')
# $pn.invokeverb('taskbarpin')



function Get-ComFolderItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] $Path
    )

    $ShellApp = New-Object -ComObject 'Shell.Application'

    $Item = Get-Item $Path -ErrorAction Stop

    if ($Item -is [System.IO.FileInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Directory.FullName).ParseName($Item.Name)
    } elseif ($Item -is [System.IO.DirectoryInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Parent.FullName).ParseName($Item.Name)
    } else {
        throw "Path is not a file nor a directory"
    }

    return $ComFolderItem
}

function Install-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarpin')
}

function Uninstall-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarunpin')
}

# The order results in a left to right ordering
$PinnedItems = @(
    'C:\ProgramData\chocolatey\lib\sim\tools\SIM.Tool.exe'
    'C:\windows\system32\notepad.exe'
)

# Removing each item and adding it again results in an idempotent ordering
# of the items. If order doesn't matter, there is no need to uninstall the
# item first.
foreach($Item in $PinnedItems) {
    Uninstall-TaskBarPinnedItem -Item $Item
    Install-TaskBarPinnedItem   -Item $Item
}