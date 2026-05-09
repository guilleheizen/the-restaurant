#!/bin/bash
# Hook PostToolUse: cuando se escribe un pedido cerrado en pedidos-cerrados/,
# extrae el total y lo suma al acumulado en caja-del-dia.txt.
#
# No bloquea nada — es un side effect automático, igual que un post-commit
# hook que actualiza un changelog o dispara un webhook.
set -euo pipefail

if ! command -v jq &> /dev/null; then
  echo "[hook update-caja-dia] ERROR: jq no está instalado. Saltando." >&2
  exit 0
fi

input=$(cat)

file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
content=$(echo "$input" | jq -r '.tool_input.content // ""')

# Solo actuar sobre escrituras dentro de pedidos-cerrados/.
case "$file_path" in
  *"/pedidos-cerrados/"*) ;;
  *) exit 0 ;;
esac

# Extraer el total. Formato en la línea: "Total: Gs. 83.000"
# Sacamos los puntos para obtener el entero limpio.
total=$(echo "$content" | grep -oE 'Total: Gs\. [0-9.]+' | head -n 1 | sed 's/Total: Gs\. //; s/\.//g')

if [ -z "$total" ]; then
  echo "[hook update-caja-dia] no se encontró un total en la línea, no se actualiza la caja" >&2
  exit 0
fi

caja_file="caja-del-dia.txt"
if [ -f "$caja_file" ]; then
  current=$(grep -oE '[0-9]+' "$caja_file" | head -n 1)
  current=${current:-0}
else
  current=0
fi

new_total=$((current + total))

echo "Caja del día (acumulado): Gs. $new_total" > "$caja_file"
echo "[hook update-caja-dia] caja actualizada → Gs. $new_total" >&2
