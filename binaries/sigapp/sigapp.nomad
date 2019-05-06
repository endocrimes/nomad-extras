job "test" {
  type        = "service"
  datacenters = ["dc1"]

  task "hello" {
    driver = "raw_exec"

    config {
      command = "sigapp"
    }
  }
}
