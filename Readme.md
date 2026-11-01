# keyd-cfqv8

Раскладка nova-42 для встроенной JIS-клавиатуры Panasonic Let's note CF-QV8 (keyd).
`apply.sh` определяет id клавиатуры, подставляет его в `nova.conf` вместо
`__KEYBOARD_IDS__`, устанавливает конфиг в `/etc/keyd/cfqv8.conf`, затем включает и
перезапускает keyd.

## Карта раскладки

- Левая колонка: Tab -> `` ` ``, CapsLock -> Tab, Shift -> `]`
- Muhenkan -> слой Raise, Henkan -> Enter, Katakana -> слой Lower, AltL -> Escape,
  Menu/Compose -> Backspace
- Home-row моды (удержание 200 мс): a/; -> Control, s/l -> Alt, d/k -> Meta, f/j -> Shift
- Аккорд Muhenkan+Henkan -> слой `std`, таймаут аккорда 100 мс (`chord_timeout`)
- Погашены (noop): escape, backspace, enter, f1-f12, 1-0, minus, equal, стрелки, insert,
  delete, home, end, pageup, pagedown, sysrq, print, scrolllock, pause, numlock, rightalt,
  rightbrace, backslash, grave, yen, zenkakuhankaku, leftcontrol, rightcontrol, rightmeta,
  rightshift, leftmeta

## Установка keyd

- Fedora: `sudo dnf copr enable alternateved/keyd && sudo dnf install keyd`
- Arch: `sudo pacman -S keyd`
- Прочие дистрибутивы: апстрим - https://github.com/rvaiya/keyd

## Применение

```bash
sudo ./apply.sh
```

При неудаче автодетекта или нескольких совпадениях: `sudo ./apply.sh --id 0001:0001` (id
видно в `sudo keyd monitor`).

## xremap

Эксперимент Super-C/V через xremap: ставится и запускается bootstrap'ом dotfiles-fedora
автоматически; отдельный запуск `./scripts/xremap-apply.sh` из активной Sway-сессии -
для переустановки или отладки. Полный откат: `sudo systemctl --user stop xremap.service`
(до следующего resume) и `sudo rm /usr/lib/systemd/system-sleep/xremap-resume.sh`
(навсегда). Подробности - `xremap/README.md`.
