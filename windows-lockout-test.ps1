# Generate failed-logon (4625) and lockout (4740) events on a LAB Windows machine.
# Run in an Administrator PowerShell on your own test instance only.
# A random one-time password is generated for the throwaway account, so nothing
# secret or reusable is stored in this file.

param(
    [string]$Account = "labtest",   # use "labadmin" to trigger custom rule 100100
    [int]$Threshold = 3
)

# 24 random characters, with a fixed suffix to satisfy Windows complexity rules
$chars = (48..57) + (65..90) + (97..122)
$TempPassword = (-join ($chars | Get-Random -Count 24 | ForEach-Object { [char]$_ })) + "!a1"

# Make sure lockout events are audited
auditpol /set /subcategory:"Account Lockout" /success:enable | Out-Null

net user $Account $TempPassword /add
net accounts /lockoutthreshold:$Threshold

Write-Host ""
Write-Host "Now run:  runas /user:$Account cmd"
Write-Host "Enter a WRONG password $($Threshold + 1) times."
Write-Host "Then search the Wazuh dashboard for rule.id:60115 (and 100100 if the account is labadmin)."
Write-Host "When done, run windows-cleanup.ps1"
