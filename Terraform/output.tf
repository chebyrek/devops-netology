output "account_id" {
  value = data.aws_caller_identity.identity.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.identity.user_id
}

output "aws_region" {
  value = data.aws_region.region.name
}

output "aws_network_interface" {
  value = data.aws_network_interface.test.private_ips
}

output "aws_subnet" {
  value = data.aws_subnet.test.id
}



