---
name: scope-1day
description: Recorta despiadadamente un PRD al wedge mínimo construible en 8 horas y lo descompone en time-boxes. Lee PRD.md (o IDEA.md como fallback) y produce SCOPE.md con el plan del día respetando el orden mock-first → backend después. Úsalo después de prd-write, o cuando el usuario diga "vamos a construir esto", "cómo lo hago en un día", "plan para hoy", "scope", o ya tenga PRD y necesite un plan ejecutable.
---

# scope-1day

Tercer paso del flujo. Toma `PRD.md` y lo corta al **wedge mínimo construible en 8 horas reales de trabajo**, con time-boxes por fase respetando el orden **maquetar primero → backend después**.

## Cuándo invocarlo

- Existe `PRD.md` en el cwd y el usuario quiere empezar a construir.
- El usuario dice "vamos a construir", "plan para hoy", "cómo lo hago en un día".
- El usuario empieza a codear sin haber recortado scope (intervén proactivo).

## Tono

Amigo técnico despiadado con el scope, amable con la persona. La frase clave que repites:

> Si esto no cabe en 8h, no es que tú seas lento — es que el scope está mal. Vamos a recortar hasta que entre.

## Workflow

### Paso 0 — Cargar contexto

1. Lee `PRD.md`. Si no existe pero hay `IDEA.md`, ofrece:
   > No veo PRD.md. ¿Pasamos por `/prd-write` (5 min) o sigo solo con IDEA.md (más débil)?

2. Si no hay ni PRD ni IDEA, manda al usuario a `/idea-check` primero.

3. Confirma stack del PRD (default: Next.js 16 + shadcn/ui + Supabase). Si el usuario lo cambia, márcalo en `SCOPE.md` pero advierte que las skills están optimizadas para el default.

### Paso 1 — Identificar el wedge real

Pregunta directa:

> Del PRD, la user story principal es "[X]". ¿Esto significa que en la demo de 30s el usuario ve [pantalla A] y hace [acción B]? Confirma o ajusta.

Si el usuario añade cosas aquí ("ah y también que pueda…"), **bloquea**:

> Eso es día 2. Va a BACKLOG.md (y va contra los no-goals del PRD).

### Paso 2 — El presupuesto de 8 horas (orden mock-first)

Plantilla por defecto (ajusta solo si hay razón fuerte):

| Bloque | Tiempo | Skill que lo hace |
|---|---|---|
| Setup repo + shadcn | 0.5h | `shadcn-init` |
| Flow UI (3-5 pantallas) | 0.5h | `flow-sketch` |
| **Maquetar UI con mock data** | **3h** | `ui-mockup` |
| **Aprobación visual (gate)** | **0.5h** | `ui-approve` |
| Schema + RLS (basado en mocks) | 0.5h | `schema-sketch` |
| Supabase setup + Auth | 1h | `supabase-setup` |
| Cablear data real (reemplaza mocks) | 1h | `wire-data` |
| Demo check + ajustes | 0.25h | `demo-check` |
| Deploy a Vercel | 0.25h | `vercel-ship` |
| Buffer / imprevistos | 0.5h | — |
| **Total** | **8h** | |

**Ojo con el orden**: la UI se construye y se aprueba **antes** de tocar Supabase. El backend nace para alimentar una UI que ya gusta, no al revés. Esto evita rehacer queries cuando la UI cambia.

### Paso 3 — Test del corte

Hazle al usuario estas tres preguntas (una por una):

1. **Auth pregunta**: ¿el día 1 necesita login real o un usuario hardcodeado basta para la demo? (Login real = +0.5h en `wire-data`, considera si vale)
2. **Datos pregunta**: ¿persistencia real con Supabase o solo mock data del lado cliente para la demo? Defecto: Supabase, pero si la demo se vende sin persistencia real, considera quedarte con mocks y saltarte la fase de backend.
3. **"Wow" pregunta**: ¿cuál es la pantalla wow que vas a enseñar? El 60% del tiempo de `ui-mockup` va ahí. Las demás son funcionales.

Captura las respuestas en `SCOPE.md`.

### Paso 4 — Test de cabida

Si después de las decisiones todavía no cabe, fuerza una de estas tres:

- **A**: Recortar una pantalla (cuál y por qué).
- **B**: Hardcodear datos en lugar de DB.
- **C**: Aceptar que es proyecto de 2 días (y ajustar expectativas).

Usa `AskQuestion` con esas tres opciones.

### Paso 5 — Escribir SCOPE.md y BACKLOG.md

`SCOPE.md` = lo que entra hoy. `BACKLOG.md` = lo que cortamos pero queremos recordar.

### Paso 6 — Confirmar arranque

Termina con:

> Listo. El plan es [resumen 1 frase]. Próximo paso: `/schema-sketch` para diseñar la(s) tabla(s). ¿Arrancamos?

## Template de SCOPE.md

```markdown
# SCOPE día-1: [Nombre]

> Generado por scope-1day el [fecha]. Lee PRD.md para contexto.

## Wedge confirmado
- **Pantalla principal**: [X]
- **Acción principal**: [Y]
- **Pantalla wow**: [cuál es la que vende la demo]

## Decisiones de arranque
- Auth: [hardcoded usuario | login Supabase email | login Supabase + Google]
- Datos: [Supabase con persistencia real | solo mocks (sin backend hoy)]
- Pantallas totales del día: [N]

## Time-boxes (mock-first)
| Hora | Bloque | Skill |
|---|---|---|
| 0:00–0:30 | Setup repo + shadcn | /shadcn-init |
| 0:30–1:00 | Flow UI | /flow-sketch |
| 1:00–4:00 | **Maquetar UI con mock data** | /ui-mockup |
| 4:00–4:30 | **Aprobación visual (gate)** | /ui-approve |
| 4:30–5:00 | Schema + RLS | /schema-sketch |
| 5:00–6:00 | Supabase setup | /supabase-setup |
| 6:00–7:00 | Cablear data real | /wire-data |
| 7:00–7:15 | Demo check | /demo-check |
| 7:15–7:30 | Deploy | /vercel-ship |
| 7:30–8:00 | Buffer | — |

## Definition of Done (día 1)
- [ ] UI aprobada en /ui-approve antes de tocar backend
- [ ] Deployed en Vercel con URL pública
- [ ] La demo de 30s funciona sin que tú expliques
- [ ] Pasa el demo-check
- [ ] Hay un BACKLOG.md con lo cortado
```

## Template de BACKLOG.md

```markdown
# BACKLOG (día 2+)

Cosas que cortamos del día 1 a propósito. No volver a pensarlas hasta haber shippeado el día 1.

- [ ] [feature cortado] — razón: [por qué no entra hoy]
- [ ] ...
```

## Qué viene después

- **Siguiente**: `/shadcn-init` (crea el repo con `npx shadcn@latest init --preset b0 --base base --template next`).
- **Si el usuario quiere ir directo a codear**: bloquea — "El scaffold con shadcn-init son 2 minutos y deja todo listo".

## Anti-patrones

- Aceptar "voy a meter una cosita más". Eso es BACKLOG.
- Hacer schema antes de UI. Esta suite invierte el orden: maquetas primero, schema después.
- Time-boxes que sumen más de 8h. Si suman 9h, el scope está mal, no el plan.
- Ser blando con el corte. El día perdido duele más que el feature recortado.
