## Juego MTR

Repositorio: https://github.com/MTR-Miceli-Tabuada-Ritter/Juego-MTR-Miceli-Ritter-Tabuada

Se trata de un juego donde un náufrago despierta sin recordar nada y descubre que se encuentra en una isla habitada por animales que hablan. El mundo está lleno de misterios, personajes con personalidad propia y desafíos que deberán resolverse para avanzar.

El objetivo principal del juego es completar las misiones principales que te asignan los animales de la isla. Cada uno de ellos te entregará una parte de un bote, y ese bote será la herramienta que te permitirá escapar de la isla.

## Historia

Un personaje despierta en una isla desconocida, sin recuerdos de cómo llegó allí ni de su pasado. A medida que explora el entorno, descubre que los animales del lugar no son simples criaturas salvajes, sino seres que pueden hablar, interactuar y guiarlo en su aventura.

Cada animal ofrece una misión distinta, y al completarlas el protagonista obtiene una pieza esencial para construir un bote. La aventura gira en torno a la exploración, la resolución de desafíos y la superación de las pruebas que cada habitante de la isla le presenta.

## Estado del proyecto

- Estado actual: en desarrollo
- Nombre del proyecto: no consolidado todavía
- Objetivo actual: construir la base del juego, mecánicas, historia y progresión principal
- Futuras mejoras: ampliar contenido, pulir jugabilidad, mejorar narrativa y terminar la experiencia completa

## Prototipo de misiones e inventario

El Gallo ofrece tres encargos independientes: entregar tres papas cosechadas,
llevar un mensaje a la Vaca y derrotar un esqueleto. Se aceptan expresamente y se
cobran al regresar al Gallo; no se completan por abrir una conversación. Las
recompensas iniciales son 30, 20 y 20 monedas, respectivamente.

Para probar sin esperar una cosecha:

1. Abrir [tests/escena_prueba_misiones.tscn](tests/escena_prueba_misiones.tscn) en Godot 4.7.
2. Ejecutar esa escena con **F6**. Incluye tres papas y coloca al Gallo cerca del jugador.
3. Acercarse, pulsar **E**, terminar la presentación y elegir un encargo.
4. Aceptar y entregar las papas; para el mensaje, hablar con la Vaca sobre el
	encargo y escuchar su respuesta. Para la derrota, aceptar **antes** de atacar
	al esqueleto con **K**.
5. Volver al Gallo para cobrar. **R** reinicia únicamente esta escena de prueba.

La partida normal no regala papas ni acepta misiones automáticamente. La barra
rápida muestra diez posiciones de un inventario de treinta; la selección por
rueda o teclas **1–0**, el uso, la cosecha y la venta trabajan sobre el modelo.
Los objetos fuera de la barra cuentan para entregas, aunque la pantalla de
mochila completa queda pendiente. Una cosecha sin espacio permanece en el mundo.

Las misiones son recursos de `Mision` compuestos por objetivos; no se crea una
subclase por encargo. Los tipos actuales son `ObjetivoEntregarItems`,
`ObjetivoHablarConNPC` y `ObjetivoDerrotarEnemigos`. Definiciones y progreso están
separados. Ver [PLAN_PARA_MISIONES.md](PLAN_PARA_MISIONES.md) y el
[ejemplo de objetivos combinados](recursos/misiones/ejemplo_combinada.tres).

### Pruebas automáticas

Desde la raíz, ejecutar `godot --headless --editor --path . --import` para importar
los recursos y luego `godot --headless --path . --script res://tests/run_tests.gd`.
Reemplazar `godot` por la ruta del ejecutable instalado si no está en el PATH.
El [ejecutor](tests/run_tests.gd) devuelve un código distinto de cero ante fallos.
Comprueba inventario, recompensas atómicas, objetivos múltiples, eventos de
combate, conversaciones y la escena real con entrega durante la pausa.

Inventario y misiones sobreviven a un cambio de escena dentro de la partida,
pero **todavía no se guardan al cerrar el juego**. Para una partida nueva,
reiniciar los servicios mediante `iniciar_nueva_partida()` y recrear la escena
del mundo; cambiar de vista por sí solo no reinicia el progreso.

## Objetivo principal

Completar las misiones que te entregan los animales, reunir cada una de las partes del bote y lograr escapar de la isla.

## Nota

Este juego aún está en fase de creación y puede sufrir cambios significativos en diseño, nombre, mecánicas y contenido durante su desarrollo.

## Integrantes

- Miceli
- Ritter
- Tabuada
- González Parodi

## Profesor

- Beitia
