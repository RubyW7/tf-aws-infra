resource "aws_instance" "web_app" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = "subnet-02d41e81eddf16052"
  vpc_security_group_ids = [module.networking.app_sg_id]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 25
    delete_on_termination = true
  }

  disable_api_termination = false
}

