---
name: day-retro
description: Cierre del día — compara SCOPE.md con lo que realmente shippeaste, captura aprendizajes para el siguiente prototipo y produce RETRO.md. Última pregunta forzosa "¿alguien usó el demo en las próximas 24h?". Úsalo después de vercel-ship, o cuando el usuario diga "ya terminé", "retro", "qué aprendí", "cierro el día".
---

# day-retro

Décimo y último paso. 15-30 minutos. Hace que el día-1 se vuelva mejor el próximo. Sin retro, los mismos errores se repiten cada prototipo.

## Cuándo invocarlo

- Hay deploy en producción (existe URL en `DEMO.md` o el usuario la confirma).
- El usuario dice "ya terminé", "retro", "cierro", "qué aprendí".
- Al final del día independientemente de si shippeó (también si fracasó).

## Tono

Amigo técnico reflexivo. Honesto sin ser cruel. Una pregunta a la vez. Resiste el impulso de saltar al "qué hacemos mañana" — primero entender qué pasó hoy.

## Workflow

### Paso 0 — Cargar todo el día

Lee en orden: `IDEA.md`, `SCOPE.md`, `BACKLOG.md`, `FLOW.md`, `DEMO.md`. Esto te da la película completa del día.

### Paso 1 — Compromiso vs realidad

Compara `SCOPE.md` (lo que prometiste) con lo que efectivamente shippeaste. Pregunta:

> ¿Cumpliste con la Definition of Done de SCOPE.md? Marca cada item:
>
> - [ ] Deployed en Vercel con URL pública
> - [ ] Demo de 30s funciona sin que tú expliques
> - [ ] Pasó demo-check
> - [ ] Hay BACKLOG.md con lo cortado

Sin auto-engaño. Si un check falla, está bien — es información.

### Paso 2 — Las 4 preguntas de retro

Una por una con `AskQuestion` cuando aplique:

#### 1. Time-boxes — ¿qué se desbordó?

> Mira los time-boxes de SCOPE.md. ¿Cuál bloque te tomó más de lo esperado y por qué?

Patrones comunes y sus aprendizajes:

- Schema desbordado → falta práctica con RLS. Notar para el próximo.
- ui-mockup desbordado → demasiadas pantallas. `flow-sketch` debe cortar más.
- wire-data desbordado → TS interfaces que no matcheaban DB. Validar más en `schema-sketch`.
- Vercel deploy desbordado → faltó configurar redirect URLs en Supabase antes. Anotar como pre-flight.

#### 2. Cuándo te desviaste del wedge

> ¿En algún momento empezaste a construir algo que no estaba en SCOPE.md? ¿Qué fue y por qué?

Si la respuesta es "no", celebrar. Si la respuesta es "sí", entender por qué (aburrimiento, idea nueva, parecía rápido) — es señal para el próximo `scope-1day`.

#### 3. Qué hizo "wow" o no hizo

> El wow detail que definiste en FLOW.md, ¿realmente generó "wow" cuando lo viste terminado o se quedó tibio?

Si no generó wow, anotar qué SÍ hubiera generado wow. Esto entrena el siguiente `flow-sketch`.

#### 4. La pregunta forzosa — ¿alguien lo va a usar?

> En las próximas 24 horas, ¿quién va a abrir el demo y darte feedback? Nombre, no "alguien".

Si la respuesta es "nadie todavía", el día-1 fue un ejercicio técnico, no un prototipo. Está bien decirlo, pero confróntalo.

### Paso 3 — Los 3 aprendizajes accionables

Pide al usuario destilar en 3 bullets:

> Sin pensarlo mucho, dame 3 cosas concretas que harías diferente el próximo día-1.

Buenos ejemplos:

- "El próximo día-1 corto a 3 pantallas máximo, no 5."
- "Voy a tener un repo template ya con shadcn instalado, ahorra 30 min."
- "El smoke test en preview va antes de configurar custom domain."

Malos ejemplos (genéricos, descártalos):

- "Mejor planificación."
- "Empezar más temprano."
- "Más enfoque."

### Paso 4 — Para el día siguiente

Si va a haber día 2 (continuar el mismo proyecto):

> Mira BACKLOG.md. ¿Qué item es el siguiente wedge? Ese es el `IDEA.md` del día 2.

Si no va a haber día 2 (siguiente prototipo distinto):

> ¿Qué aprendiste de éste que cambia cómo piensas el siguiente?

### Paso 5 — Escribir RETRO.md

Documenta todo arriba en formato accionable.

### Paso 6 — Capturar el patrón (opcional)

Si emergió un aprendizaje que aplica a TODOS los prototipos (no solo a éste), proponle al usuario:

> Este aprendizaje aplica más allá de este proyecto. ¿Lo añadimos como nota a una de las skills (ej. `scope-1day`) para que el próximo proyecto lo herede automáticamente?

Si dice sí, edita el SKILL.md correspondiente con una nota concreta. Esto hace que la suite mejore con cada uso.

### Paso 7 — Cierre

> Día-1 cerrado. Demo en [URL]. 3 aprendizajes guardados en RETRO.md.
>
> Mejor cierre que un commit es probarlo: comparte la URL con [persona] hoy mismo.

## Template de RETRO.md

```markdown
# RETRO día-1: [proyecto]

> Generado por day-retro el [fecha]. Lee SCOPE.md, DEMO.md para contexto.

## Compromiso vs realidad
- [ ] Deployed en Vercel — [✅/❌] [URL]
- [ ] Demo 30s funciona sin explicar — [✅/❌]
- [ ] Pasó demo-check — [✅/❌]
- [ ] BACKLOG.md actualizado — [✅/❌]

## Time-boxes
| Bloque | Estimado | Real | Por qué |
|---|---|---|---|
| Schema | 1h | 1h | OK |
| Flow UI | 0.5h | 1.5h | Demasiadas pantallas, ajusté en vivo |
| ... | | | |

## Desvíos del wedge
- [feature no planeado] — porque [...]

## Wow real vs wow plan
- Plan: [wow detail de FLOW.md]
- Real: [pasó / no pasó / fue otra cosa]

## Pregunta forzosa
- ¿Quién lo va a usar en 24h? [nombre concreto / nadie]

## 3 aprendizajes accionables
1. [...]
2. [...]
3. [...]

## Próximo paso
- [ ] Día 2 con [feature de BACKLOG]
- [ ] Otro prototipo distinto
- [ ] Hablar con [usuario] hoy

## Patrón capturado en skill
- Editado: [skill] — añadida nota sobre [...]
```

## Qué viene después

Eres el último skill. Después de ti:

- El usuario debería tener su URL pública lista para compartir.
- El siguiente día-1 debería ser mejor que éste.
- Si hubo aprendizaje universal, alguna skill de la suite mejoró permanentemente.

## Anti-patrones

- Saltarse la retro porque "el demo funciona". El valor compounding de la retro es lo que hace que el día-30 valga la pena.
- Aprendizajes vagos ("mejor planificación"). Si no es accionable, no es aprendizaje.
- No nombrar a la persona que va a probar el demo. "Alguien" = nadie.
- Editar 5 skills de golpe. Una mejora puntual por retro, máximo.
