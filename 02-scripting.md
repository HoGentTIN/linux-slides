---
title: "2. Scripting"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Intro Bash scripts

## Een script schrijven

1. Maak bestand aan (bv. `script.sh`) met een teksteditor, bv.

    ```bash
    #! /bin/bash
    echo "Hallo ${USER}"
    ```

2. Maak bestand uitvoerbaar: `chmod +x script.sh`
3. Voer uit: `./script.sh`

## De "shebang"

- Eerste regel van een script
- Begint met `#!` (`#` = hash; `!` = bang)
- Absoluut pad naar de interpreter voor het script, bv:
    - `#! /usr/bin/python`
    - `#! /usr/bin/ruby`
    - `#! /usr/bin/env bash`
        - = zoek in `${PATH}` naar `bash`

## Tekst afdrukken

Wat is het verschil?

```bash
var="world"

echo "Hello ${var}"
echo 'Hello ${var}'
```

---

```bash
var="world"

echo "Hello ${var}"    # Binnen " " wordt substitutie toegepast
echo 'Hello ${var}'    # Binnen ' ' NIET!
```

## Gebruik `printf`

`printf` is beter dan `echo`

```bash
var="world"

printf 'Hello %s\n' "${var}"
```

- Het gedrag is beter gedefinieerd over verschillende UNIX-varianten.
- Vgl. `printf()` method in Java!

## Fouten opsporen (1)

- Werk altijd **stap voor stap**
- **Test** voortdurend het resultaat van elke wijziging
- Hou minstens **2 vensters** open naast elkaar:
    - Editor
    - Terminal voor testen

## Fouten opsporen (2)

- Syntax check: `bash -n script.sh`
- ShellCheck: `shellcheck script.sh`
    - Gebruik editor-plugin waar mogelijk
- Druk veel info af (`printf`)
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

## Variabelen

Bash-variabelen zijn (meestal) strings.

- Declaratie: `variabele=waarde`
    - **geen** spaties rond `=`
- Waarde v/e variabele opvragen: `${variable}`
- Gebruik in strings (met dubbele aanhalingstekens):

```bash
echo "Hello ${USER}"
```

## Variabelen: codestijl

- Gebruik zoveel mogelijk de notatie `${var}`
    - *accolades*
- Gebruik dubbele aanhalingstekens: `"${var}"`
    - vermijd *splitsen* van woorden

```bash
bestand="Mijn bestand.txt"
touch ${bestand}        # Fout
touch "${bestand}"      # Juist
```

## Onbestaande variabelen opvragen

- Onbestaande variabele wordt beschouwd als *lege string*.
    - Oorzaak van veel fouten in shell-scripts!
    - `set -o nounset` ⇒ script afbreken

## Zichtbaarheid variabelen (scope)

Enkel binnen zelfde "shell", niet binnen "subshells"

- Een script oproepen creëert een subshell
- Maak "globale", of *omgevingsvariabele* met `export`:

```bash
export VARIABLE1=value

VARIABLE2=value
export VARIABLE2
```

## Variabelen: naamgeving

Conventie naamgeving:

- Lokale variabelen: kleine letters, bv: `foo_bar`
- Omgevingsvariabelen: hoofdletters, bv. `FOO_BAR`

# Opzetten werkomgeving

## Github-repo voor labo-taken aanmaken

TODO

## Configuratie Git

TODO

## Oplossingen testen

TODO