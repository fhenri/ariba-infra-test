function LogWrite {
   Param ([string]$logstring)
   $now = Get-Date -format s
   Add-Content $Logfile -value "$now $logstring"
   Write-Host $logstring
}
 
$Logfile = "C:\Windows\Temp\jdk-install.log"
 
$JDK_VER="8u77"
$JDK_FULL_VER="8u77-b03"
$JDK_PATH="1.8.0_77"

$source86 = "http://download.oracle.com/otn-pub/java/jdk/$JDK_FULL_VER/jdk-$JDK_VER-windows-i586.exe"
$source64 = "http://download.oracle.com/otn-pub/java/jdk/$JDK_FULL_VER/jdk-$JDK_VER-windows-x64.exe"

$destination86 = "C:\Windows\Temp\$JDK_VER-x86.exe"
$destination64 = "C:\Windows\Temp\$JDK_VER-x64.exe"

$client = new-object System.Net.WebClient
$cookie = "oraclelicense=accept-securebackup-cookie"
$client.Headers.Add([System.Net.HttpRequestHeader]::Cookie, $cookie)
 
LogWrite "Setting Execution Policy level to Bypass"
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
 
LogWrite 'Checking if Java is already installed'
if ((Test-Path "c:\Program Files (x86)\Java") -Or (Test-Path "c:\Program Files\Java")) {
    LogWrite 'No need to Install Java'
    Exit
}
 
LogWrite "Downloading x86 to $destination86"
try {
  $client.downloadFile($source86, $destination86)
  if (!(Test-Path $destination86)) {
      LogWrite "Downloading $destination86 failed"
      Exit
  }
  LogWrite "Downloading x64 to $destination64"
 
  $client.downloadFile($source64, $destination64)
  if (!(Test-Path $destination64)) {
      LogWrite "Downloading $destination64 failed"
      Exit
  }
} catch [Exception] {
  LogWrite '$_.Exception is' $_.Exception
}
 
try {
    LogWrite 'Installing JDK-x64'
    $proc1 = Start-Process -FilePath "$destination64" -ArgumentList "/s REBOOT=ReallySuppress" -Wait -PassThru
    $proc1.waitForExit()
    LogWrite 'Installation Done.'
 
    LogWrite 'Installing JDK-x86'
    $proc2 = Start-Process -FilePath "$destination86" -ArgumentList "/s REBOOT=ReallySuppress" -Wait -PassThru
    $proc2.waitForExit()
    LogWrite 'Installtion Done.'
} catch [exception] {
    LogWrite '$_ is' $_
    LogWrite '$_.GetType().FullName is' $_.GetType().FullName
    LogWrite '$_.Exception is' $_.Exception
    LogWrite '$_.Exception.GetType().FullName is' $_.Exception.GetType().FullName
    LogWrite '$_.Exception.Message is' $_.Exception.Message
}
 
if ((Test-Path "c:\Program Files (x86)\Java") -Or (Test-Path "c:\Program Files\Java")) {
    LogWrite 'Java installed successfully.'
} else {
    LogWrite 'Java install Failed!'
}
LogWrite 'Setting up Path variables.'
[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "c:\Program Files (x86)\Java\jdk$JDK_PATH", "Machine")
[System.Environment]::SetEnvironmentVariable("PATH", $Env:Path + ";c:\Program Files (x86)\Java\jdk$JDK_PATH\bin", "Machine")
LogWrite 'Done. Goodbye.'
