# Create a droplet on DigitalOcean
resource "digitalocean_droplet" "droplet" {
  image      = "ubuntu-22-04-x64" # Ubuntu 22.04 (LTS)
  name       = var.droplet_name
  region     = "sgp1"        # Singapore 1
  size       = "s-1vcpu-1gb" # Regular Intel 1vCPU 1GB RAM / 25GB SSD
  backups    = true
  monitoring = true
  ssh_keys = [
    data.digitalocean_ssh_key.default_key.id
  ]

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    user        = "root"
    private_key = var.private_key
  }

  # Use the "remote-exec" provisioner to setup the droplet for Ansible
  provisioner "remote-exec" {
    inline = ["apt-get update", "apt-get install python3 -y", "echo Done!"]
    connection {
      host        = self.ipv4_address
      type        = "ssh"
      user        = "root"
      private_key = var.private_key
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u root -i '${self.ipv4_address},' non-root-user-1p.yml"
    environment = {
      ANSIBLE_HOST_KEY_CHECKING = false
    }
  }
}

# Make the droplet's IP address a reserved IP
resource "digitalocean_reserved_ip" "droplet_ip" {
  droplet_id = digitalocean_droplet.droplet.id
  region     = digitalocean_droplet.droplet.region
}

output "droplet_name" {
  value = digitalocean_droplet.droplet.name
}
output "server_ip" {
  value = digitalocean_reserved_ip.droplet_ip.ip_address
}
