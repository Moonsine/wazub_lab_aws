# 02. Wazuh server install

## Prepare the server

```bash
lsb_release -a        # confirm Ubuntu 24.04
nproc                 # CPUs
free -h               # RAM
df -h /               # disk
sudo apt update && sudo apt upgrade -y
sudo reboot
```

If a pager (`less`) opens after the update list, press `q`. On a purple service-restart screen, press Enter to accept the defaults.

## Swap (insurance for a small instance)

```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab   # make it permanent
swapon --show
```

Without the `/etc/fstab` line, swap disappears after every stop/start. `swapoff` printing "Invalid argument" on a file that is not active yet is harmless.

## Install

Check the **Quickstart** page at documentation.wazuh.com for the current command. At the time of this build it was:

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh && sudo bash ./wazuh-install.sh -a
```

Tips:

- Run it inside `tmux` so a dropped SSH session does not kill a 10 to 15 minute install.
- At the end the installer prints the **admin username and password**. Save the password to a password manager immediately. Do not paste it into chats, tickets or screenshots.
- The installer also creates `wazuh-install-files.tar` in the home folder. It contains the original credentials. If you lose the password, you can print it:

```bash
sudo tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

## First login

1. Open `https://<SERVER_PUBLIC_IP>` and accept the certificate warning.
2. Log in as `admin`.
3. The overview shows 0 agents until you enroll one. The server's own events (sudo, SSH logins, package changes) already produce alerts.

For a production setup, change the default password with Wazuh's password tool and remove `wazuh-install-files.tar`. In this practice lab the dashboard is reachable only from one IP, so the password was kept.

## After every stop and start

1. Copy the new public IP.
2. Update the security-group rules that use your own IP.
3. Check the three services if the dashboard does not load after 2 to 3 minutes:

```bash
sudo systemctl status wazuh-indexer wazuh-manager wazuh-dashboard
```
