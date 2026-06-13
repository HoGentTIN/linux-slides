---
title: "4.1. Installatie van een webserver (EL)"
subtitle: "Linux for Operations<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem, Jan Willem
date: 2025-2026
---

# Webserver installatie

## Doelstelling

- LAMP-stack: **L**inux + **A**pache + **M**ariaDB + **P**HP
- Website bekijken vanop de andere VM (Linux Mint)

## Installatie software

```bash
$ sudo dnf install httpd mariadb-server php
```

## Belangrijke directories

- `/etc/httpd/`: configuratie Apache
    - `/etc/httpd/conf/httpd.conf`
    - `/etc/httpd/conf.d/*.conf`
- `/var/www/html/`: Apache DocumentRoot
- `/var/log/httpd/`: logbestanden
    - `access_log`
    - `error_log`

## Services opstarten

```bash
$ sudo systemctl enable --now mariadb
$ sudo systemctl enable --now httpd
```

- `enable`: automatisch opstarten bij *booten*
- `--now`: *nu* opstarten (kan ook met `systemctl start`)

## Het commando systemctl

Info opvragen: geen `sudo` nodig

```console
$ systemctl status <service>
$ systemctl is-enabled <service>
$ systemctl is-active <service>
$ systemctl list-units --type=service
$ systemctl list-units --failed
```

---

Toestanden wijzigen: `sudo` vereist!

```console
$ sudo systemctl start <service>
$ sudo systemctl stop <service>
$ sudo systemctl restart <service>
$ sudo systemctl enable <service>
$ sudo systemctl disable <service>
```

## Test de services

```bash
$ systemctl status httpd
$ systemctl status mariadb
```

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

## Het commando ss

`ss` = Show Sockets

| Task                 | Command                |
| :------------------- | :--------------------- |
| Show server sockets  | `ss -l`, `--listening` |
| Show TCP sockets     | `ss -t`, `--tcp`       |
| Show UDP sockets     | `ss -u`, `--udp`       |
| Show port numbers(*) | `ss -n`, `--numeric`   |
| Show process(†)      | `ss -p`, `--processes` |

(*) instead of service names from `/etc/services`

(†) *root permissions* required

## Example

```console
$ sudo ss -tlnp
State   Recv-Q Send-Q Local Address:Port Peer Address:Port
LISTEN  0      128                *:22              *:*    users:(("sshd",pid=1290,fd=3))
LISTEN  0      100        127.0.0.1:25              *:*    users:(("master",pid=1685,fd=13))
LISTEN  0      128               :::80             :::*    users:(("httpd",pid=4403,fd=4),("httpd",pid=4402,fd=4),("httpd",pid=4401,fd=4),("httpd",pid=4400,fd=4),("httpd",pid=4399,fd=4),("httpd",pid=4397,fd=4))
LISTEN  0      128               :::22             :::*    users:(("sshd",pid=1290,fd=4))
LISTEN  0      100              ::1:25             :::*    users:(("master",pid=1685,fd=14))
LISTEN  0      128               :::443            :::*    users:(("httpd",pid=4403,fd=6),("httpd",pid=4402,fd=6),("httpd",pid=4401,fd=6),("httpd",pid=4400,fd=6),("httpd",pid=4399,fd=6),("httpd",pid=4397,fd=6))
```

## Logbestanden

Voorbeeld voor Apache:

```console
$ sudo journalctl
$ sudo journalctl -u httpd
$ sudo journalctl -flu httpd
$ sudo tail -f /var/log/httpd/access_log
$ sudo tail -f /var/log/httpd/error_log
```

## `journalctl`

- `journalctl` kan enkel als `root`/met `sudo`
    - Of, voeg gebruiker toe aan groep `adm` of `systemd-journal`
- Sommige "traditionele" tekstgebaseerde logbestanden bestaan nog steeds (voorlopig?):
    - `/var/log/messages` (verdwenen in Fedora!)
    - `/var/log/httpd/access_log` en `error_log`
    - ...

## Opties

| Actie                               | Commando                                  |
| :---------------------------------- | :---------------------------------------- |
| Toon laatste lijnen en wacht        | `journalctl -f`, `--follow`               |
| Toon enkel log van SERVICE          | `journalctl -u SERVICE`, `--unit=SERVICE` |
| Log voor executable, bv. `dhclient` | `journalctl /usr/sbin/dhclient`           |
| Log voor apparaat, bv. `/dev/sda`   | `journalctl /dev/sda`                     |
| Toon auditd logs                    | `journalctl _TRANSPORT=audit`             |

---

| Actie                               | Commando                              |
| :---------------------------------- | :------------------------------------ |
| Toon log sinds laatste boot         | `journalctl -b`, `--boot`             |
| Kernelberichten (zoals `dmesg`)     | `journalctl -k`, `--dmesg`            |
| Omgekeerde uitvoer (nieuwste eerst) | `journalctl -r`, `--reverse`          |
| Toon alleen fouten en erger         | `journalctl -p err`, `--priority=err` |
| Sinds gisteren                      | `journalctl --since=yesterday`        |

---

Filter op tijd (voorbeeld):

```console
journalctl --since=2018-06-00 \
           --until="2018-06-07 12:00:00"
```

Veel meer opties in de man-pagina!

## Website vanaf Linux GUI VM bekijken

- Controleer IP-adres webserver-VM: `ip a`
- Test route vanaf Linux GUI VM met `ping <IP-adres>`
- Surf vanaf Linux GUI VM naar IP-adres webserver-VM

## Database testen: root

```bash
$ sudo mysql mysql
...
MariaDB [mysql]> SHOW DATABASES;
MariaDB [mysql]> SELECT user,host,password from user;
MariaDB [mysql]> quit
```

- `sudo`: inloggen als MariaDB-root
    - wachtwoord uitgeschakeld
    - kan enkel vanaf localhost met `sudo`
- 2e `mysql`: inloggen op database `mysql`

## Labo-oefening

Ga nu zelf verder met de labo-oefening! Leerpad 4.4.1