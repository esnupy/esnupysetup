---
name: shadcn-init
description: Hace scaffold del proyecto usando `npx shadcn@latest init --preset b0 --base base --template next` para arrancar con Next.js 16 + shadcn ya configurados, refuerza TS strict, estructura feature-based y deja todo listo para maquetar con mock data. Úsalo después de scope-1day, o cuando el usuario diga "scaffold", "iniciar repo", "crear proyecto", "arrancar el código".
---

# shadcn-init

Cuarto paso del flujo. 30 minutos. Crea el repo con el preset oficial de shadcn (b0 + base + Next), aplica tus opiniones de TS strict y estructura feature-based, y deja el repo listo para que `/ui-mockup` empiece a maquetar inmediatamente.

## Cuándo invocarlo

- Existe `PRD.md` y `SCOPE.md`.
- El usuario dice "scaffold", "crear proyecto", "iniciar repo", "vamos a empezar a codear".
- No hay `package.json` o sí hay pero está vacío.

## Tono

Amigo técnico ejecutivo. Pocas preguntas, decisiones por defecto fuertes. Solo pregunto lo que de verdad varía proyecto a proyecto (nombre, ubicación).

## Comando central

```bash
npx shadcn@latest init --preset b0 --base base --template next
```

Esto trae:
- Next.js 16 con App Router
- TypeScript
- Tailwind con el theme/preset b0 (tokens base)
- shadcn ya inicializado (registry conectado, `components.json` listo)
- Components base instalados según el preset

Después aplicamos tus opiniones encima.

## Workflow

### Paso 0 — Preguntas mínimas

Usa `AskQuestion`:

1. **Nombre del proyecto** (kebab-case, sin scope `@org`).
2. **Ubicación**: cwd actual | crear carpeta nueva en cwd | otro path.
3. **Package manager**: pnpm (default) | npm | bun.
4. **Git**: inicializar nuevo repo | usar el actual | sin git.

### Paso 1 — Crear carpeta y entrar

```bash
mkdir -p <ruta>/<nombre>
cd <ruta>/<nombre>
```

### Paso 2 — Correr el preset b0

```bash
npx shadcn@latest init --preset b0 --base base --template next
```

Si el wizard hace preguntas interactivas, contesta defaults. Si pide nombre, usa el del paso 0.

Espera a que termine. Verifica que existen:
- `package.json`
- `next.config.ts`
- `app/` o `src/app/`
- `components.json`
- `components/ui/` con los componentes base del preset

### Paso 3 — Reforzar TS strict

Edita `tsconfig.json` para garantizar:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true
  }
}
```

Si el preset ya los trae, no toques. Si no, añádelos.

### Paso 4 — Estructura feature-based

Si el preset usó `src/`, parte de ahí. Si no, trabaja en root `app/`. Crea las carpetas vacías que el resto de la suite va a llenar:

```
src/   (o root, según preset)
├── app/                   (lo que trajo el preset)
├── components/
│   ├── ui/                (lo que trajo shadcn)
│   └── shared/            ← nuevo
├── features/              ← nuevo, una carpeta por feature
│   └── .gitkeep
├── lib/
│   ├── mock/              ← nuevo, mock data vive aquí
│   └── utils.ts
└── types/
    └── .gitkeep
```

Crea `.gitkeep` en las carpetas vacías para que git las trackee.

### Paso 5 — Primer mock data placeholder

Crea `src/lib/mock/index.ts` con un comentario:

```ts
// Mock data para la fase /ui-mockup.
// Cuando /wire-data corra, este archivo desaparece o se reemplaza por queries reales.
export {};
```

Esto le da a `/ui-mockup` un lugar canónico donde escribir sus mocks.

### Paso 6 — `.env.example` mínimo

Crea `.env.example` (committeado) y `.env.local` (en `.gitignore`):

```bash
# .env.example
# Vacío en esta fase. /supabase-setup va a llenar esto cuando aprobemos la UI.
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

### Paso 7 — Levantar dev y verificar

```bash
pnpm install   # o npm/bun según paso 0
pnpm run dev
```

Confirma con el usuario:

> Levantó en http://localhost:3000 con el preset b0. ¿Lo ves bien?

Si hay errores del preset (versión, dependencia rara), repórtalos y arregla aquí. No avances roto.

### Paso 8 — Primer commit

Si git está activo:

```bash
git add .
git commit -m "chore: scaffold con shadcn init --preset b0 + estructura feature-based"
```

### Paso 9 — Confirmar siguiente

> Repo listo. Próximo: `/flow-sketch` para definir las pantallas, después `/ui-mockup` para maquetar con mock data. Cero backend hasta que apruebes la UI.

## Qué viene después

- **Siguiente**: `/flow-sketch` (qué pantallas, qué componentes shadcn).
- Luego: `/ui-mockup` (maquetar todo con mock data, sin tocar Supabase).

## Anti-patrones

- Editar el preset b0 a mano antes de que termine. Espera al "OK" del comando, después modificas.
- Instalar dependencias del backend (supabase) en este paso. **No**. Esto es solo frontend mock-first.
- Romper la estructura del preset solo para imponer la tuya. Si el preset usa `src/`, respétalo. Si no, déjalo en root.
- Saltar `pnpm run dev` para verificar. Si el scaffold está roto, mejor saberlo aquí.
- Hacer commit con `node_modules/` o `.env.local`. Verifica `.gitignore` antes.
