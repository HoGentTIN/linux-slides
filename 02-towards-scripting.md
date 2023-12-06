---
title: "2. Combining commands towards scripting 101"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2023-2024
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

## Combineren

```bash
# stdout en stderr apart wegschrijven
find / -type d > directories.txt 2> errors.txt

# stderr "negeren"
find / -type d > directories.txt 2> /dev/null

# stdout en stderr samen wegschrijven
find / -type d > all.txt 2>&1
find / -type d &> all.txt

# invoer én uitvoer omleiden
sort < unsorted.txt > sorted.txt 2> errors.txt
```

## Foutboodschappen afdrukken (op stderr)

```bash
echo "Error: ${dir} is not a directory" >&2
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

## Pipes

Probeer het volgende eens!

```console
$ sudo apt install fortune cowsay lolcat figlet
$ echo ${USER} | figlet
$ fortune
$ fortune | cowsay
$ fortune | cowsay | lolcat
```

## Here strings

```console
echo "Hello world" | figlet
```

Zonder "overbodig" proces/pipe:

```console
figlet <<< "Hello world!"
```

# Filters

## Filtercommando's

- Filter = commando dat:
    1. leest van `stdin` of bestand,
    2. tekst transformeert, en
    3. wegschrijft naar `stdout`
- Combineer filters via `|` (pipe) om complexe bewerkingen op tekst toe te passen
    - De *UNIX-filosofie*

## Filtercommando's (2)

Ofwel bestand meegeven, ofwel stdin

```console
filter file1 file2...

filter < file

cmd | filter
```

Merk op: `cat file | filter` kan je beter anders schrijven!

## I/O redirection naar bestand én stdout

```bash
find / -type d | tee directories.txt
```

`tee` schrijft weg naar bestand én stdout.

## `cat`, `tac` en `shuf`

- `cat`: wat binnenkomt op stdin afdrukken op stdout
- `tac`: idem, maar in omgekeerde volgorde
- `shuf`: in willekeurige volgorde

```console
$ cat file1 file2 > file3
$ tac file1
$ shuf cards.txt
```

## `head` en `tail`

- Toon (10) eerste/laatste regels

```console
$ head /etc/passwd
$ tail -5 /etc/passwd
$ tail -f /var/log/syslog
```

## `cut`, `paste` en `join`

- `cut`: selecteer kolommen uit gestructureerde tekst (bv. CSV)
- `paste`: voeg bestanden regel per regel samen
- `join`: voeg bestanden samen ahv gemeenschappelijke kolom

```console
cut -d: -f1,3-4 /etc/passwd
paste -d';' users.txt passwords.txt
```

---

```console
$ cat foodtypes.txt
1 Protein
2 Carbohydrate

$ cat foods.txt
1 Cheese 
2 Potato

$ join foodtypes.txt foods.txt
1 Protein Cheese
2 Carbohydrate Potato
```

## `sort` en `uniq`

```console
$ sort unsorted.txt
$ uniq -c sorted.txt
```

Welke commando's gebruik ik het vaakst?

```console
$ history | awk '{ print $2 }' | sort | uniq -c | sort -nr | head
```

## `fmt`, `nl` en `wc`

```console
$ fmt -w40 some-file.txt
$ nl script.sh
$ wc thesis.md
$ wc --words thesis.md
$ ls /usr/bin | wc -l
```

## `column`

Invoer in kolommen afdrukken.

```console
$ column -t -s: < /etc/passwd
$ column -J -N user,passwd,uid,gid,name,home,shell -s: < /etc/passwd
```

- `-t`, `--table`: Afdrukken in kolommen
- `-J`, `--json`: Vertalen naar JSON
- `-s`, `--separator`: Input separator
- `-N`, `--table-columns`: namen velden

## `grep`

```console
$ grep root /etc/passwd
$ grep '^#' script.sh
$ sudo grep -i dhcp /var/log/syslog
```

Moet je zoeken in een reeks directories? Gebruik `silversearcher-ag`

```console
$ ag TODO *.java
```

## Buitenbeentje: `tr`

- TRanslate
- Teken per teken ipv lijn per lijn
- Enkel stdin, geen files

```console
$ tr 'A-Z' 'a-z' < UPPERCASE.txt > lowercase.txt
$ tr -d '[:punct:]' < file.txt
```

## De Stream EDitor, `sed`

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

## De AWK-taal

Wat tussen accolades staat wordt uitgevoerd op elke regel

```bash
# Druk 4e kolom af (afgebakend door "whitespace")
awk '{ print $4 }'

# Enkel regels afdrukken die beginnen met #
awk '/^#/ { print $0 }'

# Druk kolom 2 en 4 af, gescheiden door ;
awk '{ printf "%s;%s", $2, $4 }'

# Druk de namen van de "gewone" gebruikers af
awk -F: '{ if($3 > 1000) print $1 }' /etc/passwd
```

## Code smells

Vermijd opstart van overbodige processen:

```bash
# Overbodige `cat`!
cat bestand | filter
# Beter:
filter bestand

# Overbodige `echo`!
echo "String" | filter
# Beter: here string
filter <<< "String"
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
