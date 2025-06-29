output "s3_bucket_name_output" {
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.raise_tech_storage.bucket
}

output "s3_bucket_arn_output" {
  description = "The ARN of the created S3 bucket"
  value       = aws_s3_bucket.raise_tech_storage.arn
}

output "s3_bucket_id_output" {
  description = "The ID of the created S3 bucket"
  value       = aws_s3_bucket.raise_tech_storage.id
}