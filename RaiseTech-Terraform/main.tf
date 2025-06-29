module "compute" {
  source = "./compute"
  cidr_ip = var.cidr_ip
}

module "storage" {
  source = "./storage"
  s3_bucket_name = var.s3_bucket_name
}