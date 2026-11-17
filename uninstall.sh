#!/usr/bin/env bash
# Удаление powermode (запускать от обычного пользователя: bash uninstall.sh)
pkill -f powermode-tray 2>/dev/null
rm -f "$HOME/.local/bin/powermode-tray" "$HOME/.config/autostart/powermode-tray.desktop"
sudo systemctl disable --now powermode.service 2>/dev/null
sudo rm -f /etc/systemd/system/powermode.service /usr/lib/systemd/system-sleep/powermode \
           /usr/local/bin/powermode /etc/sudoers.d/powermode /etc/powermode
sudo systemctl daemon-reload
echo "Удалено. Лимиты CPU/GPU сбросятся при перезагрузке (GPU сразу: sudo nvidia-smi -rgc)."
