resource "aws_iam_role" "codedeploy_role" {
  name = "ec2_codedeploy_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}




resource "aws_iam_role_policy_attachment" "codedeploy_attach" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}


resource "aws_iam_instance_profile" "codedeploy_profile" {
  name = "ec2_codedeploy_instance_profile"
  role = aws_iam_role.codedeploy_role.name
}




resource "aws_instance" "flask_ec2" {
  ami                    = "ami-0eb9d6fc9fab44d24" # Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2_key.key_name
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  #security_groups        = [aws_security_group.ec2_sg.name]
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.codedeploy_profile.name

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.ec2_key.private_key_pem
    host        = self.public_ip
  }




 
  provisioner "remote-exec" {
    inline = [
      "echo Instalando pacotes...",
      "sudo yum update -y",
      "sudo yum install -y python3-pip",
      "sudo pip3 install flask",
      "sudo yum install -y python3",
      "sudo python3 -m ensurepip --upgrade",
      "sudo mkdir -p /opt/flaskapp",
      "sudo chown ec2-user:ec2-user /opt/flaskapp",
      "sudo chmod 777 /opt/flaskapp"
  ]
 }
   provisioner "file" {
     source      = "startup.sh"
     destination = "/opt/flaskapp/startup.sh"
}

  provisioner "file" {
    source      = "stop_app.sh"
    destination = "/opt/flaskapp/stop_app.sh"
}
  provisioner "file" {
    source      = "app/app.py"
    destination = "/opt/flaskapp/app.py"
  }

   provisioner "remote-exec" {
     inline = [
       "chmod +x /opt/flaskapp/startup.sh",
       "sudo /opt/flaskapp/startup.sh"
  ]
}

   provisioner "remote-exec" {
     inline = [
       "chmod +x /opt/flaskapp/stop_app.sh"
  ]
}

  provisioner "remote-exec" {
     inline = [
       "echo Instalando o agente do CodeDeploy...",
       "sudo yum update -y",
       "sudo yum install -y ruby wget",
       "cd /home/ec2-user",
       "wget https://aws-codedeploy-sa-east-1.s3.amazonaws.com/latest/install",
       "chmod +x ./install",
       "sudo ./install auto",
       "sudo systemctl enable codedeploy-agent",
       "sudo systemctl start codedeploy-agent"
  ]
}



  tags = {
    Name = "FlaskAppEC2"
  }
}


resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow SSH, HTTP, HTTPS and ICMP"
  vpc_id      = aws_vpc.Devops_01.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ICMP (ping)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Libera saída total
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sg"
  }
}
