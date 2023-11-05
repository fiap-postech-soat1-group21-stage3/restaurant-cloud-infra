resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "restaurant-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "restaurant-igw"
  }
}

resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "private-us-east-1a"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-east-1b"

  tags = {
    "Name" = "private-us-east-1b"
  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1a"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public-us-east-1b"
  }
}

resource "aws_eip" "nat" {
  tags = {
    Name = "restaurant-eit"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "restaurant-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.public.id
}

# resource "aws_security_group" "nat_sg" {
#   name        = "nat-sg"
#   description = "NAT Security Group"
#   vpc_id      = aws_vpc.main.id
# }

# resource "aws_network_interface" "nat_eni" {
#   subnet_id          = aws_subnetpublic-us-east-1a.id # Escolha uma subnet pública
#   security_groups    = [aws_security_group.nat_sg.id]
#   source_dest_check = false
# }

# resource "aws_instance" "nat" {
#   ami           = "ami-0c55b159cbfafe1f0" # AMI do NAT Gateway
#   instance_type = "t2.micro"
#   subnet_id     = aws_subnet.public-us-east-1a.id # Escolha a mesma subnet da Network Interface
#   key_name      = "your-key-name" # Substitua pelo seu nome de chave

#   # network_interface {
#   #   network_interface_id = aws_network_interface.nat_eni.id
#   # }

#   tags = {
#     Name = "nat-instance"
#   }
# }

