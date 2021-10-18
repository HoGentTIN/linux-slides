---
title: "6. Automatiseren webserverinstallatie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Scripting (vervolg)

## De commando's `true` en `false`

Er bestaan wel gelijknamige commando's.

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

## TODO

# Automatiseren webserverinstallatie

## TODO
