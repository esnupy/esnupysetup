---
name: clerk-auth-bridge
description: Paso opcional final de identidad si no quieres Supabase Auth — integra Clerk con Next.js manteniendo Supabase solo para Postgres + RLS mediante JWT sincronizado. Úsalo cuando ya hay supabase-setup + wire-data (u operación equivalente contra Supabase) y el usuario pide Clerk o rechaza Supabase Auth.
---

# clerk-auth-bridge

**Paso opcional (seguridad extra de identidad).** Va **después** del flujo core: tiene sentido ejecutarlo cuando la app ya persiste datos con Supabase pero quieres **Clerk** para sesiones, OAuth, SSO y UX de login — **sin** usar Supabase como proveedor de identidad principal.

PostgreSQL + RLS **siguen en Supabase**; lo que cambia es **quién firma la identidad**: Clerk emite JWT; Supabase los valida (JWKS/JWT Secret según configures) y tus políticas RLS usan `auth.jwt()` / `request.jwt.claim.sub` como antes.

## Cuándo invocarlo

- Ya existen `@/lib/supabase/{client,server}.ts`, tablas con RLS, y rutas wired (idealmente después de `/wire-data`).
- El usuario dice "no uso Supabase Auth", "quiero Clerk", "auth con Clerk pero DB en Supabase", "último paso de seguridad con Clerk".

## Cuándo **no** invocarlo (todavía)

- No existe proyecto Supabase ni `schema.sql` aplicado → primero `/supabase-setup`.
- Solo hay mocks → primero `/wire-data`.

## Principio arquitectónico

| Capa              | Responsable                          |
|-------------------|--------------------------------------|
| UI de login/session | Clerk (`@clerk/nextjs`)            |
| Base de datos + RLS | Supabase Postgres                  |
| `user_id` en filas | `profiles.id = clerk user id (text/uuid estable)` sincronizado vía webhook o primera visita |

**No intentes usar el `anon` key de Supabase como si el usuario siguiera siendo solo "anon session"**: con identidad Clerk, el cliente debe enviar JWT de Supabase generado desde Clerk (o intercambiado server-side). El patrón habitual es JWT template en Clerk + mismo `sub` persistido como `profiles.id`.

## Workflow

### Paso 0 — Decisión explícita con el usuario

Confirma en una línea:

- Postgres + migraciones siguen en Supabase (sin cambiar).
- Se desactiva o ignora login por Supabase Auth (Google/email nativo Supabase ya no será la fuente de verdad si migras rutas protegidas a Clerk).

### Paso 1 — Instalar Clerk para Next.js (App Router)

```bash
pnpm add @clerk/nextjs
```

Variables mínimas (Vercel Marketplace puede auto-provionarlas):

```bash
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
```

Si usas Middleware de rutas públicas vs protegidas, añade las URLs también en la consola de Clerk (Allowed redirect / component routes según docs actuales de Clerk).

### Paso 2 — `ClerkProvider` + middleware

- Envuelve el layout raíz con `ClerkProvider`.
- Añade `clerkMiddleware` (con `auth.protect()` en rutas privadas igual que necesite el proyecto).
- Rutas típicas: `sign-in` / `sign-up` catch-all con `<SignIn />` / `<SignUp />`.

Sigue patrones vigentes del SDK Clerk para Next.js (Core 3 / v7 si aplica tu versión instalada).

### Paso 3 — Puente JWT hacia Supabase

1. En **Clerk Dashboard**: crea un **JWT Template** dirigido a Supabase (muchas cuentas usan plantilla llamada `supabase` con claim `role: "authenticated"` y `sub` igual al usuario de Clerk).

2. En **Supabase Dashboard** → Authentication: configura proveedor JWT / JWKS compatible con ese emisor según documentación combinada Clerk + Supabase (las URLs de JWKS cambian por instancia Clerk; cópialas del dashboard).

3. Obtén JWT firmado desde el cliente o servidor mediante el template (API de Clerk: `session.getToken({ template: 'supabase' })` o equivalente en tu versión del SDK).

4. Para **consultas cliente** contra Supabase, crea un cliente Supabase que use ese token en lugar de sólo anon key donde RLS espera usuario autenticado — o mueve llamadas sensibles a **route handlers / Server Actions** que usen cliente service role sólo después de validar `auth()` de Clerk (patrón más simple el día 1).

### Paso 4 — Datos `user_id` y RLS

- Asegura tabla `profiles` (o equivalente) con PK = id de Clerk (`text` estable).
- Sincroniza en **primer login** desde Server Action usando `auth()` / `currentUser()` de Clerk, o webhook `user.created`.
- Actualiza políticas RLS si antes comparaban contra `auth.uid()` de UUID Supabase: deberían alinear claims del JWT nuevo (`sub`) con la columna `user_id`.

### Paso 5 — Migración gradual (recomendado)

1. Clerk protege rutas y provee usuario en UI.
2. Server Actions leen Clerk, escriben con validación fuerte (`user_id` = clerk id server-side verificado).
3. Cuando todas las rutas están cubiertas, retira UI de magic link OAuth puramente Supabase si existía.

### Paso 6 — Deploy (Vercel)

- Si usas Marketplace: `vercel integration add clerk` y replica env vars como en `/vercel-ship`.
- Añade todas las Clerk keys en Production + Preview igual que las de Supabase.

### Paso 7 — Commit

```bash
git add .
git commit -m "feat(auth): optional Clerk identity bridge with Supabase RLS"
```

## Qué viene después

- Verificación E2E: login Clerk → crear fila protegida → comprobar que otro usuario no la ve (`/demo-check` smoke ampliado).
- `/day-retro` si quieres anotar aprendizajes (redirect URLs Clerk + previews de Vercel suelen sorprender el día 1).

## Anti-patrones

- Confiar en `user_id` enviado por el navegador sin verificar Clerk en servidor.
- Dejar políticas RLS escritas sólo para UID nativo Supabase tras cambiar a Clerk sin revisarlas.
- Exponer `service_role` al cliente sólo porque "JWT es lío".
- Ejecutar este skill **antes** de tener Postgres + RLS; sin eso solo añades fricción.

## Referencias rápidas (consulta docs vivas)

- [Clerk + Next.js (App Router)](https://clerk.com/docs/quickstarts/nextjs)
- Integración JWT Clerk ↔ Supabase: busca la guía oficial actual "Clerk Supabase" en docs de Clerk y Supabase para los campos exactos JWKS/emisor (`iss`).

