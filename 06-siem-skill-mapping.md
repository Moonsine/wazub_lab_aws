# 06. Mapping these skills to an enterprise SIEM

The lab was built to practice the workflow used in an enterprise next-gen SIEM (for example CrowdStrike Falcon Next-Gen SIEM). The query language and UI differ, but the analyst skills transfer.

| What was done in Wazuh | Enterprise SIEM equivalent |
|---|---|
| Threat Hunting > Events with DQL filters | Advanced event search (CQL, SPL or KQL equivalents) |
| `agent.name`, `rule.level`, `rule.description`, `rule.id` | Host name, severity, detection name, rule ID |
| Agents page: Active / Disconnected / Never connected | Data settings, "time of latest ingest" per source |
| Rules `100100` and `100101` with positive and negative tests | Correlation rules with a severity bump |
| Parent rule `if_sid` plus field filters | A base search narrowed by a `where` or field filter |
| Reading 4740 and 4726 events | Identity and account-change triage |
| Tracing an agent stop through the endpoint's own journal | Investigation pivot when the SIEM record is incomplete |
| Judging dpkg alerts as benign | Triage and tuning of noisy detections |
| MITRE field on alerts (for example T1562.001) | Detection coverage mapped to MITRE ATT&CK |

## Query shape comparison

| Task | Wazuh DQL | CrowdStrike CQL (illustrative) | Splunk SPL (illustrative) |
|---|---|---|---|
| Filter | `rule.id:60115` | `rule.id=60115` | `rule.id=60115` |
| Count by field | (use the dashboard visualizations) | `groupBy([field], function=count())` | `stats count by field` |
| Select columns | choose columns in the table | `table([a,b])` | `table a b` |

The CQL and SPL cells are examples of the same ideas and are not copied from a tested environment. Verify the syntax in your own tenant.

## Not covered by this lab

- The enterprise product's own query language and console
- Its prebuilt detection library
- Automation (for example SOAR workflows) and AI-assisted investigation features
- Data connectors and parsers for third-party sources

Use a vendor trial for those, and arrive with prepared queries and scenarios so the trial time goes on the product itself.
