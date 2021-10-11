---
title: "3. Software-installatie, netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Software-installatie

## Where does it come from?

Wat is een distributie?
- Linux is een operating system (OS).
- Applicaties worden ontwikkeld, al of niet met libraries
- Applicatiesoftware wordt gecompileerd voor het OS

Waar komt software vandaan?
- package = verzameling van ...
  - gecompileerde software voor een versie van Linux
	- bijhorende bestanden (configuratie, man, ...)
	- informatie over waar deze bestanden terecht horen
	- eventuele afhankelijkheden van libraries of andere software
	  = dependency (zie verder)
- packages worden aangeboden op specifieke servers
  - repository servers
	- werken zoals 'Play Store' (of liever: omgekeerd)

## Debian vs Red Hat

Klassiek zijn er twee grote Linux distributies
(zie https://nl.wikipedia.org/wiki/Linuxdistributie)

1. Debian
2. Red Hat

De verschillen zijn o.a. in de manier waarop software wordt beheerd:

1. Debian:  .deb packages
2. Red Hat: .rpm packages

## Debian dpkg

Tool die een .deb package installeert op een systeem.

1. download een .deb package (manueel)
2. installeer met dpkg

```bash
$ dpkg -i <package_name>.deb
```
3. Los eventuele depencencies manueel op (zie later)

---

Overzicht van geïnstalleerde packages op Debian:

```bash
$ dpkg -l
```

## Dependency

Software wordt gebouwd boven op andere software.
Zonder de onderliggende bouwstenen kan dit niet werken.

Linux name = dependency

```bash
dpkg -I vim_2%3a8.1.2269-1ubuntu5.3_amd64.deb 
 new Debian package, version 2.0.
 Package: vim
 Version: 2:8.1.2269-1ubuntu5.3
 Architecture: amd64
 Depends: vim-common (= 2:8.1.2269-1ubuntu5.3), vim-runtime (= 2:8.1.2269-1ubuntu5.3), libacl1 (>= 2.2.23), libc6 (>= 2.29), libcanberra0 (>= 0.2), libgpm2 (>= 1.20.7), libpython3.8 (>= 3.8.2), libselinux1 (>= 1.32), libtinfo6 (>= 6)

```

## Debian apt

APT = Advanced Package Tool

1. Zoek een package op de (aanvaarde) repository servers 
2. download de .deb package (automatisch)
3. controlleer depencencies, download eventuele extra packages
4. installeert (achterliggend) met dpkg

```bash
$ apt install <package_name>
```

## Debian apt (2) 

Automatisering:

Bijwerken van info op de repo servers
```bash
$ apt update
```

Bijwerken van alle packages op jouw systeem
```bash
$ apt upgrade
```

Bijwerken van een enkele package op jouw systeem
```bash
$ apt install <package_name> # nieuwe versie wordt geïnstalleerd
```

## Debian repository servers

List of repository servers you use:

```bash
osboxes@osboxes:~$ ls /etc/apt/sources.list*
/etc/apt/sources.list

/etc/apt/sources.list.d:
official-package-repositories.list
```

## Red Hat yum / dnf

Identical system, but different command set.
In brief...

```bash
$ dnf install <package_name>
```

Bijwerken van info op de repo servers;
aftoetsen van wat kan bijgewerkt worden:
```bash
$ dnf check-update
```

Bijwerken van alle packages op jouw systeem
```bash
$ dnf upgrade
```

Bijwerken van een enkele package op jouw systeem
```bash
$ dnf upgrade <package_name> # nieuwe versie wordt geïnstalleerd
```

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


