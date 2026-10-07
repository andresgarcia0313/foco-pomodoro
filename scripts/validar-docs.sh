#!/usr/bin/env bash
# Valida los documentos Markdown del proyecto con las reglas documentales del equipo:
# idioma es-CO declarado, sin rayas, sin rastro de asistencia automatizada,
# tabla de control de cambios y sin hipercorrecciones frecuentes.
# Uso: scripts/validar-docs.sh [archivo.md ...]   (sin argumentos: todo docs/)
set -uo pipefail

raiz="$(cd "$(dirname "$0")/.." && pwd)"
if [[ $# -gt 0 ]]; then
  archivos=("$@")
else
  mapfile -t archivos < <(find "$raiz/docs" -name '*.md' | sort)
  archivos+=("$raiz/README.md")
fi

total_fallos=0
for archivo in "${archivos[@]}"; do
  fallos=()
  head -5 "$archivo" | grep -q '^lang: es-CO$' || fallos+=("falta 'lang: es-CO' en el encabezado")
  grep -qP '[\x{2013}\x{2014}]' "$archivo" && fallos+=("contiene raya larga o corta")
  grep -qiP '\bclaude\b|anthropic|chatgpt|openai|copilot|generated with|co-authored-by' "$archivo" \
    && fallos+=("rastro de asistencia automatizada")
  grep -qP 'ci[óÓ]nes\b|si[óÓ]nes\b|gesti[óÓ]na\b' "$archivo" && fallos+=("hipercorrección de tildes")
  grep -qiP 'plant\s?uml|\.puml\b' "$archivo" && fallos+=("nombra PlantUML o rutas .puml")
  grep -q '^## Control de cambios' "$archivo" || fallos+=("falta la sección '## Control de cambios'")

  if [[ ${#fallos[@]} -eq 0 ]]; then
    echo "CORRECTO  ${archivo#"$raiz"/}"
  else
    total_fallos=$((total_fallos + 1))
    printf 'FALLA     %s: %s\n' "${archivo#"$raiz"/}" "$(IFS=';'; echo "${fallos[*]}")"
  fi
done
exit $((total_fallos > 0))
