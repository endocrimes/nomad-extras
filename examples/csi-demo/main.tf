# Create a Volume for use with the CSI Driver. Do not attach it to the Node in TF.
resource "digitalocean_volume" "test-volume" {
  region                  = "ams3"
  name                    = "csi-test-volume"
  size                    = 50
  initial_filesystem_type = "ext4"
  description             = "a volume for testing Nomad CSI"
}

resource "tls_private_key" "ephemeralkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "digitalocean_ssh_key" "ephemeralkey" {
  name       = "Ephemeral CSI Key"
  public_key = tls_private_key.ephemeralkey.public_key_openssh
}

data "template_file" "create_volume_body" {
  template = file("templates/create-volume.json.tpl")
  vars = {
    volume_id = digitalocean_volume.test-volume.id
  }
}

data "template_file" "nomad-job" {
  template = file("templates/volume-job.nomad.tpl")
  vars = {
    volume_id = digitalocean_volume.test-volume.id
  }
}

data "template_file" "plugin-job" {
  template = file("templates/do-csi.nomad.tpl")
  vars = {
    token = var.do_token
  }
}

resource "digitalocean_droplet" "nomad" {
  name = "${var.resource_prefix}-nomad"

  image  = "ubuntu-18-04-x64"
  size   = "c-4"
  region = "ams3"

  ssh_keys = [
    var.do-ssh-key,
    digitalocean_ssh_key.ephemeralkey.fingerprint,
  ]

  user_data = <<-EOF
  #!/usr/bin/env bash
  apt-get update
  apt-get upgrade -y
  apt-get install -y git build-essential docker.io

  add-apt-repository ppa:longsleep/golang-backports
  apt-get update
  apt-get install -y golang-go

  export HOME="/root"
  export PATH="$PATH:/root/go/bin"
  echo "export PATH=\"$PATH:/root/go/bin\"" >> ~/.bashrc

  mkdir -p ~/go/src/github.com/rexray
  pushd ~/go/src/github.com/rexray
  git clone https://github.com/rexray/gocsi
  pushd gocsi/csc
  make csc 2>&1 > ~/csc.build.log

  mkdir -p ~/go/src/github.com/hashicorp
  pushd ~/go/src/github.com/hashicorp
  git clone https://github.com/hashicorp/nomad.git
  pushd ./nomad
  git checkout ${var.nomad_target_branch}
  make bootstrap
  make dev 2>&1 > ~/nomad.build.log
  echo "setup complete" ~/NOTICE
  EOF

  connection {
    user        = "root"
    type        = "ssh"
    private_key = tls_private_key.ephemeralkey.private_key_pem
    host        = self.ipv4_address
    timeout     = "2m"
  }

  provisioner "file" {
    content     = data.template_file.create_volume_body.rendered
    destination = "/root/create-volume.json"
  }

  provisioner "file" {
    content     = data.template_file.nomad-job.rendered
    destination = "/root/volume.nomad"
  }

  provisioner "file" {
    content     = data.template_file.plugin-job.rendered
    destination = "/root/plugin.nomad"
  }

  provisioner "file" {
    source      = "resources/client.hcl"
    destination = "/root/client.hcl"
  }

  provisioner "file" {
    source      = "resources/setup.sh"
    destination = "/root/setup.sh"
  }
}

output "droplet_output" {
  value = digitalocean_droplet.nomad.ipv4_address
}

output "volume_id" {
  value = digitalocean_volume.test-volume.id
}

