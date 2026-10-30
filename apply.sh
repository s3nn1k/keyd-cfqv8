#!/usr/bin/env bash
set -euo pipefail

CONFIG_PATH="/etc/keyd/cfqv8.conf"
LEGACY_CONFIG_PATH="/etc/keyd/nova.conf"
TEMPLATE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/nova.conf"
KEYBOARD_NAME="AT Translated Set 2 keyboard"

die() {
    echo "apply: $1" >&2
    exit 1
}

normalize_id() {
    local raw
    raw="$(printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]')"
    printf '%s\n' "$raw" | grep -Eq '^[0-9a-f]{1,4}:[0-9a-f]{1,4}$' || return 1
    printf '%04x:%04x\n' "0x${raw%%:*}" "0x${raw##*:}"
}

print_detected_ids() {
    awk -v keyboard="$KEYBOARD_NAME" '
        $1 == "I:" {
            vendor = $3
            product = $4
            sub("^Vendor=", "", vendor)
            sub("^Product=", "", product)
        }
        $1 == "N:" && index($0, "Name=\"" keyboard "\"") {
            print vendor ":" product
        }
    ' /proc/bus/input/devices | sort -u
}

restore_previous() {
    if [[ -n "$previous_config" ]]; then
        cp "$previous_config" "$CONFIG_PATH"
    else
        rm -f "$CONFIG_PATH"
    fi
}

[[ $EUID -eq 0 ]] || die "запускай через sudo: sudo $0"
command -v keyd >/dev/null || die "keyd не найден - установи keyd (см. Readme.md)"
[[ -f "$TEMPLATE_PATH" ]] || die "нет шаблона $TEMPLATE_PATH"

manual_id=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --id)
            [[ $# -ge 2 ]] || die "--id ожидает значение вида 0001:0001"
            manual_id="$2"
            shift 2
            ;;
        *)
            die "неизвестный аргумент: $1; использование: sudo ./apply.sh [--id vend:prod]"
            ;;
    esac
done

keyboard_id=""
if [[ -n "$manual_id" ]]; then
    keyboard_id="$(normalize_id "$manual_id")" || die "--id: ожидался id вида 0001:0001, получен '$manual_id'"
else
    [[ -r /proc/bus/input/devices ]] || die "/proc/bus/input/devices недоступен - передай --id 0001:0001"
    detected=()
    while IFS= read -r candidate; do
        detected+=("$candidate")
    done < <(print_detected_ids)
    case "${#detected[@]}" in
        0)
            die "клавиатура \"$KEYBOARD_NAME\" не найдена - передай --id 0001:0001 (id из sudo keyd monitor)"
            ;;
        1)
            keyboard_id="$(normalize_id "${detected[0]}")"
            ;;
        *)
            echo "apply: найдено несколько совпадений, укажи один через --id:" >&2
            printf 'apply:   %s\n' "${detected[@]}" >&2
            exit 1
            ;;
    esac
    if [[ -t 0 ]]; then
        read -r -p "Применить nova-42 для $keyboard_id? [y/N] " answer
        answer="$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')"
        [[ "$answer" == "y" ]] || die "прервано"
    fi
fi

rendered="$(mktemp)"
previous_config=""
cleanup() {
    rm -f "$rendered"
    [[ -z "$previous_config" ]] || rm -f "$previous_config"
}
trap cleanup EXIT

sed "s|__KEYBOARD_IDS__|$keyboard_id|" "$TEMPLATE_PATH" > "$rendered"
if grep -q "__KEYBOARD_IDS__" "$rendered"; then
    die "подстановка не удалась: остался плейсхолдер в $TEMPLATE_PATH"
fi

install -d -m 755 /etc/keyd
if [[ -f "$CONFIG_PATH" ]]; then
    previous_config="$(mktemp)"
    cp "$CONFIG_PATH" "$previous_config"
fi
install -m 644 "$rendered" "$CONFIG_PATH"

if ! keyd check "$CONFIG_PATH"; then
    restore_previous
    die "keyd check провалился - предыдущий конфиг восстановлен"
fi

rm -f "$LEGACY_CONFIG_PATH"
if [[ -d /run/systemd/system ]] && command -v systemctl >/dev/null; then
    systemctl restart keyd
else
    echo "apply: systemd не обнаружен - перезапусти keyd вручную" >&2
fi

echo "apply: $CONFIG_PATH установлен для $keyboard_id"
