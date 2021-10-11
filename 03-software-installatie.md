---
title: "3. Software-installatie, netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Software-installatie

## Where does it come from?

Wat is een distributie?

- Linux is een operating system (OS) kernel
- Applicaties worden ontwikkeld, al of niet met libraries
- Applicatiesoftware wordt gecompileerd voor het OS
- Distributie = Kernel + collectie applicaties

## Waar komt software vandaan?

- package = verzameling van ...
    - gecompileerde software voor een versie van Linux
    - bijhorende bestanden (configuratie, man, ...)
    - informatie over waar deze bestanden terecht horen
    - eventuele afhankelijkheden van libraries of andere software
    - = dependency (zie verder)
- packages worden aangeboden op specifieke servers
    - repository servers
    - werken zoals 'Play Store' (of liever: omgekeerd)

## Debian vs Red Hat

Klassiek zijn er twee grote Linux distributies

(zie <https://nl.wikipedia.org/wiki/Linuxdistributie>)

1. Debian
    - Ubuntu
    - Mint
    - Raspbian
    - ...
2. Red Hat
    - Fedora
    - CentOS
    - AlmaLinux
    - ...

Opm. "Enterprise Linux" (EL) = compatibel met RedHat Enterprise Linux (RHEL)

## Verschillen tussen Debian en RedHat

De verschillen zijn o.a. in de manier waarop software wordt beheerd:

1. Debian:  .deb packages
2. Red Hat: .rpm packages

## Debian `dpkg`

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

- Software wordt gebouwd boven op andere software.
- Zonder de onderliggende bouwstenen kan dit niet werken.

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

- Bijwerken van info op de repo servers

    ```bash
    $ apt update
    ```

- Bijwerken van alle packages op jouw systeem

    ```bash
    $ apt upgrade
    ```

- Bijwerken van een enkele package op jouw systeem

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

- Identical system, but different command set.
- `rpm` = RedHat Package Manager (equivalent van `dpkg`)
- `yum` = Yellowdog Update Manager
    - equivalent van `apt`
    - Yellowdog = oude Linux distro voor Motorola-CPU's
    - Nog in gebruik op RedHat 6
- `dnf` = DaNdiFied yum
    - Vervangt `yum` vanaf RedHat Enterprise Linux 7
    - Ook in Fedora

## Red Hat yum / dnf (2)

- Installatie package

    ```bash
    $ dnf install <package_name>
    ```

- Bijwerken van info op de repo servers; aftoetsen van wat kan bijgewerkt worden:

    ```bash
    $ dnf check-update
    ```

---

- Bijwerken van alle packages op jouw systeem

    ```bash
    $ dnf upgrade
    ```

- Bijwerken van een enkele package op jouw systeem

    ```bash
    $ dnf upgrade <package_name>
    ```

## Andere handige commando's

- Lijst geïnstalleerde packages

    ```bash
    $ dnf list installed
    ```

- Lijst beschikbare packages

    ```bash
    $ dnf list available
    ```

Hoeveel packages zijn geïnstalleerd/beschikbaar op jouw VM?

---

- Met welke package kan ik het commando `fortune` installeren?

    ```bash
    $ dnf provides *bin/fortune
    ```

- Wat zijn de dependencies van `curl`?

    ```bash
    $ dnf deplist curl
    ```

## RedHat repository servers

```bash
[admin@server ~]$ ls /etc/yum.repos.d/
almalinux-ha.repo  almalinux-powertools.repo  almalinux.repo  epel-modular.repo
epel-playground.repo  epel-testing-modular.repo  epel-testing.repo  epel.repo
[admin@server ~]$ cat /etc/yum.repos.d/almalinux.repo
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

- Configbestand: `/etc/dhcp/dhcp.conf`
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
