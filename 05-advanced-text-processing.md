---
title: "5. Advanced Text Processing"
subtitle: "Linux (for data Scientists)<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# Pattern matching

## Globbing vs Regex

2 gangbare manieren om tekstpatronen te definiëren:

- Globbing (wildcards): `man 7 glob`
- Reguliere expressies (regex): `man 7 regex`

## Meerdere bestanden opgeven: globbing

Commando uitvoeren op meer dan 1 bestand?

- Geef elk bestand apart op (spatie ertussen)
    - `cp a.txt b.doc c.jpg /tmp`
- Gebruik *globbing*-patronen
    - `cp /media/usbstick/*.jpg ~/Pictures/`

## Globbing-patronen

| Patroon  | Betekenis                      | Voorbeeld           |
|:---------|:-------------------------------|:--------------------|
| `?`      | Eén willekeurig teken          | `ls /bin/??`        |
| `*`      | Willekeurige string (ook leeg) | `ls *.txt`, `ls a*` |
| `[...]`  | Elk teken opgesomd tussen `[]` | `ls /bin/[A+_]*`    |
| `[A-Z]`  | Van A t/m Z                    | `ls /bin/*[A-D1-3]` |
| `[!...]` | *Niet* 1 v/d opgesomde tekens  | `ls /bin/[!a-z]*`   |

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

## Enkele "Anti-patterns"

Gebruik nooit regex om bestanden te selecteren!

```bash
# Fout:
ls /bin | grep 'a.*'
# Beter:
ls /bin/a*
```

In dit soort gevallen is `find` overbodig:

```bash
find . -maxdepth 1 -type f -name 'a*' -exec cp {} /tmp \;
# Beter:
cp a* /tmp
```

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

`awk -F: '{print $NF}' /etc/passwd`

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
    sums[2] += $2
    sums[3] += $3
    sums[4] += $4
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

## jq

> jq is a lightweight and flexible command-line JSON processor.

- filter-commando: input > verwerking > output
- zoals awk/sed, maar dan voor JSON
- niet altijd even makkelijk in gebruik...
- RTFM: <https://stedolan.github.io/jq/manual/>

## jq als "pretty printer"

```console
curl -s 'https://api.github.com/repos/stedolan/jq/commits?per_page=5' | jq
```

of: `jq '.'` (met `.` de *identity operator*)

## Toon enkel eerste element

```console
curl -s 'https://api.github.com/repos/stedolan/jq/commits?per_page=5' | jq '.[0]'
```

(in de volgende voorbeelden: enkel het `jq`-commando)

## Toon enkel specifieke velden

```console
jq '.[0] | {message: .commit.message, name: .commit.committer.name}'
```

- Let op! `|` *binnen* de `jq`-expressie!
- `.key` haalt het `key`-veld op
    - kan ook genest, bv. `.commit.message`

---

```console
jq '.[] | {message: .commit.message, name: .commit.committer.name}'
```

- `.[]` geeft elk element van de array terug
    - Resultaat is geen JSON!
- Als JSON-array: `[]` er rond:

```console
jq '[.[] | {message: .commit.message, name: .commit.committer.name}]'
```

## Array als waarde ophalen

- Veld "parents" (parent commits) kan een array met 1 of meerdere waarden zijn
    - (bv. merge commit heeft 2 parents)

```console
jq '[.[] | {message: .commit.message, name: .commit.committer.name, parents: [.parents[].html_url]}]'
```
