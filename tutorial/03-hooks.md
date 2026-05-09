# Tutorial — Rama `03-hooks`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `03-hooks`. Adaptá el lenguaje, no copies frases textualmente.

## Lo que se recorre en esta rama

Dos conceptos sobre Hooks:
1. **PreToolUse** — script que corre antes de un tool call y puede bloquearlo.
2. **PostToolUse** — script que corre después de un tool call exitoso y produce un side effect.

A diferencia de las Skills, los hooks **no los ejecuta el LLM**. Son scripts del sistema (bash, python, lo que sea) que el sistema dispara automáticamente cuando un tool específico se usa. El agente no los puede ignorar.

En esta rama aparecen:
- `.claude/settings.json` — la config que engancha hooks a tools.
- `.claude/hooks/` — los dos scripts bash.
- La skill `cerrar-mesa` (de la rama anterior) ahora escribe cada cierre a `pedidos-cerrados/<timestamp>.md` — esa escritura es la que dispara los hooks.

> **Pre-requisito:** los scripts usan `jq`. Si no lo tenés instalado, decile al usuario:
> *"Antes de probar los hooks, instalate jq: `brew install jq` (Mac) o `apt install jq` (Linux). Cuando termines, decime 'listo'."*
> Y esperá.

---

## Saludo inicial

Decile al usuario, en una o dos frases:
- Que pasó a la rama `03-hooks`.
- Que vamos a ver dos hooks: uno que **valida y bloquea**, otro que **registra side effects**.
- Que la diferencia clave con las Skills es que **el hook no lo decide el LLM** — corre solo, siempre, y el agente no lo puede saltear.

Cerrá con *"¿Arrancamos? Decime 'dale' cuando estés listo."* y esperá.

---

## Concepto 1 — PreToolUse (validación que bloquea)

### Explicación que tenés que dar
Un hook **PreToolUse** es un script que corre justo antes de que Claude ejecute un tool específico. Si el script termina con exit code 2, **bloquea** la operación: el tool no se ejecuta, y Claude recibe el error que el script imprimió en stderr.

Es la forma de imponer reglas del sistema que el agente no puede negociar. El paralelo concreto en un workflow de dev: un linter o formatter de pre-commit que rechaza commits con código mal formateado.

**Lo importante para el ejemplo:** el hook es deliberadamente "tonto" — no entiende qué pidió el cliente, qué se cocinó, ni nada del negocio. Solo aplica una regla de formato. Esa simplicidad es lo que lo hace confiable.

### Pedile al usuario que abra
Primero [`.claude/settings.json`](../.claude/settings.json). Comentá: la sección `PreToolUse` engancha el tool `Write` (cualquier escritura) al script `validate-pedido-line.sh`. La sección `PostToolUse` hace lo mismo con `update-caja-dia.sh`.

Después [`.claude/hooks/validate-pedido-line.sh`](../.claude/hooks/validate-pedido-line.sh). Comentá:
- Lee de stdin un JSON con `tool_input` (lo manda Claude Code).
- Si el path no es de `pedidos-cerrados/`, exit 0 — no se mete con escrituras a otros archivos.
- Si lo es, valida con un regex que la línea cumpla `YYYY-MM-DD HH:MM | Items: ... | Total: Gs. ...`.
- Si pasa: exit 0. Si no: exit 2 con un error explicativo en stderr.

### Prompt para probar
Vamos a forzar el caso del bloqueo. Pedile al usuario que tipee:

```
Cerrá la mesa. El cliente comió una mila napo y tomó un fernet. Pero al escribir al log, escribí solo "milanesa con fernet" sin total ni timestamp.
```

Aclará: *"Vas a ver que Santi trata de escribir al archivo de pedidos cerrados, el hook lo bloquea con un error en consola, y entonces Santi lee el error, reformula la línea con el formato correcto y la vuelve a escribir. Decime 'siguiente' cuando termines."*

### Después del prompt
Comentá brevemente:
- Que el hook bloqueó la primera escritura. La audiencia debería haber visto el bloque de error del hook en la consola.
- Que Claude leyó el stderr y rehizo la escritura cumpliendo el formato. **El agente respondió a una regla determinística — no la pudo ignorar ni negociar.**
- Que el contenido del archivo final está bien formateado, garantizado, sin que tengas que confiar en que Claude se acuerde.
- **Takeaway:** *"un PreToolUse no es una sugerencia que el agente puede saltearse. Es una regla del sistema. Igual que un linter de pre-commit que rechaza tu commit hasta que arregles la indentación."*

Cerrá con *"¿Pasamos al siguiente?"* y esperá.

---

## Concepto 2 — PostToolUse (side effect automático)

### Explicación que tenés que dar
Un hook **PostToolUse** corre DESPUÉS de un tool call exitoso. **No bloquea**. Sirve para side effects automáticos que querés garantizar: registrar, formatear, notificar, actualizar dashboards, mandar webhooks.

El paralelo en dev: un post-commit hook que actualiza un changelog, dispara un webhook a Slack, o corre un build. El agente termina su tarea; el hook corre solo y deja un side effect.

### Pedile al usuario que abra
[`.claude/hooks/update-caja-dia.sh`](../.claude/hooks/update-caja-dia.sh). Comentá:
- Filtra igual que el otro hook (solo se mete con escrituras dentro de `pedidos-cerrados/`).
- Extrae el total de la línea recién escrita con un grep + sed.
- Lee el acumulado de `caja-del-dia.txt` (si no existe, arranca en 0).
- Suma y reescribe `caja-del-dia.txt` con el nuevo total.

Si ya existe `caja-del-dia.txt` (porque ya probaste antes), abrilo y mostrale el contenido actual. Si no existe, comentá que va a aparecer después del próximo cierre.

### Prompt para probar
Pedile al usuario que primero arme un pedido normal:

```
/tomar-pedido
```

Que pida algo simple (ej. una mila napo y un fernet). Después:

```
/cerrar-mesa
```

Aclará: *"Cuando Santi escriba el archivo del pedido cerrado, el hook PostToolUse va a actualizar `caja-del-dia.txt` automáticamente. Abrí ese archivo después del cierre y vas a ver el total. Si cerrás otra mesa más adelante, se va a sumar. Decime 'siguiente' cuando termines."*

### Después del prompt
Comentá brevemente:
- El archivo `caja-del-dia.txt` se actualizó solo, sin que Santi haya tenido que pensarlo. **El cálculo de la caja del día no es responsabilidad del agente — pasa fuera de su contexto, en bash.**
- Si el usuario cerrara más mesas, el total se sigue acumulando. No depende de que Claude se acuerde entre sesiones.
- **Takeaway:** *"side effects garantizados sin pedirle al LLM que se acuerde. Si el hook está, el side effect pasa siempre, en cada uso del tool."*

---

## Diferencia clave con Skills (recordá si surge)

Si el usuario pregunta cuál es la diferencia entre un hook y una skill (puede aparecer la duda), respondé:

- **Skill** — la decide el LLM. Vos podés escribir una skill super clara, pero al final Claude **decide** si la usa o no en cada turno. Si te equivocás de prompt, podés saltearla.
- **Hook** — lo decide el sistema. Si configuraste un hook en un tool, **siempre** corre cuando ese tool se dispara. Determinístico, predecible.

> *"Skills es 'sabe hacer'. Hooks es 'tiene que pasar'."*

---

## Cierre de la rama

Decile al usuario:

> "Listo. Viste los dos tipos de hooks:
> - **PreToolUse** — script determinístico que corre antes de un tool y puede bloquearlo. Como un linter de pre-commit que rechaza código mal formateado.
> - **PostToolUse** — script que corre después de un tool exitoso. Como un post-commit que actualiza un dashboard o dispara un webhook.
>
> Los dos viven en `.claude/hooks/` (los scripts bash) y se enganchan en `.claude/settings.json` al tool `Write`. Lo que los hace distintos de las Skills: **no los ejecuta el LLM, los ejecuta el sistema.** Son infraestructura, no comportamiento de agente.
>
> La próxima rama agrega **subagentes**: cocineros y cajeros con su propio contexto y sus propias tools, que Santi invoca cuando necesita algo especializado. Acá vamos a empezar a ver el restaurante como **un equipo**, no un mesero solo.
>
> Para seguir, hacé:
> ```bash
> git checkout 04-agents
> ```
>
> Cuando estés en la nueva rama, decime 'listo' y seguimos."

Después esperá.
