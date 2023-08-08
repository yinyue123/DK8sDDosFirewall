#!/bin/bash

forward_ip=${1:-'127.0.0.1'}
echo "New Request forward to $forward_ip"
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to "$forward_ip:80"
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j DNAT --to "$forward_ip:443"
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
