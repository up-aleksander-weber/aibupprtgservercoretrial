# Software install Script
#
# Applications to install:
#
# PRTG Installer with Trial KeyFoxit Reader Enterprise Packaging (requires registration)
# https://www.paessler.com/download/prtg-download?download=1
#

#region Set logging 
$logFile = "c:\temp\" + (get-date -format 'yyyyMMdd') + '_softwareinstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#endregion

#region PRTG Server Core
try {
    Start-Process -filepath 'c:\temp\prtg_installer_with_trial_key_000014-ZXPKFM-8FFUH3-D7XE5X-PZXXR3-W2RRE2-8V6U99-WM2Q98-WDBKYM-W6EN3J.exe' -Wait -ErrorAction Stop -ArgumentList '/VERYSILENT /LANG=English /Log:c:\temp\PRTG_install.log /licensekey=000014-ZXPKFM-8FFUH3-D7XE5X-PZXXR3-W2RRE2-8V6U99-WM2Q98-WDBKYM-W6EN3J /licensekeyname=prtgtrial /NoInitialAutoDisco=1 /adminemail=admin@mail.local'
    if (Test-Path "C:\Program Files (x86)\PRTG Network Monitor\PRTG Server.exe") {
        Write-Log "PRTG Server Core has been installed"
    }
    else {
        write-log "Error locating the PRTG installation"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error installing PRTG Server Core: $ErrorMessage"
}
#endregion

#region Sysprep Fix
# Fix for first login delays due to Windows Module Installer
try {
    ((Get-Content -path C:\DeprovisioningScript.ps1 -Raw) -replace 'Sysprep.exe /oobe /generalize /quiet /quit', 'Sysprep.exe /oobe /generalize /quit /mode:vm' ) | Set-Content -Path C:\DeprovisioningScript.ps1
    write-log "Sysprep Mode:VM fix applied"
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error updating script: $ErrorMessage"
}
#endregion

#region Time Zone Redirection
$Name = "fEnableTimeZoneRedirection"
$value = "1"
# Add Registry value
try {
    New-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services").PSObject.Properties.Name -contains $name) {
        Write-log "Added time zone redirection registry key"
    }
    else {
        write-log "Error locating the Teams registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding teams registry KEY: $ErrorMessage"
}
#endregion