function LogWrite {
    Param ([string]$logstring)
    $now = Get-Date -format s
    Add-Content $Logfile -value "$now $logstring"
    Write-Host $logstring
}
 
function CheckLocation {
    Param ([string]$location)
    if (!(Test-Path  $location)) {
        throw [System.IO.FileNotFoundException] "Could not download to Destination $location."
    }
}

function add-host([string]$ip, [string]$hostname) {
    $hostsPath = "$env:windir\System32\drivers\etc\hosts"
    $ip + "`t`t" + $hostname | Out-File -encoding ASCII -append $hostsPath
}
 
$Logfile = "C:\Windows\Temp\chrome-firefox-install.log"

$FF_VER="45.0.1";
$firefox_source = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FF_VER/win32/en-US/Firefox%20Setup%20$FF_VER.exe"
$firefox_destination = "C:\Windows\Temp\firefoxinstaller.exe"
 
LogWrite "Starting to download files $firefox_source"
try {
    LogWrite 'Downloading Firefox...'
    (New-Object System.Net.WebClient).DownloadFile($firefox_source, $firefox_destination)
    CheckLocation $firefox_destination
} catch [Exception] {
    LogWrite "Exception during download. Probable cause could be that the directory or the file didn't exist."
    LogWrite '$_.Exception is' $_.Exception
}
 
LogWrite 'Starting firefox install process.'
try {
    Start-Process -FilePath $firefox_destination -ArgumentList "-ms" -Wait -PassThru
} catch [Exception] {
    LogWrite 'Exception during install process.'
    LogWrite '$_.Exception is' $_.Exception
}

LogWrite 'Update hostfile'
add-host "192.168.90.52" "pws.app"

LogWrite 'All done. Goodbye.'
