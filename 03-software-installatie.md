---
title: "3. Software-installatie, netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Software-installatie

## TODO

# Netwerkconfiguratie

## Netwerkinstellingen controleren

Om Internettoegang mogelijk te maken zijn er 3 instellingen nodig:

1. IP-adres en subnetmasker
2. Default gateway
3. DNS-server

## Netwerkinstellingen opvragen

1. IP-adress/netmask: `ip address` (`ip a`)
2. Default gateway: `ip route` (`ip r`)
3. DNS-server: `cat /etc/resolv.conf`

## Wat is het IP-adres van...?

```bash
$ nslookup www.hogent.be
$ dig www.hogent.be
```

Wat is *mijn publiek* IP-adres?

```bash
$ curl icanhazip.com
81.164.175.191
```

## Controleer eerst netwerkinstellingen

```bash
$ ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 74751sec preferred_lft 74751sec
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168.56.101/24 brd 192.168.56.255 scope global dynamic noprefixroute enp0s8
       valid_lft 1049sec preferred_lft 1049sec
```

## Netwerkinstellingen

- `lo` (loopback): 127.0.0.1/8
- `enp0s3` (VirtualBox NAT interface): 10.0.2.15/24
- `enp0s8` (VirtualBox Host-only Adapter): 192.168.56.101/24

## Problemen oplossen

- Geen `enp0s8` of geen/verkeerd IP-adres op `enp0s8`?
- Volg instructies installatie VirtualBox:
    - Sluit VM af
    - Studiewijzer Besturingssystemen, §6.1, VirtualBox Configuratie
    - Hoofdvenster VirtualBox > VM > Details > Network
    - Maak 2e adapter aan, sluit aan op Host-only netwerk
    - Start VM op
