---
title: "4.1. Installatie van een webserver (Debian)"
subtitle: "Linux for Data Scientists<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# Webserver installatie

## Doelstelling

- LAMP-stack: **L**inux + **A**pache + **M**ariaDB + **P**HP
- Website bekijken in de browser

## Installatie software

```bash
$ sudo apt install apache2 mariadb-server php
```

## Belangrijke directories

- `/etc/apache2/`: configuratie Apache
    - `/etc/httpd/apache2.conf`
    - `/etc/httpd/conf-enabled/*.conf`
    - `/etc/httpd/mods-enabled/*.conf`
    - `/etc/httpd/sites-enabled/*.conf`
- `/var/www/html/`: Apache DocumentRoot
- `/var/log/apache2/`: logbestanden
    - `access.log`
    - `error.log`

## Services beheren

- Bij installatie worden services automatisch opgestart
- Na rebooten eveneens
- Controleer!
    - `systemctl status mariadb`
    - `systemctl status apache2`
    - `ss -tlnp`

## Het commando systemctl

```bash
$ sudo systemctl start <service>
$ sudo systemctl stop <service>
$ sudo systemctl restart <service>
$ sudo systemctl enable <service>
$ sudo systemctl disable <service>
```

## Het commando ss

ss = Show Sockets

| Task                 | Command                |
| :---                 | :---                   |
| Show server sockets  | `ss -l`, `--listening` |
| Show TCP sockets     | `ss -t`, `--tcp`       |
| Show UDP sockets     | `ss -u`, `--udp`       |
| Show port numbers(*) | `ss -n`, `--numeric`   |
| Show process(†)      | `ss -p`, `--processes` |

(*) instead of service names from `/etc/services`

(†) *root permissions* required

## Voorbeeld

```console
linuxmint@linuxmint21:~$ sudo ss -tlnp
State   Recv-Q  Send-Q  Local Address:Port  Peer Address:Port  Process
LISTEN  0       80          127.0.0.1:3306       0.0.0.0:*      users:(("mariadbd",pid=45957,fd=20))
LISTEN  0       128           0.0.0.0:22         0.0.0.0:*      users:(("sshd",pid=850,fd=3))
LISTEN  0       511                 *:80               *:*      users:(("apache2",pid=52633,fd=4),[...])
LISTEN  0       128              [::]:22            [::]:*      users:(("sshd",pid=850,fd=4)) 
```

## Test de services

- CLI webbrowser *op de VM*
    - surf naar <http://localhost/>
```bash
curl localhost
curl 127.0.0.1
```

- PHP testen: maak bestand
  `/var/www/html/info.php`
- Surf naar: <http://localhost/info.php>

```php
<?php phpinfo(); ?>
```

## Logbestanden

Voorbeeld voor Apache:

```console
$ sudo journalctl
$ sudo journalctl -u apache2
$ sudo journalctl -flu apache2
$ sudo tail -f /var/log/apache2/access_log
$ sudo tail -f /var/log/apache2/error_log
```

## `journalctl`

- `journalctl` vereist *root*-permissies
    - Of voeg gebruiker toe aan groep `adm` of `systemd-journal`
- Andere logbestanden:
    - `/var/log/syslog` (hoofd-logbestand)
    - `/var/log/dmesg` (log bootproces)
    - ...

## Options

| Action                               | Command                                   |
| :---                                 | :---                                      |
| Show latest log and wait for changes | `journalctl -f`, `--follow`               |
| Show only log of SERVICE             | `journalctl -u SERVICE`, `--unit=SERVICE` |
| Match executable, e.g. `dhclient`    | `journalctl /usr/sbin/dhclient`           |
| Match device node, e.g. `/dev/sda`   | `journalctl /dev/sda`                     |
| Show auditd logs                     | `journalctl _TRANSPORT=audit`             |

---

| Action                         | Command                               |
| :---                           | :---                                  |
| Show log since last boot       | `journalctl -b`, `--boot`             |
| Kernel messages (like `dmesg`) | `journalctl -k`, `--dmesg`            |
| Reverse output (newest first)  | `journalctl -r`, `--reverse`          |
| Show only errors and worse     | `journalctl -p err`, `--priority=err` |
| Since yesterday                | `journalctl --since=yesterday`        |

---

Filter on time (example):

```console
journalctl --since=2018-06-00 \
           --until="2018-06-07 12:00:00"
```

Much more options in the man-page!

## Website vanaf fysiek systeem bekijken

- Controleer IP-adres VM: `ip a`
    - VBox NAT-interface: 10.0.2.15
- Stel port forwarding regels in
- Open webbrowser *op fysiek systeem*
    - surf naar <http://127.0.0.1:8080/info.php>

---

![Port-forwarding](assets/webserver-portforwarding.png)

## Database beveiligen

```bash
$ sudo mysql_secure_installation
```

- Volg de instructies!
- (optioneel) kies MariaDB root-wachtwoord
    - ≠ wachtwoord Linux root!
- bevestig andere vragen (ENTER)

**Hou je wachtwoorden goed bij!**

## Database testen: root

```bash
$ sudo mysql mysql
...
MariaDB [mysql]> SHOW DATABASES;
MariaDB [mysql]> SELECT user,password from user;
MariaDB [mysql]> quit
```

- `sudo` => inloggen als MariaDB-root
- `mysql`: inloggen op database `mysql`

## Labo-oefening

Ga nu zelf verder met de labo-oefening! Leerpad 4.4.1