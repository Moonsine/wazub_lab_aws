# 03. Enrolling agents

## Linux agent (Kali VM)

1. Dashboard: **Agents > Deploy new agent**, choose **Linux > DEB amd64**, enter the server's public IP and a name (for example `kali-lab`).
2. Copy the generated commands and run them on Kali, including the `systemctl daemon-reload`, `enable` and `start` commands.
3. Port 1514 and 1515 on the server's security group must allow the public IP that Kali goes out through. Check it on Kali with `curl -s ifconfig.me; echo`.

Verify:

```bash
sudo systemctl status wazuh-agent
sudo tail -20 /var/ossec/logs/ossec.log
nc -zv -w 5 <SERVER_PUBLIC_IP> 1515
```

A timeout on port 1515 almost always means a security-group rule with the wrong source IP.

### After the server's public IP changes

The Kali agent keeps the old address. Update it with `scripts/update-agent-address.sh <NEW_IP>` or by hand:

```bash
sudo sed -i 's#<address>.*</address>#<address><NEW_IP></address>#' /var/ossec/etc/ossec.conf
sudo grep -n "<address>" /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-agent
```

Common mistake: `sed` needs the file path as its last argument. Without it you get `sed: no input files`.

Another mistake: the file named "Wazuh - Manager - Default configuration" is the **server's** config. The agent's file is on the agent machine and contains `<client><server><address>`.

## Windows agent (EC2)

1. Dashboard: **Agents > Deploy new agent**, choose **Windows**, and set the server address to the server's **private IP** (`<SERVER_PRIVATE_IP>`).
2. Run the generated command in an **Administrator PowerShell**, then `NET START WazuhSvc`.
3. A brief "never connected" status right after install is normal. If it stays that way:

```powershell
Get-Service WazuhSvc
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 30
Test-NetConnection <SERVER_PRIVATE_IP> -Port 1514
```

The private IP does not change on stop/start, so this agent reconnects on its own.

## Agent states

| State | Meaning |
|---|---|
| Active | Reporting |
| Disconnected | No keep-alive for `agents_disconnection_time` (15m by default) |
| Never connected | Registered, but has not checked in yet |
