# Pedido de ejemplo: simple

## Para qué sirve

Esta es la prueba mínima de que el restaurante funciona en la rama 01. Pegale el siguiente prompt a Claude Code corriendo en la carpeta del repo y deberías recibir una respuesta de Guillermo, en personaje, atendiéndote.

## Prompt de prueba

```
Soy un cliente que entró al restaurante. Atendeme.
```

## Qué tiene que pasar

1. Guillermo se presenta con onda.
2. Te ofrece la carta o te recomienda algo.
3. Tomás un pedido cualquiera (ej: "una mila napolitana con papas y un fernet").
4. Guillermo confirma el pedido completo, en guaraníes.
5. "Manda" a la cocina.
6. En el siguiente turno, te entrega el plato describiendo cómo salió.

## Conversación esperada (resumida)

> **Cliente:** Soy un cliente que entró al restaurante. Atendeme.
>
> **Guillermo:** ¡Bienvenido a La Esquina Criolla! Soy Guillermo, ¿cómo andás? ¿Te traigo la carta o ya sabés lo que tenés ganas?
>
> **Cliente:** Vengo con hambre. ¿Qué me recomendás?
>
> **Guillermo:** Mirá, si nunca probaste la milanesa napolitana del Gustavo, te recomiendo arrancar por ahí. Es la receta del abuelo. Y de tomar, ¿te tira un fernet con coca, una cervecita, o vamos por una copa de tinto?
>
> **Cliente:** Mila napo con papas y un fernet con coca. Dale.
>
> **Guillermo:** ¡Excelente elección! Te confirmo: una milanesa napolitana con papas fritas, un fernet con coca. Total: 83.000 guaraníes. ¿Todo bien?
>
> **Cliente:** Sí, todo bien.
>
> **Guillermo:** Marchando. Ya te lo traigo.
>
> *(siguiente turno)*
>
> **Guillermo:** Acá tenés tu mila napolitana, mirá cómo se estira la muzzarella, y el fernet con coca bien helado. Que lo disfrutes. Si necesitás algo, me pegás un grito.

## Si algo no funciona

- **Guillermo no se presenta:** revisá que `CLAUDE.md` esté en la raíz del proyecto.
- **No conoce el menú:** revisá que `knowledge/menu/` tenga los 4 archivos (entradas, principales, postres, tragos).
- **Habla en otro idioma o sin tono:** revisá `knowledge/personajes/guillermo-sevilla.md`.
- **Cobra mal o en otra moneda:** verificá que en `CLAUDE.md` esté la regla "los precios están en guaraníes".
