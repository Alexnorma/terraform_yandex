terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "y0_AgAAAABZoXU0AATuwQAAAADdvTSNtPsaLK0XRum7-HXX9_mEhI_iEMA"
  cloud_id  = "b1g2urgq2s865fsastis"
  folder_id = "b1grr0bjmdb82334mvat"
  zone      = "ru-central1-a"
}
data "yandex_compute_image" "my-ubuntu-2004-1" {
  family = "ubuntu-2004-lts"
}

resource "yandex_iam_service_account" "my_service" {
  name        = "my-service"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = "b1grr0bjmdb82334mvat"
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.my_service.id}",
  ]
}
#VM1
resource "yandex_compute_instance" "react_js" {
  name = "reactjs"
  platform_id = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.my-ubuntu-2004-1.id}"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  metadata = {
    user-script = "ubuntu:${file("~/module_08/terraform/user_data.sh")}"
    ssh-keys = "ubuntu:${file("~/.ssh/react.pub")}"
  }
}
#VM2
resource "yandex_compute_instance" "nginx_server" {
  name = "nginx-server"
  platform_id = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.my-ubuntu-2004-1.id}"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }
  metadata = {
    user-script = "ubuntu:${file("~/module_08/terraform/user_data.sh")}"
    ssh-keys = "ubuntu:${file("~/.ssh/react.pub")}"
  }
}

#сетка
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
#подсетка
resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-1.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}
#публичный адрес
resource "yandex_vpc_address" "addr" {
  name = "test_public_ip"
  external_ipv4_address{
    zone_id = "ru-central1-a"
  }
}
resource "yandex_lb_network_load_balancer" "test-lb" {
  name = "test-lb"

  listener {
    name = "listener-web-servers"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web-servers.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

resource "yandex_lb_target_group" "web-servers" {
  name = "web-servers-target-group"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.react_js.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    address   = yandex_compute_instance.nginx_server.network_interface.0.ip_address
  }
}

output "external_ip_address" {
  value = yandex_vpc_address.addr
}
output "internal_ip_address_of_reactjs" {
  value = yandex_compute_instance.react_js.network_interface
}
output "dns_name_elb" {
  value = yandex_lb_network_load_balancer.test-lb
}



