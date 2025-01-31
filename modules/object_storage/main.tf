/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "aws_s3_bucket" "vault_license_bucket" {
  bucket_prefix = "${var.resource_name_prefix}-vault-license"

  force_destroy = true

  tags = var.common_tags
}

resource "aws_s3_bucket_ownership_controls" "vault_license_bucket_own_ctrl" {
  bucket = aws_s3_bucket.vault_license_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "vault_license_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.vault_license_bucket_own_ctrl]

  bucket = aws_s3_bucket.vault_license_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "vault_license_bucket_versioning" {
  bucket = aws_s3_bucket.vault_license_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vault_license_bucket_enc_config" {
  bucket = aws_s3_bucket.vault_license_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vault_license_bucket" {
  bucket = aws_s3_bucket.vault_license_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_object" "vault_license" {
  bucket = aws_s3_bucket.vault_license_bucket.id
  key    = var.vault_license_name
  content = var.vault_license_content

  tags = var.common_tags
}
