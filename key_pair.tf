resource "aws_key_pair" "example" {
  key_name   = "key_pair_rodry"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file("~/.ssh/id_ed25519.pub")
}
