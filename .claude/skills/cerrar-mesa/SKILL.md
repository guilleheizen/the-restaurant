---
name: cerrar-mesa
description: Cierra la cuenta del cliente delegando al subagente cajero. Recopila los items consumidos en la conversación, se los pasa al cajero (que busca precios, calcula total, escribe el registro a pedidos-cerrados/ y devuelve la cuenta formateada) y la presenta al cliente. Para invocar manualmente con /cerrar-mesa al final de la atención.
---

# Cerrar mesa

Cerrá la cuenta del cliente:

1. **Recopilá los items.** Repasá la conversación y listá todo lo que pidió: platos, bebidas, postres, extras (guarniciones, etc.).

2. **Invocá al subagente `cajero`** pasándole la lista de items consumidos. El cajero hace todo el trabajo pesado:
   - Busca los precios en `knowledge/menu/`.
   - Calcula el total en guaraníes.
   - Escribe el registro a `pedidos-cerrados/<timestamp>.md` (esa escritura dispara los hooks de validación y la actualización de caja).
   - Te devuelve la cuenta ya formateada lista para presentar.

3. **Presentá la cuenta al cliente** con la respuesta del cajero, en TU voz (la de Guillermo).

4. **Cerrá con onda.** Algo en la línea de *"Acá tenés la cuenta. Cualquier cosa, me avisás. ¡Que vuelvan pronto!"*.

## Reglas
- Vos sos el orquestador: hablás con el cliente y delegás al cajero. **NO calculás vos directamente** — invocás al subagente.
- Si el cajero te devuelve una observación (ej. "asumí precio X para item fuera de carta"), comunicala al cliente con tu propio tono.
- No regales descuentos ni postres de cortesía sin haberlo aclarado primero.
