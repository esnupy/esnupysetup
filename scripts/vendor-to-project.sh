#!/usr/bin/env bash
# Vendorea las 14 skills de esnupysetup a un proyecto específico.
# Uso: bash vendor-to-project.sh /ruta/al/proyecto

set -euo pipefail

PROJECT_DIR="${1:-}"

if [ -z "$PROJECT_DIR" ]; then
  echo "Uso: bash $0 /ruta/al/proyecto"
  exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: $PROJECT_DIR no existe."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SOURCE_DIR="$REPO_DIR/skills"
TARGET_DIR="$PROJECT_DIR/.cursor/skills"

SKILLS=(
  "idea-check"
  "prd-write"
  "scope-1day"
  "shadcn-init"
  "flow-sketch"
  "ui-mockup"
  "ui-approve"
  "schema-sketch"
  "supabase-setup"
  "wire-data"
  "demo-check"
  "vercel-ship"
  "day-retro"
  "clerk-auth-bridge"
)

mkdir -p "$TARGET_DIR"

for skill in "${SKILLS[@]}"; do
  if [ -d "$SOURCE_DIR/$skill" ]; then
    cp -R "$SOURCE_DIR/$skill" "$TARGET_DIR/"
    echo "✓ $skill"
  else
    echo "⚠ $skill no encontrada en $SOURCE_DIR — skip"
  fi
done

if [ -f "$REPO_DIR/README.md" ]; then
  cp "$REPO_DIR/README.md" "$TARGET_DIR/README.md"
  echo "✓ README.md"
fi

echo ""
echo "Listo. 14 skills vendoreadas a $TARGET_DIR"
echo "Tu equipo las verá automáticamente al abrir el proyecto en Cursor."
echo ""
echo "Recordatorio: añade .cursor/skills/ al repo si quieres que el equipo las herede."
