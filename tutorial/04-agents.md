# Tutorial — Rama `04-agents`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `04-agents`. Adaptá el lenguaje, no copies frases textualmente. **Paths como rutas absolutas.**

## Lo que se recorre en esta rama

Un concepto: **subagentes** — agentes especializados con contexto, tools y modelo propios, que el agente principal (Santi) invoca cuando hace falta.

Aparecen dos:
- **Gustavo** (cocinero) — vive en `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/gustavo.md`
- **Cajero** — vive en `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/cajero.md`

Las skills `tomar-pedido` y `cerrar-mesa` (de la rama anterior) ahora **delegan** en estos subagentes en vez de hacer todo Santi.

---

## Saludo inicial

Saludo de 2-3 frases:
- Que pasó a `04-agents`.
- Que el restaurante ya no es solo Santi: ahora es un equipo. Vas a "ver" los roles porque cada uno tiene su propia voz.
- Que cada subagente arranca con **contexto fresco** — no se llena la cabeza con cosas que no le sirven.

Cerrá con *"¿Arrancamos? Decime 'dale'."* y esperá.

---

## Concepto único — Subagentes con contexto fresco

### Los dos subagentes (plantilla compacta)

> **Gustavo** — subagente encargado de la **cocina**.
> *Personalidad:* chef gritón, MAYÚSCULAS y modismos argentinos.
> *Cuándo se invoca:* cuando hay un pedido confirmado para "preparar".
> *Skills que usa:* lee recetas en `knowledge/recetas/`, descuenta stock vía MCP en rama 05+.
> *Tools:* `Read, Write, Glob, Grep, mcp__filesystem__read_file, mcp__filesystem__write_file, mcp__filesystem__list_directory`.
> *Modelo:* `sonnet` — improvisa voz, varía respuestas, razona sobre stock.
> *Vive en:* `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/gustavo.md`

> **Cajero** — subagente encargado de **cerrar cuentas**.
> *Personalidad:* serio, formal, profesional. Cero sobremesa.
> *Cuándo se invoca:* cuando hay que cerrar la cuenta de un cliente (vía la skill `cerrar-mesa`).
> *Skills que usa:* invocado por la skill `cerrar-mesa`.
> *Tools:* `Read, Glob, Grep, Write, mcp__filesystem__read_file, mcp__filesystem__list_directory`.
> *Modelo:* `haiku` — la tarea es estructurada (buscar precios, sumar, escribir formato fijo) y barata.
> *Vive en:* `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/cajero.md`

Notá:
- **Cada uno tiene un perímetro chico**. Gustavo NO atiende clientes; el cajero NO recomienda platos.
- **El modelo se elige por tarea.** Haiku para lo barato y estructurado; Sonnet para lo creativo o conversacional.
- **El frontmatter `description`** es lo que el padre lee para decidir cuándo invocarlos. Cuanto más clara, mejor.

### Ventajas y desventajas (corto)

| Ventajas | Desventajas |
|---|---|
| Contexto fresco por agente | Cada invocación = más latencia |
| Modelo distinto por tarea (paga menos) | Cada invocación = más tokens (system prompt nuevo) |
| Tools restringidas por rol | Más archivos que coordinar |
| "Se ve" la división (voces distintas) | Si el padre orquesta mal, se rompe el flujo |

**Cuándo dividir:** contexto saturado, paralelismo posible, modelo distinto. **Si tu agente único anda bien, no dividas.**

### Prompt para probar

```
Soy un cliente. Quiero milanesa napolitana con papas y un fernet con coca.
```

Lo que vas a ver:
1. Santi confirma el pedido (voz cálida).
2. Invoca a **Gustavo** → respuesta EN MAYÚSCULAS (señal visual de otro agente).
3. Vuelve a Santi → te entrega el plato en su tono.
4. Pedile la cuenta (`me cobrás`) → Santi invoca al **cajero** → escribe a `pedidos-cerrados/<timestamp>.md` (eso dispara los hooks de la rama 03) → Santi te presenta la cuenta.

Decime "siguiente" cuando termines.

### Takeaway

*"Subagentes no es feature gratis. Cada uno cuesta tokens y latencia. Dividís cuando hay un problema concreto que la división resuelve."*

---

## Cierre de la rama

> "Listo. Subagentes viven en `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/agents/<nombre>.md`. La `description` del frontmatter es lo que el padre lee para decidir cuándo invocarlos.
>
> La próxima rama agrega **MCPs** — el menú y el stock se mueven afuera del repo, a una **bóveda** externa, accedidos vía el filesystem MCP. Es la primera rama que requiere instalar algo (lo hago yo).
>
> Voy a hacer `git checkout 05-mcps` cuando me confirmes."

Esperá confirmación; al confirmar, ejecutá vos el `git checkout` y arrancá con `tutorial/05-mcps.md`.
