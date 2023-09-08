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
  network_id     = yandex_vpc_network.vpc.id
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  network_id = "${yandex_vpc_network.vpc.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

resource "yandex_compute_instance" "nginx" {
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
    inline = ["echo conection up ${self.name}"]

    connection {
      host        = "${self.network_interface.0.nat_ip_address}"
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file(var.ssh_key_private)}"
      timeout     = "1m"
    }
  }
  provisioner "local-exec" {
    command = "echo ansible_ssh_common_args: '-oStrictHostKeyChecking=no -oProxyCommand=\"ssh -oStrictHostKeyChecking=no -W %h:%p -q ubuntu@${self.network_interface.0.nat_ip_address}\"' > ../ansible/proxyvars.yml"
  }
}
resource "yandex_compute_instance" "backend" {
  name        = "${var.vm_name}-backend${count.index}"
  hostname    = "${var.vm_name}-backend${count.index}"
  platform_id = var.platform_id
  count       = 2
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
    ip_address         = var.internal_ip_address
  }

  metadata = {
    ssh-keys           = local.ssh_key
  }
}
resource "yandex_compute_instance" "database" {
  name        = "${var.vm_name}-database${count.index}"
  hostname    = "${var.vm_name}-database${count.index}"
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
    ip_address         = var.internal_ip_address
  }

  metadata = {
    ssh-keys           = local.ssh_key
  }
}