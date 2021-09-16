# Linux: slides

In deze repository vind je de slides die gebruikt wordt in de lessen van de cursus Linux (2e jaar bachelor toegepaste informatica aan Hogeschool Gent).

De slides zijn opgemaakt in [Markdown](https://guides.github.com/features/mastering-markdown/) en worden met [Pandoc](https://pandoc.org/) omgezet naar een [reveal.js](https://revealjs.com/) presentatie. Deze zijn te bekijken op: <https://hogenttin.github.io/linux-slides/>

## Slides genereren

Om zelf de slides te genereren heb je een Linux (of UN*X) omgeving nodig, met (GNU) make en [Pandoc](https://pandoc.org/).

Haal eerst de branch `gh-pages` (wordt gebruikt om de slides te publiceren via Github Pages) binnen en maak die beschikbaar in de directory `gh-pages`.

```console
git worktree add gh-pages gh-pages
```

Genereer vervolgens de slides a.h.v. de Makefile:

```console
make all
```

Je kan nu de slides bekijken door de .html-bestanden in de `gh-pages` directory te openen in een webbrowser.

Om de slides te publiceren op Github Pages, voer je het script `./publish.sh` uit. Dit is echter meestal niet nodig: telkens wanneer je wijzigingen naar Github pusht, worden de slides automatisch gecompileerd en gepubliceerd op Github Pages. Enkele minuten na de wijziging zou die moeten zichtbaar zijn in de slides.

## Bijdragen

Bijdragen aan het hier gepubliceerde lesmateriaal zijn van harte welkom! verbeteren van tikfouten, toevoegingen, onduidelijkheden melden, enz. Je kan een Issue of een Pull Request openen.

## Licentie-informatie

Deze slides zijn samengesteld door [Andy Van Maele](https://github.com/AndyVM) en [Bert Van Vreckem](https://github.com/bertvv/) en vallen onder de [Creative Commons Naamsvermelding-GelijkDelen 4.0 Internationale Publieke Licentie](http://creativecommons.org/licenses/by-sa/4.0/).
