# Wazuh SIEM Lab on AWS

A hands-on lab for practicing SOC and detection-engineering skills on a free-tier budget. It was built to practice the same workflow as an enterprise next-gen SIEM (search, rules, triage, ingest health) without needing a commercial tenant.

## What this lab covers

- A Wazuh all-in-one server (manager, indexer, dashboard) on an AWS EC2 instance
- Two agents: a Kali Linux VM and a Windows Server instance in AWS
- Real failed-logon, account-lockout and account-deletion events from Windows
- Two custom detection rules, each tested with a positive and a negative case
- Investigation practice: tracing who stopped an agent, reading a lockout event, triaging update noise
- A mapping from each Wazuh skill to its enterprise-SIEM equivalent

## Architecture

```
 Kali VM (home network)  --1514/1515-->  Wazuh server (EC2, Ubuntu 24.04)  <--1514/1515--  Windows Server (EC2)
                                              |                                        (same VPC, private IP)
                                      HTTPS 443 dashboard
                                      (your IP only)
```

## Repository layout

| Path | Contents |
|---|---|
| `docs/01-aws-setup.md` | Account, budget, EC2 launch settings, security groups |
| `docs/02-wazuh-install.md` | Server preparation and install |
| `docs/03-agents.md` | Enrolling the Kali and Windows agents |
| `docs/04-detection-exercises.md` | The lockout, deletion and agent-stop exercises |
| `docs/05-troubleshooting.md` | Problems hit during the build and their fixes |
| `docs/06-siem-skill-mapping.md` | Wazuh vs. enterprise SIEM concepts |
| `docs/07-lessons-learned.md` | Takeaways |
| `rules/local_rules.xml` | Custom rules 100100 and 100101 (tested), 100102 (untested) |
| `scripts/` | Helper scripts for agent IP updates and test accounts |

## Status of each part

| Item | Status |
|---|---|
| Server install, both agents reporting | Done |
| Rule `100100` privileged account locked out | Tested (positive and negative) |
| Rule `100101` privileged account deleted | Tested (positive and negative) |
| Rule `100102` critical agent stopped | **Written, not yet tested** |
| Rule `100103` sudo stop command | **Not recommended**, see `docs/04` |

## Cost and safety

- Everything runs on the AWS Free plan credits. Stop both instances when not practicing.
- Never open the dashboard, SSH or RDP to `0.0.0.0/0`. Use "My IP" rules.
- Never commit passwords, key files (`*.pem`), public IPs or account IDs. See `.gitignore`.
- Only run the brute-force or lockout tests against your own lab machines.

## Placeholders used in these docs

Real addresses and credentials are deliberately left out. Replace these when following along:

| Placeholder | Meaning |
|---|---|
| `<SERVER_PUBLIC_IP>` | The Wazuh server's public IPv4 (changes on every stop/start) |
| `<SERVER_PRIVATE_IP>` | The Wazuh server's private `172.31.x.x` address (stable) |
| `<MY_IP>` | The public IP you connect from |
| `<KEY_FILE>.pem` | Your EC2 key pair file (keep it private) |

## License

MIT. See `LICENSE`.
