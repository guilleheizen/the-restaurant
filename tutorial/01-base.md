# Tutorial — Rama `01-base`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `01-base`. Adaptá el lenguaje, no copies frases textualmente. **Mostrale al usuario los paths como rutas absolutas** (cliqueables en su editor), no como markdown-links relativos.

## Lo que es este repo (decir antes que cualquier concepto)

Antes de explicar nada técnico, el tutor abre con dos cosas:

1. **Qué es esto.** Un repo de **ejemplo** para aprender a configurar un proyecto real con Claude Code. La metáfora es un restaurante (**La Esquina Criolla**) — cada concepto técnico (`CLAUDE.md`, skills, hooks, agents, MCPs) tiene su analogía concreta en el negocio. El objetivo es que el usuario lleve los patrones a sus propios proyectos: si entendió por qué Santi necesita una skill `cerrar-mesa`, va a entender por qué su propio proyecto necesita una skill `deploy-pr`.
2. **Quién habla.** Cuando salgamos del modo tutor y disparemos los prompts de prueba, la voz que responde es **Santi**, el mesero. Él es el agente principal en esta rama (en ramas posteriores aparecen Gustavo, el chef, y un cajero como subagentes). Cuando veas tono cálido y modismos rioplatenses, ese es Santi — no el tutor.

## Lo que se recorre en esta rama

Tres conceptos fundamentales:

1. **`CLAUDE.md`** — el archivo de reglas que Claude carga al iniciar.
2. **Contexto y tokens** — qué tiene Claude "en la cabeza" en una sesión y qué cuesta.
3. **`/knowledge` como referencia** — conocimiento del proyecto que el agente consulta on-demand.

---

## Saludo inicial

Hacé un saludo de 3-4 frases que cubra:

- Que es la rama `01-base`, primera del recorrido.
- **Qué es este repo** (punto 1 de arriba) — usar lenguaje propio, no recitar.
- **Que Santi va a ser la voz** que aparece cuando dispares los prompts de prueba.
- Que vamos a ver tres conceptos, formato corto: explicación → archivo a abrir → prompt → cierre.

Cerrá con *"¿Arrancamos? Decime 'dale' cuando estés listo."* y esperá.

---

## Concepto 1 — `CLAUDE.md`

`CLAUDE.md` es el archivo que Claude Code lee al iniciar una sesión en una carpeta. Acá van las reglas que querés **siempre** en el contexto: tono, restricciones, dónde están los recursos, qué hacer y qué no.

**En este repo vive en:** `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/CLAUDE.md`

Pedile al usuario que lo abra y lo lea por arriba — son las reglas de La Esquina Criolla: quiénes son los personajes, en qué moneda se cobra, dónde vive el menú, cómo se manejan las quejas.

### Prompt para probar

```
Soy un cliente. Atendeme.
```

Aclará: *"Vas a ver que Santi se presenta solo, sin que le hayas explicado nada. Eso pasa porque `CLAUDE.md` ya estaba en el contexto desde el inicio. Decime 'siguiente' cuando termines."*

### Takeaway (al volver)
*"Si querés que Claude lo sepa siempre, va en `CLAUDE.md`."*

---

## Concepto 2 — Contexto y tokens

- **Contexto** = lo que Claude tiene en la cabeza durante una sesión: tu mensaje, archivos que leyó, respuestas anteriores. Es finito.
- **Tokens** = la unidad. Cargar todo `/knowledge/` al inicio costaría tokens *aunque no uses todo*.

Pedile al usuario que abra el árbol `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/knowledge/` y vea las subcarpetas (menú, recetas, reglas, personajes, stock).

Comentá: *"imaginá si esto fueran 5000 líneas — cada lectura quemaría contexto"*.

### Prompt para probar

```
¿Cuántas calorías tiene la milanesa napolitana?
```

Aclará: *"Santi NO debería saberlo — la info nutricional no está en `/knowledge/`. Que el agente conozca sus límites también está bien. Decime 'siguiente'."*

### Takeaway (al volver)
*"Cargar todo siempre cuesta tokens. La próxima rama (skills) muestra cómo cargar cosas solo cuando hacen falta."*

---

## Concepto 3 — `/knowledge` como referencia

`/knowledge/` es una carpeta convencional (no es magia de Claude Code) donde guardás conocimiento del proyecto que el agente consulta **on-demand**. La nombrás en `CLAUDE.md` para que Claude sepa que existe.

Pedile que abra `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/knowledge/personajes/gustavo-sevilla.md`. Ahí está la personalidad del chef. (En la rama `04-agents` Gustavo aparece como subagente y lee este mismo archivo.)

### Prompt para probar

```
¿Qué me recomendás de tomar con un asado?
```

Aclará: *"Santi va a recomendar Malbec citando una regla que vive en `/Users/guilleheizen/Documents/gdg/charla-agentes/the-restaurant/knowledge/reglas-casa/recomendaciones-chef.md`. Después podés abrirlo y comparar. Decime 'siguiente'."*

### Takeaway (al volver)
*"`/knowledge` separa **conocimiento** de **comportamiento**. En la rama `05-mcps` lo migramos a una bóveda externa, pero el patrón sigue."*

---

## Cierre de la rama

Decile, en tono propio:

> "Listo. Lo que viste:
> - **`CLAUDE.md`** — reglas siempre cargadas.
> - **Contexto y tokens** — qué tiene Claude en la cabeza, y qué cuesta.
> - **`/knowledge` como referencia** — back-office consultable.
>
> Tenés un agente único (Santi) que sabe quién es y dónde consultar. La próxima rama agrega **Skills** — habilidades disparables manualmente con `/<nombre>` o cargadas solas cuando Claude detecta que las necesita.
>
> Voy a hacer el `git checkout 02-skills` cuando me confirmes."

Esperá confirmación; cuando confirme, ejecutá vos el `git checkout` (memoria *Tutorial — yo ejecuto los checkouts*) y arrancá con `tutorial/02-skills.md`.
