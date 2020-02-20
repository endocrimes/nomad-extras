job "digitalocean" {
  datacenters = ["dc1"]

  group "csi" {
    task "plugin" {
      driver = "docker"

      config {
        image = "digitalocean/do-csi-plugin:v1.2.0"
        args = [
          "--endpoint=unix://csi/csi.sock",
          "--token=${token}",
          "--url=https://api.digitalocean.com/",
        ]

        privileged = true
      }

      csi_plugin {
        id        = "digitalocean"
        type      = "monolith"
        mount_dir = "/csi"
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10
          port  "plugin"{}
        }
      }
    }
  }
}
