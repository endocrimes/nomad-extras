# csi-demo

This is a terraform demo for running Nomad with CSI. To run it yourself, you
will need:
- A digitalocean account
- A digitalocean api key
- An ssh key registered with that account (or pull the private key from TF
  state for the provisioning key)

To run the demo:

- `terraform apply`
- SSH into the resulting node
- Open tmux with two splits
- in one run `nomad agent -dev -config client.hcl -data-dir /tmp/nomad-csi`
- in the other run `./setup.sh`
- Observe the connected volume through `docker inspect` or the DO UI.
