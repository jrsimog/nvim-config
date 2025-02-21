# Configuración de Neovim

Esta es mi configuración personalizada de **Neovim**, optimizada para **Elixir, PHP (Laravel/Symfony), JavaScript, TypeScript y más**. Utiliza **Lazy.nvim** como gestor de plugins y está diseñada para ser **portátil** y fácil de desplegar en cualquier máquina.

---

##  Características Principales

✅ **Gestión de Plugins con Lazy.nvim**  
✅ **LSP y Autocompletado (Intelephense, ElixirLS, etc.)**  
✅ **Explorador de archivos con Nvim-Tree y Bufferline**  
✅ **Telescope para búsquedas avanzadas**  
✅ **Alpha.nvim como pantalla de inicio personalizada**  
✅ **Project.nvim para detección de proyectos**  
✅ **Perfiles de desarrollo (PHP, Elixir, etc.)**  

---

## 🔧 Instalación

### **1️ Clonar el Repositorio**
Ejecuta este comando en tu terminal para descargar la configuración:

```bash
cd ~/.config
rm -rf nvim  # (Si ya tienes una configuración previa)
git clone git@github.com:tu-usuario/nvim-config.git nvim
```

### **2️ Instalar Neovim y Dependencias**
Si Neovim no está instalado, instálalo en **Ubuntu 20.04**:

```bash
sudo apt update
sudo apt install neovim -y
```

O en Arch Linux:
```bash
sudo pacman -S neovim
```

Además, instala las dependencias necesarias:

```bash
sudo apt install ripgrep fd-find git curl fzf -y
```

Si usas **Elixir**, instala `elixir-ls`:
```bash
mix escript.install hex elixir-ls
```

### **3️ Sincronizar los Plugins**
Abre Neovim y ejecuta:

```vim
:Lazy sync
```

Esto instalará todos los plugins automáticamente.

---

##  Perfiles de Desarrollo
Esta configuración permite cargar diferentes **perfiles** según el stack que estés usando. Puedes cambiar de perfil exportando la variable `NVIM_PROFILE` antes de abrir Neovim.

### **Activar un Perfil Específico**
```bash
export NVIM_PROFILE=php
nvim
```

Si no defines un perfil, **Elixir será el perfil por defecto**.

---

##  Atajos de Teclado Claves

| Acción | Atajo |
|--------|-------|
| Abrir/cerrar Nvim-Tree | `<leader>e` |
| Buscar archivos con Telescope | `<leader>ff` |
| Buscar en el contenido de archivos | `<leader>fg` |
| Navegar buffers | `<Tab>` / `<S-Tab>` |
| Cerrar buffer actual | `<leader>bd` |
| Ejecutar Laravel CLI | `<leader>pl` |
| Iniciar servidor Symfony | `<leader>ps` |
| Ejecutar consola de Symfony | `<leader>pc` |

> **Nota:** `<leader>` está configurado como `Space (espacio)`.

---

## Mantener la Configuración Actualizada
Si haces cambios en la configuración y quieres sincronizarla entre tu casa y la oficina, usa estos comandos:

 **Subir cambios desde tu máquina actual:**
```bash
cd ~/.config/nvim
git add .
git commit -m "Actualización de configuración"
git push origin main
```

 **Actualizar la configuración en otra máquina (ej. oficina):**
```bash
cd ~/.config/nvim
git pull origin main
:Lazy sync
```

Para hacerlo aún más rápido, puedes crear un **alias en `~/.bashrc` o `~/.zshrc`**:
```bash
alias sync-nvim="cd ~/.config/nvim && git pull origin main && nvim"
```
Así, solo tendrás que ejecutar:
```bash
sync-nvim
```

---

##  Solución de Problemas

Si algo no funciona correctamente, prueba estos comandos:

**Verificar que los plugins están instalados:**
```vim
:Lazy list
```

**Verificar que el LSP está activo:**
```vim
:LspInfo
```

**Reinstalar todos los plugins y limpiar caché:**
```vim
:Lazy clean
:Lazy sync
```

Si sigues teniendo problemas, revisa `:checkhealth` en Neovim:
```vim
:checkhealth
```

---

## Licencia
Este proyecto está bajo la licencia **MIT**, lo que significa que puedes modificarlo y adaptarlo libremente.

 **Autor:** José Simo  
 **Configurado para máxima productividad en Neovim**.

