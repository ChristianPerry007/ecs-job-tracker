# RDS Subnet group

resource "aws_db_subnet_group" "job_tracker_rds_subnet_group" {
  name        = var.data_subnet_group
  description = "Subnet group for rds"
  subnet_ids  = aws_subnet.data_subnets[*].id

  tags = {
    Name = "job tracker rds subnet group"
  }
}

# RDS Instance Pa55

resource "random_password" "rds_password" {
  length  = 16
  special = true
}

# RDS Instance

resource "aws_db_instance" "job_tracker_rds_instance" {
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  identifier             = "job-tracker-rds-instance"
  db_name                = "job_tracker_db"
  username               = "admin007"
  password               = random_password.rds_password.result
  vpc_security_group_ids = [aws_security_group.sg3_rds_job_tracker.id]
  multi_az               = true
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.job_tracker_rds_subnet_group.name

}