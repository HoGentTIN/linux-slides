---
title: "3.2. Netwerkconfiguratie"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem, Jan Willem
date: 2025-2026
---

# Netwerkconfiguratie

## Netwerkinstellingen controleren

Om Internettoegang mogelijk te maken zijn er 3 instellingen nodig:

1. IP-adres en subnetmasker
2. Default gateway
3. DNS-server

## Netwerkinstellingen opvragen

1. IP-adress/netmask: `ip address` (`ip a`)
2. Default gateway: `ip route` (`ip r`)
3. DNS-server:
    - traditionally: `cat /etc/resolv.conf`
    - `systemd-resolved`: `resolvectl dns`

## Wat is het IP-adres van...?

```bash
$ host www.hogent.be
$ dig www.hogent.be
$ nslookup www.hogent.be # old command
```

Wat is *mijn publiek* IP-adres?

```bash
$ curl icanhazip.com
81.164.175.191
```

## Controleer eerst netwerkinstellingen

(op de AlmaLinux VM, vóór uitvoeren van labo 3.4)

```bash
hogent@almaserver:~$ ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    altname enx08002743cbc1
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic noprefixroute enp0s3
       valid_lft 86250sec preferred_lft 86250sec
```

Probeer dit ook op de Linux GUI VM. Overeenkomsten? Verschillen?

## Netwerkinstellingen

Probeer ook:

- `ip a show dev enp0s3`
- `ip -br a`
- `ip -6 a`
- `ip link` of `ip l`
- `ip route`, `ip -6 route`
- `ip neigh` of `ip n`

Tip: tab-completion werkt ook (mits installatie `bash-completion`)

## Verwachte IP-adressen

Voor deze opstelling:

- `lo` (loopback): 127.0.0.1/8
- `eth0`/`enp0s3` = 1e VirtualBox adapter (NAT): 10.0.2.15/24
- `eth1`/`enp0s8` = 2e VirtualBox adapter (intnet):
    - GUI VM: 192.168.76.10/24
    - AlmaLinux: 192.168.76.254/24

## Netwerkconfiguratie opvragen (EL10)

Met NetworkManager, via `nmcli`. Probeer:

```console
$ nmcli connection show
$ nmcli -f ipv4 connection show enp0s3
$ nmcli device status
$ nmcli device show enp0s3
$ nmcli -f IP4 device show enp0s3
```

## Vast IP-adres instellen (EL10)

```console
hogent@almaserver:~$ sudo nmcli connection modify enp0s8 ipv4.method static ipv4.addresses 192.168.76.254/24
hogent@almaserver:~$ sudo nmcli connection up enp0s8 
Connection successfully activated (D-Bus active path: /org/freedesktop/NetworkManager/ActiveConnection/6)
hogent@almaserver:~$ ip -br -4 a show dev enp0s8
enp0s8           UP             192.168.76.254/24
```

Configuratiebestanden: `/etc/NetworkManager/system-connections/`

## Netwerkconfiguratie aanpassen (Debian 13)

Configuratiebestand `/etc/network/interfaces`

Voorbeeld met DHCP:

```conf
# DHCP
allow-hotplug enp0s3
iface enp0s3 inet dhcp
iface enp0s3 inet6 auto
pre-up sleep 2
```

## Netwerkconfiguratie aanpassen (Debian 13)

Voorbeeld met vast IP-adres:

```conf
# Static
allow-hotplug enp0s8
iface enp0s8 inet static
    address 192.168.76.13
    netmask 255.255.255.0
```

## Wijzigingen toepassen (Debian 13):

```bash
sudo ifdown enp0s8; sudo ifup enp0s8
```

of

```bash
sudo systemctl restart networking
```

# Let's install ISC DHCP!

## Installatie

Let op: kan niet op EL10!

Zoek de naam van de package om ISC DHCP te installeren!

## Configuratie

Zie opgave labo 3.4

- Configbestand: `/etc/dhcp/dhcpd.conf`
- Zie voorbeeld: `/usr/share/doc/dhcp-server/dhcpd.conf.example`
- Wat hebben we nodig voor onze opstelling?

## Opstarten `systemctl`

- `sudo systemctl start dhcpd`
- `systemctl status dhcpd`
- `sudo systemctl restart dhcpd`
    - Na elke wijziging config!
- `sudo systemctl enable [--now] dhcpd`
    - Start altijd bij booten
    - `--now` start meteen

# Let's install Kea!

## Installatie

- Zoek de naam van de package om ISC Kea te installeren!
- Installeer ook de documentatie-package!

## Configuratie

Zie <https://hogenttin.github.io/linux-training-hogent/opslinux/dhcp_kea/>

- Configbestand: `/etc/kea/kea-dhcp4.conf`
- Zie voorbeeld: `/usr/share/doc/kea/examples/kea4/single-subnet.json`
- Wat hebben we nodig voor onze opstelling? Pas aan!

## Opstarten `systemctl`

- `sudo systemctl start kea-dhcp4`
- `systemctl status kea-dhcp4`
- `sudo systemctl restart kea-dhcp4`
  - Na elke wijziging config!
- `sudo systemctl enable [--now] kea-dhcp4`

# Opstelling testen

## Sluit de GUI VM aan op intnet

- Pas netwerkconfiguratie aan (automatisch via DHCP)
- Vang netwerkverkeer op met `tcpdump`, bv.
    - `sudo tcpdump -w dhcp.pcap -i eth1 port 67 or port 68`
    - `sudo tcpdump -r dhcp.pcap -ne#`
    - Open het bestand met Wireshark
- Krijgt je VM een IP-adres? welk?
- Zie je iets in de DHCP logs?
    - `sudo journalctl -f -u dhcpd.service`
    - `sudo journalctl -f -u kea-dhcp4.service`
- Kan je pingen tussen de VMs?
- Heb je Internet-toegang? Waarom (niet)?
- Zoek via de man-page voor dhcpd waar DHCP leases bijgehouden worden

## Volgende weken

- Vanaf nu werken we meestal met meerdere VMs
- Zorg ervoor dat je de opstelling snel kan reproduceren!
