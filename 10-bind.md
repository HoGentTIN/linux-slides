---
title: "10. DNS met BIND"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem
date: 2024-2025
---

# DNS-server met BIND


## Agenda

- DNS
- BIND op Enterprise Linux
- Configuratie
- Zonebestanden

<http://www.zytrax.com/books/dns/>

## Opstelling

- We gaan verder met de opstelling met Linux Mint-, web- en db-VMs
    - Github repo: "linux-2122-USERNAME/automation"
- In de les: stap voor stap, manueel
- Labo-taak: automatiseren!

## Nieuwe VM

- In `vagrant-hosts.yml`:
  
    ```yaml
    - name: srv
      box: bento/almalinux-9
      ip: 192.168.76.254
      intnet: true
    ```

- In `provisioning/` script `srv.sh` toevoegen
    - bv. kopie van `web.sh`, toegevoegde code voor installatie LAMP verwijderen
- `vagrant up srv`

# DNS

## In wezen is DNS eenvoudig!

- Vertaling van hostnaam naar IP in een tekstbestand
- DNS query = opzoeking in dat tekstbestand
- Queries kunnen over het netwerk gestuurd worden

en toch blijkt...

[Everything is a freaking DNS problem](https://krisbuytaert.be/blog/linux-troubleshooting-101-2016-edition/index.html)

## Poor man's DNS

Hosts-bestand: `/etc/hosts`

```text
# IP-address   hostname    aliases
127.0.0.1      localhost   localhost.localdomain
::1            localhost6  localhost6.localdomain6

172.22.255.254 router4038  gw gw.netlab.hogent.be
172.22.0.2     server4038  server4038.netlab.hogent.be
172.22.0.3     printer4038 printer4038.netlab.hogent.be
```

- On Windows: `c:\Windows\System32\Drivers\etc\hosts`
- Ad blocker: <https://someonewhocares.org/hosts/>

## Maar...

![Hierarchical domains](https://upload.wikimedia.org/wikipedia/commons/b/b1/Domain_name_space.svg)

---

![Iterative resolver](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example_of_an_iterative_DNS_resolver.svg/800px-Example_of_an_iterative_DNS_resolver.svg.png)

## Root DNS servers

<http://www.root-servers.org/>

- 12 root servers: [a-m].root-servers.net
- Verschillende instanties per root server!
    - totaal: 1000+
    - vb. Brussels: e, f, i, l
- Instanties v/e root server delen hun IP address!
    - routers sturen trafiek naar dichtstbijzijnde instantie

## Types van DNS servers

- **Authoritative**: "bron van waarheid" voor een *zone*
    - zonebestand
- **Forwarding**/**caching**: stuurt requests door naar andere servers
- **Primary**/**Secondary** (master/slave): voor "high availability"
    - enkel primaire heeft zonebestand
    - secundaire vraagt regelmatig "zone transfer"

## Best practices in productie

- Authoritative-only
    - Caching & authoritative **niet** mengen
- DNS only
    - **Geen** andere services op die machine

Een typische AD DC overtreedt beide regels!

# Interactie met DNS

## nslookup

Stuur vraag naar de DNS-server in `/etc/resolv.conf`

```console
nslookup www.hogent.be
```

Stuur vraag naar specifieke DNS-server

```console
nslookup www.hogent.be 193.190.172.1
```

## dig: forward lookups

```console
$ dig www.hogent.be
[...]
$ dig www.hogent.be @ens1.hogent.be +short
hogent.be.
193.190.173.132
```

## dig: reverse lookup

```console
$ dig -x 193.190.173.132 @ens1.hogent.be +short
net-173-node-133.hogent.be.
```

## dig: IPv6

```console
$ dig AAAA www.google.com +short
2a00:1450:400e:806::2004
```

## dig: domain info

```console
$ dig NS hogent.be
$ dig MX hogent.be
$ dig SOA hogent.be
$ dig ANY hogent.be @ens1.hogent.be
$ dig AXFR zonetransfer.me @nsztm1.digi.ninja
```

1. Wie is de *authoritative name server* voor hogent.be?
2. Wie is de mail server voor hogent.be?
3. Vraag de Start-of-Authority section voor hogent.be op
4. Geef gelijk welk record met de opgegeven naam
5. Vraag een domain transfer aan

# BIND

## Berkeley Internet Name Domain

- Implementatie van het DNS protocol
- Meest gebruikte
- De facto standaard op Unix-achtige systemen

Lees *DNS for rocket scientists*!

<http://www.zytrax.com/books/dns/>

## Installatie op Enterprise Linux

- Package: `bind`
- Configuratie: `/etc/named*`
- Zonebestanden, enz: `/var/named/`

## Hoofdconfiguratiebestand

`/etc/named.conf`

```text
options {
  listen-on port 53 { any; };     //aanpassen!
  listen-on-v6 port 53 { any; };  //aanpassen!
  directory   "/var/named";

  // ...

  allow-query     { any; };       //aanpassen!

  recursion yes;

  // ...
};
```

## Belangrijkste opties:

- `listen-on`: port number + network interfaces
    - `any;`
    - `127.0.0.0/8; 192.168.76.0/24`
- `allow-query`: welke hosts mogen queries sturen?
- `recursion`: recursieve queries toelaten
    - zou `no` moeten zijn op een authoritative name server!

## Forwarding name server

Als je de service nu opstart, heb je een forwarding name server

Controleer dit!

- Draait de service?
- Op welke poort(en)?
- Firewall?
- Reageert de service op requests?
    - localhost?
    - vanaf de Linux Mint?

## Voorbeeld: domein example.com

| Host | Alias      | IP         | Functie               |
| :--- | :--------- | :--------- | :-------------------- |
| ns1  |            | 192.0.2.1  | Primaire DNS-server   |
| ns2  |            | 192.0.2.2  | Secundaire DNS-server |
| web  | www        | 192.0.2.10 | Webserver             |
| mail | smtp, imap | 192.0.2.20 | Mailserver            |

## Configuratie zone:

Forward lookup zone voor *example.com*

```text
zone "example.com" IN {
  type master;
  file "example.com";
  notify yes;
  allow-update { none; };
};
```

## Zonebestand voor example.com

`/var/named/example.com`

```text
$ORIGIN example.com.
$TTL 1W

@ IN SOA ns.example.com. hostmaster.example.com. (
  21120117 1D 1H 1W 1D )

       IN  NS     ns1
       IN  NS     ns2

       IN  MX     10 mail

ns1    IN  A      192.0.2.1
ns2    IN  A      192.0.2.2

web    IN  A      192.0.2.10
www    IN  CNAME  web

mail   IN  A      192.0.2.20
smtp   IN  CNAME  mail
imap   IN  CNAME  smtp
```

## Resource records (RRs)

```text
web    IN  A      192.0.2.10
www    IN  CNAME  web
```

## Types van Resource Records

- `A`: hostnaam → IP
- `AAAA`: hostnaam → IPv6
- `PTR`: IP → hostnaam
- `CNAME`: alias
- `SOA`: start of authority
- `NS`: authoritative name server(s)
- `MX`: mail server
- `SRV`: service
- `TXT`: text record
- ...

## Start of Authority

```text
@ IN SOA ns.example.com. hostmaster.example.com. (
  21120117 1D 1H 1W 1D )
```

- `srv.example.com.`: primaire DNS-server
- `hostmaster.example.com.`: email adres v/d sysadmin
    - `hostmaster@example.com`
- `21120120`: serial
    - **LET OP** secundaire servers zullen **alleen** update uitvoeren als serial verhoogd is

## Start of Authority: timeouts

```text
@ IN SOA ns.example.com. hostmaster.example.com. (
  21120117 1D 1H 1W 1D )
```

- `1D`: waneer zal secundaire ns proberen de zone te synchroniseren
- `1H`: tijd tussen update-pogingen
- `1W`: wanneer zijn zonegegevens niet langer "authoritative" (enkel op secondaire)
- `1D`: hoe lang kan een NAME ERROR resultaat gecached worden

Zie <http://www.zytrax.com/books/dns/ch8/soa.html>

## "Shortcuts"

- `$ORIGIN`: domeinnaam
    - wordt toegevoegd aan alle namen die niet eindigen op `.`
    - `@`: wordt vervangen door waarde van `$ORIGIN`
- `$TTL`: time to live (in seconden)
    - hoe lang mag een record gecached worden

## (Un)qualified domain names

- Fully Qualified Domain Name (FQDN): eindigt met een punt
- Unqualified: zonder punt
    - `$ORIGIN` toegevoegd aan het einde

## Tijdsaanduidingen

- default = seconden
- M = minuten
- H = uren
- D = dagen
- W = weken

Ook combinaties, bv. `2H30M`

## Reverse lookup zone

```text
zone "2.0.192.in-addr.arpa" IN {
  type master;
  file "2.0.192.in-addr.arpa";
  notify yes;
  allow-update { none; };
};
```

## Naam van een "reverse lookup zone"

1. Neem het IP-adres: `192.0.2.0/24`
2. Laat het host-deel vallen: `192.0.2`
3. Keer volgorde om: `2.0.192`
4. Voeg `in-addr.arpa.` toe

Resutaat: `2.0.192.in-addr.arpa.`

## Zonebestand

`/var/named/2.0.192.in-addr.arpa`

```text
$TTL 1W
$ORIGIN 2.0.192.in-addr.arpa.

@ IN SOA ns.example.com. hostmaster.example.com. (
  21120117 1D 1H 1W 1D )

       IN  NS     ns1.example.com.
       IN  NS     ns2.example.com.

1      IN  PTR    ns1.example.com.
2      IN  PTR    ns2.example.com.
10     IN  PTR    web.example.com.
20     IN  PTR    mail.example.com.
```

## Root hint

Elke (forwarding) name server moet een lijst bijhouden van de root name servers

```console
dig @a.root-servers.net
```

---

```text
.   518400 IN NS a.root-servers.net.
.   518400 IN NS b.root-servers.net.

[...]

a.root-servers.net. 518400 IN A 198.41.0.4
b.root-servers.net. 518400 IN A 199.9.14.201

[...]

a.root-servers.net. 518400 IN AAAA 2001:503:ba3e::2:30
b.root-servers.net. 518400 IN AAAA 2001:500:200::b

[...]
```

# Labo-opdracht

## Doelstelling

Authoritative name server voor het domein *linux.lan*

| Host | Alias | IP             |
| :--- | :---- | :------------- |
| web  | www   | 192.168.76.4   |
| db   |       | 192.168.76.3   |
| srv  |       | 192.168.76.254 |

- Zoek zelf op: hoe kan je "http://linux.lan" laten werken?
- Begin met forward zone, pas als die werkt de reverse
- Kan je DNS ondervragen vanaf Linux Mint?

## Nuttige commando's

- Controleer de logs: `journalctl -f -l -u named`
- Valideer configbestanden:
    - hoofdbestand: `named-checkconf`
    - zonebestanden: `named-checkzone ZONE FILE`

```console
$ sudo named-checkconf
$ sudo named-checkzone linux.lan /var/named/linux.lan
$ sudo named-checkzone 76.168.192.in-addr.arpa \
        /var/named/76.168.192.in-addr.arpa
```

## Tips

Query log aanzetten:

```console
[vagrant@srv ~]$ sudo rndc querylog
```

BIND logs tonen:

```console
[vagrant@srv ~]$ journalctl -f -u named.service
```

## Netwerkverkeer opvangen:

```console
[vagrant@srv ~]$ sudo tcpdump -i eth1 -vvnnttt
[vagrant@srv ~]$ sudo tcpdump -i any -U -w - port 53 | tee /vagrant/dns.pcap | tcpdump -vv -nn -ttttt -r -
```

1. Interactie met de Linux Mint VM
2. Alle verkeer op poort 53, opslaan in dns.pcap

Bestand `dns.pcap` kan je openen met Wireshark!

## LAN "afwerken"

Werk de huidige opstelling af tot een volledig werkend LAN

- Automatiseer de installatie en configuratie van BIND
- Zorg dat ook DHCP-server geïnstalleerd en geconfigureerd wordt
- Zorg dat Linux Mint correcte IP-instellingen krijgt op intnet
