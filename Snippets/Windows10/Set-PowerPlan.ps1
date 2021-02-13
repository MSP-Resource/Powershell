# This will set the powerplan for Windows 10 to whatever matches $s
# This is great when pulling a custom field from your RMM and applying it to a host.
# MSPResource
#
$s = 'High Performance'
$p = Get-CimInstance -Name root\cimv2\power -Class win32_PowerPlan -Filter "ElementName = '$s'"
powercfg /setactive ([string]$p.InstanceID).Replace("Microsoft:PowerPlan\{","").Replace("}","")