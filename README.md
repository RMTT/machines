# Description
My infrastructure configuration via NixOS and kubernetes for my homelab

## Nixos

### Partition

Use partition label to identify partitions

### Install

`nixos-install/nixos-rebuild --flake github:RMTT/machines#{machine name}`

## Services for kubernetes

The order to apply:

```
storage      
            |--> other apps ....
cert-issuer

and 

intel-device-plugin |--> plex
```
