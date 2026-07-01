# Subnets

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_job_tracker_cidrs)
  vpc_id                  = aws_vpc.job_tracker_ecs_vpc.id
  cidr_block              = var.public_subnet_job_tracker_cidrs[count.index]
  availability_zone       = var.availability_zones_job_tracker[count.index % length(var.availability_zones_job_tracker)]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_job_tracker_cidrs)
  vpc_id            = aws_vpc.job_tracker_ecs_vpc.id
  cidr_block        = var.private_subnet_job_tracker_cidrs[count.index]
  availability_zone = var.availability_zones_job_tracker[count.index % length(var.availability_zones_job_tracker)]

  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "data_subnets" {
  count             = length(var.data_subnet_job_tracker_cidrs)
  vpc_id            = aws_vpc.job_tracker_ecs_vpc.id
  cidr_block        = var.data_subnet_job_tracker_cidrs[count.index]
  availability_zone = var.availability_zones_job_tracker[count.index % length(var.availability_zones_job_tracker)]

  tags = {
    Name = "data-subnet-${count.index + 1}"
  }
}


# Internet Gateway

resource "aws_internet_gateway" "igw_job_tracker" {
  vpc_id = aws_vpc.job_tracker_ecs_vpc.id

  tags = {
    Name = "ecsvpcmain"
  }
}

# Public Route Tables

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.job_tracker_ecs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_job_tracker.id
  }
}

resource "aws_route_table_association" "public_route_association" {
  subnet_id      = aws_subnet.public_subnets[count.index].id
  count          = length(var.public_subnet_job_tracker_cidrs)
  route_table_id = aws_route_table.public_route_table.id
}

#Private Route Tables

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.job_tracker_ecs_vpc.id
  count  = length(var.private_subnet_job_tracker_cidrs)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.job_tracker_nat[count.index].id
  }
}

resource "aws_route_table_association" "private_route_association" {
  subnet_id      = aws_subnet.private_subnets[count.index].id
  count          = length(var.private_subnet_job_tracker_cidrs)
  route_table_id = aws_route_table.private_route_table[count.index].id
}


# EIP and NAT Gateway

resource "aws_eip" "job_tracker_eip" {
  count  = length(var.private_subnet_job_tracker_cidrs)
  domain = "vpc"
}

resource "aws_nat_gateway" "job_tracker_nat" {
  allocation_id = aws_eip.job_tracker_eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  count         = length(var.private_subnet_job_tracker_cidrs)

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}