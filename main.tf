provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "blog_sg" {
  name        = "blog-app-sg"
  ingress { from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  ingress { from_port = 80; to_port = 80; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"] }
  egress  { from_port = 0;  to_port = 0;  protocol = "-1";  cidr_blocks = ["0.0.0.0/0"] }
}

resource "aws_instance" "blog_server" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.blog_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              dnf install -y docker
              systemctl start docker
              docker run -d -p 80:80 devopslearner07/terraform-frontend-project:latest
              EOF
}

output "website_url" { value = "http://${aws_instance.blog_server.public_ip}" }