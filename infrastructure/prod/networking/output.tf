# Print public_subnet_ids
output "public_subnet_ids" {
  value = module.vpc-prod.public_subnet_ids
}

# Print private_subnet_ids
output "private_subnet_ids" {
  value = module.vpc-prod.private_subnet_ids
}

# Print vpc_id
output "vpc_id" {
  value = module.vpc-prod.vpc_id
}