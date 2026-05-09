#!/bin/bash
# Hook PreToolUse: valida que las líneas escritas en pedidos-cerrados/
# tengan el formato esperado. Si no cumplen, bloquea con exit 2 y el
# agente recibe el error en stderr para reformular.
#
# Este hook es deliberadamente "tonto": no entiende qué pidió el cliente
# ni qué se cocinó. Solo aplica una regla de formato. Es el equivalente
# a un linter de pre-commit.
set -euo pipefail

if ! command -v jq &> /dev/null; then
  echo "[hook validate-pedido] ERROR: jq no está instalado. Instalalo con 'brew install jq' (Mac) o 'apt install jq' (Linux)." >&2
  exit 1
fi

input=$(cat)

file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')
content=$(echo "$input" | jq -r '.tool_input.content // ""')

# Solo actuar sobre escrituras dentro de pedidos-cerrados/.
# Cualquier otra escritura pasa sin tocar.
case "$file_path" in
  *"/pedidos-cerrados/"*) ;;
  *) exit 0 ;;
esac

# Validar el formato esperado de la línea.
# Formato:
#   YYYY-MM-DD HH:MM | Items: <items separados por coma> | Total: Gs. <numero>
regex='^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2} \| Items: .+ \| Total: Gs\. [0-9.]+[[:space:]]*$'
line=$(printf "%s" "$content" | head -n 1)

if echo "$line" | grep -qE "$regex"; then
  exit 0
fi

cat >&2 <<EOF
[hook validate-pedido] La línea del pedido cerrado no cumple el formato esperado.

Formato esperado:
  YYYY-MM-DD HH:MM | Items: <items separados por coma> | Total: Gs. <numero>

Ejemplo válido:
  2026-05-09 14:30 | Items: Milanesa napolitana, Fernet con coca | Total: Gs. 83.000

Línea recibida:
  $line

Reformulá la escritura y volvé a intentar.
EOF
exit 2
