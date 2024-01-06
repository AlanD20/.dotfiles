# Applications

## Programs

- [Docker Desktop (experimental)](https://docs.docker.com/desktop/install/archlinux/)

## Resources

- To Install `EasyEffects`, install the following packages.

  ```bash
  sudo pacman -S easyeffects calf lsp-plugins mda.lv2 zam-plugins
  ```

  - on Manjaro, you may need to install the following packages:

    ```bash
    sudo pamac install manjaro-pipewire plasma-pa
    ```

- `Flameshot Screen Capture`: To set shortcut, search for shortcut and add
  `flameshot` application, then set shortcut for `Take Screenshot`.

## Onedrive with Abraunegg

```bash
onedrive # To login

onedrive --synchronize --verbose # Sync everything

# Automatic Sync

## Method 1
onedrive --monitor -m --monitor-internal 60 # a running process that syncs every 60 seconds

## Method 2: Enable as service and configure monitoring in onedrive config
systemctl --user enable onedrive.service
systemctl --user start onedrive.service
```

## Nginx

- On Arch-based distributions, nginx doesn't have `sites-available` and
  `sites-enabled`. If you want to set it up this way, you can import the
  symlinked directory. Or an easier way is to create a `conf.d` directory in
  `/etc/nginx` directory then import all the config files.

  ```bash
  # First Method
  mkdir /etc/nginx/sites-enabled/ /etc/nginx/sites-enabled/;
  include /etc/nginx/sites-enabled/*;

  # Second Method (Easier)
  mkdir /etc/nginx/conf.d
  include /etc/nginx/conf.d/*.conf;
  ```

## PHP

- When you install PHP on arch-distributed system, it installs the latest
  version of PHP, don't put the version when installing PHP from `pacman`.
- Due to previous point, PHP paths don't contain versions such as
  `/etc/php/php.ini` or the `php-fpm.sock` is at `/var/run/php-fpm/php-fpm.sock`
  that has `http` group.

### xdebug Setup

- Follow the official documentation if necessary,
  [here](https://xdebug.org/docs/install).

**Make sure you haven't missed any of the following steps:**

- Install `php debug` extension by `xdebug` on vscode.
- Install xdebug, using pacman:

  ```bash
  pacman -S xdebug
  ```

- Create `xdebug.ini` file at `/etc/php/conf.d` or modify the existing one. If
  you are using `docker-php-ext-enable` command to enable extensions, it creates
  its own `ini` file that starts with `docker-php-ext-<ext_name>`. After that,
  make sure it has the following content.

  ```ini
  [xdebug]
  zend_extension=xdebug.so
  xdebug.mode="debug,develop,trace"
  xdebug.remote_enable=on
  xdebug.log=/tmp/xdebug.log
  # The server IP that hosts xdebug server
  xdebug.client_host="host.docker.internal"
  xdebug.client_port=9003
  xdebug.remote_handler=dbgp
  xdebug.start_with_request=yes
  ```

- If you are using docker, don't forget to allow communication between
  container/host.

  ```bash
  # Docker flag
  --add-host=host.docker.internal:host-gateway

  # Docker compose
  extra_hosts:
    - "host.docker.internal:host-gateway"
  ```

- Restart all the services that is using native PHP server, i.e, fpm, web server

- Run the following function to check if it works:

  ```bash
  php -r "xdebug_info();"
  ```

- If it says `xdebug.so` not found, make sure to provide the full path, on
  Linux, it's usually at `/usr/lib/php/modules/xdebug.so` or use a simple find
  pattern
  ```bash
  find / -iname xdebug
  ```
- Here is a simple Dockerfile to run php-fpm-alpine and setup xdebug

  ```Dockerfile
  ARG PHP_VERSION=8.2
  FROM php:$PHP_VERSION-fpm-alpine
  RUN apk update && apk upgrade --no-cache

  # Xdebug tools
  # Tools to compile xdebug
  RUN apk add autoconf g++ make --no-cache\
      && apk add --update linux-headers --no-cache \
      # Install via pecl
      pecl install -f xdebug \
      # Enable extension, config at $PHP_INI_DIR/conf.d/docker-php-ext-xdebug.ini
      && docker-php-ext-enable xdebug \
      # Cleanup
      && rm -rf /tmp/pear\
      && apk del --purge autoconf g++ make
  ```

## A2DP Bluetooth Connection

Here is how you may pair and connect your device using `bluetoothctl`

```bash
bluetoothctl

# Turn on scanning to get your device mac address
[host] scan on

# After getting the mac address, you may pair it
[host] pair <mac-address>

# Show paired devices with its ma address
[host] devices

# After pairing successfully, you may connect to it.
[host] connect <mac-address>

# You may set the device trusted
[host] trust <mac-address>
```

## Troubleshooting

- There is no bluetooth controller to select? Try to unload and load bluetooth
  modules. [Credit](https://unix.stackexchange.com/a/707841)

  ```bash
  rmmod btusb
  rmmod btintel

  modprobe btintel
  modprobe btusb
  ```
