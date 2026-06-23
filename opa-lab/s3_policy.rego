package aws.s3

import rego.v1

deny contains msg if {
  some bucket in input.resource.aws_s3_bucket
  not has_encryption(bucket)
  msg := sprintf("Bucket '%v' does not have encryption configured", [bucket.bucket])
}

has_encryption(bucket) if {
  bucket.server_side_encryption_configuration[_].rule[_].apply_server_side_encryption_by_default[_].sse_algorithm
}
