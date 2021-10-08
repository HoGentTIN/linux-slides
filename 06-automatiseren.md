---
title: "6. Automatiseren webserverinstallatie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Scripting (vervolg)

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
