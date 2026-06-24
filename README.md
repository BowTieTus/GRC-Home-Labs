GRC Home Lab

I built this because I kept running into the same problem in GRC — everything is policies, documentation, and checklists. I wanted to understand how controls actually get enforced in a real system, so I built a small lab to figure that out.

This is that lab.


What I did

Started with a fresh AWS account and a MacBook. No prior cloud experience going into this.

Deployed intentionally broken infrastructure using Terraform — an S3 bucket with no encryption, no versioning, and public access wide open. Then scanned it with Checkov before deploying anything. Checkov mapped each finding directly to a CIS or SOC 2 control, which was the first time things started clicking for me — the gap between "encryption is required per policy" and "here is the exact line of code that violates it."

Fixed everything and deployed the compliant version to AWS. Encryption, versioning, public access blocked. Ran Prowler against the whole account afterward and got a full compliance report against CIS, SOC 2, and a few other frameworks. A fresh account fails a lot of checks — that's expected, and it's good practice material.

Wrote a policy in OPA that enforces the encryption requirement as actual code. Tested it against a non-compliant bucket (it caught the violation) and a compliant one (clean pass). The idea is that a policy doc says "encryption is required" and this makes that sentence executable.

Scanned container images with Trivy and used the exit code flag to simulate a pipeline gate — if HIGH or CRITICAL CVEs are present, the scan exits with code 1, which is how you'd block a deployment in CI/CD.


Tools

ToolWhat it doesTerraformWrites and deploys infrastructure as codeCheckovScans IaC for misconfigs before anything is deployedProwlerRuns compliance checks against a live AWS accountOPA + RegoTurns policy requirements into executable rulesTrivyScans container images for known CVEsAWS CLIConnects local tooling to a real AWS environment


Structure

grc-lab/
├── s3-lab/
│   ├── main.tf                # S3 bucket with all controls applied
│   ├── outputs.tf
│   └── output/                # Prowler compliance reports
└── opa-lab/
    ├── s3_policy.rego          # Encryption enforcement policy
    ├── input.json              # Non-compliant test input (fails)
    └── input_compliant.json    # Compliant test input (passes)


Control types demonstrated


Preventive — Checkov stops misconfigured infrastructure before it deploys. OPA blocks policy violations before they reach production. Trivy gates container deployments on CVE severity.
Detective — Prowler continuously checks the live AWS environment against CIS and SOC 2 and surfaces drift from the expected baseline.



Frameworks referenced


CIS AWS Foundations Benchmark
SOC 2 (CC6.1, CC7.1)
NIST CSF
