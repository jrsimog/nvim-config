# Configuración Minimalista de Neovim

## Resumen de la Migración

**Respaldo completo creado:**
- Archivo: `~/.config/nvim-backup-20251108-041050.tar.gz` (91MB)

**Nueva estructura creada desde cero:**
```
~/.config/nvim/
├── init.lua                     # Configuración principal con lazy.nvim
├── lua/core/
│   ├── options.lua              # Opciones de Neovim
│   ├── keymaps.lua              # Atajos de teclado
│   └── autocmds.lua             # Autocomandos
├── lua/plugins/
│   ├── mason.lua                # Gestor de LSP servers y formatters
│   ├── mason-lspconfig.lua      # Auto-instalación de LSP servers
│   ├── lspconfig.lua            # Configuración de LSP
│   ├── nvim-cmp.lua             # nvim-cmp para autocompletado
│   ├── autopairs.lua            # Auto-cierre de paréntesis y comillas
│   ├── conform.lua              # Formateo automático de código
│   ├── monokai.lua              # Tema Monokai Pro
│   ├── lualine.lua              # Barra de estado
│   ├── bufferline.lua           # Pestañas de buffers
│   ├── telescope.lua            # Búsqueda fuzzy
│   ├── treesitter.lua           # Syntax highlighting
│   ├── gitsigns.lua             # Indicadores de Git y blame
│   ├── lazygit.lua              # Interfaz de Git
│   ├── diffview.lua             # Visor de diffs de Git
│   ├── project.lua              # Gestión de proyectos
│   ├── other.lua                # Alternancia entre archivos y tests
│   └── colorizer.lua            # Visualización de colores hex/rgb
├── CLAUDE.md                    # Instrucciones para el asistente
└── README.md                    # Esta documentación
```

## Filosofía de la Configuración

Esta configuración fue construida desde cero con un enfoque minimalista:
- Plugins agregados bajo demanda
- Configuración modular y mantenible
- Compatible con Neovim 0.11+
- Prioriza el rendimiento y la simplicidad

## Plugins Instalados

### Core
- **lazy.nvim**: Gestor de plugins con lazy-loading automático

### LSP y Desarrollo
- **mason.nvim**: Gestor de LSP servers, linters y formatters
- **mason-tool-installer.nvim**: Auto-instalación de herramientas
- **mason-lspconfig.nvim**: Integración entre Mason y nvim-lspconfig
- **nvim-lspconfig**: Configuración de Language Server Protocol
- **nvim-cmp**: Motor de autocompletado
- **cmp-nvim-lsp**: Fuente de autocompletado desde LSP
- **cmp-buffer**: Autocompletado desde buffers abiertos
- **cmp-path**: Autocompletado de rutas de archivos
- **LuaSnip**: Motor de snippets
- **cmp_luasnip**: Integración de snippets con nvim-cmp
- **friendly-snippets**: Colección de snippets predefinidos
- **lspkind.nvim**: Iconos para tipos de autocompletado

### Formateo y Edición
- **conform.nvim**: Formateo automático al guardar
- **nvim-autopairs**: Auto-cierre de paréntesis, llaves y comillas

### Syntax Highlighting
- **nvim-treesitter**: Parsing y highlighting avanzado
- **nvim-treesitter-textobjects**: Text objects basados en Treesitter

### Git
- **gitsigns.nvim**: Indicadores de cambios Git y blame en línea
- **lazygit.nvim**: Interfaz TUI para Git
- **diffview.nvim**: Visualizador de diffs y historial de Git

### Productividad
- **neovim-project**: Gestión y cambio rápido entre proyectos
- **neovim-session-manager**: Gestión de sesiones (dependencia)
- **other.nvim**: Alternancia entre archivos fuente y tests

### UI/UX
- **nvim-colorizer.lua**: Visualización de colores hex, rgb, hsl en código
- **monokai.nvim**: Tema Monokai Pro con colores personalizados
- **lualine.nvim**: Barra de estado elegante
- **bufferline.nvim**: Pestañas de buffers en la parte superior
- **telescope.nvim**: Búsqueda fuzzy de archivos y contenido
- **plenary.nvim**: Librería de utilidades (dependencia)
- **nvim-web-devicons**: Iconos para archivos

## LSP Servers Configurados

Los siguientes Language Servers se instalan automáticamente:

| Lenguaje | Server | Funcionalidad |
|----------|--------|---------------|
| Lua | lua_ls | Autocompletado, diagnósticos, definiciones |
| TypeScript/JavaScript | ts_ls | Análisis de código, refactoring |
| HTML | html | Validación, autocompletado de etiquetas |
| CSS | cssls | Propiedades CSS, validación |
| JSON | jsonls | Schemas, validación |
| Python | pyright | Type checking, análisis estático |
| Go | gopls | Herramientas completas de Go |
| Rust | rust_analyzer | Análisis avanzado de Rust |
| C/C++ | clangd | Compilación, navegación de código |
| Elixir | elixirls | Mix tasks, dialyzer |
| Java | jdtls | Eclipse JDT, Maven, Gradle |
| Emmet | emmet_ls | Expansión de abreviaturas HTML/CSS |
| SQL | sqlls | Consultas SQL, validación |
| PHP | intelephense | Autocompletado PHP, navegación |

## Treesitter Parsers

Auto-instalación de parsers para:
- elixir, lua, javascript, typescript, php
- python, html, css, json
- markdown, markdown_inline, http
- sql, bash, vim, vimdoc

## Formateadores

Los siguientes formateadores se instalan automáticamente vía Mason:

| Formateador | Lenguajes |
|-------------|-----------|
| prettier | JavaScript, TypeScript, HTML, CSS, JSON, YAML, Markdown |
| stylua | Lua |
| black | Python |
| isort | Python (imports) |
| sql-formatter | SQL |

**Nota sobre PHP:** El formateo de PHP usa el LSP (Intelephense) como fallback ya que php-cs-fixer requiere PHP en el PATH global.

## Keymaps Principales

### Tecla Líder
**Espacio** (`<Space>`)

### Navegación LSP
- `gd` - Go to definition
- `gr` - Show references
- `K` - Hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol
- `<leader>e` - Show diagnostics
- `[d` - Previous diagnostic
- `]d` - Next diagnostic

### Telescope
- `<leader>ff` - Find files
- `<leader>fg` - Grep text in project (buscar texto case-insensitive)
- `<leader>fb` - Find buffers
- `<leader>fh` - Help tags

### Bufferline
- `<Tab>` - Next buffer
- `<Shift-Tab>` - Previous buffer
- `<leader>x` - Close current buffer
- `<leader>bo` - Close other buffers
- `<leader>br` - Close buffers to the right
- `<leader>bl` - Close buffers to the left
- `<leader>bp` - Pick buffer

### Navegación de Ventanas
- `<C-h>` - Ventana izquierda
- `<C-j>` - Ventana inferior
- `<C-k>` - Ventana superior
- `<C-l>` - Ventana derecha

### Edición
- `<leader>w` - Save file
- `<leader>q` - Quit
- `J` (visual) - Move line down
- `K` (visual) - Move line up
- `<leader>y` - Copy to system clipboard
- `<leader>p` - Paste from system clipboard

### Formateo
- `<leader>fm` - Format buffer manualmente
- Formateo automático al guardar (`:w`)

### Git
- `<leader>gg` - Abrir LazyGit
- `<leader>gd` - Abrir git diff
- `<leader>gc` - Cerrar git diff
- `<leader>gh` - Ver historial del archivo actual
- `<leader>gH` - Ver historial de la rama
- `]c` - Siguiente cambio (hunk)
- `[c` - Cambio anterior (hunk)
- `<leader>hp` - Preview hunk
- `<leader>hb` - Blame completo de la línea
- `<leader>tb` - Toggle blame en línea
- `<leader>hs` - Stage hunk
- `<leader>hr` - Reset hunk
- `<leader>hS` - Stage buffer completo
- `<leader>hR` - Reset buffer completo
- `<leader>hd` - Diff this

### Autocompletado
- `Ctrl+j` - Siguiente sugerencia
- `Ctrl+k` - Anterior sugerencia
- `Ctrl+Space` - Activar autocompletado
- `Enter` - Confirmar selección
- `Ctrl+e` - Cerrar menú de autocompletado
- `Ctrl+b` - Scroll docs arriba
- `Ctrl+f` - Scroll docs abajo

### Proyectos
- `<leader>p` - Descubrir y abrir proyectos
- `<leader>ph` - Ver historial de proyectos

### Alternancia Archivo/Test
- `<leader>pa` - Alternar entre archivo y test
- `<leader>pas` - Abrir alternativo en split horizontal
- `<leader>pav` - Abrir alternativo en split vertical
- `<leader>pac` - Limpiar cache de alternos

## Opciones de Neovim

### Editor
- **Numeración**: Absoluta y relativa
- **Mouse**: Habilitado
- **Clipboard**: Integrado con sistema
- **Indentación**: 4 espacios (tabstop, shiftwidth, softtabstop)
- **Auto-indent**: Habilitado (smartindent, autoindent, smarttab)
- **Scroll**: Offset de 8 líneas
- **Fuente**: JetBrainsMono Nerd Font h12

### Archivos
- **Undo file**: Persistente
- **Swap**: Deshabilitado
- **Backup**: Deshabilitado

### UI
- **Splits**: Derecha y abajo por defecto
- **Cursorline**: Visible
- **Sign column**: Siempre visible
- **Color column**: 80 y 120 caracteres

## Tema Monokai

Colores personalizados:
- **Git Diff**: Verde para add, rojo para delete, azul para change
- **Diagnósticos LSP**: Colores vibrantes con negrita
  - Error: Rojo (#ff6b6b)
  - Warn: Amarillo (#feca57)
  - Info: Azul (#48cae4)
  - Hint: Verde (#06d6a0)
- **Git Blame**: Gris tenue (#5a5a6e) en itálica

## Características de Git

### Gitsigns
- **Blame en línea**: Muestra autor, hash, fecha y mensaje al final de cada línea (delay: 300ms)
- **Indicadores laterales**: Símbolos visuales en la columna de signos
  - `+` para líneas nuevas (verde)
  - `~` para líneas modificadas (azul)
  - `-` para líneas eliminadas (rojo)
  - `≃` para líneas modificadas y eliminadas
  - `┆` para archivos sin trackear

### DiffView
- **Vista lado a lado**: Comparación horizontal de cambios
- **Navegación por conflictos**: Saltar entre cambios con `[c` y `]c`
- **Stage/Unstage**: Gestionar cambios desde la interfaz
- **Historial**: Ver commits y cambios históricos

### LazyGit
- **Interfaz TUI completa**: Gestión visual de Git
- **Gestión de commits**: Crear, editar, revertir commits
- **Branches**: Crear, cambiar, mergear ramas
- **Requiere**: Instalar `lazygit` en el sistema (`sudo apt install lazygit`)

## Primer Uso

Al abrir Neovim por primera vez:

1. `lazy.nvim` se instala automáticamente
2. Todos los plugins se descargan
3. Los LSP servers se instalan vía Mason
4. Los parsers de Treesitter se compilan
5. El tema Monokai se activa

Simplemente ejecuta:
```bash
nvim
```

Espera a que termine la instalación y reinicia Neovim.

## Comandos Útiles

### lazy.nvim
- `:Lazy` - Abrir interfaz de lazy.nvim
- `:Lazy sync` - Instalar/actualizar/limpiar plugins
- `:Lazy clean` - Eliminar plugins no utilizados
- `:Lazy update` - Actualizar todos los plugins

### Mason
- `:Mason` - Abrir interfaz de Mason
- `:MasonInstall <server>` - Instalar un LSP server
- `:MasonUninstall <server>` - Desinstalar un LSP server
- `:MasonUpdate` - Actualizar todos los servers

### LSP
- `:LspInfo` - Información de LSP activos
- `:LspRestart` - Reiniciar LSP del buffer actual

### Treesitter
- `:TSUpdate` - Actualizar parsers
- `:TSInstall <lang>` - Instalar parser de un lenguaje

### Git
- `:DiffviewOpen` - Ver cambios no commiteados
- `:DiffviewOpen HEAD~1` - Comparar con commit anterior
- `:DiffviewFileHistory` - Ver historial completo de la rama
- `:DiffviewFileHistory %` - Ver historial del archivo actual
- `:DiffviewClose` - Cerrar DiffView
- `:LazyGit` - Abrir interfaz de LazyGit

### Formateo
- `:ConformInfo` - Ver información de formateadores disponibles

## Fuente de Terminal

La configuración especifica `JetBrainsMono Nerd Font:h12` en Neovim.

Para Gnome Terminal:
```bash
gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 12'
```

## Respaldo

Tu configuración anterior está respaldada en:
- Archivo: `~/.config/nvim-backup-20251108-041050.tar.gz`

Para restaurar la configuración anterior:
```bash
rm -rf ~/.config/nvim
tar -xzf ~/.config/nvim-backup-20251108-041050.tar.gz -C ~/.config/
```

## Solución de Problemas

### LSP no se adjunta a un archivo
1. Verificar que el LSP server esté instalado: `:Mason`
2. Verificar que esté activo: `:LspInfo`
3. Reiniciar el LSP: `:LspRestart`

### Autocompletado no funciona
1. Verificar que el LSP esté activo: `:LspInfo`
2. Verificar capabilities de nvim-cmp
3. Reiniciar Neovim

### Treesitter no resalta sintaxis
1. Instalar parser manualmente: `:TSInstall <lang>`
2. Actualizar parsers: `:TSUpdate`
3. Verificar: `:checkhealth nvim-treesitter`

### Fuente no se ve correcta
1. Verificar que JetBrainsMono Nerd Font esté instalada
2. Configurar en la terminal (no en Neovim)
3. Reiniciar terminal

### Formateo no funciona
1. Verificar formateadores instalados: `:ConformInfo`
2. Verificar que Mason haya instalado las herramientas: `:Mason`
3. Para PHP: Usa el LSP (Intelephense) automáticamente como fallback
4. Formatear manualmente: `<leader>fm`

### Git plugins no funcionan
1. Verificar que Git esté instalado: `git --version`
2. Para LazyGit: Instalar con `sudo apt install lazygit`
3. Verificar repositorio Git: Debe estar en un directorio con `.git`

## Características Adicionales

### Auto-cierre de Pares (nvim-autopairs)
- Cierra automáticamente: `()`, `{}`, `[]`, `""`, `''`
- Integrado con nvim-cmp para autocompletado
- Detección inteligente de contexto (no cierra en strings o comentarios)
- Fast wrap con `Alt+e`

### Formateo Automático (conform.nvim)
- Formatea al guardar automáticamente
- Usa formateador específico según tipo de archivo
- Fallback a LSP si no hay formateador disponible
- Timeout de 500ms por seguridad

### Gestión de Proyectos (neovim-project)
- Detección automática de proyectos por patrones de archivos
- Historial persistente de proyectos visitados
- Cambio rápido de directorio al seleccionar proyecto
- Integración con Telescope para búsqueda fuzzy
- Configurado para buscar en: `/var/www/html/*`
- Detecta marcadores: `.git`, `package.json`, `mix.exs`, `composer.json`, `pom.xml`, `Cargo.toml`, `go.mod`, `pyproject.toml`, etc.
- **Auto-cambio de directorio**: Al abrir un archivo que pertenece a un proyecto, nvim cambia automáticamente el directorio de trabajo al directorio raíz del proyecto. Esto asegura que comandos como Telescope busquen en el contexto correcto del proyecto.

### Alternancia Archivo/Test (other.nvim)
- Alterna entre archivo fuente y su test correspondiente
- Crea archivos de test si no existen
- Soporta múltiples lenguajes y convenciones:
  - **Elixir**: `lib/module.ex` ↔ `test/module_test.exs`
  - **PHP**: `app/Class.php` ↔ `tests/ClassTest.php`
  - **Python**: `src/module.py` ↔ `tests/test_module.py`
  - **JavaScript**: `lib/module.js` ↔ `test/module.test.js`
  - **TypeScript**: `src/module.ts` ↔ `tests/module.test.ts`
  - **React**: `src/Component.tsx` ↔ `tests/Component.test.tsx`
  - **Java**: `src/Class.java` ↔ `src/test/java/ClassTest.java`
  - **Rust**: `lib/module.rs` ↔ `tests/module_test.rs`

### Visualización de Colores (nvim-colorizer.lua)
- Muestra colores inline en el código
- Formatos soportados:
  - **Hex**: `#RGB`, `#RRGGBB`, `#RRGGBBAA`, `#AARRGGBB`
  - **RGB**: `rgb(255, 0, 0)`, `rgba(255, 0, 0, 0.5)`
  - **HSL**: `hsl(120, 100%, 50%)`, `hsla(120, 100%, 50%, 0.5)`
  - **Nombres CSS**: `red`, `blue`, `green`, etc.
  - **Tailwind CSS**: Clases de color de Tailwind
  - **Sass/SCSS**: Variables de color
- Modo de visualización: Color de fondo
- Activado en todos los tipos de archivo
- Comandos:
  - `:ColorizerToggle` - Activar/desactivar
  - `:ColorizerAttachToBuffer` - Activar en buffer actual
  - `:ColorizerDetachFromBuffer` - Desactivar en buffer actual

## Recursos

- [Documentación de lazy.nvim](https://github.com/folke/lazy.nvim)
- [Documentación de Mason](https://github.com/williamboman/mason.nvim)
- [Documentación de nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- [Documentación de Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [Documentación de Gitsigns](https://github.com/lewis6991/gitsigns.nvim)
- [Documentación de DiffView](https://github.com/sindrets/diffview.nvim)
- [Documentación de Conform](https://github.com/stevearc/conform.nvim)
- [Documentación de Neovim-Project](https://github.com/coffebar/neovim-project)
- [Documentación de Other.nvim](https://github.com/rgroli/other.nvim)
- [Documentación de Colorizer](https://github.com/NvChad/nvim-colorizer.lua)
