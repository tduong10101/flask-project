resource "aws_db_instance" "tnote-db" {
    allocated_storage = 10
    db_name = "tnote-db"
    engine = "mysql"
    instance_class = "db.t3.micro"
    username = "root"
    password = var.db_pass
}

output "rds_endpoint" {
    value = aws_db_instance.tnote-db.endpoint
}