# Certificate Sync via SSH (Home Assistant Add-on)

This Home Assistant add-on synchronizes TLS certificates from a central server
using SSH and rsync. When certificates change, Home Assistant Core is restarted
so the new TLS certificates are activated.

## How it works
1. Generates an SSH keypair on first start
2. Prints the public key to the add-on log
3. Pulls certificates via rsync over SSH
4. Detects changes
5. Restarts Home Assistant Core if needed

## Setup
1. Install the add-on
2. Start it once
3. Copy the public SSH key from the log
4. Add it to `authorized_keys` on the remote server
5. Restart the add-on

## Default paths
- Certificates are synced into `/ssl`
- SSH keys are stored in `/data/.ssh`

## Notes
- A Home Assistant Core restart is required to reload TLS certificates
