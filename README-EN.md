## Automatic DDoS Server Starter from IT Army Ukraine (ADSS)

ADSS is a Shell script that automatically updates itself and determines the version, bitness, and distribution of your Linux OS.

Tested support for the current version - ubuntu, debian, fedora, centos (х86,х64,arm)

#### [Українська версія - нажміть сюди](/README.md)
#### 💁 [Technical support](https://t.me/+H6PnjkydZX0xNDky)

### 💽 Installation

Use this command for installation :

```
source <(curl -s https://raw.githubusercontent.com/it-army-ua-scripts/ADSS/install/install.sh)
```

During the installation, the script automatically installs the necessary packages :

`zip, unzip, gnupg, ca-certificates, curl, git, dialog`

### 🛠 Managing ADSS

To launch ADSS : 

```
adss
```

To launch ADSS in English : 

```
adss --lang en
```

This command automatically installs the necessary DDoS tools for your system, sets up brute force protection, installs a firewall, launches MHDDOS, and adds MHDDOS to system auto-start. The log of the process is displayed in real time :

```
adss --auto-install
```

For full script renovation\reinstallation to default settings :

```
adss --restore
```


