---
title: "5. Hardening van een webserver"
subtitle: "Linux<br/>HOGENT toegepaste informatica"
author: Andy Van Maele, Bert Van Vreckem
date: 2021-2022
---

# Firewall-configuratie

## Firewall-instellingen aanpassen

```console
$ sudo firewall-cmd --list-all  # = toon firewall-regels
$ sudo firewall-cmd --add-service http --permanent
$ sudo firewall-cmd --add-service https --permanent
$ sudo firewall-cmd --reload
```

Probeer opnieuw de website te bekijken vanaf het fysieke systeem

## Zones

- Zone = list of rules to be applied in a specific situation
    - e.g. public (default), home, work, ...
- NICs are assigned to zones
- For a server, `public` zone is probably sufficient

---

| Task                         | Command                              |
| :---                         | :---                                 |
| List all zones               | `firewall-cmd --get-zones`           |
| Current active zone          | `firewall-cmd --get-active-zones`    |
| Add interface to active zone | `firewall-cmd --add-interface=IFACE` |
| Show current rules           | `firewall-cmd --list-all`            |

`firewall-cmd` requires *root permissions*

## Configuring firewall rules

| Task                     | Command                            |
| :---                     | :---                               |
| Allow predefined service | `firewall-cmd --add-service=http`  |
| List predefined services | `firewall-cmd --get-services`      |
| Allow specific port      | `firewall-cmd --add-port=8080/tcp` |
| Reload rules             | `firewall-cmd --reload`            |
| Block all traffic        | `firewall-cmd --panic-on`          |
| Turn panic mode off      | `firewall-cmd --panic-off`         |

## Persistent changes

- `--permanent` option is not applied immediately!
- Two methods:
    1. Execute command once without, once with `--permanent`
    2. Execute command with `--permanent`, reload rules


```console
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --reload
```

# SELinux troubleshooting

## SELinux

- SELinux is Mandatory Access Control in the Linux kernel
- Settings:
    - Booleans: `getsebool`, `setsebool`
    - Contexts, labels: `ls -Z`, `chcon`, `restorecon`
    - Policy modules: `sepolicy`

## Do not disable SELinux

<https://stopdisablingselinux.com/>

## Check file context

- Is the file context as expected?
    - `ls -Z /var/www/html`
- Set file context to default value
    - `sudo restorecon -R /var/www/`
- Set file context to specified value
    - `sudo chcon -t httpd_sys_content_t test.php`

## Check booleans

`getsebool -a | grep http`

- Know the relevant booleans! (RedHat manuals)
- Enable boolean:
    - `sudo setsebool -P httpd_can_network_connect_db on`

## Creating a policy

Let's try to set `DocumentRoot "/vagrant/www"`

```
$ sudo vi /etc/httpd/conf/httpd.conf
$ ls -Z /vagrant/www/
-rw-rw-r--. vagrant vagrant system_u:object_r:vmblock_t:s0   test.php
$ sudo chcon -R -t httpd_sys_content_t /vagrant/www/
chcon: failed to change context of ‘test.php’ to ‘system_u:object_r:httpd_sys_content_t:s0’: Operation not supported
chcon: failed to change context of ‘/vagrant/www/’ to ‘system_u:object_r:httpd_sys_content_t:s0’: Operation not supported
```

## Creating a policy

Instead of setting the files to the expected context, allow httpd to access files with `vmblock_t` context

1. Allow Apache to run in "permissive" mode:

    ```
    $ sudo semanage permissive -a httpd_t
    ```

2. Generate "Type Enforcement" file (.te)

    ```
    $ sudo audit2allow -a -m httpd-vboxsf > httpd-vboxsf.te
    ```

3. If necessary, edit the policy

    ```
    $ sudo vi httpd-vboxsf.te
    ```

---

1. Convert to policy module (.pp)

    ```
    $ checkmodule -M -m -o httpd-vboxsf.mod httpd-vboxsf.te
    $ semodule_package -o httpd-vboxsf.pp -m httpd-vboxsf.mod
    ```

5. Install module

    ```
    $ sudo semodule -i httpd-vboxsf.pp
    ```

6. Remove permissive domain exception

    ```
    $ sudo semanage permissive -d httpd_t
    ```

Tip: automate this!