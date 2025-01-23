# Description
My infrastructure configuration via NixOS and kubernetes for my homelab

## Garnix status
[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2FRMTT%2Fmachines%3Fbranch%3Dmain)](https://garnix.io)

## Nixos

### Partition

Use partition label to identify partitions

### Install

`nixos-install/nixos-rebuild --flake github:RMTT/machines#{machine name}`

## Services
> Based on Kubernetes now

The order to apply:

```
storage      

operators     |--> postgresql --> other apps ....
            
cert-issuer

and 

intel-device-plugin |--> plex
```

### Architecture

+ network infrastructure: godel(based on ipsec). All nodes that be used to deploy services should be inserted into godel
+ runtime: k3s

### Notes

#### How to scale up Traefik?

In default, k3s only install one traefik instance per cluster and one servicelb(forward traffic to traefik via netfilter) per node, to scale up traefik instance:

1. configure `deployment.prelicas` in HelmChartConfig of Traefik, which located at `services/k3s/traefik-custom-config.yaml`

2. via `kubectl scale --replicas x deployment -n kube-system traefik`

#### How to scale up CoreDNS

via `kubectl scale --replicas x deployment -n kube-system coredns`

## macOS

Required apps:
+ `nix`
+ `homebrew`
+ `home-manager`

Configurations steps:
+ `home-manager` switch --flake .#darwin
+ `brew` bundle --global
+ configure rectangle app
+ configure skhd app
