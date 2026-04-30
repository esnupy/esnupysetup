# esnupysetup

> 14 skills de Cursor para ir de **idea a producto desplegado en un día**, con stack opinionado: **Next.js 16 + shadcn/ui + Supabase + Vercel** (con **opción final** de identidad mediante **Clerk** si no quieres usar Supabase Auth).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## La filosofía

1. **Cuestionar antes de construir** — cada skill tiene preguntas forzosas. Sin pasar el filtro, no avanzas.
2. **Maquetar primero, conectar backend después** — la UI se construye con datos mock, tú apruebas lo visual, y solo entonces nace la base de datos para servir esa UI.

Esta segunda regla es la que evita el ciclo clásico: backend hecho → UI cambia → todo se rehace.

## Demo en 30 segundos

```
Tú:    Tengo una idea de un tracker de hábitos para mi pareja…
Skill: [idea-check] interroga con 6 preguntas YC-style
       → IDEA.md

Tú:    /prd-write
Skill: [prd-write] genera un PRD de una página
       → PRD.md

Tú:    /scope-1day
Skill: [scope-1day] mete el PRD en time-boxes de 8h
       → SCOPE.md

Tú:    /shadcn-init
Skill: [shadcn-init] npx shadcn@latest init --preset b0 --base base --template next
       → repo Next 16 listo

Tú:    /flow-sketch /ui-mockup
Skill: 5 pantallas con mock data realista, pantalla wow primero
       → cero backend todavía

Tú:    /ui-approve
Skill: [ui-approve] gate visual: revisas pantalla por pantalla
       → "sí, apruebo" desbloquea backend

Tú:    /schema-sketch /supabase-setup /wire-data
Skill: tablas derivadas de los TS interfaces aprobados,
       Supabase via MCP, swap mocks → queries reales
       → la UI no cambia visualmente

Tú:    /demo-check /vercel-ship /day-retro
Skill: 3 tests + deploy + retrospectiva
       → URL pública en https://tu-app.vercel.app

       (Opcional después de datos reales:) /clerk-auth-bridge
       → mismo Postgres + RLS en Supabase; login y sesión con Clerk
```

Total: 8 horas. Cero rework.

## Las 14 skills

| Fase | Skill | Qué hace |
|---|---|---|
| **IDEA & PRD** | `idea-check` | 6 preguntas YC-style → IDEA.md |
| | `prd-write` | PRD de una página → PRD.md |
| | `scope-1day` | Recorta a 8h con time-boxes mock-first → SCOPE.md |
| **SETUP** | `shadcn-init` | `npx shadcn@latest init --preset b0 --base base --template next` |
| **VISUAL** | `flow-sketch` | Pantallas + componentes shadcn + TS interfaces → FLOW.md |
| | `ui-mockup` | TODAS las pantallas con mock data, cero backend |
| | `ui-approve` | **Gate visual**: bloquea backend hasta tu "apruebo" → UI-APPROVAL.md |
| **BACKEND** | `schema-sketch` | DB derivada de TS interfaces aprobados → schema.sql |
| | `supabase-setup` | Bootstrap completo via MCP de Supabase |
| | `wire-data` | Swap mocks → queries reales, UI intacta |
| **SHIP** | `demo-check` | 3 tests + smoke → DEMO.md |
| | `vercel-ship` | Deploy con env vars + smoke en producción |
| | `day-retro` | Compromiso vs realidad + 3 aprendizajes → RETRO.md |
| **OPCIONAL (identidad)** | `clerk-auth-bridge` | Después de datos reales: Clerk en lugar de Supabase Auth; Postgres + RLS siguen en Supabase |

## Instalación

### Una línea

```bash
curl -fsSL https://raw.githubusercontent.com/esnupy/esnupysetup/main/install.sh | bash
```

Eso clona el repo a `~/.cursor/esnupysetup/` y crea symlinks en `~/.cursor/skills/`. Cursor las descubre automáticamente al abrir cualquier proyecto.

### Manual

```bash
git clone https://github.com/esnupy/esnupysetup.git ~/.cursor/esnupysetup
cd ~/.cursor/esnupysetup
bash install.sh
```

### Vendoring a un proyecto específico (compartir con equipo)

Si quieres que las skills vivan dentro de un repo concreto y tu equipo las herede:

```bash
bash ~/.cursor/esnupysetup/scripts/vendor-to-project.sh /ruta/al/proyecto
```

## Cómo invocar las skills

Cursor las descubre solas por su `description`. Habla natural:

- "Tengo una idea de un dashboard para…" → dispara `idea-check`
- "Vamos a hacerlo en un día" → dispara `scope-1day`
- "Maquetemos esto" → dispara `ui-mockup`
- "Ya está la UI" → dispara `ui-approve`
- "Conecta los datos" → dispara `wire-data`
- "Deploy" → dispara `vercel-ship`
- "Auth con Clerk" / "no quiero Supabase Auth" → dispara `clerk-auth-bridge` (solo si ya hay Supabase + datos cableados)

O invócalas explícito en el chat: "usa el skill ui-mockup".

## Requisitos

- [Cursor](https://cursor.com/) (las skills viven en `~/.cursor/skills/`)
- Node.js 20+ y `pnpm` (recomendado)
- Cuenta gratuita en [Supabase](https://supabase.com/) y [Vercel](https://vercel.com/)
- MCP de Supabase configurado en Cursor (las skills lo aprovechan para bootstrap automático)

## El gate (lo más importante)

`ui-approve` es el gate visual obligatorio. Sin un "sí, apruebo" del usuario:

- `schema-sketch` se bloquea
- `supabase-setup` se bloquea
- `wire-data` se bloquea

Esto evita rework: la UI se diseña con mocks (rápido y barato cambiar), se aprueba, y entonces el backend nace ya sirviendo el shape correcto.

## Stack opinionado

Esta suite **no** es agnóstica. Es para:

- **Frontend**: Next.js 16 (App Router) + shadcn/ui + Tailwind v4
- **Backend**: Supabase (Postgres + RLS; **Auth por defecto** en Supabase; **opcional** identidad con Clerk vía `clerk-auth-bridge` como último paso)
- **Deploy**: Vercel
- **Setup base**: `npx shadcn@latest init --preset b0 --base base --template next`

Si tu stack es otro, esta suite probablemente no es para ti — y está bien.

## Filosofía completa

Cada artefacto vive en el repo. Son commiteables, compartibles, evaluables:

- `IDEA.md` — la idea validada
- `PRD.md` — el contrato del producto
- `SCOPE.md` — el plan del día con time-boxes
- `FLOW.md` — pantallas + TS interfaces
- `UI-APPROVAL.md` — el gate firmado
- `schema.sql` + `RLS.md` — la base de datos
- `DEMO.md` — los 3 tests pasados
- `RETRO.md` — qué aprendiste hoy
- `BACKLOG.md` — lo que cortaste a propósito

## Mejorar la suite con cada uso

`day-retro` tiene un paso opcional para capturar aprendizajes universales en las skills mismas. Cada vez que un patrón se repite (ej. "siempre olvido configurar redirect URL en Supabase Auth para preview"), el retro lo añade como nota a la skill correspondiente. La suite mejora sola con cada prototipo que construyes.

## Contribuir

Forks bienvenidos. Si una skill te funciona mejor con otro patrón, abre un PR con tu cambio + una frase del por qué. Si una skill te falla, abre un issue con el contexto exacto (qué pediste, qué hizo, qué esperabas).

Lee [CONTRIBUTING.md](CONTRIBUTING.md) para detalles.

## Inspiración

- [garrytan/gstack](https://github.com/garrytan/gstack) — el setup de Garry Tan que demostró que un solo dev con las skills correctas puede shippear como un equipo.
- La diferencia: gstack es agnóstico de stack y en inglés. esnupysetup es opinionado para Next + Supabase y nativo en español.

## Licencia

[MIT](LICENSE) — fórkalo, modifícalo, hazlo tuyo.

---

Si te funciona, **comparte tu prototipo** con el hashtag `#esnupysetup`. Cada caso que ven otros devs hace que la suite crezca.
