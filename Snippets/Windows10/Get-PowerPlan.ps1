# This will use $s to search and display only the powerplans on Windows 10 that fit that status can be True or False, Active or InActive
# This will output only the name of that powerplan great for sending to a custom field in your RMM
# MSPResource
#
$s = 'True'
Get-WmiObject -Namespace root\cimv2\power -Class win32_PowerPlan | Select-Object -Property ElementName, IsActive | Where-Object {$_.IsActive -eq "$s"} | ForEach-Object {$_.ElementName}