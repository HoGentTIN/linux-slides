---
title: "3.1. Software-installatie, netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2023-2024
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

**Opm.** "Enterprise Linux" (EL) = compatibel met RedHat Enterprise Linux (RHEL)

## Verschillen tussen Debian en RedHat

De verschillen zijn o.a. in de manier waarop software wordt beheerd:

- Debian:  .deb packages
- Red Hat: .rpm packages

**Opm.** Er zijn nog meer package managers voor Linux

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
    $ sudo apt update
    ```

- Bijwerken van alle packages op jouw systeem

    ```bash
    $ sudo apt upgrade
    ```

- Bijwerken van een enkele package op jouw systeem

    ```bash
    $ sudo apt install <package_name> # nieuwe versie wordt geïnstalleerd
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
    $ sudo dnf install <package_name>
    ```

- Bijwerken van info op de repo servers; aftoetsen van wat kan bijgewerkt worden:

    ```bash
    $ dnf check-update
    ```

---

- Bijwerken van alle packages op jouw systeem

    ```bash
    $ sudo dnf upgrade
    ```

- Bijwerken van een enkele package op jouw systeem

    ```bash
    $ sudo dnf upgrade <package_name>
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

# Other package managers

## Application-level package managers

- **pip** - Python
- **npm** - JavaScript
- **CTAN** - (La)TeX
- **Gem** - Ruby
- ...

## It's complicated

- Sommige packages zijn beschikbaar via bv. apt én pip
- Welke installeren? It depends...

---

![<https://xkcd.com/1654/>](assets/xkcd-1654-install.png)

## On other OSs

- MacOS: [Homebrew](https://brew.sh)
- Windows: [Chocolatey](https://chocolatey.org)/NuGet
