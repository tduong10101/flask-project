resource "aws_db_instance" "tnote_db" {
    allocated_storage = 10
    db_name = "tnotedb"
    engine = "mysql"
    instance_class = "db.t3.micro"
    username = "root"
    password = var.db_pass
    port=3306
    publicly_accessible = true
    skip_final_snapshot = true
}
resource "aws_ecs_task_definition" "tnote" {
    family = "tnote"
    container_definitions =  jsonencode([
        {
            name = "tnote"
            image = "069363837566.dkr.ecr.ap-southeast-2.amazonaws.com/my-ecr-repo"
            memory = 2000
            environment = [
                {
                    name = "tnote"
                    SQL_USERNAME = aws_db_instance.tnote_db.username
                    SQL_PASSWORD = var.db_pass
                    SQL_HOST = aws_db_instance.tnote_db.address
                    SQL_PORT = aws_db_instance.tnote_db.port
                    DB_NAME = aws_db_instance.tnote_db.db_name
                }
            ]
            portMappings = [
                {
                    containerPort=8000
                    hostPort=8000
                }
            ]
        }    
    ])
}