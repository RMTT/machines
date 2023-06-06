#!/usr/bin/env bash

ROUTE_MARK=6
TPROXY_PORT=7891

set -ex

setup() {
    ip rule add fwmark $ROUTE_MARK lookup 100 || true
    ip route add local 0.0.0.0/0 dev lo table 100 || true

    # for lan
    iptables -t mangle -N clash || true

    # bypass lan
    iptables -t mangle -A clash -d 0.0.0.0/8 -j RETURN
    iptables -t mangle -A clash -d 127.0.0.0/8 -j RETURN
    iptables -t mangle -A clash -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A clash -d 172.16.0.0/12 -j RETURN
    iptables -t mangle -A clash -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A clash -d 169.254.0.0/16 -j RETURN

    iptables -t mangle -A clash -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A clash -d 240.0.0.0/4 -j RETURN

    # bypass the packets to localhost
    iptables -t mangle -A clash -m addrtype --dst-type LOCAL -j RETURN

    # forward packets to clash
    iptables -t mangle -A clash -p tcp -j TPROXY --on-port $TPROXY_PORT --tproxy-mark $ROUTE_MARK
    iptables -t mangle -A clash -p udp -j TPROXY --on-port $TPROXY_PORT --tproxy-mark $ROUTE_MARK

    iptables -t mangle -A PREROUTING -j clash

    # for localhost
    iptables -t mangle -N clash_local || true

    # bypass local
    iptables -t mangle -A clash_local -d 0.0.0.0/8 -j RETURN
    iptables -t mangle -A clash_local -d 127.0.0.0/8 -j RETURN
    iptables -t mangle -A clash_local -d 10.0.0.0/8 -j RETURN
    iptables -t mangle -A clash_local -d 172.16.0.0/12 -j RETURN
    iptables -t mangle -A clash_local -d 192.168.0.0/16 -j RETURN
    iptables -t mangle -A clash_local -d 169.254.0.0/16 -j RETURN

    iptables -t mangle -A clash_local -d 224.0.0.0/4 -j RETURN
    iptables -t mangle -A clash_local -d 240.0.0.0/4 -j RETURN

    # bypass clash
    iptables -t mangle -A clash_local -p tcp -m owner --uid-owner clash -j RETURN
    iptables -t mangle -A clash_local -p udp -m owner --uid-owner clash -j RETURN

    # mark
    iptables -t mangle -A clash_local -p tcp -j MARK --set-mark $ROUTE_MARK
    iptables -t mangle -A clash_local -p udp -j MARK --set-mark $ROUTE_MARK

    iptables -t mangle -A OUTPUT -j clash_local
}

clean() {
    ip rule del fwmark $ROUTE_MARK lookup 100 || true
    ip route add local 0.0.0.0/0 dev lo table 100 || true

    iptables -t mangle -D PREROUTING -j clash || true
    iptables -t mangle -D OUTPUT -j clash_local || true

    iptables -t mangle -F clash || true
    iptables -t mangle -F clash_local || true

    iptables -t mangle -X clash || true
    iptables -t mangle -X clash_local || true
}

$1
