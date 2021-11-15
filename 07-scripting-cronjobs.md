---
title: "7. Complexe scripts, cronjobs"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
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

## Scope variabelen bij functies

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
  -h|--help|-?)
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

Meer tips op: <https://gitpitch.com/bertvv/presentation-clean-bash>

# Plannen van systeembeheertaken: cronjobs

## TODO
