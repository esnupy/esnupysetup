---
name: ui-mockup
description: Construye TODAS las pantallas del prototipo con mock data hardcoded — cero backend, cero Supabase, cero Server Actions. Solo TS interfaces, arrays mock, useState para mutaciones locales y componentes shadcn. Bloquea el avance hasta que /ui-approve apruebe lo visual. Úsalo después de flow-sketch, o cuando el usuario diga "maquetar", "construir UI", "mock", "frontend primero", "ver cómo se ve".
---

# ui-mockup

Sexto paso. **3 horas — el bloque más grande del día**. Construye TODAS las pantallas de `FLOW.md` con mock data, sin tocar backend. La meta: que el usuario pueda ver, clicar, sentir el producto **antes** de que exista una sola tabla en Supabase.

## Cuándo invocarlo

- Existe `FLOW.md` con TS interfaces definidos.
- El repo ya pasó por `/shadcn-init`.
- El usuario dice "maquetar", "construir UI", "ver cómo se ve", "mock", "frontend primero".

## Tono

Amigo técnico experto. Defiende la pantalla wow del time-box. Bloquea cualquier intento de "ya conectemos Supabase para esta cosita":

> Backend después. Si no se ve bien con mocks, no se va a ver bien con DB real. Vamos a terminar el mockup completo y `/ui-approve` decide.

## Reglas duras (no las rompas)

1. **Cero `@supabase/*` imports.** Si necesitas grep para verificar: `rg "@supabase" src/` debe devolver vacío al terminar este paso.
2. **Cero Server Actions.** Las mutaciones se hacen con `useState` o `useReducer` en cliente. Está OK que se pierdan al refrescar — esa es la naturaleza de un mockup.
3. **Cero env vars.** Si necesitas una variable, hardcodéala con un comentario `// TODO: /wire-data reemplaza esto`.
4. **Cero CSS custom.** Solo Tailwind + utilidades shadcn.
5. **Cero componentes inventados** si shadcn ya tiene uno. Antes de crear cualquier componente, busca en el registry.
6. **Empty/loading/error states obligatorios** — sin esto, el mockup parece roto.

## Workflow

### Paso 0 — Cargar contexto

Lee `FLOW.md`, `SCOPE.md`, `PRD.md`. Confirma:

> Pantalla wow es [X]. Pantallas totales: [N]. TS interfaces de FLOW: [...]. Componentes shadcn: [...]. ¿Confirmas o cambió algo?

### Paso 1 — Instalar componentes shadcn faltantes

`shadcn-init` ya dejó algunos del preset b0. Instala los que falten según `FLOW.md`:

```bash
pnpm dlx shadcn@latest add button card form input label dialog badge skeleton alert sonner sidebar
# añade lo demás de la lista
```

Para bloques pre-armados (sidebar-07, login-04, etc.):

```bash
pnpm dlx shadcn@latest add sidebar-07
```

### Paso 2 — Escribir TS interfaces en `src/types/`

Toma los TS interfaces de `FLOW.md` y crea `src/types/index.ts`:

```ts
export interface Task {
  id: string;
  title: string;
  status: 'todo' | 'doing' | 'done';
  createdAt: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
}
```

Estos son el contrato. `/wire-data` los va a respetar después.

### Paso 3 — Escribir mock data en `lib/mock/`

Una archivo por entidad. Datos realistas (no "Lorem ipsum"). 5-10 items por entidad para que la UI se vea poblada.

```ts
// src/lib/mock/tasks.ts
import type { Task } from '@/types';

export const mockTasks: Task[] = [
  { id: '1', title: 'Llamar al cliente sobre la propuesta', status: 'todo', createdAt: '2026-04-29T10:00:00Z' },
  { id: '2', title: 'Revisar diseño del onboarding', status: 'doing', createdAt: '2026-04-28T15:30:00Z' },
  { id: '3', title: 'Mandar factura de marzo', status: 'done', createdAt: '2026-04-25T09:00:00Z' },
  // ...al menos 5-7 items
];

// helper para "crear" en mock — useState lo va a usar
export const newTask = (title: string): Task => ({
  id: crypto.randomUUID(),
  title,
  status: 'todo',
  createdAt: new Date().toISOString(),
});
```

```ts
// src/lib/mock/user.ts
import type { User } from '@/types';

export const mockUser: User = {
  id: 'mock-user-1',
  name: 'María García',
  email: 'maria@example.com',
};
```

**Datos realistas, no genéricos.** Nombres de personas reales, títulos que tienen sentido para el dominio del producto. El demo se siente serio cuando los datos lo son.

### Paso 4 — Layout base

Implementa el layout que definió `FLOW.md`:

- `src/app/layout.tsx` — html shell, ThemeProvider si hay dark mode, `<Toaster />` (sonner).
- `src/app/(app)/layout.tsx` — protected layout en mock fase: usa `mockUser` directo, sin verificar sesión.

### Paso 5 — Pantalla WOW PRIMERO (60% del tiempo aquí)

Construye la pantalla wow completa antes que las demás. Patrón:

```tsx
// src/app/(app)/dashboard/page.tsx
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Dialog, DialogTrigger, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { mockTasks, newTask } from '@/lib/mock/tasks';
import type { Task } from '@/types';

const DashboardPage = () => {
  const [tasks, setTasks] = useState<Task[]>(mockTasks);
  const [draft, setDraft] = useState('');

  const handleCreate = () => {
    if (!draft.trim()) return;
    setTasks((prev) => [newTask(draft), ...prev]);
    setDraft('');
  };

  const handleToggle = (id: string) => {
    setTasks((prev) =>
      prev.map((t) =>
        t.id === id
          ? { ...t, status: t.status === 'done' ? 'todo' : 'done' }
          : t,
      ),
    );
  };

  if (tasks.length === 0) {
    return <EmptyTasks onCreate={() => {/* abre dialog */}} />;
  }

  return (
    <div className="p-6">
      <header className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Tus tareas</h1>
        {/* Dialog de crear con input controlado */}
      </header>
      <ul className="space-y-2">
        {tasks.map((task) => (
          <TaskRow key={task.id} task={task} onToggle={handleToggle} />
        ))}
      </ul>
    </div>
  );
};

export default DashboardPage;
```

### Paso 6 — Empty / loading / error en la WOW

- **Empty**: componente `EmptyTasks` con icon SVG + título + CTA.
- **Loading**: `loading.tsx` al lado de `page.tsx` con `<Skeleton />` que matchee el layout. (Aunque sea client component, deja un skeleton estático para que se vea en demo cuando navegas.)
- **Error**: `error.tsx` con `<Alert variant="destructive">` + botón retry.

Sin estos tres, el mockup parece roto.

### Paso 7 — Wow detail

Implementa el detalle wow que `FLOW.md` definió. Una hora bien gastada aquí vale más que tres pantallas tibias.

Patrones comunes para mockup:
- **Animación al toggle**: `transition-all`, `scale-95 → scale-100`, opacity. Sin librerías.
- **Counter en vivo**: deriva de `tasks.filter(t => t.status === 'done').length`.
- **Empty state ilustrado**: SVG inline o emoji grande + copy con personalidad ("Tu primera tarea está esperando ✨").
- **Toast con sonner**: `toast.success("¡Hecho!")` después de cada acción.

### Paso 8 — Pantallas restantes

Una a una. Mismo patrón: mock data desde `lib/mock/`, mutaciones con `useState`, sus 3 estados.

### Paso 9 — Auth UI (mock)

Si `SCOPE.md` dice login real, en mock fase **no** hagas Supabase Auth. En su lugar:

- `/login` con shadcn Form + Input + Button.
- handleSubmit no-op → `router.push('/dashboard')`.
- Comentario inline: `// TODO: /wire-data conecta supabase.auth.signInWithOtp aquí`.

Esto le permite al usuario ver el flujo sin necesitar email real.

### Paso 10 — Smoke recorrido manual

```bash
pnpm run dev
```

Recórrete tú mismo el happy path: home/login → dashboard → acción wow → resultado. Si algo se rompe visualmente, arregla aquí.

### Paso 11 — Commits atómicos

Por pantalla:

```bash
git commit -m "feat(ui): dashboard mockup con mock tasks"
git commit -m "feat(ui): login mockup (no-op submit)"
```

### Paso 12 — Pasar al gate

> Mockup completo: [N] pantallas, mock data realista, pantalla wow funciona en local.
>
> **No invoco backend todavía**. Próximo: `/ui-approve` para que valides visualmente. Solo si apruebas, `/schema-sketch` y `/supabase-setup` arrancan.

## Patrones útiles

### Forms en mock fase

Cero `useActionState`, cero Server Actions. Todo `useState`:

```tsx
const [state, setState] = useState<MyForm>(initial);
const handleSubmit = (e: React.FormEvent) => {
  e.preventDefault();
  // mutar mock array, mostrar toast, cerrar dialog
};
```

### Data tables

`pnpm dlx shadcn@latest add data-table`. Pasa el array mock directo. Sorting/filtering funcionan client-side, perfecto para mockup.

### Loading visible en demo

Para que el skeleton se vea en demo (porque mock data carga instantáneo), añade un `setTimeout` artificial en useEffect inicial de la pantalla wow. **Comenta** que es solo para la demo:

```tsx
const [loading, setLoading] = useState(true);
useEffect(() => {
  // mock loading para que el skeleton sea visible en demo; /wire-data lo borra
  const t = setTimeout(() => setLoading(false), 600);
  return () => clearTimeout(t);
}, []);
```

### Theming

Variables CSS de shadcn ya están del preset b0. Si el usuario quiere dark mode: `next-themes` + `<ThemeProvider>` en root layout. 5 minutos.

## Qué viene después

- **Siguiente y obligatorio**: `/ui-approve` (gate visual).
- **Bloqueado** hasta aprobación: `/schema-sketch`, `/supabase-setup`, `/wire-data`.

## Anti-patrones

- Importar `@supabase/ssr` "para tenerlo listo". **No**. Cero Supabase en este paso.
- Saltar la pantalla wow para hacer las fáciles primero. Empieza por la wow.
- Mock data tipo "Item 1", "Item 2", "Lorem ipsum". Muere la demo. Datos realistas.
- Construir las 5 pantallas con la misma calidad. La wow se lleva el 60% del tiempo.
- Olvidar empty/loading/error porque "es solo mockup". Es el 80% de lo que diferencia mockup feo de mockup que se ve real.
- Conectar Supabase porque "ya estoy aquí". No. `/ui-approve` decide cuándo.
