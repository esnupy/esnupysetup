---
name: ui-approve
description: Gate visual obligatorio entre maquetar (ui-mockup) y construir backend (schema-sketch + supabase-setup + wire-data). Recorre el mockup pantalla por pantalla con el usuario, captura ajustes pequeños y solo cuando el usuario diga "está bien" desbloquea la fase de backend. Produce UI-APPROVAL.md. Úsalo después de ui-mockup, o cuando el usuario diga "ya quedó la UI", "se ve bien", "aprobado", "vamos al backend".
---

# ui-approve

Séptimo paso. 30 minutos. **Es el gate más importante del flujo.** Sin un "sí, esto es lo que quería ver" del usuario, ningún skill de backend arranca. Esto evita el escenario clásico: backend hecho, UI cambia, todo se rehace.

## Cuándo invocarlo

- `ui-mockup` terminó (todas las pantallas de `FLOW.md` con mock data en local).
- El usuario dice "ya quedó la UI", "se ve bien", "vamos al backend", "aprobado".
- Antes de invocar `/schema-sketch`, `/supabase-setup` o `/wire-data`. Si alguien intenta saltárselo, **bloquea**.

## Tono

Amigo técnico que quiere proteger las próximas 3 horas del usuario. Honesto: si la UI no termina de convencer, **no apruebes** aunque el usuario presione. La frase clave:

> Mejor 20 minutos de ajustes ahora que 2 horas rehaciendo queries después porque la UI cambió.

## Filosofía del gate

| Sin gate | Con gate |
|---|---|
| Backend hecho con shape X | Backend hecho con shape EXACTO de la UI aprobada |
| UI cambia → queries cambian → tipos cambian | UI ya está congelada, queries la sirven |
| Día se infla 50% por rework | Día respeta los time-boxes |

## Workflow

### Paso 0 — Cargar contexto

Lee `FLOW.md`, `SCOPE.md`, los TS interfaces en `src/types/index.ts`, los archivos de `src/lib/mock/`. Asegura que `pnpm run dev` está corriendo (o sugiere arrancar).

### Paso 1 — Recorrer pantalla por pantalla con el browser MCP

Usa `cursor-ide-browser` para abrir `http://localhost:3000` y, **una pantalla a la vez** (orden: pantalla wow primero, después las demás):

1. Toma screenshot del estado base.
2. Toma screenshot del estado empty (si aplica — borra mock data temporal o usa una ruta sin datos).
3. Toma screenshot del estado loading (refresca y captura el skeleton).
4. Ejecuta la acción principal de la pantalla, toma screenshot del resultado.
5. Captura cualquier estado de error que provoques a propósito.

Pega los screenshots en el chat con el usuario.

### Paso 2 — Las 5 preguntas del gate

Para cada pantalla (una por una con `AskQuestion`):

1. **¿Esto es lo que esperabas ver?**
   - Sí, exactamente
   - Casi, con ajustes pequeños
   - No, falta algo importante
   - No, replantear

2. **¿La jerarquía visual lleva la mirada al elemento correcto?**
   - Sí
   - Más o menos (qué cambiarías)
   - No

3. **¿Los textos/labels suenan natural en español (o en el idioma definido)?**
   - Sí
   - No, hay copy raro: [...]

4. **¿Los empty/loading/error states son creíbles?**
   - Sí
   - El empty se siente vacío (no en buen sentido)
   - El loading no se ve (mock muy rápido)
   - Otro

5. **(Solo en la pantalla wow)** ¿Esta pantalla pasa el screenshot test? ¿La mostrarías en redes sin retoques?
   - Sí
   - Casi, falta [...]
   - No

### Paso 3 — Capturar ajustes pequeños (timebox 20 min)

Si hay ajustes "pequeños" (copy, spacing, color de un badge, ordenar una lista distinto), hazlos AHORA con `ui-mockup` mental — pero limitados a 20 minutos total. Reglas:

- **Sí ahora**: copy, padding/margin, ordenar, esconder/mostrar campo, cambiar variant de un componente shadcn.
- **No ahora (va a BACKLOG)**: añadir nueva pantalla, añadir nuevo campo a TS interface, animaciones complejas, refactorizar layout completo.

Si los ajustes pasan de 20 min, **detente** y pregunta al usuario si quiere:
- A) Aceptar la UI actual como mockup aprobado y seguir al backend
- B) Volver a `/ui-mockup` con la lista de cambios pendientes
- C) Recortar más en `/scope-1day` porque el wedge se está inflando

### Paso 4 — Validar TS interfaces

Recorre con el usuario los interfaces de `src/types/index.ts`:

> Estos son los datos que el backend va a tener que devolver: [lista de interfaces].
>
> ¿Falta algún campo que la UI necesita pero no estamos mockeando? ¿Hay algún campo de más?

Si añade/quita campos, **actualiza interfaces y mock data** antes de aprobar. El backend va a derivar de aquí.

### Paso 5 — La aprobación explícita

Solo después de que las 5 preguntas estén verdes y los TS interfaces validados, pide la aprobación literal:

> Para desbloquear la fase de backend necesito un "sí, apruebo" explícito. Si dices que sí, los siguientes skills (`/schema-sketch`, `/supabase-setup`, `/wire-data`) van a derivar la DB y queries de los TS interfaces de arriba. Después no es trivial cambiar shapes.
>
> ¿Apruebas?

`AskQuestion`:
- **Sí, apruebo. Vamos al backend.**
- No todavía. Quiero seguir ajustando UI.
- No. Hay algo grande que replantear.

### Paso 6 — Escribir UI-APPROVAL.md

Solo si fue **Sí**. Documenta lo aprobado, los ajustes que se hicieron, y el shape de los TS interfaces que el backend tiene que servir.

### Paso 7 — Desbloquear backend

> ✅ UI aprobada. Backend desbloqueado.
>
> Próximo: `/schema-sketch` — va a leer los TS interfaces aprobados y proponer las tablas Supabase que los sirven exactamente.

## Template de UI-APPROVAL.md

```markdown
# UI Approval

> Generado por ui-approve el [fecha]. Lee FLOW.md para contexto.

## Estado: APROBADA ✅

## Pantallas validadas
- [ ] /login — empty/loading/error OK, copy OK
- [ ] /dashboard (WOW) — pasa screenshot test, wow detail funciona
- [ ] /tasks/[id] — OK
- [ ] ...

## Ajustes hechos durante el gate (≤20 min)
- Cambiamos copy del CTA de "Crear" a "+ Nueva tarea"
- Bajamos el padding del header de 8 a 6
- Reordenamos columnas de la tabla: title, status, date

## TS interfaces aprobados (contrato del backend)

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

## Lo que va a BACKLOG (no ahora)
- Animación entre estados de status
- Editar título inline

## Próximo paso desbloqueado
- /schema-sketch (deriva tablas de los TS interfaces de arriba)
```

## Si la respuesta NO es aprobado

- **"No todavía, ajustar"** → vuelve a `/ui-mockup` con la lista. No avances al backend.
- **"No, replantear"** → vuelve a `/flow-sketch`. Posiblemente `/scope-1day` si el cambio es grande.

## Qué viene después (solo si aprobado)

- **Siguiente**: `/schema-sketch` (con UI-APPROVAL.md como contrato).
- Después: `/supabase-setup` y `/wire-data`.

## Anti-patrones

- Aprobar "porque ya tomó tiempo". El sunk cost es la peor razón. Si la UI no convence, no apruebes.
- Saltar la validación de TS interfaces. Sin esto, el schema no matchea y `/wire-data` se inventa cosas.
- Hacer ajustes de >20 min en este paso. Si pasa, devuelve a `/ui-mockup`.
- Permitir que `/schema-sketch` se invoque sin que exista `UI-APPROVAL.md`. El skill mismo lo va a verificar; tú no lo sugieras antes.
- Aprobar para que el usuario "se sienta bien". Tu trabajo es proteger sus próximas 3 horas, no su ego.
