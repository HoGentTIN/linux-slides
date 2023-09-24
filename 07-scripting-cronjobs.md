---
title: "7. Complexe scripts, cronjobs"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2023-2024
---

# Complexere scripts

## Communicatie script/omgeving

Informatie uitwisselen tussen script en omgeving:

- I/O: `stdin`, `stdout`, `stderr`
- Positionele parameters: `$1`, `$2`, enz.
- Exit-status (0-255)
- Omgevingsvariabelen, vb:

```bash
VAGRANT_LOG=debug vagrant up
```

## Functies in Bash

```bash
functie_naam() {
    # code
}
```

Een functie gedraagt zich als een script!

- oproepen: `functie_naam arg1 arg2 arg3`
- positionele parameters: `${1}`, `${2}`, enz.
- `return STATUS` ipv `exit`

## Scope variabelen bij functies - global

Wat is de uitvoer van dit script?

```bash
#! /usr/bin/env bash
var_a=a

foo() {
  var_b=b
  echo "${var_a} ${var_b}"
}

foo

echo "${var_a} ${var_b}"
```

## Scope variabelen bij functies - local

Wat is de uitvoer van dit script?

```bash
#! /usr/bin/env bash
var_a=a

foo() {
  local var_b=b
  echo "${var_a} ${var_b}"
}

foo

echo "${var_a} ${var_b}"
```

## Functies in Bash: voorbeeld

```bash
# Usage: copy_iso_to_usb ISO_FILE DEVICE
# Copy an ISO file to a USB device, showing progress with pv (pipe viewer)
# e.g. copy_iso_to_usb FedoraWorkstation.iso /dev/sdc
copy_iso_to_usb() {
  local iso="${1}"
  local destination="${2}"
  local iso_size

  iso_size=$(stat -c '%s' "${iso}")

  printf "Copying %s (%'dB) to %s\n" \
    "${iso}" "${iso_size}" "${destination}"

  dd if="${iso}" \
    | pv --size "${iso_size}" \
    | sudo dd of="${destination}"
}
```

## Parameter substitution

Zie [Parameter Substitution](https://tldp.org/LDP/abs/html/parameter-substitution.html) in de *Advanced Bash-Scripting Guide*.

```bash
var="Hello world!"
echo "${other_var:-default}" # default
echo "${var,,}"              # hello world! (lowercase)
echo "${var^^}"              # HELLO WORLD!
echo "${var//o/a}"           # Hella warld!
echo "${var:2}"              # llo world!
echo "${var:6:5}"            # world
```

## Parameter substitution (2)

Verwijder patroon van begin/einde van een string:

```bash
path="some/path/archive.tar.gz"
echo "${path#*/}"   # path/archive.tar.gz
echo "${path##*/}"  # archive.tar.gz
echo "${path%.*}"   # some/path/archive.tar
echo "${path%%.*}"  # some/path/archive
```

## Case (1)

```bash
case EXPR in
  PATROON1)
    # ...
    ;;
  PATROON2)
    # ...
    ;;
  *)
    # ...
    ;;
esac
```

## Case (2)

```bash
option="${1}"

case "${option}" in
  -h|--help|'-?')
    usage
    exit 0
    ;;
  -v|--verbose)
    verbose=y
    shift
    ;;
  *)
    printf 'Unrecognized option: %s\n' "${option}"
    usage
    exit 1
    ;;
esac
```

## Tips

- Zet positionele parameters om in beschrijvende namen
- Maak lijnen niet te lang (gebruik `\` op het einde van een regel)
- Gebruik "lange" opties: maakt script leesbaarder
- Gebruik lokale variabelen in functies
- Deel script op in (herbruikbare) functies

# Plannen van systeembeheertaken: cronjobs

## Processen op de achtergrond

Probeer dit:

```console
$ vi test.txt
Ctrl+Z

[1]+  Stopped                 gvim -v test.txt
$ bg
[1]+ sleep 30 &

$ find / -type f > all-files.txt 2>&1 &
[2] 4321
```

- `Ctrl+Z` zet de uitvoer van een proces stil (nog niet afgesloten!)
- `bg` start het proces terug op, maar in de achtergrond
- `&` op het einde van een regel start proces op de achtergrond
   = combinatie van `Ctrl+Z` en `bg`

## Achtergrondprocessen beheren

| Commando  | Betekenis                                 |
| :-------- | :---------------------------------------- |
| `jobs`    | Lijst van achtergrondprocessen            |
| `jobs -l` | Idem, toon ook Process ID (PID)           |
| `fg NUM`  | Breng proces op voorgrond                 |
| `bg NUM`  | Herstart stilgelegd proces op achtergrond |

## Processen eenmalig plannen

Probeer dit:

```console
$ at now + 2 minutes
warning: commands will be executed using /bin/sh
at Mon Nov 15 15:47:00 2021
at> date > /tmp/date.txt     
at> <Ctrl+D>
job 9 at Mon Nov 15 15:47:00 2021
$ watch cat /tmp/date.txt
```

- `at` zal binnen 2 minuten het opgegeven commando uitvoeren
- Met `watch` herbekijken we elke 2s de inhoud van het doelbestand

## Processen eenmalig plannen (2)

Nog `at` voorbeelden:

- `at 3:03 AM`
- `at midnight`
- `at 1am tomorrow`
- `at now + 3 weeks`
-...

## Overzicht

| Commando   | Betekenis                                      |
| :--------- | :--------------------------------------------- |
| `at`       | Voer commando's uit op specifiek tijdstip      |
| `atq`      | Geeft lijst van geplande taken                 |
| `atrm NUM` | Verwijder taak met id NUM                      |
| `batch`    | Voer taak uit wanneer systeem minder belast is |

## Processen herhaald plannen: cron

- Bekijk `/etc/crontab`
- Bevat taken die regelmatig gepland worden:
    - tijdsaanduiding
    - commando
- Crontab per gebruiker:
    - tonen: `crontab -l`
    - bewerken: `crontab -e`

## Tijdsaanduiding

| Veld | Beschrijving     | Waarden |
| :--- | :--------------- | :------ |
| MIN  | Minuten          | 0-59    |
| HOUR | Uren             | 0-23    |
| DOM  | Dag van de maand | 1-31    |
| MON  | Maand            | 1-12    |
| DOW  | Dag van de week  | 0-7     |
| CMD  | Commando         |         |

Dag van de week: zo = 0/7, ma = 1, di = 2, ...

## Voorbeelden

```text
# use /bin/sh to run commands, no matter what /etc/passwd says
SHELL=/bin/sh
# mail any output to `paul', no matter whose crontab this is
MAILTO=paul
# Set time zone
CRON_TZ=Japan
# run five minutes after midnight, every day
5 0 * * *       $HOME/bin/daily.job >> $HOME/tmp/out 2>&1
# run at 2:15pm on the first of every month -- output mailed to paul
15 14 1 * *     $HOME/bin/monthly
# run at 10 pm on weekdays, annoy Joe
0 22 * * 1-5    mail -s "It's 10pm" joe%Joe,%%Where are your kids?%
23 0-23/2 * * * echo "run 23 minutes after midn, 2am, 4am ..., everyday"
5 4 * * sun     echo "run at 5 after 4 every sunday"
```
