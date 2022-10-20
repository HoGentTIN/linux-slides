---
title: "5. Advanced Data Parsing"
subtitle: "Linux (for data Scientists)<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2022-2023
---

# Pattern matching

## Globbing vs Regex

2 gangbare manieren om tekstpatronen te definiëren:

- Globbing (wildcards): `man 7 glob`
- Reguliere expressies (regex): `man 7 regex`

## Globbing

- Meestal om meerdere bestanden aan te duiden
- Soms ook op andere plaatsen!
- Eenvoudiger/minder mogelijkheden dan regex!

~~`ls | grep 'txt$'`~~ → `ls *.txt`

## Globbing syntax

- `?` Eén willekeurig karakter
- `*` Een willekeurige string (incl. lege string)
- `[...]` Een reeks karakters (bv. `[abc]` of `[a-c]`)
- `[!...]` Een reeks niet toegelaten karakters

## Voorbeelden

- `ls *.md`: toon alle Markdown-bestanden
- `ls [A-Z]*.md`: toon alle Markdown-bestanden waarvan de naam begint met een hoofdletter
- `ls [0-9][0-9]-*.md`: toon alle Markdown bestanden waarvan de naam begint met twee cijfers gevolgd door een streepje
    - bv. 00-index.md, 01-intro.md, ...

---

- `ls /usr/bin/[!a-z]*`: toon alle commando's die *niet* met een kleine letter beginnen
    - bv. `/usr/bin/[`, `/usr/bin/7z`, enz.
- `ls -d /usr/share/man/man?`: toon alle directories onder `/usr/share/man`, gevolgd door nog een enkel karakter
    - bv. `man1`, `man7`, `mann`
- `apt list --installed 'lib*'`: toon alle geïnstalleerde packages met programmabibliotheken

# Advanced AWK

## AWK

- AWK = Aho, Weinberger & Kernighan
- Dateert van 1977!
- POSIX standaard => altijd aanwezig op UNIX-achtig OS
- Soms handiger dan Python voor specifieke taken

## 95% van gebruik van AWK

```console
$ ip -br a | awk '{ print $3 }'
127.0.0.1/8
10.0.2.15/24
```

```console
awk -F: '{print $1,$3}' /etc/passwd
```

---

![Source: https://wizardzines.com/comics/awk/](https://wizardzines.com/comics/awk/awk.png)

## Basisstructuur

- `{action}` → Voer uit voor elke lijn
- `/regex/ { action }` → Voer enkel uit als regex overeenkomt
- `condition { action }` → Voer enkel uit als voorwaarde voldaan is
- Geen actie: `{ print }` wordt verondersteld

vb. `awk -F: '$3 >= 1000' /etc/passwd`

## BEGIN, END

- `BEGIN { ... }` → Voer 1x uit, vóór verwerken input
- `END { ... }` → Voer 1x uit, na verwerken input

## Voorbeeld

Bereken de som van (alle getallen in) kolom 3

```awk
{s += $3}
END { print s }
```

- Initialisatie variabele `s=0` geïmpliceerd!
- `$3` wordt automatisch geïnterpreteerd als getal!

## Nuttige voorgedefinieerde variabelen

- `FNR` Huidige lijnnummer
- `FS` *Field Separator* (equivalent van optie `-F`)
- `NF` *Number Fields* (aantal kolommen)
- `NR` *Number of Records* (aantal lijnen)
- `OFS` *Output Field separator*

---

Print de laatste kolom:

```awk -F: '{print $NF}' /etc/passwd

Bereken het gemiddelde van kolom 3 in een CSV-bestand:

```awk
BEGIN { FS="," }    # This is a CSV file
{s += $3}           # Calculate sum of column 3
END { print s/NR }  # Print mean
```

## Awk scripts

Voorbeeld: `users.awk`

```awk
#! /usr/bin/awk -f
BEGIN {FS=":"}
{ print $1, $3}
```

Uitvoeren met:

```console
$ chmod +x users.awk
$ ./users.awk < /etc/passwd
root 0
bin 1
...
osboxes 1000
```

## Arrays en dictionaries

Bereken de som van kolommen 2, 3 en 4:

```awk
#! /usr/bin/awk -f
{
    sums[$2] += $2
    sums[$3] += $3
    sums[$4] += $4
}
END {
    for(s in sums)
        print s, sums[s]
}
```

---

Print de *user shells* in `/etc/passwsd` en tel hoeveel elk voorkomt

```awk
#! /usr/bin/awk -f
# countshells.awk
BEGIN { FS=":" }
{ shells[$NF]++ }
END {
    for (s in shells)
        printf "%4s\t%s\n", shells[s], s
}
```

## Meer weten?

- Free Software Foundation (2022) *[The GNU Awk User’s Guide](https://www.gnu.org/software/gawk/manual/html_node/)*
- Herbst, M. (2016) *[Introduction to AWK programming](https://michael-herbst.com/teaching/introduction-to-awk-programming-2016/)*

# JSON parsing: jq