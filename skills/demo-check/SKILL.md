---
name: demo-check
description: Reality check antes de deploy — valida que el prototipo pasa los 3 tests de demo (30s, screenshot, wow), corre smoke test del happy path con datos reales y captura ajustes urgentes. Produce DEMO.md. Úsalo después de wire-data, o cuando el usuario diga "ya está", "vamos a deployar", "demo", "review", "se ve bien en producción?".
---

# demo-check

Octavo paso. 30 minutos. Última oportunidad antes de deployar de hacer ajustes que protejan la demo. Si el prototipo no pasa estos tests, lo arreglas aquí — no después.

## Cuándo invocarlo

- El usuario dice "ya está", "creo que ya", "vamos a deploy", "se ve bien?".
- Existen pantallas funcionales con datos reales en local (probó `/wire-data`).
- Antes de `/vercel-ship`. Sin esto, deployas cosas rotas.

## Tono

Amigo técnico exigente pero amable. La frase clave:

> Mejor un dolor de 30 minutos aquí que enseñar algo que no se entiende.

## Workflow

### Paso 0 — Cargar contexto

Lee `SCOPE.md`, `FLOW.md`. Identifica la pantalla wow y el happy path completo (signup → llegar a wow → ejecutar acción wow → ver resultado).

### Paso 1 — Smoke test del happy path

Usa el MCP `cursor-ide-browser` para abrir `http://localhost:3000` y recorrer el happy path tú mismo:

1. Aterriza en home / login según corresponda.
2. Si hay login, completa el flujo (magic link puede ser tedioso — opcionalmente crea user vía Supabase MCP `execute_sql` para acelerar).
3. Llega a la pantalla wow.
4. Ejecuta la acción wow.
5. Verifica el resultado visualmente y en la DB (con Supabase MCP `execute_sql`).

Si algo se rompe, **alto**. Reporta y pide arreglar antes de continuar.

### Paso 2 — Los 3 tests obligatorios

#### Test 1 — 30 segundos en silencio

Pide al usuario:

> Imagina que le enseñas la URL a alguien por 30 segundos. Tú no hablas. ¿Qué entienden? Cuéntamelo en una frase.

Si la frase no coincide con el "en una frase" de `IDEA.md`, ajusta:

- Copy de hero / título principal
- CTA poco claro → renombrar
- Pantalla wow con demasiado ruido → simplificar

#### Test 2 — Screenshot único

Toma un screenshot de la pantalla wow con el browser MCP. Pregunta:

> Esta sola imagen, ¿basta para que alguien te quiera contactar? ¿Se ve "real" o se ve "demo"?

Ajustes típicos:

- Datos vacíos → seedea datos demo (con MCP Supabase `execute_sql`).
- Avatares placeholders ugly → usa `https://i.pravatar.cc/150?u=<id>` o iniciales.
- Spacing apretado → respira con `gap-` y `p-`.

#### Test 3 — Wow real

> ¿Hay un momento en el flujo donde alguien diga "oh interesante" o "qué fino"?

Si no lo hay, propón uno barato:

- Animación al completar acción (Tailwind transitions).
- Toast con personalidad ("¡Buen trabajo!" en lugar de "OK").
- Empty state con copy memorable.
- Skeleton de carga que muestra estructura, no spinner genérico.

### Paso 3 — Lista de "errores demo killer"

Recórrelos uno por uno:

- [ ] Hay alguna pantalla con `404` accesible desde el menú.
- [ ] Hay errores en consola del browser (Network tab).
- [ ] Hay errores en server logs (`pnpm run dev` terminal).
- [ ] Hay placeholders sin reemplazar ("Lorem ipsum", "TODO", "untitled").
- [ ] Hay botones que no hacen nada.
- [ ] Hay textos en idioma equivocado (mezcla EN/ES sin querer).
- [ ] Favicon es el default de Next.
- [ ] Title de la página dice "Create Next App".

Cualquiera de estos = arreglar antes de deploy.

### Paso 4 — Pulido rápido (15 min máximo)

Permite ajustes solo si caben en 15 minutos. Si requieren más, van a `BACKLOG.md`. La regla:

> Si el ajuste tarda más que el problema que arregla, va al backlog.

### Paso 5 — Datos seed

Si el demo necesita datos para verse bien:

- Crea 3-5 registros realistas vía Supabase MCP `execute_sql`.
- Documenta el seed en `DEMO.md` para poder recrearlo en producción si la DB se reinicia.

### Paso 6 — Escribir DEMO.md

Documenta los 3 tests (con resultado), screenshots, ajustes hechos, y el script de demo (cómo enseñarlo en 30s).

### Paso 7 — Veredicto

- **READY**: pasa los 3 tests, no hay errores killer → `/vercel-ship`.
- **NEEDS WORK**: falla algo crítico → arregla y vuelve al smoke test.
- **PUSH ANYWAY**: el usuario sabe que hay deuda, deploys porque tiene que enseñarlo ya. Documenta deuda en `DEMO.md` para `/day-retro`.

## Template de DEMO.md

```markdown
# DEMO de [proyecto]

> Generado por demo-check el [fecha].

## Pantalla wow
- URL: /dashboard
- Screenshot: ./demo/wow.png

## Los 3 tests
- 30s test: ✅/❌ — frase del usuario: "..."
- Screenshot test: ✅/❌
- Wow test: ✅/❌ — wow detail: "..."

## Script de demo (30 segundos)
1. Abrir [URL]
2. Mostrar [pantalla wow]
3. Hacer [acción wow]
4. Señalar [wow detail]

## Datos seed
[script SQL ejecutado vía Supabase MCP]

## Deuda conocida (para day-retro)
- [...]

## Veredicto
**READY / NEEDS WORK / PUSH ANYWAY** — [razón]
```

## Qué viene después

- **READY** → `/vercel-ship`.
- **NEEDS WORK** → vuelve a `/wire-data` (si es bug de datos) o a `/ui-mockup` (si es bug visual) con la lista de fixes.

## Anti-patrones

- Saltarse los 3 tests "porque ya lo viste". El test es contra ti, no contra el código.
- Aceptar "se entiende si yo explico". El demo es sin ti.
- Pulir 2 horas. El time-box es 30 minutos.
- Olvidar el favicon y el title. Los detalles tontos matan demos.
- Dejar console.errors visibles. Si tu inspector está abierto en el demo, perdiste credibilidad.
