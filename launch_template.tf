resource "aws_launch_template" "example" {
  name_prefix            = "rodry-lt-tf"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name               = aws_key_pair.example.key_name

  user_data = base64encode(file("server_setup.sh"))

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
    }
  }
}
