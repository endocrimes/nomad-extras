job "minio" {
  datacenters = ["dc1"]
  type        = "service"

  group "minio" {
    task "minio" {
      constraint {
        attribute = "${attr.kernel.name}"
        value     = "linux"
      }

      driver = "exec-storage"

      config {
        command = "./minio"

        args = [
          "server",
          "--address",
          "${NOMAD_IP_minio}:${NOMAD_PORT_minio}",
          "/mnt/data",
        ]

        volumes = [
          "minio:/mnt/data",
        ]
      }

      artifact {
        source = "https://dl.minio.io/server/minio/release/linux-amd64/minio"
      }

      service {
        name = "minio"
        tags = ["urlprefix-/minio", "http", "object-store"]

        port = "minio"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10

          port "minio" {}
        }
      }
    }
  }
}
