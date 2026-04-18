#!/usr/bin/env bash

set -e

NVIM_VERSION="v0.12.1"
NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
INSTALL_DIR="$HOME/.local"
CONFIG_DIR="$HOME/.config/nvim"

# Versiones de runtimes (sincronizar con ~/.tool-versions)
NODE_VERSION="25.9.0"
PYTHON_VERSION="3.14.4t"
PHP_VERSION="8.4.20"
JAVA_VERSION="temurin-21.0.7+6.0.LTS"
ERLANG_VERSION="28.4.2"
ELIXIR_VERSION="1.19.5-otp-28"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC}  $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
step() { echo -e "\n${YELLOW}==>${NC} $1"; }

# ─── Sistema ─────────────────────────────────────────────────────────────────

step "Instalando dependencias del sistema..."

PKGS=()
command -v make   &>/dev/null || PKGS+=(make)
command -v git    &>/dev/null || PKGS+=(git)
command -v curl   &>/dev/null || PKGS+=(curl)
command -v tar    &>/dev/null || PKGS+=(tar)
command -v unzip  &>/dev/null || PKGS+=(unzip)
command -v xclip  &>/dev/null || PKGS+=(xclip)
command -v rg     &>/dev/null || PKGS+=(ripgrep)
# dependencias para compilar parsers de treesitter y asdf
command -v gcc    &>/dev/null || PKGS+=(gcc)
dpkg -l libssl-dev &>/dev/null 2>&1    || PKGS+=(libssl-dev)
dpkg -l libreadline-dev &>/dev/null 2>&1 || PKGS+=(libreadline-dev)
dpkg -l zlib1g-dev &>/dev/null 2>&1   || PKGS+=(zlib1g-dev)

if [ ${#PKGS[@]} -gt 0 ]; then
  echo "  Instalando: ${PKGS[*]}"
  sudo apt-get update -q
  sudo apt-get install -y "${PKGS[@]}" || fail "No se pudieron instalar los paquetes"
  ok "Paquetes del sistema instalados"
else
  ok "Dependencias del sistema OK"
fi

# ─── asdf ────────────────────────────────────────────────────────────────────

step "Verificando asdf..."

if [ ! -f "$HOME/.asdf/asdf.sh" ]; then
  echo "  Instalando asdf..."
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
  echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
  ok "asdf instalado — reinicia tu shell después"
else
  ok "asdf $(cat ~/.asdf/version.txt 2>/dev/null || echo 'instalado')"
fi

# Cargar asdf en este script
export ASDF_DATA_DIR="$HOME/.asdf"
export PATH="$ASDF_DATA_DIR/bin:$ASDF_DATA_DIR/shims:$PATH"
. "$HOME/.asdf/asdf.sh" 2>/dev/null || true

# ─── Node.js ─────────────────────────────────────────────────────────────────

step "Verificando Node.js ${NODE_VERSION}..."

if ! command -v node &>/dev/null || ! node --version | grep -q "${NODE_VERSION%%.*}"; then
  asdf plugin add nodejs 2>/dev/null || true
  asdf install nodejs "$NODE_VERSION"
  asdf set --home nodejs "$NODE_VERSION"
  ok "Node.js ${NODE_VERSION} instalado"
else
  ok "Node.js $(node --version)"
fi

# ─── npm global packages ──────────────────────────────────────────────────────

step "Instalando paquetes npm globales..."

install_npm_pkg() {
  local pkg=$1
  if npm list -g --depth=0 2>/dev/null | grep -q "$pkg"; then
    ok "$pkg ya instalado"
  else
    npm install -g "$pkg"
    ok "$pkg instalado"
  fi
}

# neovim: provider para plugins que usan RPC con node
install_npm_pkg "neovim"
# tree-sitter-cli: requerido por nvim-treesitter para compilar parsers
install_npm_pkg "tree-sitter-cli"

# ─── Python ──────────────────────────────────────────────────────────────────

step "Verificando Python ${PYTHON_VERSION}..."

if ! command -v python3 &>/dev/null; then
  asdf plugin add python 2>/dev/null || true
  asdf install python "$PYTHON_VERSION"
  asdf set --home python "$PYTHON_VERSION"
  ok "Python ${PYTHON_VERSION} instalado"
else
  ok "Python $(python3 --version 2>&1 | cut -d' ' -f2)"
fi

# pynvim: provider python para nvim
if ! python3 -c "import pynvim" &>/dev/null; then
  pip install pynvim
  ok "pynvim instalado"
else
  ok "pynvim ya instalado"
fi

# ─── PHP ──────────────────────────────────────────────────────────────────────

step "Verificando PHP ${PHP_VERSION}..."

if ! command -v php &>/dev/null; then
  asdf plugin add php 2>/dev/null || true
  asdf install php "$PHP_VERSION"
  asdf set --home php "$PHP_VERSION"
  ok "PHP ${PHP_VERSION} instalado"
else
  ok "PHP $(php --version | head -1 | cut -d' ' -f2)"
fi

# Composer: requerido por intelephense (LSP PHP)
if ! command -v composer &>/dev/null; then
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
  ok "Composer instalado"
else
  ok "Composer $(composer --version 2>/dev/null | cut -d' ' -f3)"
fi

# ─── Java ─────────────────────────────────────────────────────────────────────

step "Verificando Java..."

if ! command -v java &>/dev/null; then
  asdf plugin add java 2>/dev/null || true
  asdf install java "$JAVA_VERSION"
  asdf set --home java "$JAVA_VERSION"
  ok "Java ${JAVA_VERSION} instalado"
else
  ok "Java $(java -version 2>&1 | head -1 | cut -d'"' -f2)"
fi

# ─── Erlang + Elixir (para elixirls) ─────────────────────────────────────────

step "Verificando Erlang + Elixir..."

if ! command -v erl &>/dev/null; then
  asdf plugin add erlang 2>/dev/null || true
  asdf install erlang "$ERLANG_VERSION"
  asdf set --home erlang "$ERLANG_VERSION"
  ok "Erlang ${ERLANG_VERSION} instalado"
else
  ok "Erlang $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell 2>/dev/null)"
fi

if ! command -v elixir &>/dev/null; then
  asdf plugin add elixir 2>/dev/null || true
  asdf install elixir "$ELIXIR_VERSION"
  asdf set --home elixir "$ELIXIR_VERSION"
  ok "Elixir ${ELIXIR_VERSION} instalado"
else
  ok "Elixir $(elixir --version 2>/dev/null | head -1)"
fi

# ─── lazygit ─────────────────────────────────────────────────────────────────

step "Verificando lazygit..."

if ! command -v lazygit &>/dev/null; then
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
  rm /tmp/lazygit /tmp/lazygit.tar.gz
  ok "lazygit instalado"
else
  ok "lazygit $(lazygit --version 2>/dev/null | grep -o 'version=[^ ]*' | cut -d= -f2)"
fi

# ─── Neovim ──────────────────────────────────────────────────────────────────

step "Instalando Neovim ${NVIM_VERSION}..."

if command -v nvim &>/dev/null && nvim --version 2>/dev/null | grep -q "${NVIM_VERSION}"; then
  ok "Neovim ${NVIM_VERSION} ya instalado"
else
  echo "  Descargando Neovim ${NVIM_VERSION}..."
  curl -Lo /tmp/nvim-linux-x86_64.tar.gz "$NVIM_URL" || fail "Error descargando Neovim"
  tar -xzf /tmp/nvim-linux-x86_64.tar.gz -C /tmp
  mkdir -p "$INSTALL_DIR/bin"
  cp /tmp/nvim-linux-x86_64/bin/nvim "$INSTALL_DIR/bin/nvim"
  sudo cp -r /tmp/nvim-linux-x86_64/share/nvim /usr/local/share/nvim
  rm -rf /tmp/nvim-linux-x86_64 /tmp/nvim-linux-x86_64.tar.gz
  ok "Neovim ${NVIM_VERSION} instalado en ${INSTALL_DIR}/bin/nvim"

  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "Agrega ~/.local/bin a tu PATH en ~/.zshrc:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
  fi
fi

# ─── Directorio de logs ───────────────────────────────────────────────────────

step "Creando directorio de logs..."
mkdir -p "$HOME/GDRIVE_NVIM_RESOURCES/logs"
ok "Logs en ~/GDRIVE_NVIM_RESOURCES/logs/"

# ─── Config ───────────────────────────────────────────────────────────────────

step "Verificando config de Neovim..."

if [ ! -f "$CONFIG_DIR/init.lua" ]; then
  warn "No se encontró $CONFIG_DIR/init.lua"
  warn "Clona o copia tu config en $CONFIG_DIR antes de abrir nvim"
else
  ok "Config encontrada en $CONFIG_DIR"
fi

# ─── Fin ──────────────────────────────────────────────────────────────────────

echo ""
echo -e "${GREEN}=== Instalación completa ===${NC}"
echo ""
echo "Próximos pasos:"
echo "  1. Abre nvim — lazy.nvim instalará todos los plugins automáticamente"
echo "  2. Espera a que Mason instale los LSP servers"
echo "  3. Reinicia nvim"
echo ""
echo "  nvim"
