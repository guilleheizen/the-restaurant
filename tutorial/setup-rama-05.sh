#!/bin/bash
# setup-rama-05.sh — copia el seed inicial de menú y stock a una carpeta externa
# que después se conecta a Claude Code via filesystem MCP.
#
# Uso:
#   ./tutorial/setup-rama-05.sh                    # destino default: ../the-restaurant-data
#   ./tutorial/setup-rama-05.sh /ruta/personal     # destino custom
set -euo pipefail

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
SEED_DIR="$REPO_DIR/tutorial/data-seed"
DEFAULT_DEST="$( cd "$REPO_DIR/.." && pwd )/the-restaurant-data"
DEST_DIR="${1:-$DEFAULT_DEST}"

if [ ! -d "$SEED_DIR" ]; then
  echo "ERROR: no se encontró el seed en $SEED_DIR" >&2
  exit 1
fi

echo "→ Seed origen:  $SEED_DIR"
echo "→ Destino:      $DEST_DIR"
echo

if [ -d "$DEST_DIR" ] && [ "$(ls -A "$DEST_DIR" 2>/dev/null)" ]; then
  echo "El destino ya existe y no está vacío."
  read -p "¿Sobrescribir todos los archivos? [y/N] " resp
  if [[ ! "$resp" =~ ^[yYsS] ]]; then
    echo "Cancelado."
    exit 0
  fi
fi

mkdir -p "$DEST_DIR"
cp -r "$SEED_DIR/"* "$DEST_DIR/"

echo "Listo. Archivos copiados:"
find "$DEST_DIR" -type f | sed "s|^|  |"

cat <<EOF

Próximos pasos:

  1) Registrá el filesystem MCP apuntado a esta carpeta:

       claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem $DEST_DIR

  2) Verificá que esté conectado:

       claude mcp list

  3) En el tutor, decí "listo" para seguir.

EOF
