module "compute" {
  source = "./compute"
  cidr_ip = var.cidr_ip
}

module "database" {
  source = "./database"
}

module "service" {
  source = "./service"
}

module "storage" {
  source = "./storage"
  s3_bucket_name = var.s3_bucket_name
}