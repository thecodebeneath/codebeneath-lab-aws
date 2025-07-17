output lab-vpc {
    value = aws_vpc.lab.id
    description = "The name of the lab vpc"
}

output public-subnet-id {
    value = aws_subnet.public.id
    description = "Public subnet ID to use for the bootstrap server"
}