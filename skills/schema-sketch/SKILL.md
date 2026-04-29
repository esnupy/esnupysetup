---
name: schema-sketch
description: Deriva el schema mínimo de Supabase (tablas, relaciones, RLS y enums) DESDE los TS interfaces aprobados en UI-APPROVAL.md — la DB sirve a la UI, no al revés. Produce schema.sql + RLS.md listos para /supabase-setup. Úsalo SOLO después de ui-approve, o cuando el usuario diga "diseñar tabla", "schema", "backend", "ya aprobamos la UI".
---

# schema-sketch

Octavo paso. 30 minutos. Deriva la(s) tabla(s) de Supabase y las RLS policies **desde los TS interfaces aprobados** en `UI-APPROVAL.md`. Cero invención: la DB existe para servir exactamente lo que la UI ya muestra. Produce `schema.sql` y `RLS.md` listos para que `/supabase-setup` los aplique.

## Cuándo invocarlo

- **Existe `UI-APPROVAL.md` con estado APROBADA.** Sin esto, **bloquea**:
  > Backend bloqueado. Pasa primero por `/ui-approve`. La regla de la suite: la DB nace para servir una UI ya aprobada.
- El usuario dice "schema", "tablas", "vamos al backend".

## Tono

Amigo técnico experto. Asume que el usuario sabe SQL básico pero le ayudas a no olvidar lo importante (RLS, índices, timestamps). Recomendaciones por defecto, no opciones infinitas.

## Defaults opinionados

Toda tabla por defecto tiene:

- `id uuid primary key default gen_random_uuid()`
- `created_at timestamptz not null default now()`
- `updated_at timestamptz not null default now()` (con trigger de actualización)
- `user_id uuid not null references auth.users(id) on delete cascade` (si la tabla pertenece a un usuario)
- RLS habilitado desde el día 1. Sin excepciones.

## Workflow

### Paso 0 — Verificar gate y cargar contexto

1. Verifica que `UI-APPROVAL.md` existe y dice APROBADA. Si no, **detente** y manda al usuario a `/ui-approve`.
2. Lee `UI-APPROVAL.md` (sección "TS interfaces aprobados"), `src/types/index.ts`, los archivos de `src/lib/mock/`, y `PRD.md` para contexto.

### Paso 1 — Cada TS interface = 1 tabla

Toma la lista de TS interfaces aprobados. Cada interface se convierte en una tabla Postgres. Mapeo:

| TS interface | Postgres table |
|---|---|
| `interface Task { id: string; title: string; status: 'todo' \| 'doing' \| 'done'; createdAt: string; }` | `table tasks (id uuid pk, title text, status task_status enum, created_at timestamptz, updated_at timestamptz, user_id uuid fk)` |

Reglas de mapeo:

- `id: string` → `id uuid primary key default gen_random_uuid()`
- `'a' \| 'b' \| 'c'` (literal union) → enum Postgres
- `string` ISO date → `timestamptz`
- `string` libre → `text`
- `number` → `integer` o `numeric` (pregunta si hay decimales)
- `boolean` → `boolean`
- Objeto anidado → JSONB (pregunta si conviene normalizar)
- Array de strings → `text[]`
- **Siempre añade**: `created_at`, `updated_at`, `user_id` (si la entidad pertenece a un usuario — es el caso por defecto).

Confirma con el usuario:

> Del UI-APPROVAL.md derivo estas [N] tablas. ¿Confirmas o falta algo?

Si el usuario quiere añadir un campo que la UI no usa, **bloquea**:

> Si el campo no se ve ni se edita en la UI, no entra hoy. Va a BACKLOG.

### Paso 2 — Preguntas de ownership (una por entidad)

Por cada entidad, usa `AskQuestion` con estas opciones:

1. **¿Quién la posee?**
   - Pertenece a un usuario (necesita `user_id`)
   - Es global / pública (no necesita `user_id`)
   - Pertenece a un workspace/equipo (multi-tenant — pregunta si hoy o backlog)

2. **¿Hay relaciones con otras entidades?**
   - Sí, una a muchas (FK simple)
   - Sí, muchas a muchas (tabla pivote — confirma si es necesaria hoy)
   - No

3. **¿Soft-delete o hard-delete?**
   - Hard-delete (default — más simple)
   - Soft-delete (`deleted_at timestamptz` — solo si lo necesitas hoy)

### Paso 3 — Enums vs strings

Pregunta:

> Hay campos como [estado, tipo, categoría]. ¿Valores fijos o libres?

- Valores fijos → enum de Postgres (`create type ... as enum`)
- Libres → `text` con check constraint si hay validación

Por defecto, prefiere enums para campos de estado.

### Paso 4 — Índices mínimos

Para cada tabla, añade índice en:

- Toda FK (`user_id`, etc.)
- Campo por el que filtras la query principal (pregunta cuál es).

No te pongas creativo con índices. Día 1 = mínimos.

### Paso 5 — RLS por tabla

Para cada tabla, define políticas en `RLS.md` con esta tabla mental:

| Operación | Default seguro |
|---|---|
| SELECT | `auth.uid() = user_id` (o público si la entidad es pública) |
| INSERT | `auth.uid() = user_id` (con `with check`) |
| UPDATE | `auth.uid() = user_id` (con `using` y `with check`) |
| DELETE | `auth.uid() = user_id` |

Si la tabla es pública para SELECT, dilo explícito en `RLS.md` y por qué.

### Paso 6 — Generar schema.sql

Un solo archivo, todo en orden: extensions → enums → tables → indexes → triggers → RLS enable → policies. Ver template abajo.

### Paso 7 — Validación final contra mock data

Antes de declarar terminado, valida que los mocks de `src/lib/mock/` se podrían insertar en las tablas tal cual:

1. Recórrete cada archivo de `lib/mock/`.
2. Para cada item, verifica que:
   - Cada campo tiene una columna en la tabla correspondiente.
   - Los tipos matchean (string ISO → timestamptz, etc.).
   - No hay campos del mock que NO tengan columna (señal de schema incompleto).
   - No hay columnas obligatorias sin valor en el mock (señal de que la UI no captura un dato necesario — alerta al usuario).

Si hay desalineación, ajusta el schema (no los mocks — los mocks son el contrato visible).

> Recap: [N] tablas derivadas de [N] interfaces. Mocks validados. RLS en todas. La query principal del día es [X], indexada por [Y]. ¿Listo para `/supabase-setup`?

## Template de schema.sql

```sql
-- Generado por schema-sketch para [nombre proyecto] — día [fecha]
-- Aplicar via /supabase-setup

-- ============ Extensions ============
create extension if not exists "pgcrypto";

-- ============ Enums ============
-- create type task_status as enum ('todo','doing','done');

-- ============ Trigger genérico para updated_at ============
create or replace function set_updated_at() returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- ============ Tablas ============
-- Ejemplo:
-- create table tasks (
--   id uuid primary key default gen_random_uuid(),
--   user_id uuid not null references auth.users(id) on delete cascade,
--   title text not null,
--   status task_status not null default 'todo',
--   created_at timestamptz not null default now(),
--   updated_at timestamptz not null default now()
-- );
-- create index tasks_user_id_idx on tasks(user_id);
-- create trigger tasks_updated_at before update on tasks for each row execute function set_updated_at();

-- ============ RLS ============
-- alter table tasks enable row level security;
--
-- create policy "tasks_select_own" on tasks for select using (auth.uid() = user_id);
-- create policy "tasks_insert_own" on tasks for insert with check (auth.uid() = user_id);
-- create policy "tasks_update_own" on tasks for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- create policy "tasks_delete_own" on tasks for delete using (auth.uid() = user_id);
```

## Template de RLS.md

```markdown
# RLS para [proyecto]

## Tabla: tasks
- **Ownership**: por usuario (`user_id`)
- **SELECT**: solo dueño
- **INSERT/UPDATE/DELETE**: solo dueño
- **Notas**: ninguna excepción de seguridad para el día 1.

## Tabla: [otra]
...
```

## Patrones comunes

- **Multi-tenant ligero**: añade `workspace_id` y FK a `workspaces`. RLS basadas en `auth.uid() in (select user_id from workspace_members where workspace_id = ...)`. Solo hoy si el wedge lo requiere.
- **Datos públicos de lectura, escritura privada**: SELECT con `using (true)`, INSERT/UPDATE/DELETE con `auth.uid() = user_id`.
- **Storage para archivos**: documenta el bucket en `RLS.md` pero el setup lo hace `/supabase-setup`.

## Qué viene después

- **Siguiente**: `/supabase-setup` (aplica `schema.sql` vía MCP, configura Auth, genera tipos).
- Después: `/wire-data` (reemplaza los arrays mock con queries reales — los TS interfaces se mantienen idénticos).

## Anti-patrones

- Inventar tablas que no derivan de un TS interface aprobado. Si el dato no está en la UI, no existe en la DB.
- Olvidar habilitar RLS. **Nunca** entregues una tabla sin RLS, aunque sea "demo".
- Añadir campos "por si acaso" que la UI no usa. Día 30, no día 1.
- Demasiados enums fuera de los que aparecen como literal unions en TS.
- Sobre-indexar. Una FK + el filtro principal, listo.
- Soft-delete en todo. Solo donde realmente lo necesitas.
- Saltarse la validación contra mock data. Es el chequeo de coherencia más barato del día.
