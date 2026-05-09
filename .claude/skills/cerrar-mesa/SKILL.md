---
name: cerrar-mesa
description: Cierra la cuenta del cliente. Recopila los items pedidos en la conversación, busca los precios en knowledge/menu/, calcula el total en guaraníes, escribe el registro a pedidos-cerrados/ y presenta la cuenta formateada. Para invocar manualmente con /cerrar-mesa al final de la atención.
---

# Cerrar mesa

Cerrá la cuenta del cliente:

1. **Recopilá los items.** Repasá la conversación y listá todo lo que pidió: platos, bebidas, postres, extras (guarniciones, etc.).

2. **Buscá los precios.** Para cada item, consultá `knowledge/menu/` (los archivos `entradas.md`, `principales.md`, `postres.md`, `tragos.md`). Los precios están en guaraníes (Gs.) y aparecen en negrita en cada plato.

3. **Calculá el total.** Sumá todo en guaraníes.

4. **Presentá la cuenta formateada.** Usá este layout (en bloque de código para que se vea ordenado):

   ```
   ─────────────────────────────────────
   La Esquina Criolla — Mesa
   ─────────────────────────────────────
   1× Milanesa napolitana ....... Gs.  65.000
   1× Fernet con coca ........... Gs.  18.000
   1× Flan c/ ddl ............... Gs.  22.000
   ─────────────────────────────────────
   TOTAL ........................ Gs. 105.000
   ─────────────────────────────────────
   ```

5. **Persistí el pedido cerrado.** Después de presentar la cuenta, escribí (con la tool `Write`) un archivo nuevo en `pedidos-cerrados/` con UNA sola línea en este formato exacto:

   ```
   YYYY-MM-DD HH:MM | Items: <items separados por coma> | Total: Gs. <total>
   ```

   Ejemplo:

   ```
   2026-05-09 14:30 | Items: Milanesa napolitana, Fernet con coca, Flan c/ ddl | Total: Gs. 105.000
   ```

   - Para el **timestamp**, usá la fecha y hora actuales en formato `YYYY-MM-DD HH:MM`.
   - Para el **filename**, usá `pedidos-cerrados/YYYY-MM-DDTHH-MM-SS.md` (T separa fecha y hora, sin dos puntos para que sea filesystem-safe).
   - Si la conversación tuvo un solo plato y una sola bebida, listalos igual separados por coma. No cortes items.

   **Importante:** esta escritura está vigilada por hooks. Si la línea no cumple el formato exacto, el hook `PreToolUse` la va a bloquear y vas a recibir un error en stderr. Si pasa, el hook `PostToolUse` actualiza solo el archivo `caja-del-dia.txt`.

6. **Cerrá con onda.** Algo en la línea de *"Acá tenés la cuenta. Cualquier cosa, me avisás. ¡Que vuelvan pronto!"*. Mantené la voz de Guillermo.

## Reglas
- Si no encontrás el precio de un item en `knowledge/menu/`, asumí el precio más cercano de la carta y aclará al cliente cuál usaste.
- No regales descuentos ni postres de cortesía sin que el cliente los haya pedido.
- Si el cliente pidió algo fuera del menú que se preparó (ej: un negroni), cobralo a precio similar a un trago de la casa de la misma categoría (ej: Gs. 22.000 como el Cointreau).
