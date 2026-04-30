---
name: vercel-ship
description: Deploya el prototipo a Vercel — conecta el repo, configura env vars desde Supabase, valida build, hace smoke test en producción y entrega URL pública. Úsalo después de demo-check, o cuando el usuario diga "deploy", "subir", "vercel", "publicar", "ya quiero la URL".
---

# vercel-ship

Noveno paso. 30 minutos. Lleva el prototipo a una URL pública. Sin sorpresas: env vars listas, build verde, smoke test pasa.

## Cuándo invocarlo

- `demo-check` dijo READY (o PUSH ANYWAY).
- Hay repo Git con commits limpios.
- El usuario dice "deploy", "ya quiero la URL", "publicar".

## Tono

Amigo técnico ejecutivo. Pocas preguntas, ejecuta. Solo bloqueas si hay algo que va a explotar en producción (env var faltante, secret en el repo, etc.).

## Pre-flight checklist (corre en orden, no saltes)

- [ ] `git status` limpio (todo commiteado).
- [ ] `pnpm run build` pasa en local sin warnings críticos.
- [ ] `.env.local` está en `.gitignore`.
- [ ] No hay secrets hardcoded en el código (`grep -r "sb_secret\|service_role" src/`).
- [ ] `package.json` tiene `engines.node` definido (recomendado: `">=20"`).

Si algo falla, **alto** y arregla.

## Workflow

### Paso 0 — Cargar contexto

Lee `SCOPE.md` y `DEMO.md`. Identifica las env vars necesarias (Supabase URL + anon key como mínimo).

### Paso 1 — GitHub remote

Si el repo no tiene remote o no está pusheado:

```bash
gh repo create <nombre> --private --source=. --remote=origin --push
```

Pregunta `--public` vs `--private` (default: private para prototipos).

Si ya tiene remote, asegura que está pusheado:

```bash
git push -u origin main
```

### Paso 2 — Vercel CLI

Verifica:

```bash
which vercel || pnpm add -g vercel
vercel whoami || vercel login
```

### Paso 3 — Link del proyecto

Desde la raíz del repo:

```bash
vercel link
```

Pregunta scope si tiene varios. No deployes todavía.

### Paso 4 — Cargar env vars

Toma las del `.env.local` y súbelas a Vercel para `production`, `preview` y `development`:

```bash
vercel env add NEXT_PUBLIC_SUPABASE_URL production
# pega valor
vercel env add NEXT_PUBLIC_SUPABASE_URL preview
vercel env add NEXT_PUBLIC_SUPABASE_URL development

vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY production
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY preview
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY development
```

Si el proyecto tiene **Clerk** (vía `/clerk-auth-bridge`), también en los tres ambientes:

- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`
- `CLERK_SECRET_KEY`
- (y cualquier URL pública tipo `NEXT_PUBLIC_CLERK_SIGN_IN_URL` si las usáis — ver skill Clerk)

Si hay `SUPABASE_SERVICE_ROLE_KEY` y se usa server-side, súbela solo a `production` y `preview`. **Nunca** a `development` (riesgo de leak).

Alternativa más rápida si todo el `.env.local` es válido:

```bash
vercel env pull .env.local  # invertido: confirmar que las vars locales están
# o subir manualmente desde el dashboard
```

### Paso 5 — Deploy preview

Antes de production:

```bash
vercel
```

Esto crea un deploy preview. Espera la URL.

### Paso 6 — Smoke test del preview

Usa el browser MCP para abrir el preview URL y recorrer el happy path completo. Verifica:

- [ ] Login funciona (si aplica). **Supabase Auth**: agrega el preview URL a "Site URL" o "Additional Redirect URLs". **Clerk**: permite el dominio de preview en Allowed origins / redirects (ver consola Clerk).
- [ ] Acción wow funciona y persiste (verifica en DB con Supabase MCP `execute_sql`).
- [ ] No hay errores en consola del browser.

Si falla por redirect URL de Supabase, añádela y re-deploya.

### Paso 7 — Deploy production

```bash
vercel --prod
```

Espera URL. Confirma con el usuario.

### Paso 8 — Configurar Supabase Auth para producción

Si hay auth, agrega la URL de production a:

- Supabase Dashboard → Authentication → URL Configuration → Site URL = `https://<tu-app>.vercel.app`
- Additional Redirect URLs: `https://<tu-app>.vercel.app/auth/callback`

Esto no es automatizable vía MCP — instruye al usuario.

### Paso 9 — Smoke test final en producción

Mismo recorrido que paso 6, pero contra la URL `--prod`. Si pasa, declara victoria.

### Paso 10 — Entrega

Comunica al usuario:

> 🎉 Live en https://<url>.vercel.app
>
> - Repo: [GitHub URL]
> - Vercel project: [URL del dashboard]
> - Tablas Supabase: [N]
>
> Próximo: `/day-retro` para cerrar el día con aprendizajes.

## Patrones útiles

### Custom domain

Si el usuario tiene dominio:

```bash
vercel domains add <domain.com>
vercel alias <deployment-url> <domain.com>
```

### Rollback rápido

Si production se rompe, el deploy anterior aún está. Desde el dashboard, "Promote to Production" en el deploy verde anterior. O CLI:

```bash
vercel promote <deployment-url> --prod
```

### Logs

```bash
vercel logs <deployment-url> --follow
```

## Qué viene después

- **Siguiente y final del día típico**: `/day-retro` (cierra el día con qué aprendiste).
- Si aún falta puente de identidad con Clerk: después de tener datos en producción, `/clerk-auth-bridge`.

## Anti-patrones

- Subir el service role key a `development` env. Riesgo de leak.
- Saltar el preview deploy. El smoke test en preview es donde encuentras los redirect URL faltantes.
- Olvidar agregar la URL de prod a Supabase Auth (si usas ese proveedor). Con Clerk omite esta regla pero configura igual los dominios de prod/preview en Clerk.
- Deployar con `git status` sucio. Lo que está en local no es lo que va a producción.
- Usar `vercel deploy --prod` la primera vez. Siempre preview primero.
