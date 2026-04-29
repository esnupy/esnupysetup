# Contribuir a esnupysetup

Gracias por tomarte el tiempo. Esta suite mejora con cada prototipo que alguien construye con ella.

## Tres formas de contribuir

### 1. Reportar que una skill falló

Abre un [issue](https://github.com/esnupy/esnupysetup/issues/new) con:

- Qué skill invocaste
- Qué le pediste exactamente (copia el mensaje)
- Qué hizo
- Qué esperabas que hiciera
- Versión de Cursor + sistema operativo

Sin esto no puedo reproducir. Con esto, en general arreglo en el día.

### 2. Mejorar una skill existente

Si descubriste un patrón mejor, abre un PR con:

- El cambio en el `SKILL.md` correspondiente
- **Una frase explicando el por qué** del cambio en la descripción del PR
- Un ejemplo concreto de cuándo el patrón viejo fallaba

Cambios bienvenidos:
- Anti-patrones que faltaban
- Plantillas más limpias
- Triggers que mejoran la auto-invocación
- Reducir verbosidad sin perder contexto

Cambios que probablemente no acepte:
- Hacer las skills agnósticas de stack (ese no es el objetivo)
- Suavizar el tono "amigo técnico" a algo corporativo
- Romper el orden del flujo (mock-first es ley)
- Añadir 5 opciones donde había 1 default fuerte

### 3. Proponer una skill nueva

Antes de escribirla, abre un issue describiendo:

- Qué problema resuelve que las 13 actuales no
- En qué fase del flujo entraría
- Qué artefacto produciría y qué skill(s) la consumirían

Si tiene sentido, hablamos del diseño antes de que escribas código.

## Filosofía de las skills (lo que les da consistencia)

Cualquier contribución debe respetar:

1. **<500 líneas de SKILL.md**. Si necesita más, va a `reference.md`.
2. **Tono de amigo técnico experto** — firme pero amable, cero emojis innecesarios, cero jerga corporativa.
3. **Frontmatter con `name` + `description`** — la description debe incluir QUÉ hace y CUÁNDO dispara, en español, con triggers naturales.
4. **Cada skill produce o consume un artefacto** (`IDEA.md`, `PRD.md`, etc.). Sin artefactos no hay flujo.
5. **Una skill, un trabajo.** Si hace dos cosas, son dos skills.
6. **Defaults opinionados, no opciones infinitas.** Si hay 5 formas de hacer algo, propones la mejor y mencionas la alternativa solo si tiene sentido.

## Setup local para desarrollar

```bash
git clone https://github.com/esnupy/esnupysetup.git ~/.cursor/esnupysetup
cd ~/.cursor/esnupysetup
bash install.sh
```

Esto crea symlinks de `~/.cursor/skills/<skill>` → `~/.cursor/esnupysetup/skills/<skill>`. Cualquier cambio que hagas en el repo es inmediato en Cursor sin reinstalar.

Para probar tus cambios, abre cualquier proyecto en Cursor y dispara la skill que modificaste.

## Compartir tus prototipos

Si construiste algo cool con la suite, mándame el link (issue, X, lo que sea). Los casos reales son lo que más ayuda a otros a entender qué se puede hacer en un día.
