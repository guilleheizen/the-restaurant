# Tutorial — Rama `05-mcps`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `05-mcps`. Adaptá el lenguaje, no copies frases textualmente.

## Lo que se recorre en esta rama

Tres conceptos sobre MCPs:
1. **El problema de los `.md` locales** — por qué hace falta una capa más allá del repo.
2. **MCPs como proveedores externos** — cómo se conecta un MCP a Claude Code y qué cambia.
3. **Read + Write con persistencia entre sesiones** — el stock dinámico.

> **Esta es la primera rama que requiere instalar algo.** Antes de arrancar los conceptos, hay que correr el setup (script + registro del MCP). Las instrucciones están más abajo, en "Setup obligatorio".

A partir de esta rama, el menú y el stock viven **afuera del repo**, en `the-restaurant-data/` (hermano del repo). Los archivos `knowledge/menu/*.md` y `knowledge/stock/ingredientes.md` quedan como referencia histórica, no como fuente de verdad.

---

## Saludo inicial

Decile al usuario, en una o dos frases:
- Que pasó a la rama `05-mcps`, la última del recorrido.
- Que esta rama agrega una capa nueva: el menú y el stock se mueven afuera del repo.
- Que es la primera rama que requiere instalar algo (un MCP server).
- Que vamos a hacer primero el setup, después arrancamos los conceptos.

Cerrá con: *"Empezamos con el setup. Te paso los pasos uno por uno."* y arrancá con la sección siguiente.

---

## Setup obligatorio (antes de los conceptos)

### Paso 1 — Verificar que `node`/`npx` esté instalado
Decile al usuario que tipee:

```bash
npx --version
```

Si tira error, indicale instalar Node.js primero (https://nodejs.org). Si funciona, seguir.

### Paso 2 — Correr el script de seed
Decile al usuario que ejecute desde la raíz del repo:

```bash
./tutorial/setup-rama-05.sh
```

Esto crea `the-restaurant-data/` (hermano del repo) y copia adentro los JSONs iniciales del menú y stock.

Aclará: *"Si la carpeta ya existe (probablemente sí, porque ya la dejamos pre-poblada para tu test), te va a preguntar si querés sobrescribir. Decile que sí."*

### Paso 3 — Registrar el filesystem MCP
Decile al usuario que ejecute:

```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant-data
```

(Si la ruta es distinta en su máquina, ajustar.)

### Paso 4 — Verificar
```bash
claude mcp list
```

Debería aparecer `filesystem` en la lista, con status conectado.

> Si Claude Code está corriendo en otra terminal, **reiniciá la sesión** después de registrar el MCP para que tome los nuevos tools.

Cuando confirme que está todo, arrancá con el Concepto 1.

---

## Concepto 1 — El problema de los `.md` locales

### Explicación que tenés que dar
Hasta la rama `04-agents`, todo el conocimiento del restaurante (menú, stock, recetas, personajes) vivió en `.md` dentro del repo. Funcionó. Pero pensá esto: si el restaurante creciera a 200 platos, 50 vinos, ofertas que cambian a diario y stock real-time, **¿seguiría funcionando?**

Problemas concretos:
- **Editar a mano no escala.** Cambiar un precio implica abrir el archivo, hacer commit, push.
- **Todo carga al contexto.** Si el agente abre `knowledge/menu/principales.md` para responder una pregunta, se carga el archivo entero — aunque el cliente preguntó por un solo plato.
- **No hay state real entre sesiones.** Si Gustavo descuenta ingredientes en una sesión, en la siguiente "se olvida" porque los `.md` no se modifican.

Acá es donde aparecen los **MCPs**.

### Pedile al usuario que abra
[`knowledge/menu/principales.md`](../knowledge/menu/principales.md) (el original) y [`the-restaurant-data/menu/principales.json`](../../the-restaurant-data/menu/principales.json) (el nuevo).

Comentá:
- El `.md` es para humanos (formato libre, lindo de leer).
- El `.json` es para máquinas (estructurado, queryable, con tags y `ingredientes_consumo` para automatizar).
- **La fuente de verdad ahora es el JSON.** El `.md` queda como referencia/fallback, lo dice [`knowledge/menu/README.md`](../knowledge/menu/README.md).

No hay prompt de prueba acá — es contexto para entender qué cambia. Cuando termine, decile *"¿pasamos al concepto del MCP?"* y esperá.

---

## Concepto 2 — MCPs como proveedores externos

### Explicación que tenés que dar
Un **MCP** (Model Context Protocol) es un servicio externo con el que el agente se comunica por un protocolo estándar. El agente le hace queries vía tools especiales (`mcp__<server>__<tool>`), el MCP responde. **El agente no necesita saber cómo está implementado** — solo sabe el "número de teléfono" y qué pedir.

Los tools del MCP **se mezclan con los tools nativos** de Claude Code. La diferencia: los nativos viven adentro de Claude Code; los del MCP los provee un proceso externo (en este caso, `npx -y @modelcontextprotocol/server-filesystem`).

### Pedile al usuario que abra
[`.claude/agents/cajero.md`](../.claude/agents/cajero.md). En el frontmatter, mostrale el campo `tools`:

```yaml
tools: Read, Glob, Grep, Write, mcp__filesystem__read_file, mcp__filesystem__list_directory
```

Comentá: *"Notá los `mcp__filesystem__*`. Esos son los tools del MCP. El cajero los usa para leer el menú externo. Si el MCP no estuviera registrado, esos tools no existirían y el cajero usaría el fallback (`Read` sobre `knowledge/menu/`)."*

Después abrí [`.claude/agents/gustavo.md`](../.claude/agents/gustavo.md) y mostrale lo mismo, más el `mcp__filesystem__write_file` (porque Gustavo SÍ escribe — descuenta stock).

### Prompt para probar
Pedile al usuario que tipee:

```
¿Qué platos tienen sin lactosa?
```

Aclará: *"Santi va a invocar `mcp__filesystem__list_directory` sobre `menu/` y después `mcp__filesystem__read_file` para cada JSON. Filtra los items donde `tags` no incluye `contiene-lactosa`. La respuesta sale del JSON, no del `.md`. Decime 'siguiente' cuando termines."*

### Después del prompt
Comentá brevemente:
- Que en la salida deberías haber visto las llamadas `mcp__filesystem__*` apareciendo, en vez de `Read` sobre el repo.
- Que el agente filtró por tag (`contiene-lactosa`) — eso es lo que el JSON estructurado hace posible. Con el `.md` libre tendrías que hacer parsing en lenguaje natural.
- **Takeaway:** *"un MCP es un proveedor. Lo llamás, te responde, no te importa qué hay adentro. Y vos podés escribir tus propios MCPs o usar oficiales — el filesystem que estamos usando es de Anthropic."*

Cerrá con *"¿Pasamos al último concepto?"* y esperá.

---

## Concepto 3 — Read + Write con persistencia entre sesiones

### Explicación que tenés que dar
Los MCPs no son solo para **leer**. Pueden **persistir cambios**. Esto convierte al agente en algo que **mantiene state entre sesiones** — algo que con archivos locales no se puede hacer prolijamente.

### Pedile al usuario que abra
[`the-restaurant-data/stock/ingredientes.json`](../../the-restaurant-data/stock/ingredientes.json). Mostrale la estructura: cada ingrediente tiene `cantidad`, `unidad`, `umbral_alerta`. Anotale los valores actuales de `muzzarella`, `nalga`, `provoleta` — los vamos a comparar después.

### Prompt para probar
Pedile que arme un pedido representativo:

```
Soy un cliente. Quiero 3 milanesas napolitanas y una provoleta a la parrilla.
```

Aclará lo que va a pasar:
1. **Santi atiende y confirma el pedido.**
2. **Invoca a Gustavo** (subagente cocinero, rama 04). Gustavo:
   - Lee los items del menú vía `mcp__filesystem__read_file` para saber qué ingredientes consume cada plato.
   - Lee `stock/ingredientes.json` vía MCP.
   - Calcula consumo: 3 milas × 0.15 kg muzza + 1 provoleta = 0.45 + 1 unidad provoleta.
   - **Reescribe** `stock/ingredientes.json` con los valores nuevos vía `mcp__filesystem__write_file`.
3. **Vuelve a Santi**, que entrega el plato.
4. *(Opcional)* Pedile la cuenta — el cajero también pasa por el MCP.

Decile: *"Cuando termine todo el flujo, decime 'siguiente'."*

### Después del prompt
Pedile que vuelva a abrir [`the-restaurant-data/stock/ingredientes.json`](../../the-restaurant-data/stock/ingredientes.json). Que compare:
- `muzzarella`: bajó de 10 a ~9.55 kg.
- `nalga`: bajó de 12 a ~11.4 kg.
- `provoleta`: bajó de 8 a 7 unidades.

Comentá:
- **El stock cambió de verdad, en disco.** Si cerrás Claude y abrís otra sesión, el cambio sigue ahí.
- **Esto NO se podía hacer con `.md` en el repo** sin meter el repo en un loop de commits feo.
- Si algún ingrediente cayó por debajo de su `umbral_alerta`, Gustavo debería haber agregado una entrada en `compras-pendientes.json` — fijate si está.
- **Takeaway:** *"acá se cierra el círculo. El restaurante deja de ser solo un proceso en la cabeza de Claude — empieza a tener state real, persistente, accesible desde otras herramientas (vos podés abrir el JSON con cualquier editor, otros MCPs podrían escribirlo, etc)."*

---

## Cierre de la rama (y del recorrido)

Decile al usuario:

> "Listo. Viste los tres conceptos de `05-mcps`:
> - **El problema de los `.md` locales** — por qué hace falta salir del repo cuando el sistema crece.
> - **MCPs como proveedores externos** — cómo se conectan, cómo aparecen sus tools (`mcp__<server>__*`), cómo el agente decide cuándo usarlos.
> - **Read + Write con persistencia entre sesiones** — state real que sobrevive al cierre de Claude.
>
> Y con esto cerramos el recorrido completo. Para resumir todo lo que viste:
>
> | Rama | Capa que agregó |
> |------|------------------|
> | `01-base` | CLAUDE.md, `/knowledge`, agente único |
> | `02-skills` | Skills (manuales y autoinvocadas) |
> | `03-hooks` | Hooks PreToolUse y PostToolUse |
> | `04-agents` | Subagentes con contexto fresco |
> | `05-mcps` | MCPs para state externo y persistencia |
>
> Cada capa apareció **cuando hizo falta**, no antes. Ese es el principio que se llevan: las herramientas de Claude Code no son features para coleccionar — son respuestas a problemas concretos.
>
> Si querés repetir el recorrido o saltar a una rama puntual, hacé el `git checkout` correspondiente y decime 'empezamos' para arrancar el tutor desde ahí.
>
> ¿Algo más?"

Después esperá. Si pregunta algo, respondé brevemente. Si no, dale las gracias y terminá.
