job "app" {
  datacenters = ["dc1"]
  type        = "service"

  group "app" {
    count = 1

    task "app" {
      driver = "docker"

      config {
        image        = "dantoml/maria-counter:latest"
        network_mode = "host"
      }

      resources {
        network {
          port "api" {
            static = 8080
          }
        }
      }

      template {
        data = <<EOH
{{ range service "mariadb-server" }}
DATABASE_ADDR="{{ .Address }}"
DATABASE_PORT="{{ .Port }}"
DATABASE_PASSWORD="password"
DATABASE_USER="root"
{{ end }}
EOH

        destination = "secrets/file.env"
        env         = true
      }

      service {
        name = "app"
        port = "api"

        check {
          type     = "tcp"
          interval = "5s"
          timeout  = "2s"
        }
      }
    }
  }
}
