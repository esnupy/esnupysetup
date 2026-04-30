---
name: wire-data
description: Reemplaza los mocks de lib/mock/ por queries reales a Supabase, sin tocar componentes visuales. Convierte useState mock en Server Actions + Server Components, conecta auth real si aplica, y borra los archivos mock al terminar. La UI sigue viéndose idéntica. Úsalo después de supabase-setup, o cuando el usuario diga "conectar datos", "wire", "reemplazar mocks", "datos reales".
---

# wire-data

Décimo paso. 1 hora. **El swap.** Los mocks salen, las queries reales entran. Los componentes visuales **no se tocan** — solo la fuente de datos. Si la UI cambia visualmente después de este paso, algo se hizo mal.

## Cuándo invocarlo

- Existen `UI-APPROVAL.md` (APROBADA), `schema.sql` aplicado en Supabase, `src/lib/supabase/{client,server}.ts`, `src/types/database.ts`.
- El usuario dice "conectar datos", "wire", "datos reales", "reemplazar mocks".
- La UI corriendo con mocks ya gusta y solo falta persistencia real.

## Tono

Amigo técnico ejecutivo y quirúrgico. Cero rediseño. Si te dan ganas de "aprovechar" para tocar un componente visual, **no**. Eso es otro skill. Tu trabajo es solo cambiar la fuente.

## Filosofía del swap

| Antes (mock) | Después (real) |
|---|---|
| `import { mockTasks } from '@/lib/mock/tasks'` | `import { getTasks } from '@/features/tasks/queries'` |
| `useState<Task[]>(mockTasks)` | `await getTasks()` en server component |
| `setTasks(prev => [newTask(title), ...prev])` | `await createTask(formData)` (Server Action) + `revalidatePath('/dashboard')` |
| `'use client'` en pantalla principal | server component — solo el form interactivo se queda client |

**El TS interface no cambia.** `Task` sigue siendo `Task`. Por eso este swap es seguro.

## Workflow

### Paso 0 — Verificar prerrequisitos

Confirma que existen:
- `UI-APPROVAL.md` con APROBADA.
- Tablas en Supabase (corre `mcp_user-supabase_list_tables` para verificar).
- `src/types/database.ts` generado.
- `src/lib/supabase/{client,server}.ts` escritos.

Si falta algo, redirige al skill correspondiente.

### Paso 1 — Inventario de mocks usados

Para cada archivo en `src/lib/mock/`, lista qué pantallas/componentes lo importan:

```bash
rg "from ['\"]@/lib/mock" src/
```

Esto te da el mapa exacto de qué archivos vas a tocar.

### Paso 2 — Crear `features/<entidad>/queries.ts` por cada entidad

Para cada entidad (cada archivo de `lib/mock/`), crea su query file:

```ts
// src/features/tasks/queries.ts
import { createClient } from '@/lib/supabase/server';
import type { Task } from '@/types';

export const getTasks = async (): Promise<Task[]> => {
  const supabase = await createClient();
  const { data, error } = await supabase
    .from('tasks')
    .select('id, title, status, created_at')
    .order('created_at', { ascending: false });

  if (error) throw error;

  // Importante: mapeamos snake_case (DB) → camelCase (UI/TS interface aprobado).
  return (data ?? []).map((row) => ({
    id: row.id,
    title: row.title,
    status: row.status,
    createdAt: row.created_at,
  }));
};
```

**Clave**: el shape devuelto matchea **exactamente** el TS interface aprobado en `UI-APPROVAL.md`. La UI no nota la diferencia.

### Paso 3 — Crear `features/<entidad>/actions.ts` por cada mutación

Por cada handler de cliente que mutaba el array (`handleCreate`, `handleToggle`, etc.), crea una Server Action equivalente:

```ts
// src/features/tasks/actions.ts
'use server';

import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';

type ActionResult = { success: true } | { success: false; error: string };

export const createTask = async (formData: FormData): Promise<ActionResult> => {
  const title = formData.get('title');
  if (typeof title !== 'string' || !title.trim()) {
    return { success: false, error: 'Título requerido' };
  }

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { success: false, error: 'No autenticado' };

  const { error } = await supabase.from('tasks').insert({
    title: title.trim(),
    user_id: user.id,
  });

  if (error) return { success: false, error: error.message };
  revalidatePath('/dashboard');
  return { success: true };
};

export const toggleTaskStatus = async (id: string): Promise<ActionResult> => {
  const supabase = await createClient();
  // lee actual, decide nuevo, actualiza
  const { data: current, error: readError } = await supabase
    .from('tasks').select('status').eq('id', id).single();
  if (readError) return { success: false, error: readError.message };

  const next = current.status === 'done' ? 'todo' : 'done';
  const { error } = await supabase.from('tasks').update({ status: next }).eq('id', id);
  if (error) return { success: false, error: error.message };

  revalidatePath('/dashboard');
  return { success: true };
};
```

### Paso 4 — Convertir pantalla por pantalla (orden: wow primero)

Para cada pantalla que importa mocks:

#### a. Si la pantalla puede ser server component, conviértela

Quita `'use client'`, reemplaza `useState(mockX)` por `await getX()`:

```tsx
// src/app/(app)/dashboard/page.tsx (era client, ahora server)
import { getTasks } from '@/features/tasks/queries';
import { TaskList } from '@/features/tasks/components/task-list';
import { CreateTaskDialog } from '@/features/tasks/components/create-task-dialog';

const DashboardPage = async () => {
  const tasks = await getTasks();
  return (
    <div className="p-6">
      <header className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Tus tareas</h1>
        <CreateTaskDialog />
      </header>
      <TaskList tasks={tasks} />
    </div>
  );
};

export default DashboardPage;
```

#### b. Extrae los pedazos interactivos a client components

`TaskList` y `CreateTaskDialog` son client components que reciben datos por props o ejecutan Server Actions. **El JSX de cada uno es idéntico al del mockup** — solo cambia de dónde vienen los datos y qué hace el handler.

```tsx
// src/features/tasks/components/create-task-dialog.tsx
'use client';

import { useActionState } from 'react';
import { Button } from '@/components/ui/button';
import { Dialog, DialogTrigger, DialogContent } from '@/components/ui/dialog';
import { createTask } from '../actions';

export const CreateTaskDialog = () => {
  const [state, formAction, pending] = useActionState(
    async (_prev: unknown, formData: FormData) => createTask(formData),
    null,
  );

  return (
    <Dialog>
      <DialogTrigger asChild>
        <Button>+ Nueva tarea</Button>
      </DialogTrigger>
      <DialogContent>
        <form action={formAction} className="space-y-4">
          {/* mismo JSX que el mockup, solo cambia el handler */}
          <Button type="submit" disabled={pending}>
            {pending ? 'Creando...' : 'Crear'}
          </Button>
          {state && !state.success && (
            <p className="text-destructive text-sm">{state.error}</p>
          )}
        </form>
      </DialogContent>
    </Dialog>
  );
};
```

#### c. Borra el mock setTimeout artificial

Si añadiste un `setTimeout` en el mockup para que el skeleton fuera visible, **bórralo**. Con datos reales el skeleton ya es legítimo (`loading.tsx` Suspense boundary).

### Paso 5 — Auth real (si SCOPE.md lo pidió)

Reemplaza el `/login` mock (que hacía `router.push('/dashboard')`) por el auth real con `@supabase/ssr`. Ver `supabase-setup/reference.md` para el snippet completo.

Pasos:
1. Form llama `supabase.auth.signInWithOtp({ email, options: { emailRedirectTo: ... } })`.
2. Crea `src/app/auth/callback/route.ts` con `exchangeCodeForSession`.
3. En `src/app/(app)/layout.tsx`, verifica sesión con `supabase.auth.getUser()`; si no hay, `redirect('/login')`.
4. Asegura que `src/middleware.ts` está en su lugar (ya lo dejó `/supabase-setup`).

### Paso 6 — Borrar mocks

Una vez todas las pantallas funcionan con datos reales en local, borra:

```bash
rm -rf src/lib/mock/
```

Verifica que no quedan imports rotos:

```bash
pnpm run build
```

Si el build pasa, los mocks están limpios.

### Paso 7 — Smoke test del happy path completo

Levanta dev y recórrete:

1. `/login` → submit con email real → recibe magic link → callback → `/dashboard`.
2. `/dashboard` → vacío al inicio (porque el user nuevo no tiene datos).
3. Crear tarea → aparece persistente.
4. Refresh del browser → la tarea sigue ahí (esto es lo que mock no podía).
5. Toggle status → persiste.

Si algo se rompe, **arregla aquí**. No avances roto a `/demo-check`.

### Paso 8 — Commit del swap

```bash
git add .
git commit -m "feat: wire data real (Supabase queries + Server Actions, mocks fuera)"
```

### Paso 9 — Confirmar al usuario

> Datos cableados. UI idéntica visualmente, pero ahora persiste. Mocks borrados. Próximo: `/demo-check` para validar antes de deploy.

## Patrones útiles

### Mantener el shape exacto del TS interface

DB usa snake_case (`created_at`, `user_id`); UI/interfaces usan camelCase (`createdAt`, `userId`). El `.map()` en cada query hace la traducción. Si saltas esta traducción, la UI se rompe sutilmente.

### Optimistic updates (opcional, día 2)

`useOptimistic` de React 19 puede mantener la sensación instantánea del mock. Solo si sobra tiempo. Día 1: `revalidatePath` es suficiente.

### Si una pantalla NO puede ser server component

Cuando hay mucha interactividad (drag-drop, animaciones complejas), mantenla client. Recibe los datos iniciales por prop desde un server component padre, y usa `useTransition` con Server Actions para mutaciones.

### Verificar que la DB sirve lo que la UI espera

Después del swap, contra cada query corre el smoke verification:

```sql
-- vía MCP execute_sql
select column_name, data_type from information_schema.columns where table_name = 'tasks';
```

Debe matchear los campos del `.select()` y los del TS interface.

## Qué viene después

- **Siguiente**: `/demo-check` (3 tests + smoke en local antes de deploy).
- Después: `/vercel-ship` (deploy a producción).
- **Opcional (último)**: `/clerk-auth-bridge` si el usuario rechaza Supabase Auth y quiere Clerk manteniendo la misma base y RLS.

## Anti-patrones

- Tocar componentes visuales durante el swap. Si te dan ganas, anota en `BACKLOG.md` y sigue.
- Cambiar shape de un TS interface aprobado para que matchee la DB. Es al revés: la query mapea a la forma del interface.
- Saltarte el `.map()` de snake_case a camelCase porque "es solo demo". Romperá un campo cuando menos lo esperes.
- Dejar mocks "por si acaso". Bórralos. Si los necesitas de vuelta, git los recupera.
- Hacer auth real cuando `SCOPE.md` dijo hardcoded. Respeta la decisión.
- Probar solo con datos seed. Crea tu propio user nuevo y verifica que funciona desde cero (RLS te puede sorprender).
