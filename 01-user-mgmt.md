---
title: "1. User management"
subtitle: "HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# Permissies (herhaling)

## Bestandspermissies (1)

= toegangsrechten voor bestanden en directories

- Bestanden zijn eigendom van een gebruiker en groep
- cfr. `ls -l` voor een overzicht

## Bestandspermissies (2)

Instelbaar op niveau van:

- `u`: gebruiker, **u**ser
- `g`: groep, **g**roup
- `o`: andere gebruikers, **o**thers
- `a`: iedereen, **a**ll

## Soorten permissies

- `r`: lezen, **r**ead
- `w`: schrijven, **w**rite
- `x`: e**x**ecute
    - bestand: uitvoeren als commando
    - directory: toegang met `cd`

## Instellen met symbolische notatie

permissies instellen met `chmod`, symbolische notatie

```text
chmod MODUS FILE
chmod u+r FILE
      g-w
      o=x
      a
```

Voorbeelden:

- `chmod g+rw bestand`
- `chmod +x bestand`
- `chmod u+rw,g+r,o-rw bestand`
- `chmod a=r bestand`

## Instellen met octale notatie

```text
  u      g      o
r w x  r - x  - - -
1 1 1  1 0 1  0 0 0
4+2+1  4+0+1  0+0+0
  7      5      0
```

Voorbeelden:

- `chmod 755 script`
- `chmod 600 file`
- `chmod 644 file`
- `chmod 775 dir`

## Merk op

- sommige permissie-combinaties komen nooit voor in de praktijk, bv. 1, 2, 3
- directories: altijd lezen (r) en execute (x) *samen* toekennen of afnemen
- permissies owner ≥ group ≥ others
- `root` negeert bestandspermissies (mag alles), vb. `/etc/shadow`
- tip: octale permissies opvragen: `stat -c %a BESTAND`

# Speciale Permissies

## Permissies van nieuwe bestanden: `umask`

- `umask` bepaalt permissies van bestand/directory bij aanmaken
- huidige waarde opvragen: `umask` zonder opties
- opgegeven in octale notatie
    - enkel 0, 2 en 7 zijn zinvol
- welke permissies *afnemen*
    - bestand krijgt nooit execute-permissie

## Voorbeeld `umask`

`umask 0027`, wat worden de permissies?

```text
  file      directory

  0 6 6 6     0 7 7 7      basis
- 0 0 2 7   - 0 0 2 7      umask
---------   ---------
  0 6 4 0     0 7 5 0      permissies
```

## Speciale permissies: *SETUID*

- set user ID (*SETUID*)
- op bestanden met execute-permissies
- tijdens uitvoeren krijgt de gebruiker de rechten van de eigenaar van het bestand
- symbolisch: `u+s`
- octaal: 4

```bash
$ ls -l /bin/passwd
-rwsr-xr-x. 1 root root 28k 2017-02-11 12:02 /bin/passwd
```

## Speciale permissies: *SETGID*

- set group ID (*SETGID*)
- op bestanden met execute-permissies
- tijdens uitvoeren krijgt de gebruiker de rechten van de groep van het bestand
- symbolisch: `g+s`
- octaal: 2

```bash
$ ls -l /usr/bin/write 
-rwxr-sr-x. 1 root tty 20k 2017-09-22 10:55 /usr/bin/write
```

## Speciale permissies: *SGID*

- Set Group ID kan ook op directories
- Nieuwe bestanden binnen de directory worden toegekend aan de groep van die directory

```console
$ mkdir /tmp/testdir
$ sudo chgrp users /tmp/testdir
$ touch /tmp/testdir/nosetguid
$ sudo chmod g+s /tmp/testdir/
$ touch /tmp/testdir/setguid
$ ls -l /tmp/testdir/
total 0
-rw-r--r--. 1 osboxes osboxes  0 2022-09-19 23:39 nosetguid
-rw-r--r--. 1 osboxes users    0 2022-09-19 23:39 setguid
```

## Speciale permissies: *restricted deletion*

- restricted deletion, of *sticky bit*
- toegepast op directories
- een bestand mag in zo'n directory enkel door de eigenaar verwijderd worden
- symbolisch: `+t`
- octaal: 1

```bash
ls -ld /tmp
drwxrwxrwt. 16 root root 360 2017-12-04 13:05 /tmp/
```

# Beheer van gebruikers

## Commando's voor gebruikers en groepen

- Gebruikers: `useradd`, `usermod`, `userdel`
- Groepen: `groupadd`, `groupmod`, `groupdel`
- Info opvragen: `who`, `groups`, `id`

## Configuratiebestanden

- Gebruikers: `/etc/passwd`, `/etc/shadow`
- Groepen: `/etc/group`, (`/etc/gshadow`, van weinig belang)

---

- bekijk het verschil in permissies tussen deze drie bestanden
- het wachtwoord van een gebruiker komt **niet** voor in `/etc/passwd`

## Primaire vs aanvullende groepen

- Primaire groep: 4e veld van `/etc/passwd` (group ID)
- Aanvullende groepen: in `/etc/group`. Gebruiker staat niet vermeld in de primaire groep!

---

*primaire* groep aanpassen

```bash
sudo usermod -g groep gebruiker
```

gebruiker toevoegen aan opgegeven groepen *en verwijderen uit alle andere groepen*

```bash
sudo usermod -G groep1,groep2 gebruiker
```

gebruiker toevoegen aan opgegeven groep, blijft lid van andere groepen

```bash
sudo usermod -aG groep gebruiker
```

## Eigenaar/groep veranderen:

Merk op: root-rechten nodig

```console
chown user file
chown user:group file
chgrp group file
```

## root of administrator

- `root` oorspronkelijk de enige administrator van het systeem
- `sudo` kan root rechten verlenen aan een gebruiker
    - voor een bepaald commando
    - voor alle commando's 
- `/etc/sudoers` tells you who can be admin
    - group `sudo` in Ubuntu/Debian distro
    - group `wheel` in Fedora/RedHat distro

## wachtwoord

eigen wachtwoord aanpassen

```bash
passwd
```

wachtwoord aanpassen van een gebruiker als administrator

```bash
sudo passwd <username>
```

wachtwoord genereren in hash vorm (zoals in `/etc/shadow`)

```bash
openssl passwd -6 -salt <salt-string> <desired passwd>
e.g.
openssl passwd -6 -salt hogent nieuwWachtWoord
```
