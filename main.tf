resource "aws_vpc" "raise_tech" {
  cidr_block = "10.0.0.1/16"
  tags = {
    Name = "RaiseTech_VPC"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-1a"
  }
}

resource "aws_subnet" "public_1c" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet-1c"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet-1a"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = aws_vpc.raise_tech.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "PrivateSubnet-1c"
  }
}

resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.raise_tech.id
  tags = {
    Name = "InternetGateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.raise_tech.id
  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.raise_tech.id
  tags = {
    Name = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "public_rt_association_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_rt_association_1c" {
  subnet_id      = aws_subnet.public_1c.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_association_1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_rt_association_1c" {
  subnet_id      = aws_subnet.private_1c.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.raise_tech.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_route_table.id]
  tags = {
    Name = "S3GatewayEndpoint"
  }
}

