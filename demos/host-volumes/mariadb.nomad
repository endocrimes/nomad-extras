job "mariadb" {
  datacenters = ["dc1"]
  type        = "service"

  group "server" {
    count = 1

    volume "data" {
      type = "host"

      config {
        source = "mariadb-a"
      }
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "server" {
      driver = "docker"

      volume_mount {
        volume      = "data"
        destination = "/var/lib/mysql"
      }

      env = {
        "MYSQL_ROOT_PASSWORD" = "password"
        "MYSQL_DATABASE"      = "counters"
      }

      config {
        image = "mariadb:latest"

        port_map {
          db = 3306
        }
      }

      resources {
        cpu    = 500
        memory = 1024

        network {
          port "db" {}
        }
      }

      service {
        name = "mariadb-server"
        port = "db"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
