#!/usr/bin/env bash
# Установка powermode (запускать от обычного пользователя: bash install.sh)
set -e
cd "$(dirname "$0")"
[ "$(id -u)" = 0 ] && { echo "Запускайте БЕЗ sudo: bash install.sh (sudo спросится внутри)"; exit 1; }

# 1. Зависимости для иконки в трее
if ! python3 -c "import gi; gi.require_version('AyatanaAppIndicator3','0.1')" 2>/dev/null; then
  echo "Ставлю зависимости для иконки (apt)..."
  sudo apt-get install -y python3-gi gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator
fi

# 2. Основной скрипт, сохранённый режим, служба и хук сна
sudo install -m755 powermode /usr/local/bin/powermode
[ -f /etc/powermode ] || echo eco | sudo tee /etc/powermode >/dev/null
sudo install -m644 powermode.service /etc/systemd/system/powermode.service
sudo install -m755 powermode-sleep /usr/lib/systemd/system-sleep/powermode
sudo systemctl daemon-reload
sudo systemctl enable --now powermode.service

# 3. Переключение без пароля (по желанию)
read -r -p "Разрешить переключать режим без пароля (sudoers только для powermode)? [y/N] " a
if [[ "$a" =~ ^[yYдД] ]]; then
  tmp=$(mktemp); echo "$USER ALL=(root) NOPASSWD: /usr/local/bin/powermode" > "$tmp"
  sudo visudo -cf "$tmp" && sudo install -m440 -o root -g root "$tmp" /etc/sudoers.d/powermode
  rm -f "$tmp"
fi

# 4. Иконка в трее + автозапуск
install -Dm755 powermode-tray "$HOME/.local/bin/powermode-tray"
mkdir -p "$HOME/.config/autostart"
sed "s|@HOME@|$HOME|" powermode-tray.desktop > "$HOME/.config/autostart/powermode-tray.desktop"
pkill -f powermode-tray 2>/dev/null || true
nohup "$HOME/.local/bin/powermode-tray" >/dev/null 2>&1 &

echo; powermode status
echo "Готово. Режимы: sudo powermode eco | max | status (или кнопка в трее)."
