---
title: "5. Hardening van een webserver"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2022-2023
---

# Firewall-configuratie

## Firewall-instellingen aanpassen

```console
$ sudo systemctl status firewalld  # is de firewall actief?
$ sudo firewall-cmd --list-all     # = toon firewall-regels
$ sudo firewall-cmd --add-service http --permanent
$ sudo firewall-cmd --add-service https --permanent
$ sudo firewall-cmd --reload
```

Probeer opnieuw de website te bekijken vanaf de Linux Mint VM.

<https://192.168.76.2/>

## Zones

- Zone = lijst van regels voor een specifieke situatie
    - bv. in een publieke ruimte (standaard), thuisnetwerk, werk, ...
- Netwerkkaarten worden toegekend aan een zone
- Vooral nuttig voor laptop
    - Server: `public` zone is meestal voldoende

---

| Task                            | Command                              |
| :------------------------------ | :----------------------------------- |
| Toon alle zones                 | `firewall-cmd --get-zones`           |
| Actieve zones                   | `firewall-cmd --get-active-zones`    |
| Voeg IFACE toe aan actieve zone | `firewall-cmd --add-interface=IFACE` |
| Toon huidige regels             | `firewall-cmd --list-all`            |

Voor `firewall-cmd` moet je *root-rechten* hebben!

## Firewall-regels instellen

| Task                          | Command                            |
| :---------------------------- | :--------------------------------- |
| Laat service toe              | `firewall-cmd --add-service=http`  |
| Toon beschikbare services     | `firewall-cmd --get-services`      |
| Laat poort toe                | `firewall-cmd --add-port=8080/tcp` |
| Firewall-regels herladen      | `firewall-cmd --reload`            |
| Alle netwerkverkeer blokkeren | `firewall-cmd --panic-on`          |
| Paniekmodus uitschakelen      | `firewall-cmd --panic-off`         |

## Persistente wijzigingen

- `--permanent` optie wordt niet onmiddellijk toegepast!
- Twee werkwijzen:
    1. Commando 2x uitvoeren, 1x zonder, 1x mét `--permanent`
    2. Commando enkel met `--permanent` uitvoeren, firewall herladen

```console
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
```

# Security Enhanced Linux

## SELinux

- SELinux: Security Enhanced Linux
    - "Mandatory Access Control"
    - Ingebouwd in de Linux kernel
    - Vooral op RedHat!
- AppArmor:
    - equivalent op Debian/Ubuntu
    - niet behandeld in deze cursus

## Staat SELinux aan?

```console
[admin@server ~]$ getenforce 
Enforcing
```

---

Let op! Dit werkt niet op de Linux Mint-VM!

```console
osboxes@osboxes:~$ getenforce

Command 'getenforce' not found, but can be installed with:

sudo apt install selinux-utils

osboxes@osboxes:~$ sudo aa-status
[sudo] password for osboxes:
apparmor module is loaded.
22 profiles are loaded.
[...]
```

## Hoofdconfiguratiebestand

```console
[admin@server ~]$ cat /etc/selinux/config
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected. 
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

## Zet SELinux niet uit!

Op productie-systemen zou SELinux altijd aan moeten staan!

<https://stopdisablingselinux.com/>

## 3 soorten SELinux-instellingen

- Booleans: `getsebool`, `setsebool`
- Contexts, labels: `ls -Z`, `chcon`, `restorecon`
- Policy modules: `sepolicy`

In de meeste gevallen is configuratie van booleans/context voldoende!

## Controleer de context van een bestand

- Wat is de SELinux-context van een bestand?
    - `ls -lZ`
- Wat wordt de SELinux-context bij aanmaken van een nieuw bestand?
    - `/etc/selinux/targeted/contexts/files/files_contexts`
- Standaard-context herstellen:
    - `sudo restorecon -R /var/www/`
- Context instellen naar een bepaalde waarde:
    - `sudo chcon -t httpd_sys_content_t test.php`

## Check booleans

`getsebool -a | grep http`

- Know the relevant booleans! (RedHat manuals)
- Enable boolean:
    - `sudo setsebool -P httpd_can_network_connect_db on`

## Hoe weet ik wat SELinux tegenhoudt?

```console
$ sudo tail -f /var/log/audit/audit.log
$ sudo grep denied /var/log/audit/audit.log
```
