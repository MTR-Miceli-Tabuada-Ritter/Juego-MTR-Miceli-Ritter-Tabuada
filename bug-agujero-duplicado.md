# Bug: Agujeros duplicados en el mismo tile

## ¿Qué pasaba?

El jugador podía crear más de un agujero en el mismo tile del suelo.
Esto solo ocurría cuando se acercaba desde un **ángulo diferente** al que usó la primera vez.
Si lo intentaba desde el mismo ángulo, el juego lo bloqueaba correctamente.

---

## ¿Por qué pasaba?

Antes de crear un agujero, el código chequeaba si ya existía uno en ese lugar.
Para eso, le daba un **nombre único** a cada agujero basado en su posición en el mundo:

```gdscript
# Código con el bug
var nombreAgujero = "agujero_" + str(int(round(global_position.x))) + "_" + str(int(round(global_position.y)))
```

El problema está en cómo se obtenía esa posición.
La función que mueve el marcador de vista al tile de enfrente usa varias conversiones matemáticas:

```
posición del jugador → coordenadas del tile → centro del tile → posición en el mundo
```

Cada vez que se hace este cálculo, el resultado es un número con decimales (float).
Y aunque el tile sea **el mismo**, las conversiones pueden dar resultados ligeramente distintos según el ángulo de llegada:

- Desde el sur: `x = 160.00001`
- Desde el este: `x = 159.99999`

Esa diferencia mínima hacía que `round()` redondeara de forma distinta:
- `round(160.00001)` → `160`
- `round(159.99999)` → `160` ← en este caso da igual, pero con otros valores:
- `round(160.50001)` → `161`
- `round(160.49999)` → `160` ← ¡nombres distintos para el mismo tile!

Resultado: el nombre generado era diferente, el juego **no encontraba** el agujero existente, y creaba uno nuevo encima.

---

## ¿Cómo se arregló?

En vez de usar la posición en el mundo (float), se usa directamente la **coordenada del tile** (entero):

```gdscript
# Código corregido
var pos_tile = tilemap.local_to_map(tilemap.to_local(direccionVistaMarker.global_position))
var nombreAgujero = "agujero_" + str(pos_tile.x) + "_" + str(pos_tile.y)
```

`pos_tile` es un `Vector2i`, es decir, dos números enteros que identifican la columna y fila del tile en la grilla.
Los enteros **no tienen decimales ni problemas de redondeo**, así que el nombre del agujero siempre es el mismo para el mismo tile, sin importar desde qué dirección llegue el jugador.

---

## Resumen rápido

| | Antes (bug) | Después (fix) |
|---|---|---|
| Nombre basado en | Posición mundial (float) | Coordenada de tile (entero) |
| Problema | Redondeo inconsistente por floats | No aplica, son enteros exactos |
| Resultado | Agujeros duplicados | Un solo agujero por tile ✓ |
