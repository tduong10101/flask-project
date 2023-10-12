resource "aws_vpc" "main" {
    cidr_block = var.ipv4_cidr

    tags = {
        Name = var.namespace
        Stage = var.stage
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = var.namespace
        Stage = var.stage
    }
    depends_on = [ aws_vpc.main ]
}

resource "aws_default_route_table" "route_table" {
    default_route_table_id = aws_vpc.main.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }

    tags = {
        Name = var.namespace
        Stage = var.stage
    }
    depends_on = [ aws_vpc.main ]
}

resource "aws_subnet" "sn1" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.sn1_ipv4_cidr

    tags = {
        Name = var.namespace
        Stage = var.stage
    }
    depends_on = [ aws_vpc.main ]
}

resource "aws_subnet" "sn2" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.sn2_ipv4_cidr

    tags = {
        Name = var.namespace
        Stage = var.stage
    }
    depends_on = [ aws_vpc.main ]
}

resource "aws_subnet" "sn3" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.sn3_ipv4_cidr

    tags = {
        Name = var.namespace
        Stage = var.stage
    }
    depends_on = [ aws_vpc.main ]
}