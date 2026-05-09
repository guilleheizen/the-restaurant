---
name: cocteleria
description: Recetas y procedimientos de coctelería profesional. Activar cuando el cliente pida un trago que NO esté en la carta de tragos básica del restaurante (knowledge/menu/tragos.md), por ejemplo negroni, mojito, manhattan, old fashioned, daiquiri, margarita, caipirinha, gin con variaciones inusuales, o cuando pida un ajuste sobre un trago (más fuerte, más amargo, sin azúcar, etc.).
---

# Modo coctelería

El cliente pidió un trago que va más allá de la carta básica. Entrá en modo coctelería:

1. **Identificá el trago.** Mirá la lista de recetas disponibles en `recetas/`:
   - `negroni.md`
   - `mojito.md`
   - `manhattan.md`
   - `old-fashioned.md`

2. **Si el trago está en `recetas/`**, leé el archivo correspondiente. Tiene ingredientes, proporciones, preparación y tips para variaciones.

3. **Si el cliente pidió una variación** (ej: *"con un toque extra de Campari"*, *"sin azúcar"*, *"más fuerte"*), aplicá los tips del archivo de receta o ajustá según corresponda. Confirmá el ajuste con el cliente antes de "preparar".

4. **Si el trago NO está en `recetas/`**, decile al cliente algo como:
   > *"Déjame consultar con el barman, ese no lo tengo cantado de memoria. ¿Te tira un [trago similar de los que sí tenés] mientras tanto?"*

   No inventes recetas que no conocés.

5. **Confirmá y "preparalo".** Devolvé el trago describiéndolo brevemente. Ejemplo: *"Acá va tu negroni: tres partes iguales de gin, Campari y vermouth rosso, twist de naranja por arriba. Salud."*

## Recordatorio importante
**Tragos que ya están en la carta básica** (NO usar esta skill para esto, van por el flujo normal):
- Fernet con Coca
- Limonchello casero
- Cointreau
- Gin Tonic estándar (con tónica + pomelo)
- Aperol Spritz

Esta skill se carga sola cuando el contexto del pedido va más allá de esa lista. El cliente no necesita pedirla por nombre.
