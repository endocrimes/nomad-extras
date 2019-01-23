job "fabio" {
  datacenters = ["dc1"]
  type        = "system"

  update {
    stagger      = "60s"
    max_parallel = 1
  }

  group "fabio" {
    task "fabio" {
      constraint {
        attribute = "${attr.kernel.name}"
        value     = "linux"
      }

      driver = "exec"

      config {
        command = "./BINNAME"
      }

      artifact {
        source = "https://github.com/fabiolb/fabio/releases/download/vVERSION/BINNAME"
      }

      service {
        name = "fabio-http"
        tags = ["http", "load-balancer", "VERSION"]

        port = "http"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      service {
        name = "fabio-ui"
        tags = ["ui", "load-balancer", "VERSION"]

        port = "ui"

        check {
          type     = "http"
          path     = "/"
          interval = "30s"
          timeout  = "3s"
        }
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10

          # Fabio acts as the routing layer therefore static ports are used for
          # both the http and ui ports.
          port "http" {
            static = 9999
          }

          port "ui" {
            static = 9998
          }
        }
      }
    }
  }
}
