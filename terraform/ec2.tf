
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "ec2_kops" {

  depends_on = [
    aws_internet_gateway.igw
  ]

  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  key_name                    = var.key_pair
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id
  vpc_security_group_ids      = [aws_security_group.sg_kops.id]

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl --static set-hostname kops-ec2

              # Change Timezone
              ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

              # Install Packages
              cd /root
              yum -y install tree jq git htop
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install
              export PATH=/usr/local/bin:$PATH
              source ~/.bash_profile
              complete -C '/usr/local/bin/aws_completer' aws
              ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
              echo 'alias vi=vim' >> /etc/profile
              curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
              wget https://github.com/andreazorzetto/yh/releases/download/v0.4.0/yh-linux-amd64.zip
              unzip yh-linux-amd64.zip
              mv yh /usr/local/bin/
              EOF

  user_data_replace_on_change = true

  tags = {
    Name = "ec2_kops_${var.study_name}"
  }
}
