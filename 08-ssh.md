---
title: "8. Secure Shell (SSH)"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Thomas Parmentier, Andy Van Maele, Bert Van Vreckem, Jan Willem
date: 2025-2026
---

# SSH

## Log in on a remote system: SSH

Verbinden met een remote server, via URL of IP-adres

```console
$ ssh <URL> | <IP-address>
$ ssh remote.hogent.be | 192.168.76.254
```

Login naam toevoegen:

```console
$ ssh -l <login name> 192.168.76.254
$ ssh <login name>@192.168.76.254
$ ssh -l vagrant 192.168.76.254
$ ssh vagrant@192.168.76.254
```

## password vs keypair

```text
debug1: Authentications that can continue: publickey,password
```

## password

- Linux user/password combinatie
- Wachtwoord vergeleken met hash string uit `/etc/shadow`

## keypair

- klassiek: RSA keypair
- generate with `ssh-keygen`, e.g.

```bash
$ ssh-keygen -t rsa-sha2-512
Generating public/private rsa-sha2-512 key pair.
Enter file in which to save the key (.ssh/id_rsa):
```

## RSA (1977-...) - SHA-1 (1995-2013)

RSA keys are not deprecated; SHA-1 signature scheme is!

- eerste public/private key algoritme
  (Ron Rivest, Adi Shamir en Len Adleman)
- vroeger default als SSH-keypair: RSA; deprecated aug/2021 (SHA-1 issue)
  <https://www.openssh.com/txt/release-8.7>
- voorganger DSA: deprecated aug/2015
  <https://www.openssh.com/txt/release-7.0> (ssh-dss)

---

Gevolgen:

- oude RSA keys met SHA-1 werken nog op oude servers, maar niet meer op nieuwere
- bijwerken van SSH software kan de oude RSA key onbruikbaar maken

Keypairs anno 2022: rsa-sha2-256/512, ssh-ed25519, ECDSA

## persoonlijke ssh bestanden

```console
$ ls .ssh/
authorized_keys  id_ecdsa  id_ecdsa.pub  known_hosts
```

- known_hosts: `fingerprint` van elke server waarmee je al verbonden was
- authorized_keys: publieke keys die kunnen inloggen op jouw account
- id_ecdsa: jouw private ECDSA key `(perm 600)`
- id_ecdsa.pub:  jouw publieke ECDSA key

## SSH server configuratie

```console
$ ls /etc/ssh/
$ ls /etc/ssh/ | grep config
ssh_config
sshd_config
```

Configuratie van de server daemon: `sshd_config`

```bash
#Port 22
#ListenAddress 0.0.0.0
PermitRootLogin prohibit-password
UsePAM yes
```

Configuratie van de client opties: `ssh_config`

```bash
HostKeyAlgorithms=-ssh-rsa
StrictHostKeyChecking accept-new
```

## SSH key checking

```console
$ ssh -p 2222 osboxes@localhost
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ED25519 key sent by the remote host is
SHA256:WaS4xm8g/lJFkWsUTw3mLF0FqiDOqolH2Sn1nNUwLtM.
Please contact your system administrator.
Add correct host key in /home/bert/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/bert/.ssh/known_hosts:14
Host key for [localhost]:2222 has changed and you have requested strict checking.
Host key verification failed.
```
