# Battery Charge Limit via TLP (Ubuntu 24.04)

Battery charge thresholds are controlled with [`tlp`](https://linrunner.de/tlp/).

## Install

```sh
sudo apt install tlp tlp-rdw
sudo systemctl enable --now tlp.service
```

## Configure thresholds

Edit `/etc/tlp.conf`:

```
START_CHARGE_THRESH_BAT0=75
STOP_CHARGE_THRESH_BAT0=80
```

Apply:

```sh
sudo tlp start
```

## Verify

```sh
sudo tlp-stat -b
```
