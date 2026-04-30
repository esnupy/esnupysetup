#!/usr/bin/env bash
# Instala las 14 skills de esnupysetup en ~/.cursor/skills/ via symlinks.
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/esnupy/esnupysetup/main/install.sh | bash
#   o desde el repo clonado: bash install.sh

set -euo pipefail

REPO_URL="https://github.com/esnupy/esnupysetup.git"
INSTALL_DIR="$HOME/.cursor/esnupysetup"
SKILLS_DIR="$HOME/.cursor/skills"

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

echo ""
echo "  esnupysetup — instalando 14 skills"
echo "  ────────────────────────────────────"
echo ""

# Paso 1: clonar o actualizar el repo en ~/.cursor/esnupysetup
if [ -d "$INSTALL_DIR/.git" ]; then
  echo "→ Repo existente en $INSTALL_DIR — actualizando…"
  git -C "$INSTALL_DIR" pull --ff-only
else
  echo "→ Clonando repo en $INSTALL_DIR…"
  mkdir -p "$(dirname "$INSTALL_DIR")"
  # Si el script corre desde un clone local existente, reusarlo
  if [ -d "$(dirname "$0")/skills" ] && [ -f "$(dirname "$0")/install.sh" ]; then
    echo "  (instalando desde clone local: $(cd "$(dirname "$0")" && pwd))"
    REPO_LOCAL="$(cd "$(dirname "$0")" && pwd)"
    if [ "$REPO_LOCAL" != "$INSTALL_DIR" ]; then
      mkdir -p "$INSTALL_DIR"
      cp -R "$REPO_LOCAL/." "$INSTALL_DIR/"
    fi
  else
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
  fi
fi

# Paso 2: crear ~/.cursor/skills/ si no existe
mkdir -p "$SKILLS_DIR"

# Paso 3: linkear cada skill
echo ""
echo "→ Conectando skills a $SKILLS_DIR/"
for skill in "${SKILLS[@]}"; do
  source_path="$INSTALL_DIR/skills/$skill"
  target_path="$SKILLS_DIR/$skill"

  if [ ! -d "$source_path" ]; then
    echo "  ⚠ $skill no encontrado en repo — saltando"
    continue
  fi

  if [ -L "$target_path" ]; then
    rm "$target_path"
  elif [ -d "$target_path" ]; then
    echo "  ⚠ $skill ya existe como carpeta (no symlink) — saltando para no sobrescribir"
    continue
  fi

  ln -s "$source_path" "$target_path"
  echo "  ✓ $skill"
done

echo ""
echo "  Listo. 14 skills instaladas."
echo ""
echo "  Reinicia Cursor o abre un proyecto para que las descubra."
echo "  Después di algo como: 'tengo una idea de…' y mira qué pasa."
echo ""
echo "  Para actualizar después: bash $INSTALL_DIR/install.sh"
echo "  Para vendorear a un proyecto: bash $INSTALL_DIR/scripts/vendor-to-project.sh /ruta/al/proyecto"
echo ""
