terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "iEMA"
  cloud_id  = "tis"
  folder_id = "mvat"
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
  folder_id = "vat"
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.my_service.id}",
  ]
}
#VM1
resource "yandex_compute_instance" "conserv1" {
  name = "consulserv1"
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
resource "yandex_compute_instance" "conserv2" {
  name = "consulserv2"
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

#VM3
resource "yandex_compute_instance" "conserv3" {
  name = "consulserv3"
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
#VM4
resource "yandex_compute_instance" "consulclient1" {
  name = "consulcli1"
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
#VM5
resource "yandex_compute_instance" "consulclient2" {
  name = "consulcli2"
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
