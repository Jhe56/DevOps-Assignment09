output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_public_dns" {
  value = aws_instance.bastion.public_dns
}

output "private_instance_private_ips" {
  value = aws_instance.private_nodes[*].private_ip
}

output "private_instance_ids" {
  value = aws_instance.private_nodes[*].id
}

output "observer_id" {
	value = aws_instance.observer.id
}

output "observer_ip"{
	value = aws_instance.observer.private_ip
}
