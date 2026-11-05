# xremap

Run as the normal user from an active Fedora Sway session:

```sh
./scripts/xremap-apply.sh
```

Installer adds pinned xremap and narrow uaccess rules and enables autostart in
graphical-session.target.
Live-check `xremap --desktop wlroots --list-windows`; test global/foot/footclient
Super+C/V, Shift+Super+C reload, US/RU, and keyd restart reattach. Missing `getfacl`:
`sudo dnf install acl`, then rerun.

Manual start from Sway (fallback):

```sh
systemctl --user import-environment WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
systemctl --user start xremap.service
```

Rollback: `systemctl --user disable --now xremap.service` (until the next resume); full
rollback is `sudo rm /usr/lib/systemd/system-sleep/xremap-resume.sh` (permanent);
udev/module remains.
