---
title: "6. Automatiseren webserverinstallatie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2022-2023
---

# Automatiseren webserverinstallatie

## De kracht van automatisering

- Installeren van een server is terugkerende taak
- Moet snel én foutloos kunnen gebeuren!
    - 1x, 10x, 100x, ...
- ⇒ Automatiseren is een noodzaak!

## Kwaliteitsbewaking bij server-installatie

Opbouw in de opleiding:

1. Gedetailleerde procedurehandleiding
    - SELab, Linux, System Engineering Project
2. Script voor automatisering
   - Linux, System Engineering Project
3. Configuration Management
   - Infrastructure Automation

## Tool: Vagrant

<https://www.vagrantup.com/>

- Command-line applicatie
- Automatiseert aanmaken en configureren van (VirtualBox) VMs
- Draait op Linux, Windows, MacOS

## Waarom Vagrant gebruiken?

- Snel nieuwe VMs aanmaken
- Reproduceerbaar!
    - Enkel code, geen .ova van +4GB
    - Overdraagbaar naar ander platform
- Aantal VMs onder controle houden

## Installeer Vagrant

Op je fysieke systeem!

- Windows: `choco install vagrant`
- MacOS: `brew install vagrant`
- Linux: `apt install vagrant` (of `dnf`)

Of ga naar <https://www.vagrantup.com/downloads>

## Werkomgeving opzetten

- Kloon je Github-repo voor je labo-taken op je **fysieke systeem**
- Ga naar de directory `automation/`
- Lees de README.md

## Overzicht repo

```console
$ tree
.
├── LICENSE.md
├── provisioning
│   ├── common.sh
│   ├── db.sh
│   └── web.sh
├── README.md
├── Vagrantfile
└── vagrant-hosts.yml

1 directory, 7 files
```

## Overzicht repo (2)

- `Vagrantfile`: configuratiebestand van Vagrant
    - hoef je niet aan te komen
- `vagrant-hosts.yml`: overzicht VMs in de opstelling
    - incl. eigenschappen zoals IP-adres
- `provisioning/`: installatiescripts voor VMs

## Werken met Vagrant

```console
$ vagrant status
Current machine states:

db                        not created (virtualbox)
web                       not created (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

## Start de `db` VM op

```console
$ vagrant up db
Bringing machine 'db' up with 'virtualbox' provider...
==> db: Importing base box 'bento/almalinux-9'...
==> db: Matching MAC address for NAT networking...
==> db: Checking if box 'bento/almalinux-9' version '202109.10.0' is up to date...
==> db: Setting the name of the VM: linux-2223-bertvv_db_1635848839364_33506
==> db: Clearing any previously set network interfaces...
==> db: Preparing network interfaces based on configuration...
    db: Adapter 1: nat
    db: Adapter 2: intnet
==> db: Forwarding ports...
    db: 22 (guest) => 2222 (host) (adapter 1)
==> db: Running 'pre-boot' VM customizations...
==> db: Booting VM...
==> db: Waiting for machine to boot. This may take a few minutes...
    db: SSH address: 127.0.0.1:2222
    db: SSH username: vagrant
    db: SSH auth method: private key
    db: 
    db: Vagrant insecure key detected. Vagrant will automatically replace
    db: this with a newly generated keypair for better security.
    db: 
    db: Inserting generated public key within guest...
    db: Removing insecure key from the guest if it's present...
    db: Key inserted! Disconnecting and reconnecting using new SSH key...
==> db: Machine booted and ready!
==> db: Checking for guest additions in VM...
==> db: Setting hostname...
==> db: Configuring and enabling network interfaces...
==> db: Mounting shared folders...
    db: /vagrant => /home/bert/Documents/Vakken/Linux/22-23/linux-2223-bertvv
==> db: Running provisioner: shell...
    db: Running: /tmp/vagrant-shell20211102-9694-yq9qn5.sh
    db: [LOG]  === Starting common provisioning tasks ===
    db: [LOG]  Ensuring SELinux is activePermissivePermissivePermissive
    db: [LOG]  Installing useful packages
    [...]
    db: [LOG]  Securing the database
    db: [LOG]  Creating database and user
    db: [LOG]  Creating database table and add some data
```

## Wat gebeurt er?

1. Een nieuwe VirtualBox-VM wordt aangemaakt
    - Check in de GUI!
2. Een zgn. "base box" wordt zo nodig gedownload
    - = VM image met minimale installatie
    - hier: [bento/almalinux-9](https://app.vagrantup.com/bento/boxes/almalinux-9)
    - wordt later hergebruikt

---

3. De VM wordt geconfigureerd:
    - Naam, CPU, RAM, netwerkkaarten, ...
    - IP-adres
    - Gedeelde map `/vagrant`
4. Het installatie-script wordt uitgevoerd

## Inloggen

```console
$ vagrant ssh db

This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
[vagrant@db ~]$ ip a show dev eth1
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:1f:c4:a7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.76.3/24 brd 192.168.76.255 scope global noprefixroute eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::a00:27ff:fe1f:c4a7/64 scope link 
       valid_lft forever preferred_lft forever
[vagrant@db ~]$ 
```

## Probeer het volgende!

- Kan je pingen vanuit Linux Mint naar deze VM?
- Draait MariaDB?
- Kan je inloggen in de database?
- Welke data zit in de database?

Tip: bekijk het installatiescript `provisioning/db.sh`

## Belangrijkste commando's

| Commando               | Taak                         |
| :--------------------- | :--------------------------- |
| `vagrant status`       | Overzicht omgeving           |
| `vagrant up VM`        | start VM op                  |
| `vagrant ssh VM`       | inloggen op VM               |
| `vagrant halt VM`      | VM uitschakelen              |
| `vagrant reload VM`    | VM rebooten                  |
| `vagrant provision VM` | Installatie-script uitvoeren |
| `vagrant destroy VM`   | VM vernietigen               |

## Opdracht

- Maak van `web` een webserver
- Poort 80, 443 (firewall!)
- Test-php script dat resultaat query naar `db` toont
- Eindresultaat:  `vagrant up web` ⇒ werkende webserver!

## Werkwijze

1. Begin met `vagrant up web` en log in
2. Open installatiescript `provisioning/web.sh` in een editor
3. Zoek de juiste commando's voor de webserverinstallatie (labo-verslagen!)
4. Voeg toe aan installatiescript
5. `vagrant provision web`

Herhaal 3-5 **in kleine iteraties!**

## Richtlijnen

- Rebooten/herbeginnen niet nodig! `provision` is voldoende
- Controleer telkens het effect van wijzigingen
- Onherstelbaar beschadigd? `vagrant destroy`
- Script mag **geen input** van gebruiker vragen
- Script moet meermaals na elkaar uitgevoerd kunnen worden
    - **idempotentie**
- Script klaar?
    - Test met `vagrant destroy web; vagrant up web`

## Idempotentie

- Wiskundige eigenschap v/e operatie
- Een operatie herhaald uitvoeren verandert het resultaat niet meer na de 1e keer
- Server installatie: handeling wordt enkel uitgevoerd indien nodig
    - Sommige Linux commando's zijn al idempotent (bv. `dnf install`)
    - Sommige commando's zijn dat niet (bv. `useradd`)
    - ⇒ test of het nodig is bepaalde taak uit te voeren!
