## Automatic DDoS Server Starter from IT Army Ukraine (ADSS)

ADSS is a Shell script that automatically updates itself and determines the version, bitness, and distribution of your Linux OS.

Tested support for the current version :

Ubuntu, Debian, Fedora, Centos, Arch Linux, Kali Linux, Parrot Security OS, Rocky Linux, AlmaLinux OS, Manjaro, Oracle Linux, Void Linux (х86,х64,arm)

#### [Українська версія - нажміть сюди](/README.md)
#### 💁 [Technical support](https://t.me/+H6PnjkydZX0xNDky)

### 💽 Installation

Use this command for installation :

```
curl -sL https://raw.githubusercontent.com/it-army-ua-scripts/ADSS/install/install.sh  | bash -s
```

During the installation, the script automatically installs the necessary packages :

`zip, unzip, gnupg, ca-certificates, curl, git, dialog`

Working directory:

`/opt/itarmy`

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

View current ADSS settings :

```
adss config
```

Uninstall ADSS :

```
adss --uninstall
```

### ✪ Menu items
<details>
<summary>Expand</summary>

- **Install Docker - (optional, not mandatory)**

- **Extend ports (optional, not mandatory):**

To increase the efficiency of DDOS attacks, specifically on the Linux OS, it is necessary to allow a multitude of outgoing network connections, you need to increase the local range of TCP ports. This happens by adding the line `net.ipv4.ip_local_port_range=16384 65535` to the `/etc/sysctl.conf` file.

- **Security Settings - (optional, not mandatory)**
- **Install protection:**

Automatically installs in the INACTIVE state UFW Firewall and protection against bruteforce Fail2ban

- **Security Settings - (optional, not mandatory)**

- **Firewall settings:**

All incoming traffic is prohibited, except for 22/tcp port for connecting to the machine via SSH, all outgoing traffic is allowed.

- **Setting up protection against bruteforce:**

Allows 3 attempts to connect via SSH, in case of unsuccessful attempts (wrong login or password) blocks the attacking ip for 10 minutes.

- **DDOS**

- **Installing DDOS tools:**

Automatic installation of db1000n, distress, mhddos of the appropriate architecture and bit depth for the corresponding machine. For each utility, in addition to downloading, a system service is created. This allows you to monitor its status and in case of a failure or reboot of the machine automatically start it again.

- **DDOS tool management**

- **Attack status:**

View the log of the running utility in real time with automatic update of the output.

- **Setting up auto-launch:**

Automatic start of ddos utility when the machine is turned on\rebooted.

- **Stop the attack:**

The item is displayed only in the case of an active ddos utility.

- **MHDDOS**

- **Start/Stop MHDDOS:**

Changes depending on the current state. Start a ddos attack.

- **Setting up MHDDOS:**

Clear step-by-step fine tuning of the utility to increase\decrease the load on the system, the effectiveness of the attack by adding appropriate launch parameters for the utility. (optional, not mandatory)

- **MHDDOS status:**

Displays the current status of the ddos utility service (active\dead) with the current fine-tuning launch parameters.

- **The "DISTRESS" and "DB1000N" items are similar to "MHDDOS"**

</details>
