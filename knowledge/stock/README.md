# Stock — referencia histórica

Hasta la rama `04-agents`, este archivo es informativo (Gustavo puede consultarlo manualmente al preparar).

A partir de la rama `05-mcps`, el stock se migra a una carpeta externa al repo (`the-restaurant-data/stock/ingredientes.json`) accedida vía el filesystem MCP. Acá Gustavo no solo lee — **descuenta los ingredientes consumidos** después de cada preparación, y el estado **persiste entre sesiones** porque vive afuera del repo.

Esta versión `.md` queda como referencia histórica y fallback si el MCP no está disponible.
