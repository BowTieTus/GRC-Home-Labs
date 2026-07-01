# GRC Home Lab

I built this because I wanted to understand the engineering side of GRC — not just writing policies, but actually implementing and enforcing controls in a real system.

Everything here is built on AWS using real tools. Each lab covers a different part of the GRC engineering stack.

---

## Labs

### [Lab 1 — S3 Security Controls](./s3-lab/)
Deployed intentionally misconfigured S3 infrastructure, scanned it with Checkov to surface CIS and SOC 2 violations, fixed everything, deployed compliant, then ran Prowler against the whole account for a live compliance score. Also wrote an OPA policy that enforces encryption as executable code.

**Tools:** Terraform, Checkov, Prowler, OPA

**Controls:** CIS AWS 2.1.1, SOC 2 CC6.1, CIS AWS Foundations Benchmark

---

### [Lab 2 — CloudTrail + Alerting](./cloudtrail-lab/)
Enabled CloudTrail across the AWS account and wired it into CloudWatch to trigger real-time email alerts on security events — root account logins, IAM policy changes, and unauthorized API calls.

**Tools:** Terraform, CloudTrail, CloudWatch, SNS

**Controls:** CIS AWS 1.7, 3.1, 3.4

---

## Frameworks Referenced
- CIS AWS Foundations Benchmark
- SOC 2 (CC6.1, CC7.1)
- NIST CSF

## Up Next
- IAM least privilege enforcement
- GitHub Actions CI/CD pipeline
- AWS SCPs
