# 05. Troubleshooting log

| Symptom | Cause | Fix |
|---|---|---|
| Launch failed: explicit deny on `volume/*` | Managed sandbox policy limiting disk size or type | Smaller volume (20 GB worked), try gp2 |
| Launch failed: explicit deny on `instance/*` | Sandbox limiting instance types | Try other types, or use a personal account |
| Server showed about 1 GB RAM | Micro instance type | Resize before installing; Wazuh recommends 8 GiB |
| Wazuh installer would not suit the OS | Ubuntu 26.04 is not in Wazuh's supported list | Use Ubuntu 24.04 LTS |
| Terminal stuck on `(END)` | Pager (`less`) after a long list | Press `q` |
| Dashboard `ERR_CONNECTION_TIMED_OUT` | Wrong address typed, no `https://`, or 443 rule not matching current IP | Copy the public IP from EC2, use `https://`, re-select My IP |
| Cannot remember dashboard password | Not saved | Read it from `wazuh-install-files.tar` (see `02`) |
| Agent log: `Unable to connect to enrollment service ...:1515` | Security-group source IP wrong or stale | Fix the 1514/1515 rules for the IP the agent uses |
| `sed: no input files` | File path missing from the command | Add `/var/ossec/etc/ossec.conf` at the end |
| Opened a config with no `<address>` line | It was the server's manager config, not the agent's | Edit the file on the agent machine |
| Windows agent "never connected" | Service not started, wrong address, or missing 1514 rule | `Get-Service WazuhSvc`, use the private IP, check both ports |
| Browser Connect (EC2 Instance Connect) fails with SSH open to My IP only | The browser connection comes from AWS ranges | SSH from your own machine with the key file |
| `swapoff: Invalid argument` | Swap file not active | Harmless; run `swapon -a` |
| Swap gone after restart | No `/etc/fstab` entry | Add the line (see `02`) |
| Dashboard rule save: `XML syntax error` | Rule placed outside any `<group>` | Move the closing `</group>` below the new rule |
| Rule saved but never fires | Wrong parent `if_sid`, or `data.` prefix in the field name | Check `rule.id` in a real alert; drop `data.` |
| No `5402` sudo event for agent-stop commands | Agent was stopping and could not forward the log line | Check the endpoint journal |

## Useful commands

```bash
# Test rule files and restart the manager (on the server)
sudo /var/ossec/bin/wazuh-analysisd -t
sudo systemctl restart wazuh-manager

# Service health
sudo systemctl status wazuh-indexer wazuh-manager wazuh-dashboard

# Agent logs (Linux agent)
sudo tail -f /var/ossec/logs/ossec.log

# Which hosts forward which events (Threat Hunting)
agent.name:"kali-lab" and rule.level >= 5
```
