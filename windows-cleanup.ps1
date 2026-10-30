# Remove the lab test accounts and reset the lockout policy.
# Deleting labadmin also fires custom rule 100101 (privileged account deleted).
# Errors saying the account does not exist are harmless.

foreach ($acct in @("labadmin", "labtest")) {
    net user $acct /delete 2>$null
}
net accounts /lockoutthreshold:0
Write-Host "Cleanup done."
