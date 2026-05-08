provider "aws" {
  region = "us-east-1"
}

# 1. Security Group: Fixed syntax (removed semicolons)
resource "aws_security_group" "blog_sg" {
  name        = "blog-app-sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Server: Launch EC2 and Automate Deployment
resource "aws_instance" "blog_server" {
  ami                    = "ami-0440d3b780d96b29d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.blog_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update and Install Docker
              dnf update -y
              dnf install -y docker
              
              # Start and Enable Docker service
              systemctl start docker
              systemctl enable docker
              
              # Add default user to docker group
              usermod -aG docker ec2-user
              
              # Run the container from Docker Hub
              docker run -d -p 80:80 devopslearner07/terraform-frontend-project:latest
              EOF

  tags = {
    Name = "Live-Blog-Server"
  }
}

# 3. Output: Final website URL
output "website_url" {
  value = "http://${aws_instance.blog_server.public_ip}"
}