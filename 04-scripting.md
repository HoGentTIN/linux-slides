---
title: "4.2. Scripting 102"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# Scripting (vervolg)

## Positionele parameters

Bij uitvoeren van script zijn opties en argumenten beschikbaar via variabelen, *positionele parameters*

| Variabele           | Betekenis                                  |
|:--------------------|:-------------------------------------------|
| `${0}`              | Naam script                                |
| `${1}`, `${2}`, ... | Eerste, tweede, ... argument               |
| `${10}`             | Tiende argument (accolades verplicht!)     |
| `${*}`              | Alle argumenten: `${1} ${2} ${3}...`       |
| `${@}`              | Alle argumenten: `"${1}" "${2}" "${3}"...` |
| `${#}`              | Aantal positionele parameters              |

## Positionele parameters: shift

Het commando `shift` schuift positionele parameters op naar links:

- `${1}` verdwijnt
- `${2}` wordt `${1}`
- `${3}` wordt `${2}`
- enz.

## Positionele parameters instellen

```bash
set par1 par2 par3
echo "${1}"  #  => par1
echo "${2}"  #  => par2
echo "${3}"  #  => par3
echo "${4}"  #  =>       (lege string)
```

## Exit-status

- Elk commando heeft een *exit-status*, numerieke waarde
    - Opvragen met `echo "$?"`
    - 0 => commando geslaagd, logische *true*
    - 1-255 => commando gefaald, logische *false*
- Logische operatoren in Bash zijn gebaseerd op exit-status
- Booleaanse variabelen *bestaan niet*

## If (1)

```bash
if EXPR
then
  # ...
elif EXPR
then
  # ...
else
  # ...
fi
```

## If (2)

```bash
if [ "${#}" -gt '2' ]; then
  printf 'Expected at most 2 arguments, got %d\n' "${#}" >&2
  exit 1
fi
```

## While-lus

```bash
while EXPR; do
  # ...
done
```

## Until-lus

```bash
until EXPR; do
  # ...
done
```

## While lus met teller

```bash
counter=0

while [ "${counter}" -le '10' ]; do
  echo "${counter}"
  counter=$((counter + 1))
done
```

`$(( ... ))` is *arithmetic expansion*

## Itereren over lijnen in een bestand

```bash
while read -r line; do
    # process "${line}"
done < file.txt
```

## For-lus

Itereren over een lijst

```bash
for ITEM in LIST; do
  # ...
done
```

```bash
for file in *.md; do
  printf 'Processing file %s\n' "${file}"
  # ...
done
```

## For-lus met teller (1/3)

```bash
for i in {1..10}; do
  echo "${i}"
done
```

```bash
for i in {2..20..2}; do
  echo "${i}"
done
```

## For-lus met teller (2/3)

```bash
for i in $(seq 1 10); do
  echo "${i}"
done
```

```bash
for i in $(seq 2 2 20); do
  echo "${i}"
done
```

## For-lus met teller (3/3)

"Klassieke" for-lus, komt slechts uitzonderlijk voor

```bash
for ((i=0; i<=10; i++)); do
  echo "${i}"
done
```

## Itereren over positionele parameters (`while`)

```bash
while [ "$#" -gt 0 ]; do
  printf 'Arg: %s\n' "${1}"
  # ...
  shift
done
```

## Itereren over positionele parameters (`for`)

```bash
for arg in "${@}"; do
  printf 'Arg: %s\n' "${arg}"
  # ...
done
```

## Let op! Een lus is niet altijd nodig!

Find is zelf een "lus", dus `| while` is overbodig

```bash
# find | while is overbodig!
find . -type d | while read -r dir; do chmod 700 "${dir}"; done
```

Beter:

```bash
find . -type d -exec chmod 700 "{}" \;
```

## Labo-oefeningen

- Start met oefeningenreeks `script102`

    ```console
    cd ~/linux-2122-scripts-USERNAME/script102
    ```

- Opgave: `script102/README.md` of Chamilo-leerpad
