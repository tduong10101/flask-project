resource "aws_kms_key" "tnote-mysql-secret"{
    description = "tnote mysql secret"
}

resource "aws_db_instance" "tnote-db" {
    allocated_storage = 10
    db_name = "database"
    engine = "mysql"
    instance_class = "db.t3.micro"
    manage_master_user_password = true
    master_user_secret_kms_key_id = aws_kms_key.tnote-mysql-secret.key_id
    username = "root"
}

output "rds_endpoint" {
    value = aws_db_instance.tnote-db.endpoint
}