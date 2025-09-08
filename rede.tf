
# VPC
resource "aws_vpc" "Devops_01" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "Devops_01"
  }
}

# Criação das duas Subnets para o ambiente, uma publica e outra privada
resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.Devops_01.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "SubnetA"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id            = aws_vpc.Devops_01.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "SubnetB"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Devops_01.id
  tags = {
    Name = "MainIGW"
  }
}

resource "aws_eip" "nat_eip" {
  #vpc = true
  tags = {
    Name = "NatEIP"
  }
}

# Criando o nat_gateway para atribuir a tabela de rota da subnet privada
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_a.id
  tags = {
    Name = "MainNATGateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# Tabela de rota para a rede privada
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.Devops_01.id
  tags = {
    Name = "MainRouteTable"
  }
}

# Rota para internet
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associações da tabela de rotas às subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_a.id
  route_table_id = aws_route_table.rt.id
}


# 
resource "aws_route_table" "rtp" {
  vpc_id = aws_vpc.Devops_01.id
  tags = {
    Name = "Route_private"
  }
}

# Associação da tabela de rota 
resource "aws_route_table_association" "b" {
   subnet_id      = aws_subnet.subnet_b.id
   route_table_id = aws_route_table.rtp.id
}


resource "aws_route" "default_route_private" {
  route_table_id         = aws_route_table.rtp.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gw.id
}