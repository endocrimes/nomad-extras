datacenter = "dc1"

log_level = "TRACE"

leave_on_interrupt = true

enable_debug = true

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics       = true
  prometheus_metrics         = true
}

client {
  enabled = true

  /* chroot_env { */
  /*   "/nix" = "/nix" */
  /* } */

  host_volume "tmp-dir" {
    path      = "/tmp"
    read_only = true
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

plugin "docker" {
  config {
    allow_privileged = true
  }
}

consul {
  "timeout" = "5s"
}
