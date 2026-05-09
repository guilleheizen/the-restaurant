# Menú — referencia histórica

Hasta la rama `04-agents`, esta carpeta es la **fuente de verdad** del menú: el cocinero y el cajero leen estos `.md` para preparar y cobrar.

A partir de la rama `05-mcps`, el menú se migra a una carpeta externa al repo (`the-restaurant-data/menu/*.json`) accedida vía el filesystem MCP. Estos archivos quedan como **referencia histórica** y como fallback si el MCP no está disponible.

¿Por qué la migración? Ver el tutor de la rama 05 (`tutorial/05-mcps.md`) o el README del repo. En resumen: archivos `.md` cargados al contexto no escalan a 200 platos + ofertas que cambian a diario.
