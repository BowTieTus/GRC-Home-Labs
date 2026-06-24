# GRC Home Lab

A hands-on GRC engineering lab built on AWS demonstrating how security controls are implemented and enforced in code — not just documented in policy.

## What This Lab Covers

Most GRC work gets reduced to writing policies and filling out checklists. This lab focuses on the engineering side: turning compliance requirements into automated, enforceable controls.

## Tools Used

| Tool | Purpose |
|---|---|
| Terraform | Infrastructure as code — deploys AWS resources |
| Checkov | Static IaC scanning — catches misconfigs before deploy |
| Prowler | Continuous compliance monitoring against CIS/SOC 2 |
| OPA (Rego) | Policy as code — enforces controls programmatically |
| Trivy | Container image scanning for CVEs |
| AWS CLI | Connects local tooling to AWS account |

## Lab Structure

```
grc-lab/
├── s3-lab/          # Terraform IaC + Checkov scan results
│   ├── main.tf      # Compliant S3 bucket with encryption, versioning, public access block
│   ├── outputs.tf
│   └── output/      # Prowler compliance reports
└── opa-lab/         # OPA policy as code
    ├── s3_policy.rego       # Rego policy enforcing encryption requirement
    ├── input.json           # Test input — non-compliant bucket (should fail)
    └── input_compliant.json # Test input — compliant bucket (should pass)
```

## What I Built

### 1. IaC Scanning with Checkov
Wrote a Terraform S3 bucket with intentional misconfigurations (no encryption, no versioning, public access enabled), then scanned it with Checkov to surface violations mapped to CIS and SOC 2 controls before anything was deployed.

**Controls demonstrated:** CKV_AWS_21 (versioning), CKV_AWS_145 (encryption at rest), CKV_AWS_53-56 (public access block)

### 2. Compliant Infrastructure Deployment
Fixed all Checkov findings and deployed a compliant S3 bucket to AWS with:
- AES256 server-side encryption
- Versioning enabled
- All public access blocked

### 3. Continuous Compliance Monitoring with Prowler
Ran Prowler against the full AWS account to generate a compliance posture report against CIS AWS Foundations, SOC 2, and other frameworks. Identified real findings across IAM, logging, and monitoring controls.

### 4. Policy as Code with OPA
Wrote a Rego policy that encodes the encryption requirement as an executable rule. Tested against both a non-compliant input (returns violation message) and a compliant input (returns empty — clean pass).

**Maps to:** SOC 2 CC6.1, CIS AWS 2.1.1

### 5. Container Scanning with Trivy
Scanned Python container images for known CVEs using Trivy. Used `--exit-code 1` flag to simulate a CI/CD pipeline gate that blocks deployment on HIGH or CRITICAL findings.

## Key Takeaway

Each tool in this lab represents a different control type:
- **Checkov** — preventive control (stops bad config before deploy)
- **Prowler** — detective control (finds drift in live environment)
- **OPA** — preventive control (policy enforcement as code)
- **Trivy** — preventive control (blocks vulnerable containers)

## Frameworks Referenced
- CIS AWS Foundations Benchmark
- SOC 2 (CC6.1, CC7.1)
- NIST CSF

## Next Labs
- CloudTrail + CloudWatch alerting (detective controls, audit logging)
- AWS SCPs (preventive controls at org level)
- Kubernetes + OPA Gatekeeper (policy enforcement in containers)
