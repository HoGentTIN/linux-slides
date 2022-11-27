---
title: "9. Automatiseren v/workflows met Makefiles"
subtitle: "Linux (for data Scientists)<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2022-2023
---

# Makefiles

## GNU Make

- `make` = deel van basis toolset voor software-ontwikkeling op Unix
    - POSIX!
- GNU make = implementatie op Linux
- Vgl. met ant, Maven, Grunt, ..
- Oorspronkelijk voor C/C++
- Algemeen bruikbaar!
    - bronbestand > transformatie > doelbestand
    - bv. c-code > GCC compiler > executable
    - bv. java-code > javac > .class-files
    - ...

## Makefile

```Makefile
doel: bronnen...
    recept
    @cmd
    ...
```

- `doel`: naam v/te creëren bestand
- `bronnen`: naam van bestanden die daarvoor nodig zijn
- `recept`: commando('s) die nodig zijn om `doel` te creëren uit `bronnen`
    - `@cmd` uitgevoerde commando wordt *niet* getoond
    - LET OP! Inspringen met TAB, geen spaties!

## Voorbeeld Makefile

`Makefile`:

```Makefile
hello: hello.c
    gcc -o hello hello.c
```

`hello.c`:

```c
#include <stdio.h>
int main()
{
    printf("Hello World");
    return 0;
}
```

## Uitvoeren

- `make [DOEL]`
    - zonder argumenten: eerste doel
    - hier bv. `make hello`
- Resultaat: uitvoerbaar bestand met de naam `hello`

```console
$ make
gcc -o hello hello.c
$ ./hello
Hello World
$ make hello
make: 'hello' is up to date.
```

Make voert enkel recept uit als bron veranderd is!

## Voorbeeld meerdere bron- en doelbestanden

```c
// booleans.h
int EXIT_TRUE  = 0;
int EXIT_FALSE = 1;
```

```c
// true.c
#include <stdio.h>
#include "booleans.h"

int main(void) {
    return EXIT_TRUE;
}
```

(false.c: analoog)

---

```Makefile
# Makefile
.PHONY: all clean

all: true false
true: true.c booleans.h
    gcc -o true true.c
false: false.c booleans.h
    gcc -o false false.c
clean:
    rm -vf true false
```

- `all`
    - 1e regel wordt uitgevoerd bij oproepen `make` (zonder args)
    - "recursieve" regel, zal `true` én `false` uitvoeren
- `clean`
    - regel voor het opruimen van alle gegenereerde bestanden
- `.PHONY` = geen "echt" recept, moet *altijd* uitgevoerd worden

## Makefiles compacter & generisch maken

```Makefile
# Makefile - part 1

sources := $(wildcard *.c)
objects := $(patsubst %.c,%.o,$(sources))
executables := true false

CC := gcc
CFLAGS := -Wall -O
```

- Variabelen:
    - declaratie: `:=`
    - waarde opvragen: `$(variabele)`
- `wildcard` - lijst v/bestanden die matchen met globbing-patroon
    - hier: `true.c false.c`
- `patsubsts` - zoeken & vervangen
    - hier: `true.o false.o`

---

```Makefile
# Makefile - part 2

.PHONY: all clean mrproper

all: $(executables)

true: true.o
	$(CC) $(CFLAGS) -o true true.o

false: false.o
	$(CC) $(CFLAGS) -o false false.o

%.o: %.c booleans.h
	$(CC) $(CFLAGS) -c $<
```

---

- `%` = "Pattern rule"
    - `%` matcht met `true` en `false`
- `$<` = [Automatische variabele](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)
    - Eerste bron voor deze regel

```Makefile
%.o: %.c booleans.h
	$(CC) $(CFLAGS)  -c $<
```

wordt vertaald naar:

```Makefile
true.o: true.c booleans.h
	gcc -Wall -O -c true.c
false.o: false.c booleans.h
	gcc -Wall -O -c false.c
```

---

```Makefile
# Makefile - part 3

clean:
	rm -vf $(objects)

mrproper: clean
	rm -vf $(executables)
```

## *Portable* Makefiles

Begin Makefile met:

```Makefile
.POSIX:     # Get reliable POSIX behaviour
.SUFFIXES:  # Clear built-in inference rules
```

- `.POSIX`: Makefile werkt beter op andere platformen
    - bv. MacOS, Windows, BSD, ...
- `.SUFFIXES`: ingebouwde regels (voor C-compilatie) wissen
- `.PHONY` is een GNU make uitbreiding, werkt misschien niet op andere platformen