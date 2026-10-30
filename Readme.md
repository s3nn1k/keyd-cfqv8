# keyd-cfqv8

Раскладка nova-42 для встроенной JIS-клавиатуры Panasonic Let's note CF-QV8 (keyd).
`apply.sh` определяет id клавиатуры, подставляет его в `nova.conf` вместо `__KEYBOARD_IDS__`
и устанавливает конфиг в `/etc/keyd/cfqv8.conf`.

## Карта раскладки

- Левая колонка: Tab -> `` ` ``, CapsLock -> Tab, Shift -> `]`
- AltL/Muhenkan -> слой Raise, Henkan -> Enter, Katakana -> слой Lower, Menu -> Backspace
- Home-row моды: a/s/d/f и j/k/l/; -> Control/Alt/Meta/Shift, удержание 200 мс
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

При неудаче автодетекта или нескольких совпадениях: `sudo ./apply.sh --id 0001:0001`
(id видно в `sudo keyd monitor`).
