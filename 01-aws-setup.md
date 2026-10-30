# 01. AWS setup

## Account

- A new account created after July 2025 gets the **Free plan**: about $100 in credits, up to $100 more for onboarding tasks, valid up to 6 months or until credits run out.
- Joining an AWS Organization ends the free credits immediately, so keep this account standalone.
- Enable **MFA on the root user** straight away.
- A separate IAM admin user is recommended but optional for a personal practice account. In this lab the console's IAM flow only offered programmatic users, so root with MFA was used. Never create access keys for root.

## Budget alert

1. Open **AWS Budgets** and create a **monthly cost budget** (for example $20) with an alert at 80% to your email.
2. If the advanced options allow it, exclude credits from the cost type, otherwise the budget stays at $0 while credits absorb the spend.
3. Check **Billing > Credits** every few days. It is the only place that shows the remaining balance directly.

## Region and network

- Stay in one region for everything.
- Use the **default VPC**. It already has an internet gateway and public subnets.
- Avoid NAT gateways. They bill hourly and drain credits quickly.

## Wazuh server instance

| Setting | Value |
|---|---|
| Image | Ubuntu Server **24.04 LTS** (Wazuh did not support 26.04 at the time) |
| Instance type | `m7i-flex.large` (Free plan eligible, 2 vCPU, about 8 GiB RAM) |
| Storage | 50 GB gp3 |
| Public IP | Auto-assign enabled |

Wazuh's quickstart table recommends 4 vCPU, 8 GiB RAM and 50 GB for 1 to 25 agents. This instance meets the RAM and disk guidance and has half the CPU, which is fine for a lab with two agents.

## Windows endpoint instance

| Setting | Value |
|---|---|
| Image | Windows Server 2022 Base |
| Instance type | Free-plan-eligible size with at least 2 GB RAM (for example `t3.small`) |
| Storage | 30 GB |
| Security group | RDP 3389 from **My IP** only |

Decrypt the Administrator password in the console (**Connect > RDP client > Get password**) using the `.pem` file. The key file stays on your machine.

## Security group rules (Wazuh server)

| Port | Source | Purpose |
|---|---|---|
| 22 | My IP | SSH |
| 443 | My IP | Dashboard |
| 1514 and 1515 | Windows instance's security group | Windows agent (private IP) |
| 1514 and 1515 | My IP | Kali agent connecting from home |

Notes:

- The Windows agent makes outbound connections, so the 1514/1515 rules belong on the **server's** group, not the Windows group.
- A security-group source only matches private addresses, so the Windows agent must use the server's **private IP**.
- Home IPs change. Re-select "My IP" on every rule after a restart if a connection times out.
- One mistyped IP in a rule was enough to cause "unable to connect to enrollment service" on port 1515.

## Sandbox limits seen along the way

A managed lab sandbox denied instance and volume launches through an organization-level policy. Reading the denied resource in the error (`volume/*` vs `instance/*`) told us whether the disk size or the instance type was blocked. A personal account avoids this.
