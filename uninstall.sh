#!/usr/bin/env bash

set -e

echo "=== Desinstalando Neovim y plugins ==="

# Binarios
echo "Eliminando binarios..."
rm -f ~/.local/bin/nvim
sudo rm -f /usr/local/bin/nvim

# Runtime instalado en /usr/local/share
sudo rm -rf /usr/local/share/nvim

# Datos, plugins, mason, treesitter parsers
echo "Eliminando plugins y datos..."
rm -rf ~/.local/share/nvim

# Estado (shada, logs)
echo "Eliminando estado..."
rm -rf ~/.local/state/nvim

# Cache
echo "Eliminando cache..."
rm -rf ~/.cache/nvim

echo ""
echo "=== Listo ==="
echo "Puedes eliminar ~/.config/nvim manualmente cuando quieras."
