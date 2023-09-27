---
title: "3.2. Collecting data, web scraping with curl"
subtitle: "Linux for Data Scientists<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2023-2024
---

# Interacting with web servers from the terminal

## Terminal-based web clients

Browsers:

- [elinks](http://elinks.or.cz)
- [links](http://links.twibright.com)
- lynx

CLI utilities:

- [cURL](https://curl.se/)
- [httpie](https://httpie.io/)
- [wget](https://www.gnu.org/software/wget/)

## cURL

```console
$ curl icanhazip.com
193.190.172.117
```

Try this:

- `curl 'https://icanhazdadjoke.com/'`
- `curl 'https://covid19.mathdro.id/api/countries/BE'`
- `curl 'https://api.coinlore.net/api/ticker/?id=90'`
- `curl 'https://education.thingsflow.eu/IAQ/DeviceByQR?hashedname=5201731f632701e602d31f98be7297e088a94eb38736c452495f02e444d4ba2d'`

## Output, redirection

- Normally, `curl` prints to `stdout`
- When redirected, progress information is printed:

    ```console
    $ curl 'https://icanhazdadjoke.com/' > joke.txt
      % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                     Dload  Upload   Total   Spent    Left  Speed
    100    95  100    95    0     0    320      0 --:--:-- --:--:-- --:--:--   319
    ```

- Turn off with `-s` / `--silent`

## HTTP Request methods

E.g.

```console
curl -X GET https://httpbin.org/anything
curl -X POST https://httpbin.org/anything
curl -X PUT https://httpbin.org/anything
curl -X DELETE https://httpbin.org/anything
...
```

Which request is default?

## Saving the result

- `-o`, `--output` `<file>`
- `-O`, `--remote-name`

```console
curl -s -o anything.json https://httpbin.org/anything
curl -s -O https://www.google.com/robots.txt
```

## Show headers

- `-i`, `--include`: toon ook de HTTP response headers
- `-I`, `--head`: toon **enkel** de headers

```console
curl -i http://google.com
```

## Set request headers

```console
curl -H 'User-Agent: Mozilla/4.0 (compatible; MSIE 5.0; Windows 98; DigExt)' \
    https://httpbin.org/anything
```

## Follow redirects

- `-L`, `--location`

```bash
curl https://www.twitter.com      # Leeg resultaat!
curl -i https://www.twitter.com   # zie location: veld in de response header
curl -L https://www.twitter.com   # volg de redirect
```

## POST data

- `-d`, `--data` `var=val&var=val`

```console
curl -X POST -d 'penguin=tux&color=blue' https://httpbin.org/anything
```

## Opdracht Automatiseren data-workflow

1. Verzamel data over een bepaalde periode (bv. curl)
2. Zet ruwe data om in geschikte vorm (bv. JSON/HTML -> CSV)
3. Simuleer analyse van de data (bv. grafiekje, basis-statistieken)
4. Genereer rapport (webpagina, PDF)

Resultaat in te dienen/demonstreren (= 30% examencijfer)

## Stap 1. Verzamel data

- Kies een dataset
- Schrijf een script dat de gewenste data downloadt
    - Slaat op in bepaalde directory (instellen met variabele)
    - Bestand met timestamp in de naam

## Voorbeelden open datasets

- [Open Dataportaal stad Gent](https://data.stad.gent/)
- [CO2-meter in lokaal B.4.037](https://education.thingsflow.eu/IAQ/DeviceByQR?hashedname=5201731f632701e602d31f98be7297e088a94eb38736c452495f02e444d4ba2d)
- [Lijst van publieke REST APIs](https://documenter.getpostman.com/view/8854915/Szf7znEe) (Postman)
- [Public API's](https://github.com/public-apis/public-apis) (Github-repo)
- [Free APIs for developers](https://rapidapi.com/collection/list-of-free-apis) (Rapid API)
- [Big list of free and open APIs](https://mixedanalytics.com/blog/list-actually-free-open-no-auth-needed-apis/) (Ana Kravitz)
- ...
