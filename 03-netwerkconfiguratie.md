---
title: "3.2. Netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem, Jan Willem
date: 2025-2026
---

# Netwerkconfiguratie

## Netwerkinstellingen controleren

Om Internettoegang mogelijk te maken zijn er 3 instellingen nodig:

1. IP-adres en subnetmasker
2. Default gateway
3. DNS-server

## Netwerkinstellingen opvragen

1. IP-adress/netmask: `ip address` (`ip a`)
2. Default gateway: `ip route` (`ip r`)
3. DNS-server:
    - EL: `cat /etc/resolv.conf`
    - Debian, Fedora: `resolvectl dns`

## Wat is het IP-adres van...?

```bash
$ host www.hogent.be
$ dig www.hogent.be
$ nslookup www.hogent.be # old command
```

Wat is *mijn publiek* IP-adres?

```bash
$ curl icanhazip.com
81.164.175.191
```

## Controleer eerst netwerkinstellingen

(op de AlmaLinux VM, vóór uitvoeren van labo 3.4)

```bash
[osboxes@almaserver] $ ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 85546sec preferred_lft 85546sec
```

Probeer dit ook op de Linux Mint VM. Overeenkomsten? Verschillen?

## Netwerkinstellingen

- `lo` (loopback): 127.0.0.1/8
- `eth0`/`enp0s3` = 1e VirtualBox adapter (NAT): 10.0.2.15/24
- `eth1`/`enp0s8` = 2e VirtualBox adapter (intnet):
    - Linux Mint: 192.168.76.10/24
    - AlmaLinux: 192.168.76.12/24

## Netwerkinstellingen aanpassen (RedHat)

`/etc/sysconfig/network-scripts/ifcfg-<interface_name>`

```bash
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.76.12
NETMASK=255.255.255.0
DEVICE=eth1
PEERDNS=no
```

---

Na aanpassingen, netwerk herstarten (RHEL <=8):

```console
$ sudo systemctl restart network
```

Vanaf RHEL 9:

```console
$ sudo nmcli device reapply eth1
```

Bemerk: er is een overgang naar het uitfaseren van het gebruik van `ifcfg` bestanden, en dit te vervangen door `nmcli`. Hierdoor zal je nog geruime tijd beide systemen moeten begrijpen!

# Let's install DHCP!

## Installatie

Zoek de naam van de package om ISC DHCP te installeren!

## Configuratie

Zie opgave labo 3.4

- Configbestand: `/etc/dhcp/dhcpd.conf`
- Zie voorbeeld: `/usr/share/doc/dhcp-server/dhcpd.conf.example`
- Wat hebben we nodig voor onze opstelling?

## Opstarten `systemctl`

- `sudo systemctl start dhcpd`
- `systemctl status dhcpd`
- `sudo systemctl restart dhcpd`
    - Na elke wijziging config!
- `sudo systemctl enable [--now] dhcpd`
    - Start altijd bij booten
    - `--now` start meteen

## Sluit de Linux-Mint VM aan op intnet

- Vang netwerkverkeer op met `tcpdump`, bv.
    - `sudo tcpdump -w dhcp.pcap -i eth1 port 67 or port 68`
    - `sudo tcpdump -r dhcp.pcap -ne#`
    - Open het bestand met Wireshark
- Krijgt je VM een IP-adres? welk?
- Zie je iets in de DHCP logs?
    - Doe: `sudo journalctl -f -u dhcpd.service`
- Kan je pingen tussen de VMs?
- Heb je Internet-toegang? Waarom (niet)?
- Zoek via de man-page voor dhcpd waar DHCP leases bijgehouden worden
