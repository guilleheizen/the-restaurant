# Tutorial — Rama `04-agents`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `04-agents`. Adaptá el lenguaje, no copies frases textualmente.

## Lo que se recorre en esta rama

Dos conceptos sobre subagentes:
1. **Subagentes con contexto fresco** — cómo Claude Code permite tener "un equipo" de agentes especializados, cada uno con su propio contexto y sus propias tools.
2. **Cuándo dividir y cuándo no** — la regla pedagógica clave: subagentes no son una feature gratis, dividís cuando hay un problema concreto que resuelven.

En esta rama aparece la carpeta `.claude/agents/` con dos subagentes:
- `gustavo.md` — el cocinero. Habla en MAYÚSCULAS.
- `cajero.md` — el cajero. Serio y formal.

Las skills `tomar-pedido` y `cerrar-mesa` (que en la rama anterior hacían todo solas) ahora **delegan**: Guillermo es el orquestador, Gustavo cocina, el cajero cobra.

---

## Saludo inicial

Decile al usuario, en una o dos frases:
- Que pasó a la rama `04-agents`.
- Que el restaurante deja de ser un mesero solo y se convierte en un equipo.
- Que la diferencia visible va a ser que las respuestas van a tener "voces" distintas — Guillermo tranquilo, Gustavo gritando en mayúsculas, el cajero serio.

Cerrá con *"¿Arrancamos? Decime 'dale' cuando estés listo."* y esperá.

---

## Concepto 1 — Subagentes con contexto fresco

### Explicación que tenés que dar
Un **subagente** es un agente con su propio contexto, sus propias tools y su propia descripción de cuándo invocarlo. El agente "padre" (en este caso Guillermo, que es el Claude principal con el `CLAUDE.md` cargado) lo invoca cuando hace falta.

**Lo crucial:** el subagente arranca con **contexto fresco**. NO ve la conversación con el cliente. Solo recibe la comanda que el padre le pasa. Eso es lo que lo hace eficiente:
- El cocinero no se "llena la cabeza" con la charla sobre el clima entre el cliente y el mesero.
- Cada subagente puede usar un modelo distinto (más barato si la tarea es simple), tener tools restringidas, etc.

### Pedile al usuario que abra
Primero [`.claude/agents/gustavo.md`](../.claude/agents/gustavo.md). Comentá:
- El **frontmatter** define `name`, `description` (cuándo invocarlo — Claude lo lee para decidir) y `tools` (qué puede hacer — Gustavo solo lee, no escribe).
- El **body** es el system prompt del subagente. Contiene su personalidad, su workflow, sus reglas.

Después [`.claude/agents/cajero.md`](../.claude/agents/cajero.md). Comentá:
- Mismo formato pero el cajero **sí tiene `Write`** entre sus tools — necesita escribir el registro a `pedidos-cerrados/`.
- Notá que cada agente tiene un perímetro chico: el cocinero NO atiende clientes, el cajero NO recomienda platos.

Mostrale también el cambio en [`.claude/skills/tomar-pedido/SKILL.md`](../.claude/skills/tomar-pedido/SKILL.md): el step 5 ya no dice "simulás vos la entrega", ahora dice **"invocá al subagente gustavo"**. Lo mismo en [`.claude/skills/cerrar-mesa/SKILL.md`](../.claude/skills/cerrar-mesa/SKILL.md) con el cajero.

### Prompt para probar
Pedile al usuario que tipee:

```
Soy un cliente. Quiero milanesa napolitana con papas y un fernet con coca.
```

Aclará lo que va a ver:
1. **Guillermo atiende y confirma** (voz cálida, modismos).
2. **Invoca a Gustavo.** Va a aparecer una llamada a Task tool con `subagent_type: gustavo`. La respuesta vuelve **EN MAYÚSCULAS, GRITANDO** — esa es la señal visual de que es otro agente.
3. **Vuelve a Guillermo**, que toma lo que dijo Gustavo y se lo presenta al cliente con su propio tono.

Después decile: *"Cuando termines de ver el flujo de la cocina, pedile la cuenta a Guillermo (ej. 'me cobrás'). Vas a ver que Guillermo invoca al cajero, que escribe al log y devuelve la cuenta formateada. Ahí decime 'siguiente'."*

### Después del prompt (cuando dice 'siguiente')
Comentá brevemente:
- Que la voz de Gustavo en MAYÚSCULAS hace **inmediatamente visible** que hay otro agente operando. Es la señal pedagógica clave: "se ve" la división.
- Que el cajero escribió a `pedidos-cerrados/<timestamp>.md` y disparó los hooks de la rama anterior. Si el usuario quiere, puede abrir `caja-del-dia.txt` y ver que se actualizó.
- **Que cada subagente recibió contexto fresco**: Gustavo no escuchó el saludo del cliente, el cajero no escuchó la conversación entera. Solo recibieron la tarea concreta.
- **Takeaway:** *"un agente solo es un mesero corriendo todo. Subagentes es tener equipo. Cada uno arranca con contexto fresco — no se llena la cabeza con cosas que no le sirven."*

Cerrá con *"¿Pasamos al siguiente concepto?"* y esperá.

---

## Concepto 2 — Cuándo dividir y cuándo no

### Explicación que tenés que dar
Subagentes **no son una feature gratis**. Cada llamada a un subagente:
- Suma latencia (es otra invocación al modelo).
- Suma tokens (cada subagente carga su system prompt).
- Suma complejidad (más archivos, más coordinación).

Solo conviene dividir cuando hay un problema concreto que resuelve la división.

### Tres criterios para dividir
1. **Contexto saturado** — el agente único tiene tanta info en la cabeza que se pierde o gasta mucho. Dividir lo libera.
2. **Paralelismo posible** — dos cosas pueden pasar al mismo tiempo (cocina + atención simultánea).
3. **Modelo distinto** — una tarea es simple y barata (ej. el cajero podría correr en haiku), otra es compleja (mesero conversando con cliente conviene en sonnet).

### Pedile al usuario que abra
[`.claude/agents/`](../.claude/agents/) y mire los dos archivos de subagentes lado a lado. Resaltá las `description`:
- Gustavo: "se invoca cuando hay que cocinar". No para conversar, no para cobrar.
- Cajero: "se invoca para cerrar la cuenta". No para recomendar, no para cocinar.

Cada uno hace una cosa, la hace bien.

### No hay prompt de prueba
Este es un concepto de reflexión, no de hacer. Si el usuario quiere experimentar, sugerile que mire qué pasaría si Gustavo tuviera la tool `Write` (podría escribir al log él mismo, pero entonces ¿para qué un cajero?).

### Después de la reflexión
Comentá:
- En la rama `01-base` el restaurante funcionaba con un solo agente. Y andaba. **Dividir no es una mejora automática.**
- Acá lo dividimos porque (1) el contexto se llenaba, (2) pedagógicamente queremos mostrar la división, y (3) en sistemas reales esto escala mejor.
- En tu propio dominio, antes de dividir, preguntate: ¿qué problema concreto resuelvo? Si no podés contestar, no dividas.
- **Takeaway:** *"subagentes no es una feature avanzada. Es una solución a un problema concreto. Si tu agente único anda bien, no dividas."*

---

## Cierre de la rama

Decile al usuario:

> "Listo. Viste los dos conceptos de `04-agents`:
> - **Subagentes con contexto fresco** — Gustavo y el cajero, cada uno con su voz, su workflow y sus tools restringidas. Guillermo orquesta.
> - **Cuándo dividir** — solo cuando hay problema concreto. Subagentes no son una mejora automática.
>
> Los subagentes viven en `.claude/agents/<nombre>.md`. La `description` del frontmatter es lo que Claude lee para decidir cuándo invocarlos.
>
> La próxima rama agrega **MCPs**: el menú y el stock se mueven afuera del repo, a una carpeta personal del usuario, accedidos via el filesystem MCP oficial. Vamos a ver el patrón de "dato externo, agente lo consulta on-demand". Y va a ser la primera rama que requiere instalar algo (un MCP server).
>
> Para seguir, hacé:
> ```bash
> git checkout 05-mcps
> ```
>
> Cuando estés en la nueva rama, decime 'listo' y seguimos."

Después esperá.
