job "logger" {
  type        = "service"
  datacenters = ["dc1"]

  task "loggy" {
    driver = "raw_exec"

    config {
      command = "sigapp"
    }
  }
}
