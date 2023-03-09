output "EC2_KOPS_Public_IP" {
  value = aws_instance.ec2_kops.public_ip
}
