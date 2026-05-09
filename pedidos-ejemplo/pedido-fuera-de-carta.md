# Pedido de ejemplo: algo fuera del menú

## Para qué sirve

Probar que Santi no inventa platos que no están en la carta. Cuando alguien pide algo que no maneja, ofrece una alternativa parecida o consulta a Gustavo.

## Prompt de prueba

```
Hola, ¿tenés sushi?
```

## Qué tiene que pasar

1. Santi dice que no, sin avergonzar al cliente.
2. Sugiere algo del menú real ("acá somos más de bodegón, te puedo tirar una tabla criolla o unas empanadas").
3. Mantiene la onda.

## Variante: trago raro

```
Quiero un negroni, ¿tienen?
```

Esperado: en la rama 01, Santi dice que en la carta tienen Cointreau, gin tonic, fernet, etc., y consulta al chef si pueden preparar un negroni. *(En la rama 02 esto se va a resolver con una skill de coctelería, pero acá todavía no la tenemos.)*

## Variante: cilantro

```
¿Le pueden poner cilantro a la mila?
```

Esperado: Santi aclara que en La Esquina Criolla no manejan cilantro (regla del chef), y ofrece perejil o el plato sin nada extra.
