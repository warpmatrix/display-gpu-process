# GPU Process Monitor

## Quick Start

Install the scripts and the dependence `prettytable`:

```bash
git submodule update --init
sudo install prettytable.sh/prettytable /usr/local/bin/
sudo install ./display_gpu_process.sh /usr/local/bin/
```

Then, you can query process by running command `display-gpu-process.sh`.

## Share Result over the Web

1. Download the latest [`ttyd`](https://github.com/tsl0922/ttyd/releases), for example:

    ```bash
    curl -LO https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.$(arch)
    mv ttyd.$(arch) ttyd
    chmod +x ./ttyd
    sudo install ./ttyd /usr/local/bin/
    ```

2. Start up the monitor server

    ```bash
    ttyd display-gpu-process.sh
    ```

## Enable Automatic Start-up

You can leverage `systemd` to automatic start-up the monitor server.

```bash
mkdir -p ~/.config/systemd/user
cp ./systemd/gpu-monitor.service ~/.config/systemd/user/
systemctl --user enable gpu-monitor.service
systemctl --user start gpu-monitor.service
```

Besides, you can start-up the server right after boot and keep it running without any open session by enable lingering for your own user.

```bash
loginctl enable-linger
```
