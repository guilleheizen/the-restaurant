# Tutorial — Rama `03-hooks`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `03-hooks`. Adaptá el lenguaje, no copies frases textualmente. **Mostrale al usuario los paths como rutas absolutas** (cliqueables en su editor).

## Lo que se recorre en esta rama

Un solo concepto, en dos sabores:

**Hooks** — scripts del sistema (bash) que el harness dispara automáticamente antes (`PreToolUse`) o después (`PostToolUse`) de un tool call. Diferencia clave con las skills: **no los ejecuta el LLM** — corren solos, siempre, y el agente no los puede saltear.

> **Pre-requisito:** los scripts usan `jq`. Si no lo tenés instalado, decile: `brew install jq` (Mac) o `apt install jq` (Linux). Esperá confirmación.

---

## Saludo inicial

Saludo de 2-3 frases:
- Que pasó a la rama `03-hooks`.
- Que vamos a crear UN hook para asegurar que el cierre de mesa se escriba con un formato fijo, y que cuando se escriba, se actualice la caja del día. Dos efectos, mismo concepto.
- Que la diferencia con skills: el sistema lo dispara, no Claude.

Cerrá con *"¿Arrancamos? Decime 'dale'."* y esperá.

---

## Concepto único — Hooks: validar antes, reaccionar después

### En lenguaje de negocio

Cada vez que el cajero cierra una mesa, dos cosas tienen que pasar **siempre**:
- **Antes** de escribir: validar que la línea cumpla el formato (fecha, items, total). Si no, se rechaza.
- **Después** de escribir: actualizar `caja-del-dia.txt` con el nuevo total acumulado.

No queremos depender de que Claude se acuerde. Lo automatizamos con dos hooks.

### Anatomía

| Pieza | Path | Qué hace |
|---|---|---|
| Configuración | `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/settings.json` | Engancha el tool `Write` a los dos scripts. |
| Hook `PreToolUse` | `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/hooks/validate-pedido-line.sh` | Lee stdin, filtra por path `pedidos-cerrados/`, valida regex de la línea. `exit 2` → bloquea el `Write` con mensaje en stderr. |
| Hook `PostToolUse` | `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/hooks/update-caja-dia.sh` | Mismo filtro. Extrae el total y lo suma a `caja-del-dia.txt`. |

Mostrale los tres archivos al usuario; los hooks son cortos, los puede leer entero.

### Ventajas y desventajas (corto)

| Ventajas | Desventajas |
|---|---|
| Determinístico, el LLM no lo puede saltear | Vive afuera del LLM, hay que mantenerlo |
| Sirve para cualquier tool, no solo `Write` | Un script roto frena el flujo |
| Side effects garantizados sin pedirle nada al agente | Debug es bash, no prompt |

### Prompt para probar

```
Cerrá la mesa. El cliente comió una mila napo y tomó un fernet. Pero al escribir al log, escribí solo "milanesa con fernet" sin total ni timestamp.
```

Lo que vas a ver:
1. El cajero intenta escribir mal → **`PreToolUse` lo bloquea** con un error en stderr.
2. Claude lee el error, **reformula** la línea con el formato correcto, y vuelve a escribir.
3. La escritura pasa → **`PostToolUse`** actualiza `caja-del-dia.txt`.

Después abrí `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/caja-del-dia.txt`: el total apareció solo. Si cerrás otra mesa, se acumula.

Decime "siguiente" cuando termines.

### Takeaway

*"Skills es 'sabe hacer'. Hooks es 'tiene que pasar'."*

---

## Cierre de la rama

> "Listo. Hooks viven en `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/.claude/hooks/` y se enganchan en `.claude/settings.json` al tool `Write`. Lo importante: NO los ejecuta el LLM, los ejecuta el sistema. Son **infraestructura**.
>
> La próxima rama agrega **subagentes** — el restaurante deja de ser solo Santi y se convierte en un equipo (cocinero + cajero) con contexto fresco cada uno.
>
> Voy a hacer `git checkout 04-agents` cuando me confirmes."

Esperá confirmación; al confirmar, ejecutá vos el `git checkout` y arrancá con `tutorial/04-agents.md`.
