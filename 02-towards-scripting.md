---
title: "2. Combining commands towards scripting"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Streams, pipes, redirects

## Input en output

![ ](http://linux-training.be/funhtml/images/bash_stdin_stdout_stderr.svg)

- *stdin*, standard input
    - vgl. Java `System.in`
- *stdout*, standard output
    - vgl. `System.out`
- *stderr*, standard error
    - vgl. `System.err`

## Normaal gedrag

- *standard input*: invoer toetsenbord
- *standard output/error*: afdrukken op scherm (console)

![ ](http://linux-training.be/funhtml/images/bash_ioredirection_keyboard_display.png)

## I/O Redirection (1)

| Syntax        | Betekenis                                          |
| :------------ | :------------------------------------------------- |
| `cmd > file`  | schrijf uitvoer van `cmd` weg naar `file`          |
| `cmd >> file` | voeg toe aan einde van `file`                      |
| `cmd 2> file` | schrijf foutboodschappen van `cmd` weg naar `file` |
| `cmd < file`  | gebruik inhoud van `file` als invoer voor `cmd`    |
| `cmd1 | cmd2` | gebruik uitvoer van `cmd1` als invoer voor `cmd2`  |

## I/O Redirection (2)

`cmd > file`

![ ](http://linux-training.be/funhtml/images/bash_output_redirection.png)

## I/O Redirection (3)

`cmd 2> file`

![ ](http://linux-training.be/funhtml/images/bash_error_redirection.png)

## Pipes

Probeer het volgende eens!

```console
$ sudo apt install fortune cowsay lolcat figlet
$ echo ${USER} | figlet
$ fortune
$ fortune | cowsay
$ fortune | cowsay | lolcat
```

## Combineren

```bash
# stdout en stderr apart wegschrijven
find / -type d > directories.txt 2> errors.txt

# stderr "negeren"
find / -type d > directories.txt 2> /dev/null

# stdout en stderr samen wegschrijven
find / -type d > all.txt 2>&1

# invoer én uitvoer omleiden
sort < unsorted.txt > sorted.txt 2> errors.txt
```

## Foutboodschappen afdrukken

(Equivalent van [System.err.printf()](https://docs.oracle.com/javase/7/docs/api/java/io/PrintStream.html#printf(java.lang.String,%20java.lang.Object...)))

```bash
printf 'Error: %s is not a directory\n' "${dir}" >&2
```

## Here documents (1)

Als je meer dan één lijn wil afdrukken:

```bash
cat << _EOF_
Usage: ${0} [OPT]... [ARG]..

OPTIONS:
  -h, --help  Print this help message

_EOF_
```

*Let op:* geen spaties toegelaten vóór de eindemarkering

## Here documents (2)

Dit kan bv. ook:

```bash
mysql -uroot -p"${db_password}" mysql << _EOF_
DROP DATABASE IF EXISTS drupal;
CREATE DATABASE drupal;
GRANT ALL PRIVILEGES ON drupal TO ${drupal_usr}@localhost
  IDENTIFIED BY ${drupal_password};
_EOF_
```


# Filters

## Filters

- Filter = commando dat:
    1. leest van `stdin` of bestand,
    2. tekst transformeert, en
    3. wegschrijft naar `stdout`
- Combineer filters via `|` (pipe) om complexe bewerkingen op tekst toe te passen
    - De *UNIX-filosofie*

## Filters: overzicht (1)

| Commando | Doel                                                          |
| :------- | :------------------------------------------------------------ |
| `awk`    | Veelzijdige tool voor bewerken van tekst                      |
| `cat`    | Druk inhoud bestand(en) af op stdout                          |
| `cut`    | Selecteer "kolommen" uit tekstbestanden                       |
| `fmt`    | Herformatteer tekst (bv. bepaald aantal kolommen)             |
| `grep`   | Zoek ahv reguliere expressies naar tekstpatronen in bestanden |
| `head`   | Toon de eerste regels van een tekstbestand                    |

## Filters: overzicht (2)

| Commando | Doel                                                            |
| :------- | :-------------------------------------------------------------- |
| `join`   | Voeg twee tekstbestanden samen ahv een gemeenschappelijke kolom |
| `nl`     | Voeg regelnummers toe aan een bestand                           |
| `paste`  | Voeg twee tekstbestanden regel per regel samen                  |
| `sed`    | Veelzijdige tool voor bewerken van tekst (Stream EDitor)        |

## Filters: overzicht (3)

| Commando | Doel                                                    |
| :------- | :------------------------------------------------------ |
| `sort`   | Sorteer tekst                                           |
| `tail`   | Toon de laatste regels van een tekstbestand             |
| `tr`     | Zoek en vervang lettertekens in tekst                   |
| `uniq`   | Verwijder dubbele rijen uit een gesorteerd tekstbestand |
| `wc`     | Tel karakters, woorden of lijnen in een tekstbestand    |

## Filters: voorbeelden

```bash
# Invoer uit bestand
grep 'Williams' tennis.txt
sort -k2 tennis.txt

# Invoer via stdin
cat tennis.txt | grep 'Williams'
cat tennis.txt | tr 'a-z' 'A-Z'

# Combinatie
sort music.txt | uniq
```

## Sed: voorbeelden

```bash
# Zoeken en vervangen (1x per regel)
sed 's/foo/bar/'

# "Globaal", meerdere keren per regel
sed 's/foo/bar/g'

# Regels die beginnen met '#' verwijderen
sed '/^#/d'

# Lege regels verwijderen
sed '/^$/d'
```

## Awk: voorbeelden

Wat tussen accolades staat wordt uitgevoerd op elke regel

```bash
# Druk 4e kolom af (afgebakend door "whitespace")
awk '{ print $4 }'

# Enkel regels afdrukken die beginnen met #
awk '/^#/ { print $0 }'

# Druk kolom 2 en 4 af, gescheiden door ;
awk '{ printf "%s;%s", $2, $4 }'
```

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

# [Xtra]: vi(m) vs nano

## Hoe maak je een bestand aan?

1. Met teksteditor Vi/Vim: `vim bestand.txt`
2. Met teksteditor Nano: `nano bestand.txt`
3. Leeg bestand: `touch bestand.txt`

## Vim survival guide

- Bij opstarten van Vim kom je terecht in *normal mode*.
- Als je tekst wil invoeren moet je naar *insert mode*.

| Taak                       | Commando |
| :------------------------- | :------- |
| Normal mode -> insert mode | `i`      |
| Insert mode -> normal mode | `<Esc>`  |
| Opslaan                    | `:w`     |
| Opslaan en afsluiten       | `:wq`    |
| Afsluiten zonder opslaan   | `:q!`    |


---

Steep learning curve, great tool!

```bash
sudo apt install vim-runtime
vimtutor
```
## Nano

- Ook een command-line teksteditor
- Iets toegankelijker dan Vim
- Shortcuts staan onderaan het scherm
    - vb. Exit: `^X` -> Ctrl+X

