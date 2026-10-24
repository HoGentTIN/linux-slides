---
title: "Automatiseren webserverinstallatie met Vagrant"
subtitle: "Linux"
author: "HOGENT toegepaste informatica"
date: "2026-2027"
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

- Windows: `winget install vagrant`
- MacOS: `brew install vagrant`
- Linux: `apt install vagrant` (of `dnf`)

Of ga naar <https://www.vagrantup.com/downloads>

## Werkomgeving opzetten

- Kloon je Github-repo voor je labo-taken op je **fysieke systeem**
- Ga naar de directory `vagrant_rpm/` (OpsLinux) of `vagrant_deb/` (Data/DevLinux)
- Lees de README.md
- Download onze base boxes (zie Leermateriaal voor dit hoofdstuk op Orion)

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
==> db: Importing base box 'hogenttin/almalinux-10'...
==> db: Matching MAC address for NAT networking...
==> db: Setting the name of the VM: vagrant_rpm_db_1792843218365_99961
==> db: Fixed port collision for 22 => 2222. Now on port 2201.
==> db: Clearing any previously set network interfaces...
==> db: Preparing network interfaces based on configuration...
    db: Adapter 1: nat
    db: Adapter 2: intnet
==> db: Forwarding ports...
    db: 22 (guest) => 2201 (host) (adapter 1)
==> db: Running 'pre-boot' VM customizations...
==> db: Booting VM...
==> db: Waiting for machine to boot. This may take a few minutes...
    db: SSH address: 127.0.0.1:2201
    db: SSH username: vagrant
    db: SSH auth method: private key
[...]
==> db: Machine booted and ready!
==> db: Checking for guest additions in VM...
==> db: Setting hostname...
==> db: Configuring and enabling network interfaces...
==> db: Mounting shared folders...
    db: /home/bert/Documents/Vakken/Linux/linux-labos/topics/vagrant_rpm => /vagrant
==> db: Running provisioner: shell...
    db: Running: /tmp/vagrant-shell20261024-69798-h4xhtj.sh
    db: [LOG]  === Starting common provisioning tasks ===
[...]
    db: success
    db: [LOG]  Securing the database
    db: [LOG]  Creating database and user
    db: [LOG]  Creating database table and add some data
```

## Wat gebeurt er?

1. Een nieuwe VirtualBox-VM wordt aangemaakt
    - Check in de GUI!
2. Een zgn. "base box" wordt zo nodig gedownload
    - = VM image met minimale installatie
    - wordt later hergebruikt

---

3. De VM wordt geconfigureerd:
    - Naam, CPU, RAM, netwerkkaarten, ...
    - IP-adres
    - SSH-sleutel
    - Gedeelde map `/vagrant`
4. Het installatie-script wordt uitgevoerd

## Inloggen

```console
$ vagrant ssh db

This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento

Use of this system is acceptance of the OS vendor EULA and License Agreements.
vagrant@db:~$ ip -br a
lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp0s3           UP             10.0.2.15/24 fe80...
enp0s8           UP             192.168.76.3/24 fe80...
```

## Probeer het volgende!

- Kan je pingen vanuit de GUI VM naar deze VM?
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
