variable "version" {
  type    = string
  default = "latest"
}

source "docker" "alpine" {
  commit = true
  image  = "alpine:latest"
}

build {
  sources = ["source.docker.alpine"]

  # Upgrade the software
  provisioner "shell" {
    inline = [
      "apk update",
      "apk upgrade",
    ]
  }

  # Do stuff here

  # Remove APK cache for space
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
    ]
  }

  post-processor "docker-tag" {
    repository = "akester/containername"
    tags = [
      "${var.version}"
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}
