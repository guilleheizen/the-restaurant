# Tutorial — Rama `01-base`

> Este archivo lo lee el modo tutor cuando el usuario está en la rama `01-base`. Contiene el guion del recorrido. Adaptá el lenguaje, no copies frases textualmente.

## Lo que se recorre en esta rama

Tres conceptos fundamentales:
1. **CLAUDE.md** — cómo se le indican a Claude las reglas de un proyecto.
2. **Contexto y tokens** — qué tiene Claude "en la cabeza" en una sesión.
3. **`/knowledge` como referencia** — cómo darle al agente conocimiento que pueda consultar.

En esta rama hay un único agente (Santi, el mesero) que hace todo: atiende, simula la cocina, cobra. Las próximas ramas van a agregar capas para dividir esas responsabilidades.

---

## Saludo inicial

Decile al usuario, en una o dos frases:
- En qué rama está.
- Que vamos a ver tres conceptos.
- Que el formato de cada concepto es: **explicación corta → archivo a abrir → prompt para probar → comentario corto post-prueba**.

Cerrá el saludo con una invitación tipo *"¿Arrancamos? Decime 'dale' cuando estés listo."* y esperá.

---

## Concepto 1 — CLAUDE.md

### Explicación que tenés que dar
`CLAUDE.md` es el archivo que Claude Code lee al iniciar una sesión en una carpeta. Acá van las reglas que querés que estén **siempre** en el contexto: tono, restricciones, dónde están los recursos del proyecto, qué hacer y qué no.

### Pedile al usuario que abra
[`CLAUDE.md`](../CLAUDE.md) en la raíz del repo.

Comentá brevemente: son las reglas de La Esquina Criolla — quiénes son los personajes, en qué moneda se cobra, dónde vive el menú, cómo se manejan las quejas.

### Prompt para probar
Pedile que tipee, en un mensaje aparte:

```
Soy un cliente. Atendeme.
```

Aclará: *"Vas a ver que Santi se presenta solo, sin que le hayas explicado nada. Cuando termines, decime 'siguiente'."*

### Después del prompt (cuando el usuario dice "siguiente")
Comentá brevemente:
- Que Santi se presentó con onda y ofreció la carta porque `CLAUDE.md` ya estaba cargado al inicio.
- **Takeaway:** *"si querés que Claude lo sepa siempre, va en CLAUDE.md."*

Cerrá con: *"¿Pasamos al siguiente concepto?"* y esperá.

---

## Concepto 2 — Contexto y tokens

### Explicación que tenés que dar
- **Contexto** = lo que Claude tiene "en la cabeza" durante una sesión: tu mensaje, archivos que leyó, respuestas anteriores. Es finito. Cuando se llena, empieza a tirar cosas viejas.
- **Tokens** = la unidad. Cargar todo `/knowledge/` al inicio gasta tokens *aunque no uses todo*.

### Pedile al usuario que abra
El árbol [`knowledge/`](../knowledge/) en su editor. Que vea las subcarpetas: menú, recetas, reglas, personajes, stock.

Comentá: *"imaginá que cada archivo se carga al contexto cuando Claude lo lee. ¿Cuánto contexto se quemaría si esto fueran 5000 líneas?"*

### Prompt para probar
Pedile que tipee:

```
¿Cuántas calorías tiene la milanesa napolitana?
```

Aclará: *"Santi NO debería saber. La info nutricional no está en `/knowledge/`. Y eso está bien — el agente conoce sus límites. Decime 'siguiente'."*

### Después del prompt
Comentá brevemente:
- Si quisieras que lo supiera, lo agregás a `/knowledge/`. Pero ojo: cada cosa que agregás, gasta tokens en cada sesión.
- **Takeaway:** *"contexto es lo que tiene en la cabeza ahora. Por eso no todo se carga siempre — eso lo resolvemos con skills en la próxima rama."*

Cerrá con: *"¿Seguimos?"* y esperá.

---

## Concepto 3 — `/knowledge` como referencia

### Explicación que tenés que dar
`/knowledge/` es una carpeta convencional (no es magia de Claude Code) donde guardás conocimiento del proyecto que el agente puede consultar **on demand**. Lo nombrás en `CLAUDE.md` para que Claude sepa que existe y vaya a buscar cuando hace falta.

### Pedile al usuario que abra
[`knowledge/personajes/gustavo-sevilla.md`](../knowledge/personajes/gustavo-sevilla.md).

Comentá: *"ahí está la personalidad del chef. Cuando llegue Gustavo como subagente en la rama `04-agents`, va a leer este mismo archivo para saber cómo es."*

### Prompt para probar
Pedile que tipee:

```
¿Qué me recomendás de tomar con un asado?
```

Aclará: *"Santi va a recomendar Malbec citando una regla de maridajes. Esa regla vive en `knowledge/reglas-casa/recomendaciones-chef.md`. Después podés abrirlo y compará. Decime 'siguiente'."*

### Después del prompt
Comentá brevemente:
- La respuesta sale literalmente del archivo. Eso es `/knowledge` funcionando como back-office del agente.
- **Takeaway:** *"`/knowledge` separa conocimiento de comportamiento. En la rama `05-mcps` lo migramos a una bóveda externa, pero el patrón sigue."*

---

## Cierre de la rama

Decile al usuario, en su tono natural pero con esta estructura:

> "Listo. Viste los tres conceptos de `01-base`:
> - **CLAUDE.md** — reglas siempre cargadas.
> - **Contexto y tokens** — qué tiene Claude en la cabeza, y qué cuesta.
> - **`/knowledge` como referencia** — back-office consultable.
>
> Tenés un agente único (Santi) que sabe quién es y dónde consultar.
>
> La próxima rama agrega **Skills**: habilidades que disparás manualmente con `/<nombre>` o que Claude carga solo cuando detecta que las necesita.
>
> Para seguir, hacé:
> ```bash
> git checkout 02-skills
> ```
>
> Cuando estés en la nueva rama, decime 'listo' y seguimos."

Después esperá.
