resource "aws_vpc" "mera-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform vpc"
  }
}
/*
Requirements:
1.Public Subnets(3)
2.Internet gateway
3.Routing Table
4.Associating  Routing table with IG for 3 public subnets for Internet access.
*/

#Public Subnet 1
resource "aws_subnet" "pub1" {
  vpc_id            = aws_vpc.mera-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "pub-subnet-1"
  }
}
#Public Subnet 2
resource "aws_subnet" "pub2" {
  vpc_id            = aws_vpc.mera-vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "pub-subnet-2"
  }
}
#Public Subnet 3
resource "aws_subnet" "pub3" {
  vpc_id            = aws_vpc.mera-vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "pub-subnet-3"
  }
}

# Internet Gateway:
resource "aws_internet_gateway" "mera-IG" {
  vpc_id = aws_vpc.mera-vpc.id

  tags = {
    Name = "My-IG"
  }
}
# Route Table
resource "aws_route_table" "PB-RT" {
  vpc_id = aws_vpc.mera-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mera-IG.id
  }

  tags = {
    Name = "PB-RT"
  }
}
# Associate RT with IG for internet for All subnets:
resource "aws_route_table_association" "RT-IG-S1" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.PB-RT.id
}
resource "aws_route_table_association" "RT-IG-S2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.PB-RT.id
}
resource "aws_route_table_association" "RT-IG-S3" {
  subnet_id      = aws_subnet.pub3.id
  route_table_id = aws_route_table.PB-RT.id
}

#Task 2: Create 3 private subnets:
/*
Requirements:
1.Private Subnets(3)
2.NAT gateway
3.Routing Table
4.Associating  Routing table with IG for 3 subnets for Internet access.
*/
#Private  Subnet 1
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.mera-vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private-subnet-1"
  }
}
#Private  Subnet 2
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.mera-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "private-subnet-2"
  }
}
#Private  Subnet 3
resource "aws_subnet" "private3" {
  vpc_id            = aws_vpc.mera-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "private-subnet-3"
  }
}
# EIP Address for NAT-Gateway
resource "aws_eip" "NAT-EIP" {
  vpc = true
}

#NAT Gateway:
resource "aws_nat_gateway" "NAT-GW" {
  allocation_id = aws_eip.NAT-EIP.id
  subnet_id     = aws_subnet.pub1.id
}
#Route Table for NATGAteway:

resource "aws_route_table" "NATED-RT" {
  vpc_id = aws_vpc.mera-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT-GW.id
  }

  tags = {
    Name = "Main Route Table for NAT-ed subnet"
  }
}

#Nated RT Associated
resource "aws_route_table_association" "NATED-RT-S1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.NATED-RT.id
}
resource "aws_route_table_association" "NATED-RT-S2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.NATED-RT.id
}
resource "aws_route_table_association" "NATED-RT-S3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.NATED-RT.id
}
