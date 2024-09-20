---
title: "6. Scripting 103"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# Scripting (vervolg)

## Fouten opsporen (1)

- Begin met minimaal script, voer het zo snel mogelijk uit!
- Werk altijd **stap voor stap**
    - iteratieve toevoegingen
- **Test** voortdurend het resultaat van elke wijziging
- Hou minstens **2 vensters** open naast elkaar:
    - Editor
    - Terminal voor testen

## Fouten opsporen (2)

- Syntax check: `bash -n script.sh`
- ShellCheck: `shellcheck script.sh`
    - Gebruik editor-plugin waar mogelijk
- Druk veel info af (`printf` of `echo`)
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

## Booleans in Bash

- In Bash bestaan **geen** booleaanse variabelen!
- Er bestaan wel gelijknamige commando's `true` en `false`
- Booleaanse waarden zijn gebaseerd op exit-status v/e proces

## De commando's `true` en `false`

In Java zou je `true` als volgt implementeren

```java
public class True {
  public static void main(String[] args) {
    System.exit(0);
  }
}
```

en `false`:

```java
public class False {
  public static void main(String[] args) {
    System.exit(1);
  }
}
```

De echte implementatie [vind je hier](https://github.com/coreutils/coreutils/blob/master/src/true.c)

## Logische operatoren

```bash
if COMMANDO; then
  # A
else
  # B
fi
```

- `A`-blok wordt uitgevoerd als exit-status van `COMMANDO` 0 is (geslaagd, TRUE)
- `B`-blok wordt uitgevoerd als exit-status van `COMMANDO` verschillend is van 0 (gefaald, FALSE)

## Toepassing

Maak gebruiker `${user}` aan als die nog niet bestaat

```bash
if ! getent passwd "${user}" > /dev/null 2>&1; then
  echo "Adding user ${user}"
  useradd "${user}"
else
  echo "User ${user} already exists"
fi
```

## Operatoren `&&` en `||`

```bash
command1 && command2
```

`command2` wordt enkel uitgevoerd als `command1` succesvol was (exit 0)

```bash
command1 || command2
```

`command2` wordt enkel uitgevoerd als `command1` **niet** succesvol was (exit ≠ 0)

## Het commando `test`

- Evalueren van logische expressies
- Geeft geschikte exit-status
    - 0 = TRUE
    - 1 = FALSE
- Alias voor `test` is `[`
    - `[` is een *commando*, geen "haakje" in de traditionele betekenis
    - spaties vóór en na!

---

```bash
# Fout:
if[$#-eq 0]; then
  echo "Expected at least one argument"
fi

# Juist:
if [ "${#}" -eq "0" ]; then
  echo "Expected at least one argument"
fi
```
