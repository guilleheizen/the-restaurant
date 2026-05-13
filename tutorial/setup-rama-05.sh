#!/bin/bash
# setup-rama-05.sh — Setup completo para la rama 05-mcps.
#
# Hace dos cosas, en orden:
#   1) Pobla la bóveda externa (carpeta hermana del repo) con el seed de
#      menú y stock — esa carpeta es la fuente de verdad fuera del repo.
#   2) Registra el filesystem MCP de Claude Code apuntándolo a esa bóveda.
#
# Es idempotente: si la bóveda ya está poblada o el MCP ya está registrado,
# no rompe nada — solo lo reporta.
#
# Uso:
#   ./tutorial/setup-rama-05.sh                       # destino default: ../the-restaurant-data
#   ./tutorial/setup-rama-05.sh /ruta/personal        # destino custom
#   ./tutorial/setup-rama-05.sh --force               # sobrescribe seed sin preguntar
#   ./tutorial/setup-rama-05.sh /ruta --force         # custom + sobrescribe
set -euo pipefail

REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
SEED_DIR="$REPO_DIR/tutorial/data-seed"
DEFAULT_DEST="$( cd "$REPO_DIR/.." && pwd )/the-restaurant-data"
MCP_NAME="filesystem"
MCP_PACKAGE="@modelcontextprotocol/server-filesystem"

DEST_DIR=""
FORCE=false
for arg in "$@"; do
  case "$arg" in
    --force|-f) FORCE=true ;;
    -h|--help)
      sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*)
      echo "ERROR: opción desconocida: $arg" >&2
      exit 1
      ;;
    *)
      if [ -n "$DEST_DIR" ]; then
        echo "ERROR: pasaste más de un path: '$DEST_DIR' y '$arg'" >&2
        exit 1
      fi
      DEST_DIR="$arg"
      ;;
  esac
done
DEST_DIR="${DEST_DIR:-$DEFAULT_DEST}"

if [ ! -d "$SEED_DIR" ]; then
  echo "ERROR: no se encontró el seed en $SEED_DIR" >&2
  exit 1
fi

# Resolver a path absoluto, sin trailing slash.
DEST_DIR="$( cd "$( dirname "$DEST_DIR" )" 2>/dev/null && cd "$( basename "$DEST_DIR" )" 2>/dev/null && pwd || true )"
if [ -z "$DEST_DIR" ]; then
  # No existe todavía. Resolver el parent y reconstruir.
  parent="$( cd "$( dirname "${1:-$DEFAULT_DEST}" )" 2>/dev/null && pwd )"
  DEST_DIR="$parent/$( basename "${1:-$DEFAULT_DEST}" )"
fi

echo "→ Seed origen:  $SEED_DIR"
echo "→ Bóveda:       $DEST_DIR"
echo

# ────────────────────────────────────────────────────────────────────
# Paso 1 — Poblar la bóveda con el seed.
# ────────────────────────────────────────────────────────────────────
populate_vault() {
  mkdir -p "$DEST_DIR"
  cp -R "$SEED_DIR/." "$DEST_DIR/"
  echo "  bóveda poblada con:"
  find "$DEST_DIR" -type f -not -path '*/.*' | sed "s|^|    |"
}

if [ -d "$DEST_DIR" ] && [ -n "$(ls -A "$DEST_DIR" 2>/dev/null)" ]; then
  # Hay contenido — chequear si difiere del seed.
  diff_out=$(diff -qr "$SEED_DIR" "$DEST_DIR" 2>&1 | grep -v "^Only in $DEST_DIR" || true)
  if [ -z "$diff_out" ]; then
    echo "✓ La bóveda ya coincide con el seed — no hace falta sobrescribir."
  else
    echo "La bóveda existe y difiere del seed:"
    echo "$diff_out" | sed 's/^/    /'
    if [ "$FORCE" = true ] || [ ! -t 0 ]; then
      [ "$FORCE" = true ] && echo "→ --force: sobrescribo." || echo "→ sin TTY: sobrescribo."
      populate_vault
    else
      read -p "¿Sobrescribir los archivos del seed (menú + stock)? [y/N] " resp
      if [[ "$resp" =~ ^[yYsS] ]]; then
        populate_vault
      else
        echo "✗ Cancelado. La bóveda quedó como estaba."
        exit 0
      fi
    fi
  fi
else
  populate_vault
fi
echo

# ────────────────────────────────────────────────────────────────────
# Paso 2 — Registrar el filesystem MCP apuntando a la bóveda.
# ────────────────────────────────────────────────────────────────────
if ! command -v claude &> /dev/null; then
  cat <<EOF
✗ No encontré el comando 'claude' en el PATH. El seed se copió bien, pero
  no puedo registrar el MCP por vos. Hacelo a mano:

      claude mcp add $MCP_NAME -- npx -y $MCP_PACKAGE $DEST_DIR

EOF
  exit 0
fi

mcp_list_out=$(claude mcp list 2>&1 || true)
if echo "$mcp_list_out" | grep -qE "^$MCP_NAME[: ]"; then
  current_path=$(echo "$mcp_list_out" | grep -E "^$MCP_NAME[: ]" | grep -oE "/[^ ]+the-restaurant-data[^ ]*" || true)
  if [ "$current_path" = "$DEST_DIR" ]; then
    echo "✓ El MCP '$MCP_NAME' ya está registrado y apunta a $DEST_DIR. Listo."
  else
    echo "⚠ El MCP '$MCP_NAME' ya está registrado pero apunta a otro path."
    echo "  Lo voy a re-registrar apuntando a $DEST_DIR."
    claude mcp remove "$MCP_NAME" >/dev/null 2>&1 || true
    claude mcp add "$MCP_NAME" -- npx -y "$MCP_PACKAGE" "$DEST_DIR"
  fi
else
  echo "→ Registrando MCP '$MCP_NAME' apuntando a $DEST_DIR..."
  claude mcp add "$MCP_NAME" -- npx -y "$MCP_PACKAGE" "$DEST_DIR"
fi
echo

# ────────────────────────────────────────────────────────────────────
# Paso 3 — Verificar.
# ────────────────────────────────────────────────────────────────────
echo "Estado actual de los MCPs:"
claude mcp list 2>&1 | sed 's/^/  /' || true
echo

cat <<EOF
────────────────────────────────────────────────────────────────────
Listo. La bóveda está poblada y el MCP registrado.

⚠ IMPORTANTE: Claude Code carga los MCPs al iniciar la sesión.
   Salí de Claude Code (Ctrl+D o /exit) y volvé a entrar en este
   mismo directorio para que las tools 'mcp__filesystem__*' queden
   disponibles.

Cuando vuelvas, decile al tutor "listo" y seguí con la rama.
────────────────────────────────────────────────────────────────────
EOF
