---
title: "3.2. Collecting data, web scraping with curl"
subtitle: "Linux for Data Scientists<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2022-2023
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
7370:b673:ac23:a771:1a0a:ea7a:5094:03d7
```

Try this:

- `curl 'https://icanhazdadjoke.com/'`
- `curl 'https://covid19.mathdro.id/api/countries/BE'`
- `curl 'https://api.coinlore.net/api/ticker/?id=90'`
- `curl 'https://data.stad.gent/api/records/1.0/search/?dataset=real-time-bezettingen-fietsenstallingen-gent&q=&facet=facilityname'`

## Tip: publieke API's

- Gent Open Data portaal: <https://data.stad.gent/>
- <https://documenter.getpostman.com/view/8854915/Szf7znEe>
- <https://rapidapi.com/collection/list-of-free-apis>
- <https://github.com/public-apis/public-apis>
- <https://mixedanalytics.com/blog/list-actually-free-open-no-auth-needed-apis/>