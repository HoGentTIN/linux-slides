---
title: "3.2. Netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2022-2023
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
    - Debian, Fedora: `resolvectl status <interface>`

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
[admin@server] $ ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute eth0
       valid_lft 85546sec preferred_lft 85546sec
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168.76.2/24 brd 192.168.76.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
```

Probeer dit ook op de Linux Mint VM. Overeenkomsten? Verschillen?

## Netwerkinstellingen

- `lo` (loopback): 127.0.0.1/8
- `eth0`/`enp0s3` = 1e VirtualBox adapter (NAT): 10.0.2.15/24
- `eth1`/`enp0s8` = 2e VirtualBox adapter (Host-only): 192.168.76.2/24

## Netwerkinstellingen aanpassen (RedHat)

`/etc/sysconfig/network-scripts/ifcfg-<interface_name>`

```bash
NM_CONTROLLED=yes
BOOTPROTO=none
ONBOOT=yes
IPADDR=192.168.76.2
NETMASK=255.255.255.0
DEVICE=eth1
PEERDNS=no
```

Na aanpassingen, netwerk herstarten:

```console
$ sudo systemctl restart network
```

# Let's install DHCP!

## Installatie

Zoek de naam van de package om ISC DHCP te installeren!

## Configuratie

- Configbestand: `/etc/dhcp/dhcpd.conf`
- Zie voorbeeld: `/usr/share/doc/dhcp-server/dhcpd.conf.example`
- Wat hebben we nodig voor onze opstelling?

## Opstarten `systemctl`

- `sudo systemctl start dhcpd`
- `systemctl status dhcpd`
- `sudo systemctl restart dhcpd`
    - Na elke wijziging config!
- `sudo systemctl enable dhcpd`
    - Start altijd bij booten

## Sluit de Linux-Mint VM aan op intnet

- Krijgt je VM een IP-adres? welk?
- Zie je iets in de DHCP logs?
- Kan je pingen tussen de VMs?
- Heb je Internet-toegang? Waarom (niet)?
- Zoek via de man-page voor dhcpd waar DHCP leases bijgehouden worden

# Vim survival guide

## Hoe maak je een bestand aan?

1. Met teksteditor Vi/Vim: `vim bestand.txt`
2. Met teksteditor Nano: `nano bestand.txt`
3. Leeg bestand: `touch bestand.txt`

## Essentiële Vim-commando's

- Bij opstarten van Vim kom je terecht in *normal mode*.
- Als je tekst wil invoeren moet je naar *insert mode*.

| Taak                       | Commando |
| :------------------------- | :------- |
| Normal mode -> insert mode | `i`      |
| Insert mode -> normal mode | `<Esc>`  |
| Opslaan                    | `:w`     |
| Opslaan en afsluiten       | `:wq`    |
| Afsluiten zonder opslaan   | `:q!`    |

---

Steep learning curve, great tool!

```console
$ sudo apt install vim-runtime     # Op Debian
$ sudo dnf install vim-enhanced    # Op RedHat
$ vimtutor
```
