---
title: "6. Automatiseren webserverinstallatie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Scripting (vervolg)

## Fouten opsporen (1)

- Begin met minimaal script, voer het zo snel mogelijk uit!
- Werk altijd **stap voor stap**
    - iteratieve toevoegingen
- **Test** voortdurend het resultaat van elke wijziging
- Hou minstens **2 vensters** open naast elkaar:
    - Editor
    - Terminal voor testen

## Fouten opsporen (2)

- Syntax check: `bash -n script.sh`
- ShellCheck: `shellcheck script.sh`
    - Gebruik editor-plugin waar mogelijk
- Druk veel info af (`printf` of `echo`)
- Debug-mode:
    - `bash -x script.sh`
    - In het script: `set -x` en `set +x`

## Fouten voorkomen

Begin elk script met:

```bash
set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes
```

## Booleans in Bash

- In Bash bestaan **geen** booleaanse variabelen!
- Er bestaan wel gelijknamige commando's `true` en `false`
- Booleaanse waarden zijn gebaseerd op exit-status v/e proces

## De commando's `true` en `false`

In Java zou je `true` als volgt implementeren

```java
public class True {
  public static void main(String[] args) {
    System.exit(0);
  }
}
```

en `false`:

```java
public class False {
  public static void main(String[] args) {
    System.exit(1);
  }
}
```

De echte implementatie [vind je hier](https://github.com/coreutils/coreutils/blob/master/src/true.c)

## Logische operatoren

```bash
if COMMANDO; then
  # A
else
  # B
fi
```

- `A`-blok wordt uitgevoerd als exit-status van `COMMANDO` 0 is (geslaagd, TRUE)
- `B`-blok wordt uitgevoerd als exit-status van `COMMANDO` verschillend is van 0 (gefaald, FALSE)

## Toepassing

Maak gebruiker `${user}` aan als die nog niet bestaat

```bash
if ! getent passwd "${user}" > /dev/null 2>&1; then
  echo "Adding user ${user}"
  adduser "${user}"
else
  echo "User ${user} already exists"
fi
```

## Operatoren `&&` en `||`

```bash
command1 && command2
```

`command2` wordt enkel uitgevoerd als `command1` succesvol was (exit 0)

```bash
command1 || command2
```

`command2` wordt enkel uitgevoerd als `command1` **niet** succesvol was (exit ??? 0)

## Het commando `test`

- Evalueren van logische expressies
- Geeft geschikte exit-status
    - 0 = TRUE
    - 1 = FALSE
- Alias voor `test` is `[`
    - `[` is een *commando*, geen "haakje" in de traditionele betekenis
    - spaties v????r en na!

---

```bash
# Fout:
if[$#-eq 0]; then
  echo "Expected at least one argument"
fi

# Juist:
if [ "${#}" -eq "0" ]; then
  echo "Expected at least one argument"
fi
```

# Automatiseren webserverinstallatie

## De kracht van automatisering

- Installeren van een server is terugkerende taak
- Moet snel ??n foutloos kunnen gebeuren!
    - 1x, 10x, 100x, ...
- ??? Automatiseren is een noodzaak!

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

- Ga naar Chamilo
- Volg link voor aanmaken Github repo labo automatisering
- Kloon deze Github repo lokaal (op je fysieke systeem!)
- Open terminal (Git Bash of PowerShell)
- Ga in de directory (`linux-2122-automation-USER`)

## Overzicht repo

```console
$ tree
.
????????? LICENSE.md
????????? provisioning
???   ????????? common.sh
???   ????????? db.sh
???   ????????? web.sh
????????? README.md
????????? Vagrantfile
????????? vagrant-hosts.yml

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
==> db: Importing base box 'bento/almalinux-8'...
==> db: Matching MAC address for NAT networking...
==> db: Checking if box 'bento/almalinux-8' version '202109.10.0' is up to date...
==> db: Setting the name of the VM: linux-2122-automation-bertvv_db_1635848839364_33506
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
    db: /vagrant => /home/bert/Documents/Vakken/Linux/21-22/linux-2122-automation-bertvv
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
    - hier: [bento/almalinux-8](https://app.vagrantup.com/bento/boxes/almalinux-8)
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
- Eindresultaat:  `vagrant up web` ??? werkende webserver!

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
    - ??? test of het nodig is bepaalde taak uit te voeren!
