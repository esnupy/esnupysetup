---
name: flow-sketch
description: Define los 3-5 flujos/pantallas mínimos del prototipo, los componentes shadcn por pantalla y los TS interfaces de mock data por pantalla. Identifica la pantalla wow. Lee PRD.md y SCOPE.md, produce FLOW.md. Úsalo después de shadcn-init, o cuando el usuario diga "qué pantallas hago", "diseñar flujo", "UI", "qué componentes", "wireframe".
---

# flow-sketch

Quinto paso. 30 minutos. Define las pantallas mínimas, sus componentes shadcn, y cuál es la **pantalla wow** que vende la demo. NO diseñas pixel-perfect; defines la estructura **y los TS interfaces de mock data** que `/ui-mockup` va a consumir. Cero backend en este paso.

## Cuándo invocarlo

- Hay `PRD.md`, `SCOPE.md` y el repo ya scaffoldado por `/shadcn-init`.
- El usuario pregunta "qué pantallas necesito", "qué componentes", "cómo es la UI".
- Antes de `/ui-mockup`. Sin esto, `ui-mockup` improvisa y se va de tiempo.

## Tono

Amigo técnico con criterio de UX y opinión sobre shadcn. No preguntas tonterías que ya están en `SCOPE.md`. Confirmas, propones, pides ajustes.

## Defaults opinionados

- Layout base: shadcn `sidebar-07` o `dashboard-01` para apps internas; landing limpia para públicas.
- 3-5 pantallas máximo en día 1. Si necesitas más, está mal el scope.
- Una pantalla wow obligatoria. Es la que sale en el screenshot del demo.
- Componentes: solo de shadcn registry oficial. Cero CSS custom hasta que duela.
- Mobile-first si la demo se enseña en celular; desktop-first si es producto B2B.

## Workflow

### Paso 0 — Cargar contexto

Lee `PRD.md` y `SCOPE.md`. Nota: la pantalla wow ya debería estar mencionada en `SCOPE.md`. Confírmala.

**IMPORTANTE**: en esta fase aún no hay schema.sql. La fuente de verdad de los datos son las **user stories del PRD** y los **TS interfaces que vas a inventar aquí**. El schema real lo deriva `/schema-sketch` después de que la UI esté aprobada.

### Paso 1 — Inventario de pantallas

Pregunta:

> Basado en el wedge, propongo estas pantallas. Confirma o ajusta:
>
> 1. [Auth/Login] — solo si el SCOPE dice login real
> 2. [Pantalla principal] — la que hace la acción del wedge
> 3. [Pantalla wow] — la que vende la demo (puede ser la misma que la principal)
> 4. [Pantalla secundaria, opcional]
> 5. [Settings/Empty state, opcional]

Usa `AskQuestion` para que el usuario marque cuáles entran al día 1.

### Paso 2 — Por cada pantalla

Para cada pantalla, define en `FLOW.md`:

- **Path**: `/`, `/dashboard`, `/items/[id]`, etc. (Next.js 16 App Router).
- **Tipo de render**: server component (default) | client component (con razón) | mix.
- **Datos (mock)**: qué TS interface consume y de qué archivo de `lib/mock/` viene. Ejemplo: `Task[]` desde `lib/mock/tasks.ts`.
- **Componentes shadcn**: lista concreta (Button, Card, Form, Dialog, DataTable, etc.).
- **Acciones**: qué botones / forms hay. **En la fase mock**, las acciones son no-op o mutan el array mock en cliente con `useState`. NO hay Server Actions todavía.
- **Estados**: loading (Skeleton estático para el screenshot), error (Alert), empty (componente vacío bonito), success.

### Paso 2.5 — TS interfaces (esto es nuevo y crítico)

Por cada entidad que aparece en las pantallas, define el TS interface aquí mismo. Ejemplo:

```ts
// Eventualmente vivirá en src/types/index.ts
interface Task {
  id: string;
  title: string;
  status: 'todo' | 'doing' | 'done';
  createdAt: string; // ISO date
}
```

Estos interfaces son el **contrato**. `/ui-mockup` los usa para los mocks. `/schema-sketch` los usa para diseñar tablas. `/wire-data` valida que las queries Supabase devuelvan estos mismos shapes.

Reglas:
- Solo los campos que la UI necesita mostrar/editar. Si la UI no lo muestra, no existe.
- Tipos primitivos + `Date as string ISO`. Cero tipos exóticos.
- Nombres en inglés, camelCase (TS standard).

### Paso 3 — La pantalla wow

Pregunta directa:

> ¿Esta pantalla [wow] cumple los 3 tests?
>
> 1. **30s test**: si te quedas callado, ¿se entiende?
> 2. **Screenshot test**: ¿se ve bien en una sola captura?
> 3. **Wow test**: ¿hay un detalle (animación, vacío bonito, dato concreto) que da "wow"?

Si falla alguno, propón un ajuste **antes** de que `/ui-mockup` la construya.

### Paso 4 — Layout y navegación

Pregunta:

> Layout: ¿sidebar (apps internas), top nav (landing/marketing), o single page (super mínimo)?

Por defecto: sidebar para apps con auth, single page para landing/demo.

### Paso 5 — Empty / loading / error states

Recordatorio explícito:

> Cada pantalla con datos necesita: skeleton mientras carga, mensaje vacío si no hay datos, alert si falla. shadcn los tiene; no inventes.

Marca en `FLOW.md` cuáles están planeados.

### Paso 6 — Confirmación

Cierra con:

> Recap: [N] pantallas, pantalla wow es [X]. Componentes shadcn a instalar: [lista]. TS interfaces definidos: [lista]. Próximo paso: `/ui-mockup` para maquetar todo con mock data, sin tocar backend. ¿Listo?

## Template de FLOW.md

```markdown
# FLOW de [proyecto]

> Generado por flow-sketch. Lee PRD.md y SCOPE.md para contexto.

## Layout base
- shadcn: [sidebar-07 | dashboard-01 | landing custom | single-page]
- Mobile-first: [sí | no]

## TS interfaces (contrato de datos)

```ts
interface Task {
  id: string;
  title: string;
  status: 'todo' | 'doing' | 'done';
  createdAt: string;
}

interface User {
  id: string;
  name: string;
  email: string;
}
```

## Pantallas

### 1. /login — Login
- **Render**: client component (form interactivo)
- **Datos**: en mock fase, no-op (botón "Entrar" → redirige a /dashboard sin auth)
- **Componentes**: Card, Form, Input, Button, Alert
- **Acciones**: handleSubmit (mock) → router.push('/dashboard')
- **Estados**: loading (Button con spinner)

### 2. /dashboard — Pantalla principal ⭐ (WOW)
- **Render**: client component (para poder mutar mock con useState)
- **Datos (mock)**: `Task[]` desde `lib/mock/tasks.ts`
- **Componentes**: Card, DataTable, Dialog (para crear), Badge (status)
- **Acciones**: handleCreate (push al array local), handleToggle (mutate local)
- **Estados**: Skeleton fake (1s setTimeout para mostrarlo en demo), EmptyState si vacío
- **Wow detail**: animación al completar tarea + contador "Hoy completaste X"

### 3. /tasks/[id] — Detalle (opcional)
...

## Pantalla WOW: /dashboard
- 30s test: ✅ — usuario ve lista, clickea +, escribe, aparece. Sin explicar.
- Screenshot test: ✅ — sidebar + tabla + empty state animado
- Wow test: ✅ — animación de check + counter

## Componentes shadcn a instalar
button, card, form, input, dialog, badge, skeleton, alert, sidebar, data-table, sonner

## Lo que NO entra (apuntado en BACKLOG.md)
- Settings page
- Editar tarea inline
- Filtros avanzados

## Próximo paso
- `/ui-mockup` para construir las pantallas con mock data del array de cada interface.
- Backend (`/schema-sketch`, `/supabase-setup`, `/wire-data`) NO se invocan hasta que `/ui-approve` apruebe.
```

## Qué viene después

- **Siguiente**: `/ui-mockup` (construye todas las pantallas con mock data, cero backend).
- Después: `/ui-approve` (gate antes de tocar Supabase).

## Anti-patrones

- 8 pantallas para el día 1. Recorta o vuelve a `/scope-1day`.
- Pantalla wow vaga. Si no puedes describir el wow detail en una frase, no es wow.
- Olvidar empty/loading/error. Esos son el 80% de lo que diferencia "demo" de "producto".
- Inventar componentes que ya existen en shadcn. Siempre busca primero en el registry.
- Definir TS interfaces "completos por si acaso" con 15 campos. Solo lo que la UI necesita mostrar/editar HOY.
- Dejar los campos `userId`, `createdAt` como tipos exactos de DB. Aquí son `string` (ISO). El schema real los traduce.
