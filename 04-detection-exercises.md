# 04. Detection exercises

All exercises run against your own lab machines. Search in **Threat Hunting > Events** using DQL.

## Exercise 1: failed logon and account lockout (Windows)

Run `scripts/windows-lockout-test.ps1`, then `runas /user:labtest cmd` and enter a wrong password 3 to 4 times.

| Search | Expected |
|---|---|
| `agent.name:"wazuh-lab" and rule.id:60122` | Logon failure, level 5 |
| `agent.name:"wazuh-lab" and rule.id:60115` | User account locked out, level 9 |
| `data.win.system.eventID:4740` | The raw lockout event |

If no 4740 appears: `auditpol /get /subcategory:"Account Lockout"` and enable success auditing.

### Reading the 4740 event

- **Subject block**: the account that *recorded* the event. Here it is the machine account (name ends in `$`, SID `S-1-5-18`, Local System). It is not the locked-out user.
- **Account That Was Locked Out**: the affected user (`data.win.eventdata.targetUserName`).
- **Caller Computer Name**: where the failed attempts came from. In a domain this points at the workstation or server with a stale password or a spraying source.
- The same user name recreated later gets a **new SID**, so match on SID when you must be sure it is the same identity.

## Exercise 2: custom rule for privileged lockouts (100100)

`rules/local_rules.xml` extends the built-in lockout rule and raises severity to 12 for `administrator` and `labadmin`.

- Positive test: lock out `labadmin`. `rule.id:100100` fires alongside 60115.
- Negative test: lock out `labtest`. Only 60115 fires.

Lessons:

- Dashboard field `data.win.eventdata.targetUserName` is written `win.eventdata.targetUserName` in rule files. Adding `data.` makes the rule load but never match.
- Confirm the parent rule ID in your own alert (`rule.id`) before using it in `if_sid`.

## Exercise 3: privileged account deletion (100101)

```powershell
net user labadmin "<RANDOM_THROWAWAY_PASSWORD>" /add
net user labadmin /delete
```

- Positive: `rule.id:100101` fires (level 12) next to the built-in 60111.
- Negative: do the same with `labtest`. Only 60111 fires.
- The `win.system.eventID` = `^4726$` filter is needed because parent 60111 also covers account *disables* (4725).
- Placement matters: a rule after a closing `</group>` fails with `Could not upload rule (1113) - XML syntax error`.

Reading event 4726: the `Privileges -` line means no special privilege was recorded for the action. The Subject block names who performed the deletion.

## Exercise 4: agent stopped (rule 506)

On the Linux agent: `sudo systemctl stop wazuh-agent`.

- Rule `506` ("Wazuh agent stopped", level 3) arrives immediately. It maps to MITRE T1562.001 (Impair Defenses: Disable or Modify Tools).
- The alert contains **no user name**. It is the agent's own goodbye message.
- If the agent is killed abruptly it sends nothing, and the manager only notices after `agents_disconnection_time` (15m).

### Who stopped it?

The SIEM did not have the answer, because the sudo log line was written while the agent was shutting down. The endpoint's journal did:

```bash
sudo journalctl _COMM=sudo --since "2 days ago" | grep wazuh-agent
```

```
kali : TTY=pts/0 ; PWD=/home/kali ; USER=root ; COMMAND=/usr/bin/systemctl stop wazuh-agent
```

- The name before the colon is the person. `USER=root` is the identity the command ran *as*.
- In the Wazuh event for `sudo ... session closed`, `data.dstuser: root` is also the identity it ran as, not the person.
- A search for rule `5402` found nothing for these commands, so a detection built on it (a possible rule 100103) would have missed them. It was **not** added to the rules file.
- Timestamps differ by the time-zone offset between the endpoint journal (local time) and Wazuh (UTC). Normalize before correlating.

Takeaways: go to the endpoint when the SIEM record is incomplete, and forward logs off-host (or use auditd) so tampering does not erase evidence.

Rule `100102` (alert at level 12 when the Windows agent stops) is written but commented out in `local_rules.xml` until it has been tested.

## Exercise 5: noise triage (dpkg alerts 2902/2904)

After a restart the server raised bursts of "New dpkg package installed" and "half configured" alerts (level 7). Checking `/var/log/apt/history.log` showed:

- `Commandline: /usr/bin/unattended-upgrade` on every entry
- Timing matching the first boot after a week off
- Only ordinary Ubuntu packages (libraries, systemd, openssh, curl), no `wazuh-*` packages

Conclusion: benign automatic security updates. The same three questions apply in any investigation: who ran it, when, and what changed. A rule with a lower level for known patch windows is the tuning option.
