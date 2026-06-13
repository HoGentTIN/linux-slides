---
title: "Collecting data, web scraping with curl"
subtitle: "Linux"
author: "HOGENT toegepaste informatica"
date: "2026-2027"
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
curl -X GET https://httpbun.com/any
curl -X POST https://httpbun.com/any
curl -X PUT https://httpbun.com/any
curl -X DELETE https://httpbun.com/any
...
```

Which request is default?

## Saving the result

- `-o`, `--output` `<file>`
- `-O`, `--remote-name`

```console
curl -s -o anything.json https://httpbun.com/any
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
    https://httpbun.com/any
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
curl -X POST -d 'penguin=tux&color=blue' https://httpbun.com/any
```
