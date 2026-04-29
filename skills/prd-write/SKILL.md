---
name: prd-write
description: Convierte una idea validada (IDEA.md) en un PRD inicial de una página — problema, usuarios, user stories, criterios de éxito, no-goals y supuestos. Produce PRD.md que el resto de la suite va a respetar como contrato. Úsalo después de idea-check, o cuando el usuario diga "PRD", "documento de producto", "qué vamos a construir", "specs", o ya tenga la idea clara y necesite escribirla.
---

# prd-write

Segundo paso del flujo. Toma `IDEA.md` y escribe un PRD inicial **de una página máximo**. No es un documento corporativo de 30 páginas; es el contrato que mantiene honesto al resto del día.

## Cuándo invocarlo

- Existe `IDEA.md` (idealmente recién pasó por `idea-check`).
- El usuario dice "vamos a documentar esto", "PRD", "specs", "qué vamos a construir exactamente".
- Antes de `scope-1day`. Sin PRD, el scope se decide a ojo.

## Tono

Amigo técnico experto que escribe PRDs ejecutables, no académicos. Una frase = una decisión clara. Cero buzzwords ("synergy", "unlock", "leverage"). Verbo activo, sujeto concreto.

## Filosofía del PRD de un día

| PRD largo (no es esto) | PRD de un día (esto sí) |
|---|---|
| "El usuario podrá realizar acciones..." | "El usuario crea una tarea con título y la marca como hecha." |
| OKRs, métricas vagas | 1 métrica de éxito clara: "shippeado a Vercel y 3 amigos lo abren hoy" |
| Roadmap de 6 meses | Día 1 + lo que queda en BACKLOG.md |
| 30 user stories | 1 user story principal + 2 secundarias máximo |

## Workflow

### Paso 0 — Cargar contexto

Lee `IDEA.md`. Si no existe:

> No veo IDEA.md. ¿Pasamos primero por `/idea-check` o me cuentas la idea en 2 frases para escribir directo?

Si no hay tiempo, acepta las 2 frases pero advierte que el PRD va a ser más débil.

### Paso 1 — Confirmar el "en una frase"

Toma el "en una frase" de `IDEA.md` y pregunta:

> El IDEA.md dice: "[frase]". ¿Sigue así o algo cambió mientras pensabas?

Lo que confirmes aquí es la primera línea del PRD. Si cambia, el resto del documento se reescribe alrededor.

### Paso 2 — Las 7 secciones (una por una)

Cada sección es 1-3 líneas. Si una se va de 5 líneas, está mal escrita.

#### 2.1 Problema (1 frase)

> ¿Qué dolor concreto resolvemos? No la solución, el dolor.

Ejemplo bueno: "Los freelancers olvidan facturar a tiempo y pierden cobros."
Ejemplo malo: "Mejorar el flujo de cobro para profesionales independientes."

#### 2.2 Usuarios (1-2 frases)

> ¿Quién específico? Edad/rol/contexto. NO "todo el mundo".

Ejemplo: "Freelancers de servicios (diseñadores, devs, consultores) que facturan menos de 10 clientes al mes y usan Excel/notas para tracking."

#### 2.3 User stories (1 principal + 2 secundarias)

Formato estricto: **Como [usuario], quiero [acción], para [beneficio].**

- **Principal** (la del wedge, lo único que entra hoy si no cabe nada más):
  > Como freelancer, quiero ver de un vistazo qué facturas vencen esta semana, para no olvidar ninguna.

- **Secundaria 1**:
  > Como freelancer, quiero marcar una factura como cobrada, para limpiar mi pendiente.

- **Secundaria 2**:
  > Como freelancer, quiero crear una nueva factura en menos de 30 segundos, para no romper mi ritmo de trabajo.

Si el usuario propone más de 3 stories, **bloquea**: "Las demás van a BACKLOG. Hoy entran 3 máximo."

#### 2.4 Criterio de éxito (1 línea, medible)

> ¿Cómo sabemos al final del día si esto valió la pena? Algo binario o un número.

Ejemplos buenos:
- "Shippeado a Vercel con URL pública y 3 amigos lo abrieron hoy."
- "Yo mismo cargo 5 facturas reales en mi propio prototipo y lo uso esta semana."
- "Mostrarlo en Demo Day del viernes sin que se rompa."

Ejemplos malos:
- "Que funcione bien." (no medible)
- "Que tenga buen feedback." (vago)

#### 2.5 No-goals (lista corta)

> ¿Qué cosas obvias **NO** entran hoy aunque parezcan tentadoras?

Ejemplo:
- No multi-usuario / equipos
- No notificaciones por email
- No exportar a PDF
- No integraciones (Stripe, Google Calendar)

Esto es tan importante como las user stories. Le da permiso al usuario de decir "no" durante el día.

#### 2.6 Supuestos / dependencias (lista corta)

> ¿Qué estamos asumiendo que tiene que ser cierto para que esto funcione?

Ejemplo:
- Asumimos que el usuario ya tiene cuenta Google (para login OAuth).
- Asumimos que máximo 50 facturas por usuario el día 1.
- Asumimos que el usuario sabe la fecha de vencimiento (no la calculamos).

#### 2.7 Stack técnico (1 línea)

> Default opinionado de la suite. Confirma o cambia.

Default:
- **Frontend**: Next.js 16 + shadcn/ui + Tailwind v4
- **Backend**: Supabase (Auth + DB + RLS)
- **Deploy**: Vercel
- **Setup base**: `npx shadcn@latest init --preset b0 --base base --template next`

Si el usuario quiere otro stack, márcalo y pasa a `scope-1day`. Pero advierte que las skills están optimizadas para este.

### Paso 3 — Validación cruzada con IDEA.md

Antes de escribir, comprueba:

- [ ] La user story principal del PRD = el wedge de IDEA.md
- [ ] El criterio de éxito del PRD ≥ el "demo de 30s" de IDEA.md
- [ ] Los no-goals del PRD incluyen lo que IDEA.md cortó

Si hay desalineación, alerta y reconcilia.

### Paso 4 — Escribir PRD.md

Una página. Si no cabe en pantalla sin scroll, está mal.

### Paso 5 — Confirmación final

> PRD listo. La user story principal es: "[X]". El criterio de éxito es: "[Y]". ¿Vamos a `/scope-1day` para meterlo en time-boxes de 8h?

## Template de PRD.md

```markdown
# PRD: [Nombre del producto]

> v0.1 — [fecha]. Generado por prd-write desde IDEA.md.

## En una frase
[Producto] para [usuarios] que resuelve [problema] reemplazando [status quo].

## Problema
[1 frase. El dolor concreto, no la solución.]

## Usuarios
[1-2 frases. Específico, no "todo el mundo".]

## User stories

### Principal (wedge del día 1)
Como [X], quiero [acción], para [beneficio].

### Secundarias
1. Como [X], quiero [acción], para [beneficio].
2. Como [X], quiero [acción], para [beneficio].

## Criterio de éxito
[1 línea medible. Binario o número.]

## No-goals (NO entran hoy)
- [item]
- [item]
- [item]

## Supuestos
- [supuesto técnico o de usuario]
- [supuesto técnico o de usuario]

## Stack
- Frontend: Next.js 16 + shadcn/ui + Tailwind v4
- Backend: Supabase (Auth + DB + RLS)
- Deploy: Vercel
- Setup: `npx shadcn@latest init --preset b0 --base base --template next`

## Próximo paso
- `/scope-1day` para descomponer en time-boxes.
```

## Qué viene después

- **Siguiente**: `/scope-1day` (lee PRD.md y lo mete en 8 horas).
- Todos los skills posteriores leen `PRD.md` como fuente de verdad. Si algo se desvía del PRD durante el día, el skill correspondiente debe alertarte.

## Anti-patrones

- PRDs de 5 páginas. Una. Si no cabe, recorta.
- User stories sin "para [beneficio]". El beneficio es lo que justifica la story.
- "Criterio de éxito: que sea bueno". Tiene que ser medible.
- Olvidar no-goals. Sin no-goals, el día se infla.
- Asumir el stack del usuario. Confírmalo (aunque el default sea fuerte).
