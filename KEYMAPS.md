# Neovim Keymaps — Referencia de uso

> `<leader>` = barra espaciadora
> Abrir esta guía: `<leader>k`

---

## Navegación y edición general

| Atajo | Modo | Descripción |
|-------|------|-------------|
| `<Esc>` | Normal | Limpia el resaltado de búsqueda |
| `<C-h/j/k/l>` | Normal | Mueve el foco entre ventanas (izq/abaj/arriba/der) |
| `<C-d>` / `<C-u>` | Normal | Scroll abajo/arriba manteniendo el cursor centrado |
| `n` / `N` | Normal | Siguiente/anterior resultado de búsqueda (centrado) |
| `J` / `K` | Visual | Mueve la línea seleccionada hacia abajo/arriba |
| `<leader>w` | Normal | Guarda el archivo |
| `<leader>q` | Normal | Cierra el buffer |
| `<leader>k` | Normal | Abre esta guía de keymaps |
| `<leader>cp` | Normal | Copia la ruta completa del archivo al portapapeles |
| `:Bda` | Comando | Cierra todos los buffers excepto el actual |

**Ejemplo — mover bloques de código:**
```
1. Seleccionas 3 líneas en visual
2. J → las mueves hacia abajo
3. K → las mueves hacia arriba
4. gv → recupera la selección si la perdiste
```

### Clipboard y registros

| Atajo | Modo | Descripción |
|-------|------|-------------|
| `<leader>y` | Normal/Visual | Copia al portapapeles del sistema (`+`) |
| `<leader>Y` | Normal | Copia la línea al portapapeles del sistema |
| `<leader>d` | Normal/Visual | Elimina sin guardar en ningún registro (void) |
| `<leader>p` | Visual | Pega sin reemplazar el registro actual |

**Ejemplo — pegar sin perder lo copiado:**
```
1. Copias "foo" con yy
2. Seleccionas "bar" en visual
3. <leader>p → pega "foo" sobre "bar" sin que "bar" reemplace al registro
```

---

## Markdown — Markview

Renderiza archivos `.md` directamente en el editor (títulos, tablas, listas, código).

| Atajo | Descripción |
|-------|-------------|
| `<leader>mv` | Alternar entre markdown renderizado y raw |

**Ejemplo — revisar documentación:**
```
1. <leader>k → abre esta guía renderizada
2. <leader>mv → alterna a raw para copiar un alias exacto
3. <leader>mv → vuelves al modo visual
```

---

## Telescope — Buscador fuzzy

| Atajo | Descripción |
|-------|-------------|
| `<leader>ff` | Buscar archivos en el proyecto |
| `<leader>fr` | Archivos recientes (al abrir hace cd al directorio) |
| `<leader>fg` | Buscar texto en todo el proyecto (live grep) |
| `<leader>fc` | Buscar la palabra bajo el cursor en el proyecto |
| `<leader>fl` | Buscar dentro del buffer actual (fuzzy con colores) |
| `<leader>fb` | Ver y cambiar entre buffers abiertos |
| `<leader>fh` | Buscar en la ayuda de Neovim |
| `<leader>fk` | Ver todos los atajos de teclado registrados |
| `<leader>fs` | Símbolos LSP del archivo actual (funciones, clases...) |
| `<leader>fw` | Símbolos LSP en todo el workspace |
| `<leader>fd` | Diagnósticos LSP del buffer actual |
| `<leader>fe` | Diagnósticos LSP de todo el workspace |

**Dentro de Telescope:**
- `<C-j>` / `<C-k>` — moverse por los resultados
- `<C-q>` — enviar selección a quickfix list
- `<Enter>` — abrir selección
- `<Esc>` — cerrar

**Ejemplo — buscar y navegar errores:**
```
1. <leader>fg → escribes "getUserById"
2. Ves todos los archivos donde aparece con preview
3. <C-q> → manda los resultados a quickfix
4. :cn / :cp para navegar entre ellos sin cerrar el editor
```

**Ejemplo — buscar dentro del archivo actual:**
```
1. <leader>fl → escribes "function"
2. Ves todas las funciones del archivo con preview y número de línea
3. <Enter> → saltas a esa línea
```

---

## LSP — Navegación de código

| Atajo | Descripción |
|-------|-------------|
| `gd` | Ir a la definición (usa Telescope, fallback a grep) |
| `<C-]>` | Ir a la definición (alternativa) |
| `gr` | Ver todas las referencias |
| `gD` | Ir a la declaración |
| `gi` | Ver implementaciones |
| `gy` | Ver definiciones de tipo |
| `K` | Documentación del símbolo bajo el cursor |
| `<leader>ca` | Acciones de código (fix, refactor...) |
| `<leader>rn` | Renombrar símbolo en todo el proyecto |
| `<leader>d` | Ver diagnóstico de la línea actual (float) |
| `<leader>D` | Ver todos los diagnósticos del buffer (loclist) |
| `[d` / `]d` | Ir al diagnóstico anterior/siguiente |
| `<leader>lr` | Reiniciar el servidor LSP |

**Ejemplo — explorar código desconocido:**
```
1. Cursor sobre una función externa
2. K → ves la documentación sin salir del archivo
3. gd → vas a la definición
4. <C-o> → vuelves al punto anterior
5. gr → ves todos los lugares donde se usa
```

**Ejemplo — refactorizar un nombre:**
```
1. Cursor sobre la función "fetchUser"
2. <leader>rn → escribes "getUser" → Enter
3. Renombra en todos los archivos del proyecto automáticamente
```

---

## Trouble — Panel de diagnósticos

| Atajo | Descripción |
|-------|-------------|
| `<leader>xx` | Panel persistente de errores/warnings del workspace |
| `<leader>xb` | Panel de diagnósticos solo del buffer actual |
| `<leader>xs` | Árbol de símbolos del archivo (funciones, clases) |
| `<leader>xq` | Quickfix list con mejor UI |

**Diferencia con `<leader>fd` (Telescope):**
Telescope cierra al seleccionar. Trouble se mantiene abierto
mientras navegas el código, ideal para resolver varios errores seguidos.

**Ejemplo — resolver errores de TypeScript:**
```
1. <leader>xx → panel inferior con todos los errores del proyecto
2. j/k para navegar entre errores
3. <Enter> → salta al error sin cerrar el panel
4. Corriges, el panel se actualiza en tiempo real
5. <leader>xx → cierra cuando terminas
```

**Ejemplo — ver estructura del archivo:**
```
1. <leader>xs → árbol lateral con todas las funciones y clases
2. Navegas el árbol para entender la estructura
3. <Enter> → saltas a esa función en el código
```

---

## Terminal — Toggleterm

| Atajo | Descripción |
|-------|-------------|
| `<C-\>` | Abrir/cerrar terminal flotante |
| `<C-h/j/k/l>` | (dentro del terminal) Cambiar de ventana sin cerrar |

**La terminal es persistente:** al cerrarla con `<C-\>` no se destruye,
al reabrirla continúa desde donde estaba.

**Ejemplo — ejecutar tests sin salir del editor:**
```
1. <C-\> → abre la terminal flotante
2. Escribes: mix test / pytest / npm test
3. <C-\> → ocultas la terminal, sigues editando
4. <C-\> → vuelves a ver el output anterior
```

**Ejemplo — usar un REPL:**
```
1. <C-\> → abre terminal
2. Escribes: iex (Elixir) o node o python
3. Pegas código desde el editor con <C-\><C-n> + p
4. <C-\> → ocultas el REPL, sigues en el editor
```

---

## Git — Gitsigns (cambios en el buffer)

Los signos en el gutter (`+`, `~`, `-`) indican líneas añadidas, modificadas y eliminadas.
El blame del commit aparece al final de cada línea automáticamente.

| Atajo | Modo | Descripción |
|-------|------|-------------|
| `]c` / `[c` | Normal | Ir al hunk siguiente/anterior |
| `<leader>hp` | Normal | Preview del hunk bajo el cursor |
| `<leader>hs` | Normal/Visual | Stagear el hunk (o selección) |
| `<leader>hr` | Normal/Visual | Resetear el hunk (o selección) |
| `<leader>hS` | Normal | Stagear todo el buffer |
| `<leader>hR` | Normal | Resetear todo el buffer |
| `<leader>hu` | Normal | Deshacer el último stage |
| `<leader>hb` | Normal | Ver blame completo de la línea |
| `<leader>tb` | Normal | Activar/desactivar blame en línea |
| `<leader>hd` | Normal | Diff del archivo actual vs HEAD |
| `<leader>hD` | Normal | Diff del archivo actual vs HEAD~ |
| `<leader>td` | Normal | Mostrar/ocultar líneas eliminadas |
| `ih` | Operator/Visual | Seleccionar el hunk como text object |

**Ejemplo — stagear solo parte de los cambios:**
```
1. Tienes cambios en varias partes del archivo
2. ]c → vas al hunk que quieres stagear
3. <leader>hp → preview para confirmar que es el correcto
4. <leader>hs → stagea solo ese hunk
5. Repites para los hunks que quieres incluir
6. <leader>gc → haces el commit solo con lo stageado
```

---

## Git — Operaciones generales

| Atajo | Descripción |
|-------|-------------|
| `<leader>gl` | Git pull |
| `<leader>gp` | Git push |
| `<leader>gc` | Commit interactivo (pide mensaje) |
| `<leader>gu` | Ver commits sin pushear, seleccionar para deshacer |
| `<leader>gs` | Estado del repositorio (Telescope) |
| `<leader>gg` | Historial de commits (Telescope) |

**Ejemplo — flujo completo de commit:**
```
1. Editas archivos
2. <leader>gs → ves los archivos modificados en Telescope
3. <leader>hs → stageas los hunks que quieres
4. <leader>gc → escribes el mensaje del commit
5. <leader>gp → pusheas
```

---

## Git — Diffview (comparar cambios)

| Atajo | Descripción |
|-------|-------------|
| `<leader>dv` | Ver diff de todos los cambios locales |
| `<leader>db` | Comparar con otra rama (pide nombre, default: main) |
| `<leader>dh` | Historial de cambios del archivo actual |
| `<leader>dH` | Historial de toda la rama |
| `<leader>dc` / `<leader>dq` | Cerrar diffview |

**Dentro de diffview:**

| Tecla | Descripción |
|-------|-------------|
| `q` | Cerrar |
| `<Tab>` | Mostrar/ocultar panel de archivos |
| `s` | Stagear/destagear archivo (en panel) |
| `r` | Restaurar archivo desde la otra rama |
| `R` | Refrescar lista de archivos |
| `gf` | Ir al archivo en el editor |
| `[c` / `]c` | Navegar entre conflictos de merge |
| `do` | Tomar cambios del lado izquierdo (merge) |

**Ejemplo — revisar qué cambió antes de hacer PR:**
```
1. <leader>db → escribes "main"
2. Ves todos los archivos que cambiaron respecto a main
3. <Enter> sobre un archivo → ves las líneas exactas modificadas
4. q → cierras
```

**Ejemplo — resolver conflicto de merge:**
```
1. <leader>dv → ves los archivos en conflicto marcados
2. <Enter> → abre la vista de 3 paneles (base, tuyo, resultado)
3. ]c → navegas entre conflictos
4. do → aceptas los cambios del lado izquierdo
5. q → cierras cuando terminas
```

---

## Base de datos — Dadbod

| Atajo | Descripción |
|-------|-------------|
| `<leader>sq` | Abrir/cerrar el panel de DB |
| `<leader>sa` | Añadir nueva conexión |
| `<leader>sf` | Buscar buffer de query abierto |
| `<leader>se` | Ejecutar query (normal: query completa, visual: selección) |
| `<leader>sx` | Cancelar query en ejecución |
| `<leader>sw` | Guardar query como archivo .sql |
| `<leader>sc` | Exportar resultado a CSV |
| `<leader>st` | Activar/desactivar autocompletado de DB |

**Comandos disponibles:**
- `:DBUIAddConnection` — añadir conexión
- `:DBSaveQuerySQL` — guardar query en la carpeta de la conexión
- `:DBExportCSV` — exportar resultado visible a CSV
- `:DBToggleCompletion` — toggle del autocompletado

**Ejemplo — ejecutar y guardar una query:**
```
1. <leader>sq → abre el panel, seleccionas la BD y tabla
2. Se abre un buffer SQL temporal
3. Escribes: SELECT * FROM users WHERE active = 1
4. <leader>se → resultado aparece en panel derecho
5. <leader>sw → pide nombre, guarda como users-activos.sql
6. <leader>sc → exporta el resultado a CSV con timestamp
```

**Ejemplo — ejecutar solo parte de una query:**
```
1. Tienes un archivo con varias queries
2. Seleccionas en visual solo el SELECT que quieres
3. <leader>se → ejecuta solo la selección
```

**El autocompletado sugiere tablas con alias automático:**
```sql
-- Al escribir "FROM doc" el completado sugiere:
FROM documents_attributes as da
-- El alias se genera con las iniciales del nombre de tabla
```

---

## HTTP Client — Kulala

| Atajo | Descripción |
|-------|-------------|
| `<leader>rs` | Ejecutar la petición bajo el cursor |
| `<leader>ra` | Ejecutar todas las peticiones del archivo |
| `<leader>rt` | Alternar vista body/headers en el resultado |
| `<leader>rp` / `<leader>rn` | Ir a la petición anterior/siguiente |
| `<leader>re` | Seleccionar entorno (dev, staging, prod...) |
| `<leader>rc` | Copiar la petición como comando curl |
| `<leader>ri` | Inspeccionar la petición (variables resueltas) |
| `<leader>rq` | Cerrar panel de resultado |
| `<leader>rh` | Crear nuevo archivo .http |
| `<leader>rl` | Listar todos los archivos .http guardados |

**Ejemplo — probar un endpoint con entorno:**
```http
# archivo: login.http
@baseUrl = {{$env:BASE_URL}}

POST {{baseUrl}}/api/login
Content-Type: application/json

{
  "email": "test@example.com",
  "password": "secret"
}
```
```
1. <leader>re → seleccionas entorno "dev" (carga BASE_URL)
2. <leader>rs → ejecuta, ves el JSON de respuesta
3. <leader>rt → alterna para ver los headers de respuesta
4. <leader>rc → copia el curl equivalente para compartir
```

**Ejemplo — probar todas las peticiones de un flujo:**
```
1. Tienes login.http con: POST login, GET perfil, PUT actualizar
2. <leader>ra → ejecuta las tres en orden
3. <leader>rp / <leader>rn → navegas entre los resultados
```

---

## Archivo alternativo — Other.nvim

Salta entre archivo fuente y su test automáticamente.

| Atajo | Descripción |
|-------|-------------|
| `<leader>pa` | Abrir archivo alternativo (test ↔ source) |
| `<leader>pas` | Abrir en split horizontal |
| `<leader>pav` | Abrir en split vertical |
| `<leader>pac` | Limpiar caché de alternativas |

**Lenguajes configurados:** Elixir, PHP, Python, JS, TS, TSX, Java, Rust

**Ejemplo — trabajar en paralelo código y test:**
```
1. Estás en: lib/accounts/user.ex
2. <leader>pav → abre test/accounts/user_test.exs en split vertical
3. Editas el código a la izquierda y el test a la derecha
4. <C-h> / <C-l> → cambias de panel sin salir del teclado
```
