---
title: "Vim Survival Guide"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# Vim survival guide

## The editor wars

![https://xkcd.com/378/](assets/xkcd-378.png)

## Vim vs Nano

- Nano = default editor on Mint (& Ubuntu, ...)
    - Niet altijd beschikbaar! (bv. servers)
- ed (1973) > ex (1976) > vi (1976) > Vim (1991)
- Vi is standaard
    - POSIX
    - Single UNIX Specification

---

![Source: <https://www.soemtron.org/pdp7.html>](assets/pdp7.jpg)

## Vim

- Vi Improved, Bram Molenaar
- Altijd aanwezig in Linux, MacOS
- "Modal editor"
    - Insert mode = tekst invoeren
    - Command mode = tekst bewerken
- Efficiënte toetsenbordinvoer
    - Handen blijven centraal op toetsenbord
    - Krachtige commando's

## Essentiële Vim-commando's

```console
$ vim <bestand>
```

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

```console
$ sudo apt install vim-runtime     # Op Debian
$ sudo dnf install vim-enhanced    # Op RedHat
$ vimtutor
```
