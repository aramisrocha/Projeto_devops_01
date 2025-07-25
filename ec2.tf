
resource "aws_instance" "flask_ec2" {
  ami                    = "ami-0eb9d6fc9fab44d24" # Amazon Linux 2
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.ec2_key.key_name
  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  #security_groups        = [aws_security_group.ec2_sg.name]
  associate_public_ip_address = true

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
      "pip3 install flask",
      "sudo yum install -y python3",
      "sudo python3 -m ensurepip --upgrade",
      "sudo mkdir -p /opt/flaskapp",
      "sudo chown ec2-user:ec2-user /opt/flaskapp",
      "sudo chmod 755 /opt/flaskapp",
      "cd /opt/flaskapp && nohup python3 app.py > app.log 2>&1 & "
  ]
 }

  provisioner "file" {
    source      = "app/app.py"
    destination = "/opt/flaskapp/app.py"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Executando app...",
      "cd /opt/flaskapp",
      "sleep 30",
      "nohup python3 app.py > app.log 2>&1 &"
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

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
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
