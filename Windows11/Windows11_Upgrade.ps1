#
# Created by MSPResource (mspresource.com) 2021
#

# Variables
# name of working folder
$isoFolderName = 'Windows11Upgrade'
# Name of temp folder
$isoFolder = $Env:Temp + '\' + $isoFolderName
# Name of the iso
$isoName = 'Win11_English_x64.iso'
# Path used in script
$isoPath = $isoFolder + '\' + $isoName
# ISO URL
$isoURL = 'https://www.dropbox.com/s/zft4tmsc6200c7e/Win11_English_x64.iso?raw=1'
# Ready Script URL 
$hardwareCheckURL = 'https://aka.ms/HWReadinessScript'
# Hash from windows download page
$isoTargetHash = '667BD113A4DEB717BC49251E7BDC9F09C2DB4577481DDFBCE376436BEB9D1D2F'
# Hash for the Windows 11 hardware check
$hardwareTargetHash = 'B6F11CDCA5AC52DC054F8C20FF89776B922CC1C7EA9AA5A9ACEB0CD64812F393'
# Hardware check script path
$hardwareCheckPath = $isoFolder + '\Windows11HWReadiness.ps1'
# Targeted OS Version
$targetOS = 'Windows 10'
# Argument List
$argList = '/auto upgrade /quiet /eula accept /copylogs ' + $isoFolder


# Check if directory exists
if (!(Test-Path -Path $isoFolder)) {
    # Create folder
    New-Item -ItemType directory $isoFolder
}
# Set directory
Set-Location -Path $isoFolder

# Check if Windows 10
$currentOS = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
If ($currentOS.Contains($targetOS)){
    
    # Check Hardware
    If (!(Test-Path -Path $hardwareCheckPath)) {
        # Download File
        #Start-BitsTransfer -Source $hardwareCheckURL -Destination $isoFolder + $hardwareCheckPath | Complete-BitsTransfer
        Invoke-WebRequest -Uri $hardwareCheckURL -OutFile $isoFolder + $hardwareCheckPath
    }
    $HardwareCheckHash = (Get-FileHash $hardwareCheckPath).Hash

    if ($hardwareTargetHash -eq $HardwareCheckHash) {
        $win11Check = & $hardwareCheckPath | ConvertTo-Json
    } 
    else {
            Remove-Item $hardwareCheckPath
            return 'Invalid hardware check hash'
        }
    # If Admin is required
    If ($win11Check.Contains('UNDETERMINED')){
        return 'UNDETERMINED'
    } 
    # If Passes
    elseif ($win11Check.Contains('CAPABLE')){
        If (!(Test-Path -Path $isoPath)) {
            # Download File
            #Start-BitsTransfer -Source $isoURL -Destination $isoPath | Complete-BitsTransfer
            Invoke-WebRequest -Uri $isoURL -OutFile $isoPath
        }
        # Set Hash Command
        $isoHash = (Get-FileHash $isoPath).Hash
        # Compare hashes
        if ($isoTargetHash -eq $isoHash) {
            # if hashes match
            $isoMount = Mount-DiskImage $isoPath -PassThru
            $win11Setup = ($isoMount| Get-Volume).DriveLetter + ':\setup.exe'
            Start-Process -FilePath $win11Setup -ArgumentList $argList
        } 
        # Catch all invlaid hash
        else {
            Remove-Item $isoPath
            return 'Invalid Windows 11 iso hash'
        }
    }
    # Catch all fail
    else {
        return 'NOT CAPABLE'
    }
}


#############################################

# Party