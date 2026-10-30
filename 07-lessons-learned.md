# 07. Lessons learned

## Technical

1. **Read the denied resource in an AWS error.** `volume/*` and `instance/*` point to different limits.
2. **Match the platform to the requirements table.** Wazuh's quickstart guidance (4 vCPU, 8 GiB, 50 GB) decided the instance, and it turned out a 4 GiB machine was too small to plan around.
3. **Security groups are the control.** Source-by-group rules only match private addresses, so agents in the same VPC must use the server's private IP.
4. **A single wrong character in an allow-list rule looks like a service outage.** A timeout, not a refusal, usually means a network filter.
5. **Rule files and the dashboard name fields differently.** Rules use `win.eventdata.x`; the dashboard shows `data.win.eventdata.x`.
6. **Test every rule twice.** A positive test proves it fires. A negative test proves it does not fire on everyone.
7. **Subject is not the user.** In Windows security events, the Subject is often the system recording the action. The affected account is in the target fields.
8. **`root` in a sudo event is the identity the command ran as.** The person is in the `COMMAND` log line.
9. **The SIEM can miss the event that matters.** A stop command can be written while the agent is shutting down. Keep the endpoint's own logs as a second source.
10. **Normalize time zones before correlating.** Local-time journals and UTC alerts differ by hours.
11. **Noisy does not mean malicious.** Check who ran it, when, and what changed before escalating.

## Operational

- Stop instances when not practicing, and watch the credit balance, not only the budget alert.
- Public IPs change on every stop/start. Keep the checklist in `02-wazuh-install.md`.
- Save credentials to a password manager at install time. Do not paste them into chats or screenshots.
- Redact screenshots before sharing them (passwords, IPs, account IDs).

## Next steps

- Test rule `100102` (agent stop on the Windows host).
- Add an ingest-health check for sources that go silent.
- Run a brute-force test from the Kali VM against the Windows instance, on your own lab only.
- Add Sysmon or process-creation auditing on Windows so the user behind a service stop is recorded.
- Compare the same detections in a vendor SIEM trial.
