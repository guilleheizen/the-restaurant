# Tutorial — Rama `05-mcps`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `05-mcps`. Adaptá el lenguaje. **Paths absolutos. La instalación la hago YO** (Bash con permiso del usuario), no le pido al usuario que tipee comandos.

## Lo que se recorre en esta rama

Un concepto en dos partes:
1. **MCPs como proveedores externos** — qué son, cómo se conectan, cómo aparecen sus tools.
2. **Persistencia entre sesiones** — el stock que sobrevive después de cerrar Claude.

A partir de esta rama, el menú y el stock viven **afuera del repo**, en una **bóveda** (carpeta de datos externa, hermana del repo). `/knowledge/menu/` y `/knowledge/stock/` quedan como referencia histórica.

---

## Saludo inicial

Saludo de 2-3 frases:
- Que pasó a `05-mcps`, última rama del recorrido.
- Que esta rama agrega una capa: el menú y el stock se mueven afuera del repo, a una **bóveda** que vos elegís dónde vive.
- Que el setup lo hago YO — solo necesito preguntarte dónde querés la bóveda.

Cerrá con: *"Arranquemos por el setup."* y arrancá la siguiente sección.

---

## Setup (lo hago YO)

### Paso 1 — ¿Dónde vive la bóveda?

Preguntale al usuario:

> *"La 'bóveda' es la carpeta donde van a vivir el menú y el stock — siempre **afuera del repo**, nunca adentro. Tres opciones:*
> - *Default: `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant-data/` (hermana del repo).*
> - *Ya tenés una: pasame el path absoluto.*
> - *Querés otra ubicación: pasame el path absoluto.*
> *¿Cuál?"*

**No asumir el nombre `vault/`.** Y nunca dentro del repo.

### Paso 2 — Crear y poblar la bóveda (yo ejecuto)

Una vez que tengas el path:

```bash
./tutorial/setup-rama-05.sh <path-de-la-bóveda>
```

Si el destino existe, el script pregunta si sobrescribir. Si el usuario ya dio luz verde, podés tirar `yes |` adelante.

### Paso 3 — Registrar el filesystem MCP (yo ejecuto)

```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem <path-de-la-bóveda>
```

### Paso 4 — Verificar (yo ejecuto)

```bash
claude mcp list
```

Confirmá que aparezca `filesystem ✓ Connected`. Después chequeá que la bóveda tenga los archivos esperados:

```bash
ls <path-de-la-bóveda>/menu <path-de-la-bóveda>/stock
```

### Paso 5 — Reinicio obligatorio del usuario

> ⚠️ Después de registrar el MCP, **Claude Code no expone los nuevos tools en sesiones ya abiertas**. Decile al usuario:
> *"Salí de Claude Code y volvé a entrar (en este mismo directorio). Cuando vuelvas, decime 'listo' — voy a verificar que las tools del MCP estén disponibles antes de seguir."*

Cuando vuelva, hacé un `mcp__filesystem__list_directory` con path `menu/` para verificar que los tools están expuestos. Si responde, seguí. Si no, debug (probable: el `claude mcp list` ya no aparece, o el path está mal).

---

## Concepto 1 — MCPs como proveedores externos

### En lenguaje de negocio

Movimos el menú y el stock a una bóveda externa. ¿Cómo accede el agente? Necesitamos darle un "teléfono" para ir a buscar info cuando la necesita. Eso es un **MCP (Model Context Protocol)**: un proceso externo que expone tools, y el agente las llama por un protocolo estándar.

### MCPs en la naturaleza (ejemplos reales)

| MCP | Qué hace | Tools que expone |
|---|---|---|
| **Filesystem** (oficial Anthropic) — el que usamos | Lee/escribe archivos en una carpeta | `mcp__filesystem__read_file`, `mcp__filesystem__list_directory`, `mcp__filesystem__write_file` |
| **Chrome DevTools** (oficial Google) | Controla un Chrome real (navegar, hacer clicks, screenshots, ejecutar JS) | `mcp__chrome_devtools__*` |
| **GitHub** | Crea PRs, gestiona issues, lee repos | `mcp__github__*` |
| **Postgres** | Queries directas a una base | `mcp__postgres__*` |

Patrón común: `mcp__<server>__<tool>`. Los tools del MCP **se mezclan con los nativos** (`Read`, `Write`, `Bash`, etc.) — el agente los usa como cualquier otro.

### Permisos por subagente

Mostrale el frontmatter de los dos subagentes:

| Subagente | Path | Tools MCP que tiene |
|---|---|---|
| Cajero | `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/cajero.md` | `read_file` + `list_directory`. **Sin `write_file`** — el cajero no toca stock. |
| Gustavo | `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/gustavo.md` | `read_file` + `list_directory` + `write_file`. Gustavo SÍ modifica (descuenta stock). |

> 🔑 **Permisos del MCP se asignan por subagente**, igual que cualquier tool nativa.

### Prompt para probar

```
¿Qué platos tienen sin lactosa?
```

Vas a ver llamadas `mcp__filesystem__list_directory` sobre `menu/` y `mcp__filesystem__read_file` sobre cada JSON. El agente filtra por `tags`. Decime "siguiente".

### Takeaway

*"Un MCP es un proveedor. Lo llamás, te responde, no te importa qué hay adentro. Los permisos se asignan por subagente, igual que cualquier tool."*

---

## Concepto 2 — Persistencia: state que sobrevive entre sesiones

### En lenguaje de negocio

Leer está bien. Pero el stock cambia en tiempo real cuando se cocina. Necesitamos **escribir** — y que el cambio quede en disco para la próxima sesión.

Antes de probar, decile al usuario que abra `<bóveda>/stock/ingredientes.json` y anote: `muzzarella`, `nalga`, `provoleta`.

### Prompt para probar

```
Soy un cliente. Quiero 3 milanesas napolitanas y una provoleta a la parrilla.
```

Lo que pasa:
1. Santi confirma el pedido.
2. Invoca a **Gustavo** → lee menú y stock vía MCP, calcula consumo, **reescribe** stock vía `mcp__filesystem__write_file`.
3. Vuelve a Santi → te entrega el plato.
4. *(Opcional)* `me cobrás` → cajero genera la cuenta y escribe a `pedidos-cerrados/`.

Cuando termine, abrí el JSON de nuevo y compará: muzzarella bajó ~0.45 kg, nalga ~0.6 kg, provoleta -1. **El cambio quedó en disco** — si cerrás Claude y volvés mañana, sigue así.

### Takeaway

*"Acá se cierra el círculo. El restaurante deja de ser un proceso en la cabeza de Claude — tiene state real, persistente, accesible desde otras herramientas."*

---

## Cierre de la rama (y del recorrido)

Decile al usuario:

> "Listo. La rama `05-mcps` agregó:
> - **MCPs como proveedores externos** — proceso externo, tools `mcp__<server>__*`, permisos por subagente.
> - **Persistencia entre sesiones** — el state vive afuera del LLM y sobrevive al cierre de Claude.
>
> | Rama | Capa que agregó |
> |------|------------------|
> | `01-base` | CLAUDE.md, /knowledge, agente único |
> | `02-skills` | Skills (manuales y autoinvocadas) |
> | `03-hooks` | Hooks Pre + Post |
> | `04-agents` | Subagentes con contexto fresco |
> | `05-mcps` | MCPs para state externo |
>
> Cada capa apareció **cuando hizo falta**. No son features para coleccionar — son respuestas a problemas concretos.
>
> ¿Querés que deje todo limpio? Puedo: volver a `main`, restaurar el stock al seed, borrar `pedidos-cerrados/` y `caja-del-dia.txt`, y desregistrar el MCP."

Esperá. Si dice que sí, hacé el reset (yo ejecuto):

```bash
cp /Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/tutorial/data-seed/stock/ingredientes.json <bóveda>/stock/ingredientes.json
rm -f /Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/pedidos-cerrados/*.md
rm -f /Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/caja-del-dia.txt
claude mcp remove filesystem
git -C /Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant checkout main
```

Verificá que cada paso salió bien antes de reportar al usuario.
