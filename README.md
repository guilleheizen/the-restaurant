# 🍽️ The Restaurant

> Aprendé Claude Code construyendo un sistema agéntico que evoluciona, rama por rama. El ejemplo que viene incluido es un restaurante (**La Esquina Criolla**), pero está pensado para que puedas reemplazarlo por tu propio dominio sin tocar la estructura.

Cada rama agrega una capa nueva sobre la anterior: `CLAUDE.md` → Skills → hooks → subagentes → MCPs. Después de recorrerlo, vas a tener un mapa de **cuándo usar qué herramienta de Claude Code** — no solo qué herramientas existen.

---

## Tabla de contenidos

- [Qué vas a aprender](#qué-vas-a-aprender)
- [Cómo usar este repo](#cómo-usar-este-repo)
- [Antes de arrancar: ¿qué es un agente?](#antes-de-arrancar-qué-es-un-agente)
- [Rama `01-base` — CLAUDE.md, contexto y `/knowledge`](#rama-01-base--claudemd-contexto-y-knowledge)
- [Rama `02-skills` — Skills](#rama-02-skills--skills)
- [Rama `03-hooks` — pre y post tool use](#rama-03-hooks--pre-y-post-tool-use)
- [Rama `04-agents` — subagentes y pipelines](#rama-04-agents--subagentes-y-pipelines)
- [Rama `05-mcps` — MCPs como proveedores externos](#rama-05-mcps--mcps-como-proveedores-externos)
- [Cambiar el ejemplo (forkear y adaptar a tu dominio)](#cambiar-el-ejemplo-forkear-y-adaptar-a-tu-dominio)
- [Estructura del repo](#estructura-del-repo)
- [Licencia](#licencia)

---

## Qué vas a aprender

| Rama | Concepto | Qué se agrega en el repo |
|------|----------|--------------------------|
| `01-base` | Contexto, tokens, `CLAUDE.md`, `/knowledge` como referencia | `CLAUDE.md` con las reglas del local + carpeta `/knowledge` con menú, recetas, personajes, reglas, stock |
| `02-skills` | **Skills**: invocación manual con `/` y autoinvocación por descripción | `.claude/skills/tomar-pedido/SKILL.md`, `.claude/skills/cerrar-mesa/SKILL.md`, `.claude/skills/cocteleria/SKILL.md` |
| `03-hooks` | Hooks `PreToolUse` y `PostToolUse` | `.claude/settings.json` con un hook que valida pedidos y otro que escribe `pedidos-cerrados/<timestamp>.md` |
| `04-agents` | Subagentes y división de responsabilidades | `.claude/agents/gustavo.md` (cocinero) y `.claude/agents/cajero.md` |
| `05-mcps` | MCPs como proveedores externos | Menú y stock movidos a `the-restaurant-data/` (hermano del repo), accedidos via el [filesystem MCP oficial](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem) |

---

## Cómo usar este repo

1. **Cloná el repo** y entrá a la carpeta:
   ```bash
   git clone https://github.com/guilleheizen/the-restaurant.git
   cd the-restaurant
   ```

2. **Posicionate en la rama** que querés explorar:
   ```bash
   git checkout 01-base   # o 02-skills, 03-hooks, etc.
   ```

3. **Abrí Claude Code** en la carpeta:
   ```bash
   claude
   ```

4. **Probá los prompts** de cada sección de este README. Cada concepto trae un prompt y una descripción de qué tiene que pasar.

> 💡 **Para enseñarlo a otros.** Cada concepto en este README sigue el mismo formato: **qué es** → **dónde lo ves en el repo** → **probalo** → **cómo lo explicarías**. La última parte es una metáfora del restaurante que podés reusar para que el concepto "se entienda al toque".

---

## Antes de arrancar: ¿qué es un agente?

Un **agente** es un LLM con un objetivo, un loop, y herramientas para cumplirlo. Lee, escribe, busca, decide. Si le pasás herramientas, las usa. Si le pasás un objetivo, intenta cumplirlo y vuelve a intentar cuando no sale.

En este repo vamos a construir un restaurante con varios agentes especializados (mesero, cocinero, cajero). Pero arrancamos con **uno solo** y vamos viendo qué problemas aparecen, y qué herramienta de Claude Code soluciona cada uno.

> 🍽️ **La metáfora.** Un agente es un mesero. Si está solo, atiende, cocina y cobra. Si el restaurante crece, contratás especialistas.

---

## Rama `01-base` — CLAUDE.md, contexto y `/knowledge`

```bash
git checkout 01-base
```

En esta rama hay **un solo agente** (Santi, el mesero) que hace todo: atiende, simula la cocina, cobra. Sin Skills, sin hooks, sin subagentes. Es el punto de partida — el restaurante minimal.

### Concepto 1 — `CLAUDE.md`

**Qué es.** El archivo que Claude Code lee al iniciar cada sesión en la carpeta. Acá van las reglas que querés que estén **siempre** en el contexto: tono, restricciones, dónde están los recursos del proyecto, qué hacer y qué no.

**Dónde lo ves en el repo.** Abrí [`CLAUDE.md`](CLAUDE.md) en la raíz. Son las reglas de La Esquina Criolla: quiénes son los personajes, en qué moneda se cobra (guaraníes), dónde vive el menú, cómo se manejan las quejas.

**Probalo.** Con Claude Code abierto en la carpeta:

```
Soy un cliente. Atendeme.
```

Vas a ver que Santi se presenta con onda, ofrece la carta y usa modismos rioplatenses. Sin que le hayas dicho nada más, ya sabe quién es y cómo hablar — porque `CLAUDE.md` se cargó al inicio.

**Cómo lo explicarías.**
> *"El manual del empleado pegado en la cocina. Antes de abrir, el mesero lo relee. Cada turno. No tiene que preguntarlo."*

🔑 **Takeaway:** si querés que Claude lo sepa siempre, va en `CLAUDE.md`.

---

### Concepto 2 — Contexto y tokens

**Qué es.** El **contexto** es lo que Claude tiene "en la cabeza" durante una sesión: tu mensaje, los archivos que leyó, las respuestas anteriores. Es finito. Cuando se llena, empieza a tirar cosas viejas.

Los **tokens** son la unidad en la que se mide. Cada palabra que entra y sale cuesta. Cargar `/knowledge/` entero al inicio de una sesión gasta tokens *aunque no uses todo*.

**Dónde lo ves en el repo.** Abrí el árbol [`knowledge/`](knowledge/) en tu editor. Ahí vive: menú, recetas, reglas, personajes, stock. Imaginá que cada archivo se carga al contexto cuando Claude lo lee.

**Probalo.** Tirá una pregunta cuya respuesta **no esté** en `/knowledge/`:

```
¿Cuántas calorías tiene la milanesa napolitana?
```

Santi no sabe — y eso está bien. El agente conoce sus límites. La info nutricional no está en `/knowledge/`, así que no se la inventa.

**Cómo lo explicarías.**
> *"El mesero tiene memoria de corto plazo: lo que pasó este turno. Si le seguís hablando, se empieza a olvidar de lo primero. Y los tokens son las palabras que escucha y dice en una jornada — cada palabra de más, pagás."*

🔑 **Takeaway:** contexto es lo que tiene en la cabeza ahora. Cuando se llena, empieza a tirar cosas viejas. Por eso, no todo se carga siempre — eso lo resolvemos con **skills** en la próxima rama.

---

### Concepto 3 — `/knowledge` como referencia

**Qué es.** Una carpeta convencional (no es magia de Claude Code) donde guardás conocimiento del proyecto que el agente puede consultar **on demand**. Lo nombrás en `CLAUDE.md` para que Claude sepa que existe, y se carga cuando lo necesita.

**Dónde lo ves en el repo.** Abrí [`knowledge/personajes/gustavo-sevilla.md`](knowledge/personajes/gustavo-sevilla.md). Ahí está la personalidad del chef. *Cuando llegue Gustavo como subagente en la rama 04, va a leer este mismo archivo para saber cómo es.*

**Probalo.**

```
¿Qué me recomendás de tomar con un asado?
```

Santi recomienda Malbec citando la regla de maridajes (que vive en `knowledge/reglas-casa/recomendaciones-chef.md`). Si abrís ese archivo, vas a ver que la respuesta sale literalmente de ahí.

**Cómo lo explicarías.**
> *"Carpetas en el back del restaurante: el menú está acá, las recetas allá, las reglas en otro cajón. El mesero no se lo aprende de memoria, va y consulta."*

🔑 **Takeaway:** `/knowledge` es el "back office" del agente. En la rama `05-mcps` esto se va a migrar a una bóveda externa, pero el patrón sigue: separar conocimiento de comportamiento.

➡️ **Próximo paso: rama `02-skills`** — cómo darle atajos al agente y habilidades que solo aparecen cuando hacen falta.

---

## Rama `02-skills` — Skills

```bash
git checkout 02-skills
```

Acá agregamos **Skills** — habilidades que viven en `.claude/skills/<nombre>/SKILL.md`. Una Skill puede dispararse manualmente con `/<nombre>` o cargarse sola cuando Claude detecta que hace falta. Doc oficial: [docs.claude.com/skills](https://code.claude.com/docs/en/skills.md).

### Concepto 1 — Skills con invocación manual (`/`)

**Qué es.** Una Skill es una carpeta con un `SKILL.md` que define el atajo `/<nombre>`. Cuando lo tipeás con `/`, Claude ejecuta el body como instrucciones. Sirve para empaquetar flujos repetitivos.

**Dónde lo ves en el repo.** Abrí [`.claude/skills/tomar-pedido/SKILL.md`](.claude/skills/tomar-pedido/SKILL.md). Mirá el frontmatter (`name`, `description`) y el body con el flujo del mesero.

**Probalo.**

```
/tomar-pedido
```

Santi arranca el flujo completo en una sola tirada: saludo → invitación a ordenar. Sin que hayas escrito un prompt largo.

**Cómo lo explicarías.**
> *"El atajo del mesero. Llegás al bar y decís 'lo de siempre'. El mesero sabe: cortado en jarrito, dos medialunas. No le tuviste que explicar nada."*

🔑 **Takeaway:** si lo hacés más de tres veces, hacelo una Skill.

---

### Concepto 2 — Skills con autoinvocación (Claude la carga sola)

**Qué es.** Una Skill puede tener un `description` lo suficientemente específico para que Claude la cargue **sola**, sin que vos uses `/`. Cuando detecta que el contexto matchea la descripción, la activa. Si no la necesita, no se carga (y no gasta tokens).

**Dónde lo ves en el repo.** Abrí [`.claude/skills/cocteleria/SKILL.md`](.claude/skills/cocteleria/SKILL.md). Mirá la `description` en el frontmatter — **ese texto es el que hace que Claude sepa cuándo cargar la skill**.

**Probalo.**

```
Quiero un negroni con un toque extra de Campari.
```

Claude detecta "negroni" + "trago no en carta" en el contexto. Carga la skill `cocteleria` automáticamente, lee la receta, y prepara el trago con el ajuste pedido. En la barra inferior de Claude Code vas a ver que la skill se cargó.

Si en cambio pedís una cerveza, la skill **ni se carga** — y ahí está el ahorro de tokens.

**Cómo lo explicarías.**
> *"El mesero hizo un curso de coctelería. La habilidad la tiene cargada cuando hace falta. Si nadie pide trago, esa habilidad no existe en su cabeza. Pero si alguien pide un negroni, automáticamente abre el manualcito."*

🔑 **Takeaway:** las skills autoinvocadas son habilidades que aparecen cuando hacen falta. No están en la cabeza si no se usan.

> 💡 **Diferencia clave entre los dos modos.** El mismo archivo de Skill puede ser invocable a mano (con `/`) y autoinvocable (por descripción) — no son skills distintas, son **dos formas de disparar la misma**. El criterio: si el usuario va a saber pedirla por nombre, dejala con `/`; si se debería activar sola por contexto, redactá un `description` específico.

➡️ **Próximo paso: rama `03-hooks`** — reglas determinísticas que se disparan solas, antes y después de cada tool call.

---

## Rama `03-hooks` — pre y post tool use

```bash
git checkout 03-hooks
```

Hasta ahora todo lo que hicimos depende del LLM: las reglas de `CLAUDE.md`, las Skills. Si Claude las ignora, no pasa nada. Los **hooks** son distintos: son scripts que el sistema ejecuta automáticamente, **no los negocia el agente**.

### Concepto 1 — `PreToolUse`

**Qué es.** Un hook que se ejecuta **antes** de que el agente use una tool específica. Si el script termina con exit code 2, **bloquea** la acción y el agente tiene que rehacerla.

**Dónde lo ves en el repo.** Abrí [`.claude/settings.json`](.claude/settings.json) y mirá la sección `PreToolUse`. Es un script bash que valida que un pedido tenga estructura mínima (al menos un plato, una bebida y un total).

**Probalo.** Mandale un pedido deliberadamente incompleto:

```
Quiero una mila.
```

Sin guarnición, sin bebida, sin contexto. Santi va a intentar confirmar el pedido pero el hook lo bloquea (exit code 2) porque falta estructura. Santi se da cuenta, pide aclaraciones al cliente, y rehace el pedido bien. En la consola vas a ver que el hook se disparó.

**Cómo lo explicarías.**
> *"El cocinero mira cada plato antes de que salga. Si el plato no está bien, no sale. Pasa automáticamente, sin que el mesero tenga que pedirlo."*

🔑 **Takeaway:** un hook `PreToolUse` no es una instrucción que el agente *puede* ignorar — es una regla del sistema, determinística, no depende del LLM.

---

### Concepto 2 — `PostToolUse`

**Qué es.** Un hook que se ejecuta **después** de que el agente usó una tool. **No bloquea**, solo registra. Sirve para auditoría, logs, métricas, side effects que querés que pasen sí o sí.

**Dónde lo ves en el repo.** Misma sección `PostToolUse` en [`.claude/settings.json`](.claude/settings.json). Después de cada `cerrar-mesa`, escribe una línea en `pedidos-cerrados.log` con timestamp y detalle.

**Probalo.**

```
/cerrar-mesa
```

Santi cierra la cuenta. Después, abrí `pedidos-cerrados.log` — vas a ver una línea nueva con la fecha, los items y el total.

**Cómo lo explicarías.**
> *"Después de servir, el mesero anota en el cuaderno: qué mesa, qué pidió, a qué hora. No bloquea nada, solo registra."*

🔑 **Takeaway:** los hooks son las reglas de la casa. No las negocia el mesero.

➡️ **Próximo paso: rama `04-agents`** — un mesero solo no escala. Toca dividir el restaurante en equipo.

---

## Rama `04-agents` — subagentes y pipelines

```bash
git checkout 04-agents
```

Hasta acá Santi era todo: mesero, cocinero, cajero. Funciona, pero el contexto se le llena con cosas que no le sirven (la receta del locro mientras está cobrando una pizza). Toca dividir.

### Concepto 1 — Subagentes

**Qué es.** Un subagente es un agente con su propio contexto, sus propias tools y su propia descripción de cuándo invocarlo. El agente "padre" lo llama, le pasa instrucciones, y recibe el resultado. El subagente **no ve** la conversación del padre — arranca con contexto fresco.

**Dónde lo ves en el repo.** Abrí el árbol [`.claude/agents/`](.claude/agents/):
- [`gustavo.md`](.claude/agents/gustavo.md) — el cocinero. Frontmatter: `name`, `description` (cuándo invocarlo), `tools` (qué puede hacer), `model` (qué modelo usar).
- [`cajero.md`](.claude/agents/cajero.md) — el cajero. Recibe el pedido cerrado, devuelve el total desglosado.

**Probalo.**

```
Soy un cliente. Quiero milanesa napolitana con papas y un fernet con coca.
```

Lo que vas a ver:

1. **Santi atiende y confirma** (su voz, atenta, modismos).
2. **Invoca a Gustavo.** La respuesta cambia: APARECEN LAS MAYÚSCULAS, los gritos, el entusiasmo. Es un agente **distinto** trabajando.
3. Gustavo confirma stock y "prepara" el plato.
4. Vuelve a Santi, que entrega.
5. Cliente pide la cuenta → Santi invoca al cajero, que devuelve total desglosado en guaraníes.
6. Santi presenta la cuenta.

**Cómo lo explicarías.**
> *"Hasta acá teníamos un mesero solo, que también cocinaba y cobraba. Pero un restaurante real tiene equipo. Cada uno con su contexto, sus tools, su especialidad."*

🔑 **Takeaway:** un agente solo es un mesero corriendo todo. Subagentes es tener equipo. Y ojo: cada uno arranca con contexto **fresco**. Gustavo no sabe nada de la conversación con el cliente, solo recibe la comanda.

---

### Concepto 2 — Cuándo dividir y cuándo no

**Qué es.** Subagentes no es una feature gratis. Cada llamada a un subagente es overhead (más latencia, más tokens, más complejidad). Solo dividís cuando el agente único "se llena la cabeza" o cuando hay ganancia clara.

**Dónde lo ves en el repo.** Volvé a [`.claude/agents/`](.claude/agents/) y mirá las `description` de cada subagente:
- **Gustavo cocina pero NO atiende clientes** (no tiene tools de chat).
- **Cajero cobra pero NO recomienda platos.**
- **Santi orquesta, pero NO toca la receta.**

Cada uno hace una cosa, la hace bien.

**Probalo.** Ya lo viste en el ejemplo anterior. Notá qué tan distinto es el contexto de cada agente: Gustavo no escucha al cliente, solo recibe `"milanesa napolitana, sin sal"`.

**Cómo lo explicarías.**
> *"No empezás con tres meseros. Empezás con uno y, cuando ves que el flaco está saturado, contratás cocinero."*

🔑 **Takeaway:** subagentes no es una feature avanzada, es una solución a un problema concreto. Si tu agente único anda bien, no dividas. Razones para dividir: contexto saturado, paralelismo, o tarea que necesita un modelo distinto.

➡️ **Próximo paso: rama `05-mcps`** — los archivos `.md` no escalan a 200 platos. Hora de salir del repo.

---

## Rama `05-mcps` — MCPs como proveedores externos

```bash
git checkout 05-mcps
```

Hasta acá el menú y el stock vivieron en archivos `.md` locales. Anduvo. Pero esto **no escala**: si mañana sumás 200 platos, 50 vinos y ofertas que cambian a diario, editar archivos a mano deja de tener sentido. Y todo eso se carga al contexto cada turno.

### Setup de esta rama (una sola vez)

Esta es la primera rama que requiere instalar algo. Vamos a usar el **filesystem MCP oficial de Anthropic** apuntado a una carpeta personal fuera del repo:

```bash
# 1. Crear la carpeta de datos (afuera del repo, persiste entre sesiones).
mkdir -p ~/the-restaurant-data

# 2. Sembrar la data inicial (menú + stock en JSON).
./tutorial/setup-rama-05.sh

# 3. Registrar el MCP en Claude Code apuntado a esa carpeta.
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem ~/the-restaurant-data

# 4. Verificar que esté conectado.
claude mcp list
```

Después de esto, Claude tiene tools como `read_file`, `write_file`, `list_directory` apuntando solo a `~/the-restaurant-data/` (no a tu home entero — el filesystem MCP scopea por carpeta).

### Concepto 1 — El problema de los `.md` locales

**Qué es.** Reconocer cuándo tu sistema ya creció lo suficiente como para que el patrón "todo en archivos" no alcance. Es el setup para entender por qué existen los MCPs.

**Dónde lo ves en el repo.** Abrí [`knowledge/menu/principales.md`](knowledge/menu/principales.md). Hoy son ~50 líneas. Imaginá que fueran 5000.

**Probalo.** No hay prompt; es un ejercicio de imaginación. Preguntate: *¿cuánto contexto estaríamos quemando para responder UN pedido si el menú fueran 5000 líneas?*

🔑 **Takeaway:** acá es donde aparecen los MCPs.

---

### Concepto 2 — MCPs como proveedores externos

**Qué es.** Un MCP (Model Context Protocol) es un servicio externo con el que el agente se comunica por un protocolo estándar. El agente le hace queries, el MCP responde. El agente no necesita saber cómo está implementado el MCP — solo sabe el "número de teléfono" y qué pedir.

**Dónde lo ves en el repo.** La config del MCP vive en `~/.claude.json` (no en el repo, porque depende de tu máquina). Lo que sí vive en el repo:
- El `CLAUDE.md` de la rama dice explícitamente *"el menú vive en `~/the-restaurant-data/menu/` — usá las tools del filesystem MCP, no leas `/knowledge/menu/`"*.
- `tutorial/setup-rama-05.sh` siembra `~/the-restaurant-data/menu/*.json` con el menú en formato estructurado (un JSON por categoría: principales, postres, tragos).

**Probalo.**

```
¿Qué platos tienen sin lactosa?
```

Santi invoca el filesystem MCP, lista los JSON del menú, los parsea, filtra por tag `contiene-lactosa: false` y te devuelve los que cumplen. En la barra de Claude Code vas a ver que se llamó al MCP (no a `Read` del repo).

**Cómo lo explicarías.**
> *"El proveedor que el mesero llama por teléfono. Si se acaba el queso, el mesero llama: 'mandame 5 kilos'. El proveedor es una empresa externa, con sus propias reglas. El mesero no sabe cómo lo producen, solo sabe el número y qué pedir."*

🔑 **Takeaway:** los MCPs son proveedores. Tu agente los llama, ellos responden, no necesitás saber qué hay adentro.

---

### Concepto 3 — Stock dinámico (lectura + escritura)

**Qué es.** Los MCPs no son solo lectura. Pueden persistir cambios — y eso es lo que convierte a un agente en algo que **mantiene estado entre sesiones**.

**Dónde lo ves en el repo.** En `~/the-restaurant-data/stock/ingredientes.json` (creado por el script de setup). Cada ingrediente tiene cantidad, unidad y umbral de alerta:

```json
{
  "muzzarella": { "cantidad": 10, "unidad": "kg", "umbral_alerta": 2 },
  "carne":      { "cantidad": 25, "unidad": "kg", "umbral_alerta": 5 }
}
```

**Probalo.**

```
Soy cliente. Quiero 3 milas napolitanas, una provoleta y dos jamón crudo en tabla.
```

Gustavo (subagente) consulta `ingredientes.json` vía MCP, descuenta los ingredientes que se usaron (`write_file` al mismo JSON), y si alguno cae bajo `umbral_alerta`, **agrega** una tarea en `~/the-restaurant-data/compras-pendientes.json`.

Cerrá Claude, abrilo de nuevo, pedí "¿cuánta muzzarella queda?" → la cantidad sigue bajada. **El estado persiste entre sesiones porque vive afuera del repo.**

**Cómo lo explicarías.**
> *"El proveedor no solo te informa, también te avisa cuando se está acabando algo y te toma el pedido de reposición."*

🔑 **Takeaway:** acá se cierra el círculo. El restaurante ya no es 100% local — está conectado a un sistema que persiste estado entre sesiones.

---

## Cambiar el ejemplo (forkear y adaptar a tu dominio)

El restaurante es **un** ejemplo. Las herramientas de Claude Code que se enseñan son las mismas para cualquier dominio: soporte al cliente, generación de contenido, gestión de proyectos, herramientas internas, lo que se te ocurra.

Pasos para adaptar el repo a tu caso:

1. **Forkeá el repo** en GitHub.
2. **Reescribí [`CLAUDE.md`](CLAUDE.md)** con las reglas de tu dominio. Quiénes son los "personajes" (puede ser un solo agente), qué tono, qué restricciones, dónde viven los recursos.
3. **Reemplazá [`knowledge/`](knowledge/)** con el conocimiento de tu dominio. Las subcarpetas (`menu/`, `recetas/`, `stock/`, `personajes/`, `reglas-casa/`) son sugerencias — usá las que te sirvan, renombralas, agregá las tuyas.
4. **Reemplazá [`pedidos-ejemplo/`](pedidos-ejemplo/)** con conversaciones de prueba para tu caso.
5. **Mantené la estructura de ramas** (`01-base` → `05-mcps`). Cada una sigue agregando la misma capa de Claude Code; solo cambia *qué hace* esa capa en tu dominio.

> 💡 **Regla de oro al adaptar.** No rompas la progresión. Cada rama tiene que poder ejecutarse por sí sola y la siguiente tiene que agregar **una sola capa nueva**. Si querés meter dos cosas, abrí dos ramas.

---

## Estructura del repo

```
the-restaurant/
├── CLAUDE.md                  # Reglas del proyecto (manual del empleado)
├── knowledge/                 # Conocimiento del dominio
│   ├── menu/                  # Carta dividida por categorías
│   ├── recetas/               # Recetas (las usa el cocinero desde la rama 04)
│   ├── stock/                 # Inventario (cambia con cada pedido)
│   ├── reglas-casa/           # Horarios, política de quejas, recomendaciones
│   └── personajes/            # Personalidades de los agentes
└── pedidos-ejemplo/           # Conversaciones de prueba
```

En `main` ya hay:

```
├── .claude/
│   └── skills/
│       └── empezamos/         # El tutor del recorrido (esta misma skill)
│           └── SKILL.md
└── tutorial/                  # Guion del tutor, una sub-página por rama
    └── 01-base.md
```

A partir de la rama `02`, aparece también:

```
└── .claude/
    ├── skills/                # Skills (rama 02). Cada una define un atajo `/<nombre>` invocable a mano o autoinvocable.
    ├── settings.json          # Hooks (rama 03)
    └── agents/                # Subagentes (rama 04)
```

---

## Licencia

MIT. Usalo, forkealo, modificalo, enseñalo.
