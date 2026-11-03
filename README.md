# dotfiles

## profile

```bash
# for agent-sandbox
tee ~/.config/chezmoi/chezmoi.toml <<EOF
[data]
profile = "agent-sandbox"
EOF
```

## macOS loopback aliases

`system/macos/loopback-aliases.sh` adds `127.17.17.1` through
`127.17.17.254` to `lo0`. The accompanying LaunchDaemon runs it at startup.
These files are not installed by `chezmoi apply`. To install and start them
manually from the repository root:

```sh
sudo install -d -o root -g wheel -m 755 /usr/local/sbin
sudo install -o root -g wheel -m 755 system/macos/loopback-aliases.sh /usr/local/sbin/loopback-aliases.sh
sudo install -o root -g wheel -m 644 system/macos/local.loopback-aliases.plist /Library/LaunchDaemons/local.loopback-aliases.plist
sudo launchctl bootstrap system /Library/LaunchDaemons/local.loopback-aliases.plist
```

- Check the registered service: `sudo launchctl print system/local.loopback-aliases`
- Check the addresses: `ifconfig lo0`
- Reload an already registered service after updating the files: run
  `sudo launchctl bootout system/local.loopback-aliases` before the `bootstrap` command.

