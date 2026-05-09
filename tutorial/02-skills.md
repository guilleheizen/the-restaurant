# Tutorial — Rama `02-skills`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `02-skills`. Adaptá el lenguaje, no copies frases textualmente.

## Lo que se recorre en esta rama

Dos conceptos sobre Skills:
1. **Skills con invocación manual** (`/<nombre>`) — atajos que el usuario dispara explícitamente con `/`.
2. **Skills con autoinvocación** (por `description`) — habilidades que Claude carga solo cuando detecta que las necesita.

En esta rama, además de lo de `01-base`, aparece la carpeta `.claude/skills/` con tres skills:
- `tomar-pedido/` — manual
- `cerrar-mesa/` — manual
- `cocteleria/` — autoinvocada, con archivos de soporte en `recetas/`

---

## Saludo inicial

Decile al usuario, en una o dos frases:
- Que pasó a la rama `02-skills`.
- Que vamos a ver dos formas de Skills: las que disparás vos con `/`, y las que Claude carga sola.
- Que el formato es el mismo de la rama anterior: explicación → archivo a abrir → prompt para probar → comentario corto.

Cerrá con *"¿Arrancamos? Decime 'dale' cuando estés listo."* y esperá.

---

## Concepto 1 — Skills con invocación manual (`/<nombre>`)

### Explicación que tenés que dar
Una **Skill** es una carpeta `.claude/skills/<nombre>/SKILL.md` con un body que Claude ejecuta cuando vos tipeás `/<nombre>`. Sirve para empaquetar flujos repetitivos en un atajo. El body es lenguaje natural — son instrucciones, no código.

### Pedile al usuario que abra
[`.claude/skills/tomar-pedido/SKILL.md`](../.claude/skills/tomar-pedido/SKILL.md).

Comentá brevemente:
- El **frontmatter** (entre `---`) define `name` y `description`.
- El **body** son las instrucciones que Claude sigue cuando lo invocás. Notá que es prosa común.

### Prompt para probar
Pedile que tipee:

```
/tomar-pedido
```

Aclará: *"Vas a ver que Guillermo arranca el flujo completo en una sola tirada — saludo, oferta de carta, propuesta de recomendación. Sin que vos hayas tipeado el prompt largo. Cuando termines (podés llegar hasta el pedido confirmado o cortar antes), decime 'siguiente'."*

### Después del prompt (cuando el usuario dice "siguiente")
Comentá brevemente:
- Que sin la skill, hubieras tenido que prompear *"actuá como mesero, saludá, ofrecé la carta..."* cada vez. La skill empaqueta eso en un atajo.
- Mencioná de paso que también está [`.claude/skills/cerrar-mesa/SKILL.md`](../.claude/skills/cerrar-mesa/SKILL.md) con el mismo patrón (calcula la cuenta y la presenta formateada). Si quiere probarlo después, va con `/cerrar-mesa`.
- **Takeaway:** *"si lo hacés más de tres veces, hacelo una Skill."*

Cerrá con *"¿Pasamos al siguiente concepto?"* y esperá.

---

## Concepto 2 — Skills con autoinvocación

### Explicación que tenés que dar
Una Skill puede tener un `description` lo suficientemente específico para que Claude la cargue **sola**, sin que el usuario use `/`. Cuando detecta que el contexto matchea la descripción, la activa. Si no la necesita, no se carga (y no gasta tokens).

Eso es **carga progresiva**: tener un montón de habilidades disponibles que viven en disco, y solo las que aplican entran al contexto cuando hace falta.

### Pedile al usuario que abra
[`.claude/skills/cocteleria/SKILL.md`](../.claude/skills/cocteleria/SKILL.md).

**Lo importante**: pedile que mire bien el campo `description` del frontmatter. Comentá: *"Ese texto es lo que Claude lee para decidir cuándo activar la skill. Notá que enumera nombres de tragos específicos (negroni, mojito, manhattan) y situaciones (pedidos de variaciones). Cuanto más específico el `description`, mejor matchea Claude."*

Después pedile que mire la carpeta hermana [`.claude/skills/cocteleria/recetas/`](../.claude/skills/cocteleria/recetas/) — son cuatro archivos de soporte (negroni, mojito, manhattan, old-fashioned) que la skill puede consultar cuando se activa.

Comentá: *"Ese formato — carpeta con `SKILL.md` + archivos de soporte — es la diferencia entre una skill simple y una con conocimiento estructurado. Los archivos de `recetas/` no se cargan al contexto siempre — solo cuando la skill se activa y los necesita."*

### Prompt para probar
Pedile que tipee:

```
Quiero un negroni con un toque extra de Campari.
```

Aclará: *"Claude debería detectar 'negroni' (no está en la carta de tragos) + la variación ('toque extra de Campari') y autocargarse la skill `cocteleria`. Después, Guillermo te confirma el trago con el ajuste leído de `recetas/negroni.md`. Decime 'siguiente' cuando termines."*

### Después del prompt
Comentá brevemente:
- Si la skill se cargó, en la respuesta de Claude vas a ver que aparece info específica del negroni (las proporciones 1:1:1, el twist de naranja, el ajuste para "más Campari"). Eso vino del archivo `recetas/negroni.md`.
- Si pidieras una **cerveza Quilmes** (que sí está en la carta básica), la skill **no se cargaría** — Claude ya tiene esa info en el `knowledge/menu/tragos.md` que carga al inicio. Ahí está el ahorro: la habilidad de coctelería no ocupa contexto si nadie pide tragos raros.
- **Takeaway:** *"las skills autoinvocadas son habilidades que aparecen cuando hacen falta. Si no las usás, no gastan tokens."*

---

## Cierre de la rama

Decile al usuario:

> "Listo. Viste los dos modos de Skills:
> - **Invocación manual** — `/tomar-pedido` y `/cerrar-mesa` empaquetan flujos repetitivos en un atajo.
> - **Autoinvocación** — `cocteleria` se activa sola cuando el contexto la pide, y trae sus archivos de soporte cuando los necesita.
>
> Las dos viven en `.claude/skills/<nombre>/SKILL.md`. La diferencia está en el `description` del frontmatter y en cómo se disparan.
>
> La próxima rama agrega **hooks**: scripts que el sistema corre automáticamente, antes y después de cada tool call. A diferencia de las Skills, los hooks **no los puede ignorar el agente** — son determinísticos.
>
> Para seguir, hacé:
> ```bash
> git checkout 03-hooks
> ```
>
> Cuando estés en la nueva rama, decime 'listo' y seguimos."

Después esperá.
