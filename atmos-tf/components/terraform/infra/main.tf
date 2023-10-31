resource "aws_db_instance" "tnote_db" {
  allocated_storage   = 10
  db_name             = "tnotedb"
  engine              = "mysql"
  instance_class      = "db.t3.micro"
  username            = "root"
  password            = var.db_pass
  port                = 3306
  publicly_accessible = true
  skip_final_snapshot = true
}

resource "aws_launch_template" "tnote_lt" {
  name_prefix   = "${var.namespace}_template"
  image_id      = "ami-09b402d0a0d6b112b"
  instance_type = "t3.micro"
  key_name      = "aws-ec2-kp"

  instance_initiated_shutdown_behavior = "terminate"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.ecs_sg.id]
  }
  iam_instance_profile {
    name = "ecsInstanceRole"
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.namespace}_instance"
    }
  }

  user_data = base64encode(data.template_file.ecs_user_data.rendered)

}

resource "aws_autoscaling_group" "tnote_acg" {
  vpc_zone_identifier = data.aws_subnets.tnote_sn.ids
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = resource.aws_launch_template.tnote_lt.id
    version = "$Latest"
  }
}

resource "aws_lb" "tnote_alb" {
  name               = "${var.namespace}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.tnote_sn.ids
  tags = {
    Name = "${var.namespace}_alb"
  }
}

resource "aws_lb_listener" "tnote_alb_listener" {
  load_balancer_arn = resource.aws_lb.tnote_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = resource.aws_lb_target_group.tnote_tg.arn
  }
}

resource "aws_lb_target_group" "tnote_tg" {
  name        = "${var.namespace}-target-group"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.tnote_vpc.id

  health_check {
    path = "/"
  }
}
resource "aws_ecs_cluster" "tnote_ecs_cluster" {
  name = "${var.namespace}_ecs_cluster"
}

resource "aws_ecs_capacity_provider" "tnote_ecs_cp" {
  name = "${var.namespace}_ecs_cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.tnote_acg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 3
    }
  }
}
resource "aws_ecs_cluster_capacity_providers" "tnote_ecs_cluster_cp" {
  cluster_name = aws_ecs_cluster.tnote_ecs_cluster.name

  capacity_providers = [aws_ecs_capacity_provider.tnote_ecs_cp.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.tnote_ecs_cp.name
  }
}

resource "aws_ecs_task_definition" "tnote_td" {
  family             = "${var.namespace}_td"
  network_mode       = "awsvpc"
  execution_role_arn = data.aws_iam_role.ecs_te_role.arn
  cpu                = 1024
  container_definitions = jsonencode([
    {
      name   = "tnote_docker"
      image  = "069363837566.dkr.ecr.ap-southeast-2.amazonaws.com/my-ecr-repo::latest"
      memory = 2048
      environment = [
        {
          name         = "tnote_docker"
          SQL_USERNAME = aws_db_instance.tnote_db.username
          SQL_PASSWORD = var.db_pass
          SQL_HOST     = aws_db_instance.tnote_db.address
          SQL_PORT     = aws_db_instance.tnote_db.port
          DB_NAME      = aws_db_instance.tnote_db.db_name
        }
      ]
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "tnote_ecs_service" {
  name            = "${var.namespace}_service"
  cluster         = aws_ecs_cluster.tnote_ecs_cluster.id
  task_definition = aws_ecs_task_definition.tnote_td.arn
  desired_count   = 1
  network_configuration {
    subnets         = data.aws_subnets.tnote_sn.ids
    security_groups = [data.aws_security_group.ecs_sg.id]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  triggers = {
    redeployment = timestamp()
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.tnote_ecs_cp.name
    weight            = 100
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tnote_tg.arn
    container_name   = "tnote_docker"
    container_port   = 8000
  }

  depends_on = [aws_autoscaling_group.tnote_acg]
}
