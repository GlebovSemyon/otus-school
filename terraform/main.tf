locals {
  ssh_key = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
}

resource "yandex_vpc_network" "vpc" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "subnet" {
  # folder_id = var.folder_id
  v4_cidr_blocks = var.subnet_cidrs
  zone           = var.zone
  name           = var.subnet_name
  network_id = yandex_vpc_network.vpc.id
}

resource "yandex_compute_instance" "instance" {
  name        = "${var.vm_name}${count.index}"
  hostname    = "${var.vm_name}${count.index}"
  platform_id = var.platform_id
  count       = 1
  zone        = var.zone
  resources {
    cores         = var.cpu
    memory        = var.memory
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.disk
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet.id
    nat                = var.nat
    ip_address         = var.internal_ip_address
    nat_ip_address     = var.nat_ip_address
  }

  metadata = {
    ssh-keys           = local.ssh_key
  }
  provisioner "remote-exec" {
    inline = ["sudo apt -y install python"]

    connection {
      host        = yandex_compute_instance.instance.0.network_interface.0.nat_ip_address
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_private)}"
      timeout     = "1m"
    }
  }

    provisioner "local-exec" {
      command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${yandex_compute_instance.instance.0.network_interface.0.nat_ip_address},' --private-key ${var.ssh_key_private} ../ansible/install_nginx.yml"
    }
}
