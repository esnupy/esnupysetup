---
name: supabase-setup
description: Bootstrap completo de Supabase usando el MCP user-supabase — crea proyecto, aplica schema.sql con RLS, configura Auth, genera tipos TypeScript y escribe lib/supabase/{client,server}.ts compatible con Next.js 16. Úsalo SOLO después de schema-sketch (que a su vez requiere ui-approve). El usuario dice "conectar supabase", "crear backend", "auth", "base de datos".
---

# supabase-setup

Noveno paso. 1 hora. Conecta el repo (ya con UI aprobada y maquetada con mocks) con Supabase real. Aplica el `schema.sql` que generó `/schema-sketch`. Configura Auth. Genera tipos. Escribe los clients para Next.js 16 con `@supabase/ssr`. **No toca la UI** — eso lo hace `/wire-data` después.

## Cuándo invocarlo

- Existe `schema.sql` y `UI-APPROVAL.md` con estado APROBADA.
- El usuario dice "conectar supabase", "crear backend", "auth".
- Si no existe `UI-APPROVAL.md`, **bloquea** y manda a `/ui-approve`.

## Tono

Amigo técnico experto. Ejecuta vía MCP, comunica progreso, falla rápido si algo no aplica. Pregunta solo lo que el MCP no puede inferir (org, nombre, región).

## Herramientas MCP que usa

Servidor: `user-supabase`. Tools relevantes:

- `list_organizations` — para elegir org
- `get_cost` + `confirm_cost` + `create_project` — para crear proyecto
- `apply_migration` — para aplicar `schema.sql` (atómico, transaccional)
- `execute_sql` — para queries de inspección
- `get_project_url` + `get_publishable_keys` — para `.env.local`
- `generate_typescript_types` — para `src/types/database.ts`
- `get_advisors` — para detectar fugas de seguridad después de aplicar el schema
- `list_tables`, `list_extensions` — para verificación

**Siempre lee primero el JSON descriptor del tool** en `~/.cursor/projects/<project>/mcps/user-supabase/tools/<tool>.json` (o donde Cursor tenga registrado el MCP de Supabase del usuario) antes de llamarlo.

## Workflow

### Paso 0 — Cargar contexto

Lee `schema.sql`, `RLS.md`, `SCOPE.md`, `UI-APPROVAL.md`. Verifica que `shadcn-init` ya corrió (existe `package.json` con next) y que `ui-approve` aprobó la UI.

### Paso 1 — Decidir proyecto: nuevo o existente

`AskQuestion`:

- A) Crear proyecto Supabase nuevo para esto (recomendado para prototipos)
- B) Usar un proyecto existente (el usuario te dirá el ref)

#### Si A — crear nuevo

1. Llama `list_organizations` y deja al usuario elegir si tiene varias.
2. Pregunta nombre (default: el del repo) y región (default: `us-east-1` o la más cercana al usuario).
3. Llama `get_cost` con type=project para mostrar el costo (probablemente $0 en free tier).
4. Llama `confirm_cost` con el id retornado.
5. Llama `create_project` con `confirm_cost_id`. Espera a que esté `ACTIVE_HEALTHY` haciendo poll de `get_project`.

#### Si B — existente

Pide el `project_id` (ref) y verifica con `get_project`.

### Paso 2 — Aplicar schema

Llama `apply_migration` con:

- `name`: `init_schema_dia1` (o similar — siempre snake_case, descriptivo).
- `query`: el contenido de `schema.sql`.

Si falla, **no continúes**. Lee el error, ajusta el SQL con el usuario, vuelve a aplicar. No hagas execute_sql parcial — usa migrations para mantener historia.

### Paso 3 — Verificar RLS

1. `list_tables` para confirmar tablas creadas.
2. Para cada tabla del schema, ejecuta:
   ```sql
   select tablename, rowsecurity from pg_tables where schemaname='public' and tablename = '<nombre>';
   ```
3. Si alguna tabla tiene `rowsecurity = false`, **alerta** y pregunta si aplicar `alter table <x> enable row level security` ahora. No avances sin RLS.

### Paso 4 — Llamar advisors de seguridad

```
get_advisors({ type: "security" })
```

Si hay warnings de RLS desactivado, políticas faltantes, o funciones inseguras, repórtalas y arregla en migración nueva. No las ignores.

### Paso 5 — Configurar Auth (según SCOPE)

Si `SCOPE.md` dice login real:

- Para email magic link: el default de Supabase ya funciona, no requiere config extra.
- Para Google OAuth: instruye al usuario para configurar el provider en el dashboard (no automatizable vía MCP) y dale las URLs de callback que Next.js 16 va a usar (`/auth/callback`).

Si `SCOPE.md` dice usuario hardcoded: skip este paso.

### Paso 6 — Variables de entorno

1. Llama `get_project_url` y `get_publishable_keys` (anon key).
2. Escribe en `.env.local`:
   ```bash
   NEXT_PUBLIC_SUPABASE_URL=<url>
   NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon>
   ```
3. **No** escribas el service role key automáticamente. Si el usuario lo necesita, dale instrucciones para copiarlo del dashboard (no exponer al cliente nunca).

### Paso 7 — Generar tipos TypeScript

```
generate_typescript_types()
```

Escribe el resultado en `src/types/database.ts`. Esto desbloquea el resto del código tipado.

### Paso 8 — Escribir lib/supabase/{client,server}.ts

Crea ambos siguiendo el patrón oficial de `@supabase/ssr` para App Router. Ver `reference.md`.

Instala primero:

```bash
pnpm add @supabase/ssr @supabase/supabase-js
```

### Paso 9 — Smoke test (sin tocar UI)

Crea un script aislado en `scripts/smoke-supabase.ts` que haga un `select count(*)` de una tabla y un insert/delete de prueba. Córrelo con `tsx`:

```bash
pnpm dlx tsx scripts/smoke-supabase.ts
```

Una vez confirmado que conecta, **borra el script**. **No toques la UI todavía** — la UI sigue corriendo con mocks. `/wire-data` es el que hace el swap.

### Paso 10 — Commit

```bash
git add .
git commit -m "feat: connect supabase (schema + RLS + auth + types)"
```

### Paso 11 — Confirmar al usuario

> Supabase listo. Tablas: [N], RLS verificado, tipos generados, advisors limpios. La UI sigue corriendo con mocks. Próximo: `/wire-data` para reemplazar mocks con queries Supabase reales — sin tocar componentes visuales.

## Qué viene después

- **Siguiente**: `/wire-data` (cambia las fuentes de datos, mantiene UI intacta).

## Anti-patrones

- Aplicar SQL con `execute_sql` para cambios de schema. Siempre `apply_migration` para tener historia.
- Ignorar advisors. Un advisor en rojo el día 1 es deuda que se acumula.
- Hardcodear keys en el código. Solo en `.env.local`.
- Escribir el service role key en `.env.local` automáticamente. No es necesario para el día 1.
- Saltarse el smoke test. Si la conexión falla, mejor saberlo aquí que durante `/wire-data`.

## Recursos

- Snippets de `@supabase/ssr` para Next.js 16 → ver [reference.md](reference.md)
