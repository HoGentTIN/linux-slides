---
title: "9. SSH-tuning, BIND"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# SSH Tuning

## TODO

# DNS-server met BIND

## Before we begin

Set up the test environment

```console
$ cd elnx-syllabus/demo
$ vagrant up ns1 ns2
[...]
```

## Agenda

- DNS
- BIND on Enterprise Linux
- Main configuration
- Zone files
- Secondary servers
- Troubleshooting

<http://www.zytrax.com/books/dns/>

# DNS

## Actually, DNS is simple!

- name to IP mappings in text file
- DNS query = lookup mapping in text file
- Send queries over the network

## Poor man's DNS

Hosts file: `/etc/hosts`

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

## However...

![Hierarchical domains](https://upload.wikimedia.org/wikipedia/commons/b/b1/Domain_name_space.svg)

---

![Iterative resolver](https://upload.wikimedia.org/wikipedia/commons/thumb/a/a5/Example_of_an_iterative_DNS_resolver.svg/800px-Example_of_an_iterative_DNS_resolver.svg.png)

## Root DNS servers

<http://www.root-servers.org/>

- 12 root servers: [a-m].root-servers.net
- Multiple instances per root server!
    - total: 1000+
    - e.g. Brussels: e, f, i, l
- Each root server has one IP address!
    - routers will guide traffic to nearby instance

## Types of DNS servers

- Authoritative: "source of truth" for a *zone*
- Forwarding/caching: sends requests to other servers
- Primary/Secondary (master/slave)

## Best practices in production

- Authoritative-only
    - **Do not** mix caching & authoritative
- DNS only
    - **Do not** run other services on that machine

Typical Active Directory Domain Controller violates both!

# Interacting with DNS

## nslookup

query the DNS server in `/etc/resolv.conf`

```console
nslookup www.hogent.be
```

query the specified DNS server

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

1. Who is the authoritative name server for hogent.be?
2. Who is the mail server for hogent.be?
3. Start-of-Authority section for hogent.be
4. Get any RR that contains the given name
5. Request domain transfer

# BIND

## Berkeley Internet Name Domain

- Implementation of DNS protocol
- Most widely used
- De facto standard on Unix-like systems

Read *DNS for rocket scientists*: <http://www.zytrax.com/books/dns/>

## Installation on Enterprise Linux

- Package: `named`
- Service configuration: `/etc/named*`
- Zone files, etc.: `/var/named/`

## Main config file

```text
options {
  listen-on port 53 { any; };
  listen-on-v6 port 53 { any; };
  directory   "/var/named";

  // ...

  allow-query     { any; };
  allow-transfer  { any; };

  recursion no;

  rrset-order { order random; };

  // ...
};
```

## Important options

- `listen-on`: port number + network interfaces
    - `any;`
    - `127.0.0.0/8; 192.168.56.0/24`
- `allow-query`: which hosts may send queries?
- `allow-transfer`: which secondary name servers may receive zone transfers?
- `recursion`: allow recursive queries
    - should be `no` on authoritative name server

## Primary server forward zone definition

Forward lookup zone for *example.com*

```text
zone "example.com" IN {
  type master;
  file "example.com";
  notify yes;
  allow-update { none; };
};
```

## Secondary server zone definition

On a secondary name server:

```text
zone "example.com" IN {
  type slave;
  masters { 192.168.56.10; };
  file "slaves/example.com";
};
```

## Primary server reverse lookup zone

```text
zone "56.168.192.in-addr.arpa" IN {
  type master;
  file "56.168.192.in-addr.arpa";
  notify yes;
  allow-update { none; };
};
```

## IP to reverse lookup zone

1. Take the "dotted quad", e.g. `192.168.56.0/24`
2. Drop the host part: `192.168.56`
3. Reverse the quads: `56.168.192`
4. Add `in-addr.arpa.`:
    - `56.168.192.in-addr.arpa.`

## Example zone file

```text
$ORIGIN example.com.
$TTL 1W

@ IN SOA ns1.example.com. hostmaster.example.com. (
  18042020 1D 1H 1W 1D )

                     IN  NS     ns1
                     IN  NS     ns2

ns1                  IN  A      192.168.56.10
ns2                  IN  A      192.168.56.11
dc                   IN  A      192.168.56.40
web                  IN  A      192.168.56.172
www                  IN  CNAME  web
db                   IN  A      192.168.56.173

priv0001             IN  A      172.16.0.10
priv0002             IN  A      172.16.0.11
```

## Resource records (RRs)

```text
web  IN  A      192.168.56.172
www  IN  CNAME  web
```

## Types of Resource Records

- `A`: name → IP
- `AAAA`: name → IPv6
- `PTR`: IP → name
- `CNAME`: alias
- `SOA`: start of authority, info about the domain
- `NS`: authoritative name server(s)
- `MX`: mail server
- `SRV`: service
- `TXT`: text record
- ...

## Start of Authority

```text
@ IN SOA ns1.example.com. hostmaster.example.com. (
  18042020 1D 1H 1W 1D )
```

- `ns1.example.com.`: primary name server
- `hostmaster.example.com.`: email address of sysadmin
    - `hostmaster@example.com`
- `18042020`: serial
    - **REMARK** Secondary name servers will **only** update if serial increments

## Start of Authority timeouts

```text
@ IN SOA ns1.example.com hostmaster.example.com (
  18042020 1D 1H 1W 1D )
```

- `1D`: when will secondary ns try to refresh the zone
- `1H`: time between update retries
- `1W`: when is zone data no longer authoritative (only secondary)
- `1D`: how long can NAME ERROR result be cached

## "Shortcuts"

- `$ORIGIN`: domain name
    - added to all names not ending with `.`
    - `@`: replaced with value of `$ORIGIN`
- `$TTL`: time to live (in seconds)
    - how long may record be cached

## (Un)qualified names

- Qualified name (FQDN): end with dot
- Unqualified: without dot
    - `$ORIGIN` added to the end

## Specifying time

- default = seconds
- M = minutes
- H = hours
- D = days
- W = weeks

Combinations are allowed, e.g. `2H30M`

## Reverse zone file

```text
$TTL 1W
$ORIGIN 16.172.in-addr.arpa.

@ IN SOA ns1.example.com. hostmaster.example.com. (
  18042020
  1D 1H 1W 1D )

                 IN  NS   ns1.example.com.
                 IN  NS   ns2.example.com.

10.0             IN  PTR  priv0001.example.com.
11.0             IN  PTR  priv0002.example.com.
```

## Root hint

Every (forwarding) name server should have list of root name servers

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

# Troubleshooting

## Assignment

Authoritative name server for domain *example.com*

| Host     | IP            |
| :---     | :---          |
| ns1      | 192.168.56.10 |
| ns2      | 192.168.56.11 |
| dc       | 192.168.56.40 |
| web      | 192.168.56.72 |
| db       | 192.168.56.73 |
| priv0001 | 172.16.0.10   |
| priv0002 | 172.16.0.11   |

The host `web` has an alias, `www`.

## Goal: make the tests succeed!

```console
[vagrant@ns1]$ /vagrant/tests/runtests.sh
Testing 192.168.56.10
 ✓ The dig command should be installed
 ✓ It should return the NS record(s)
 ✓ It should be able to resolve host names
 ✓ It should be able to do reverse lookups
 ✓ It should be able to resolve aliases
 ✓ It should return the SRV record(s)

6 tests, 0 failures
Testing 192.168.56.11
 ✓ The dig command should be installed
 ✓ It should return the NS record(s)
 ✓ It should be able to resolve host names
 ✓ It should be able to do reverse lookups
 ✓ It should be able to resolve aliases
 ✓ It should return the SRV record(s)

6 tests, 0 failures
```

## Useful commands

- Check the logs: `journalctl -f -l -u named`
- Validate config files:
    - main: `named-checkconf /etc/named.conf`
    - zone files: `named-checkzone ZONE FILE`

```console
$ named-checkconf
$ named-checkzone example.com /var/named/example.com
$ named-checkzone 16.172.in-addr.arpa /var/named/16.172.in-addr.arpa
```

## Tips

Enable Query log:

```console
[root@ns1 ~]# rndc querylog
```

Force zone update:

```console
[root@ns2 ~]# rndc refresh example.com
```

## Tips (vervolg)

Follow BIND logs:

```console
[root@ns1 ~]# journalctl -f -u named.service
```

Capture network traffic:

```console
[root@ns2 ~]# tcpdump -i eth1 -vvnnttt
[root@ns2 ~]# tcpdump -i eth1 -U -w - | tee dns.pcap | tcpdump -vv -nn -ttttt -r -
```