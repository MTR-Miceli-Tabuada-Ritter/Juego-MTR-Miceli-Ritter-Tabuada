# Plan para el sistema de misiones

## Estado de implementación — 29/10/2026

Se implementó la base de las etapas 1 a 4 descritas abajo:

- [Inventario](globales/inventario/inventario.gd) independiente de treinta posiciones,
  con apilamiento, sobrantes explícitos e intercambios atómicos.
- [InventarioJugador](globales/inventario/inventario_jugador.gd) como propietario
  de los datos, la selección y el dinero; la barra rápida es una vista.
- [Mision](globales/misiones/mision.gd), [ObjetivoMision](globales/misiones/objetivo_mision.gd),
  sus tres subtipos, [MisionActiva](globales/misiones/mision_activa.gd) y
  [GestorMisiones](globales/misiones/gestor_misiones.gd).
- Tres encargos jugables del Gallo: papas (30 monedas), conversación con la Vaca
  (20) y derrota de un esqueleto (20). El ejemplo combinado se prueba automáticamente,
  pero no se ofrece como cuarto encargo en el juego.
- Emisión de muerte única, atribución al jugador y conversaciones mediante hitos.
- Cargas de regadera separadas de la cantidad de objetos y visibles en su espacio.
- [Escena manual de prueba](tests/escena_prueba_misiones.tscn), para ejecutar con F6,
  y [pruebas automáticas](tests/run_tests.gd) sobre modelos y escenas reales.

No se implementaron las ampliaciones de la etapa 5: guardado, diario, pantalla de
mochila completa, piezas del bote y nuevas reglas de progresión. El soporte de
recompensas de objetos sí está disponible y probado, aunque los encargos iniciales
usan dinero. La capacidad inicial elegida es treinta y se puede configurar.

Las secciones siguientes conservan la propuesta original como referencia de diseño;
la «situación actual» de su sección 2 describe el punto de partida anterior a estos cambios.

## 1. Propósito y alcance

Este documento describe el diseño y la hoja de ruta del sistema.
La primera prueba será una misión del Gallo que pide tres papas, pero el sistema no
debe asumir que todas las misiones consisten en entregar objetos.

Debe permitir, con la misma estructura:

- Entregar objetos: «Traeme tres papas».
- Derrotar enemigos: «Derrotá a cinco zombis».
- Hablar con personajes: «Andá a hablar con la Vaca».
- Combinar varios objetivos en una misión.
- Agregar otros tipos más adelante, como visitar una zona o realizar una cosecha.

El inventario es una base importante del diseño: debe poder almacenar los objetos
del jugador independientemente de los diez espacios visibles de la barra rápida.

## 2. Situación actual del proyecto

| Área | Situación actual | Consecuencia para el plan |
| --- | --- | --- |
| Objetos | [Item](globales/items/item.gd) define identificador, apilamiento y comportamiento; [ItemStack](globales/items/item_stack.gd) mantiene objeto y cantidad. | Reutilizar estas clases, sin convertir cada objeto en una misión. |
| Inventario | [La interfaz](escenas/interfaz/interfaz.gd) guarda los objetos en diez nodos de espacios y agrega las cosechas. | Separar almacenamiento y presentación. |
| Selección | [El selector](globales/selectorSlot.gd) guarda en la escena principal una referencia al nodo visual seleccionado. | Reemplazar gradualmente esa dependencia por una selección del modelo de inventario. |
| Venta | [La tienda](escenas/tienda/tienda.gd) resta directamente del `ItemStack` seleccionado y refresca su nodo visual. | Hacer que venta, uso y entrega pasen por una API común. |
| Diálogos | Los NPC usan Dialogue Manager; la tienda ya pasa su contexto y llama métodos desde el diálogo. | Aprovechar condiciones y acciones existentes, sin modificar el complemento. |
| Salud | [El componente de salud](escenas/saludComponente.gd) emite `danio_recibido` y elimina al padre cuando llega a cero. | Hace falta una notificación específica de muerte, no contar golpes como derrotas. |
| Ataques | [Ataque](escenas/ataque.gd) contiene daño, empuje y posición, pero no identifica al responsable. | Definir atribución de la derrota antes de contar enemigos para una misión. |
| Estado del juego | [La escena principal](escenas/escenaPrincipal/escena_principal.gd) administra fecha, dinero y selección. | No agregar toda la lógica de misiones a esta escena. |
| Pausa | [PausaDialogo](globales/pausaDialogo.gd) pausa el árbol durante las conversaciones. | Las acciones de aceptar y entregar deben funcionar también durante esa pausa. |

El plan no supone que ya exista un guardado de partida. Su implementación queda
para una etapa posterior, pero los datos deben prepararse para poder guardarlos.

## 3. Cambio principal respecto de la propuesta inicial

`Mision` no debe tener como estructura obligatoria `item_id` y `cantidad_requerida`.
Esos datos pertenecen exclusivamente a un objetivo de entrega.

La separación propuesta es:

1. **Definición de misión:** contenido diseñado en el editor.
2. **Definición de objetivo:** qué debe ocurrir para satisfacer cada requisito.
3. **Estado de misión y objetivos:** qué hizo el jugador en esta partida.
4. **Gestión de misiones:** aceptación, eventos, consultas, finalización y recompensas.
5. **Servicios del juego:** inventario, diálogos y combate, sin depender de la interfaz.

Las definiciones son recursos compartibles que se tratan como inmutables durante
la partida. Los contadores y estados nunca se escriben en esos recursos.

## 4. Modelo de datos propuesto

### 4.1. `Mision`: definición estática

Recurso personalizado de Godot con:

- `id`: identificador único y estable.
- `titulo` y `descripcion`.
- `npc_otorgante_id`: quién ofrece la misión.
- `npc_receptor_id`: con quién se finaliza; puede ser el mismo personaje.
- `objetivos`: lista de definiciones de `ObjetivoMision`.
- `recompensas`: definiciones de dinero u objetos, separadas de los objetivos.

Primera regla de composición: **todos los objetivos son obligatorios y pueden
resolverse en cualquier orden**. No implementar todavía objetivos opcionales,
alternativas, etapas secuenciales ni un editor de grafos.

### 4.2. `ObjetivoMision`: definición extensible

Recurso base con `id` y descripción. Los identificadores de objetivos son únicos
dentro de su misión. Cada subtipo agrega únicamente los campos que necesita:

| Tipo | Datos específicos | Cómo se evalúa |
| --- | --- | --- |
| `ObjetivoEntregarItems` | `item_id`, cantidad requerida. | Consulta existencias actuales; consume objetos al finalizar. |
| `ObjetivoDerrotarEnemigos` | Tipo o etiqueta del enemigo, cantidad requerida. | Acumula derrotas válidas desde que se aceptó la misión. |
| `ObjetivoHablarConNPC` | `npc_id`, identificador de conversación o hito. | Registra que se alcanzó el punto de diálogo indicado. |

Cada tipo tendrá su propia política de evaluación y tratamiento de eventos.
Agregar un tipo nuevo puede requerir código nuevo para ese comportamiento, pero
no debe obligar a agregar campos específicos de ese tipo a `Mision`.

No usar un objetivo «genérico» lleno de campos opcionales como sustituto de esta
separación. Tampoco permitir que cada objetivo reparta premios por su cuenta.

### 4.3. `MisionActiva`: registro de la partida

Objeto de ejecución independiente, por ejemplo `RefCounted`, con:

- Referencia a la definición o su identificador.
- Estado de la misión.
- Progreso por identificador de objetivo.
- Datos necesarios para evitar procesar dos veces un mismo evento, cuando corresponda.

El progreso de cada objetivo se guarda aparte de su definición: contador de
derrotas, conversación realizada, etc. Las entregas consultan el inventario y no
guardan una copia de sus cantidades.

Aunque se llame `MisionActiva`, su registro se conserva al finalizar para recordar
que ya se completó y evitar recompensas repetidas. Si ese nombre resulta confuso,
se puede llamar `EstadoMision` antes de implementar; es el mismo rol.

### 4.4. `GestorMisiones`: autoridad del sistema

Autoload registrado en [la configuración del proyecto](project.godot), con catálogo
de definiciones y un diccionario de registros por `mision_id`. No limitarlo a una
única variable de misión activa: distintas misiones podrán coexistir.

Responsabilidades:

- Validar identificadores y definiciones antes de usarlos.
- Aceptar una misión una sola vez.
- Aplicar eventos únicamente a objetivos de misiones activas.
- Consultar progreso y disponibilidad de finalización.
- Coordinar consumo de objetos, cambio de estado y recompensas.
- Emitir notificaciones una vez que los datos estén consistentes.
- Reiniciar su estado al comenzar una partida nueva.

API orientativa, todavía no implementada:

- `aceptar_mision(mision_id) -> bool`.
- `obtener_estado(mision_id)`.
- `obtener_progreso(mision_id)`.
- `puede_finalizar(mision_id, npc_id) -> bool`.
- `intentar_finalizar(mision_id, npc_id) -> bool`.
- Entradas de eventos para derrota y conversación, con datos explícitos.

Señales orientativas: `mision_aceptada`, `progreso_actualizado`,
`disponibilidad_finalizacion_cambiada` y `mision_completada`.

## 5. Estados y reglas de progreso

### 5.1. Ciclo de vida mínimo

**DISPONIBLE → ACTIVA → COMPLETADA**

- `DISPONIBLE`: existe en el catálogo y todavía no tiene registro aceptado.
- `ACTIVA`: fue aceptada, pero no se finalizó.
- `COMPLETADA`: requisitos satisfechos, objetos entregados y recompensa aplicada.

No guardar indicadores redundantes en el NPC como `misionAceptada` o
`misionCompletada`. El gestor es la única fuente de verdad.

### 5.2. «Lista para finalizar» es una consulta

No hace falta un cuarto estado persistente para la primera versión. Se calcula
si todos los objetivos están satisfechos y se cumplen las condiciones de entrega.

- **Entrega:** depende de objetos disponibles ahora. Tener tres papas y vender
  una vuelve a impedir la finalización; no se reinicia la misión.
- **Derrotas:** el progreso es histórico y no retrocede. Se limita al objetivo
  requerido para mostrar, por ejemplo, `5/5` en lugar de seguir aumentando.
- **Conversación:** queda registrada al alcanzar el hito correcto del diálogo.

Tener objetos suficientes no equivale a haberlos entregado. La interfaz puede
mostrar «Papas disponibles: 2/3»; solo se consumen al confirmar la finalización.

Si una misión pide el mismo objeto en varios objetivos, se suman sus requisitos
antes de consultar existencias. Tres papas no pueden satisfacer dos entregas de
tres papas dentro de una misma finalización.

### 5.3. Política temporal inicial

- Los objetos obtenidos antes de aceptar la misión sí sirven para una entrega.
- Derrotas y conversaciones anteriores a la aceptación no cuentan.
- No tomar `veces_hablado` ni un contador global histórico como progreso de misión.
- Sin entregas parciales en esta versión: se finaliza la misión completa.
- Si dos misiones piden papas, ambas pueden parecer listas; al completar una se
  consumen las papas y se reevalúa la otra. No hay reservas automáticas.
- Una derrota puede contar para varias misiones activas compatibles. No se consume
  el evento; esta es una decisión de diseño explícita para la primera versión.

## 6. Integración por tipo de objetivo

### 6.1. Entregar objetos

Consultar el inventario completo por `Item.id`, no la barra rápida ni el objeto
que el jugador tenga seleccionado. Validar nuevamente al confirmar, aunque el
diálogo ya haya comprobado los requisitos al abrirse.

### 6.2. Derrotar enemigos

Agregar una señal de muerte que se emita una sola vez al pasar de vivo a muerto,
antes de eliminar el nodo. `danio_recibido` no es suficiente: un enemigo puede
recibir varios golpes y aún seguir vivo.

La notificación debe identificar el tipo de enemigo, la instancia o evento y al
responsable de la derrota. El código del enemigo traduce la muerte del componente
de salud a un evento del juego; el componente de salud no necesita conocer misiones.

Definir la atribución mediante información del ataque o de su propietario. La
primera regla propuesta es contar únicamente derrotas atribuibles al jugador.
No contar eliminación por cambio de escena, limpieza de nodos ni muerte de NPC.

Ignorar notificaciones repetidas de la misma muerte. No usar posiciones del mundo
como identificadores. Si más adelante se guarda progreso entre sesiones, habrá
que definir también identificadores persistentes; el ID temporal de un nodo no basta.

### 6.3. Hablar con un personaje

Emitir un evento al llegar a una línea, acción o final de rama relevante, con
`npc_id` y `conversacion_id`. No contar simplemente apretar interactuar o abrir el
globo: el jugador puede abandonar antes de terminar la conversación requerida.

No registrar todos los cierres de diálogo indiscriminadamente. La conversación
que ofrece una misión tampoco cumple automáticamente otro objetivo de hablar
con ese personaje: debe alcanzar expresamente el hito configurado tras aceptarla.

Los NPC adaptan los eventos al gestor; el diálogo no manipula diccionarios de
progreso ni decide premios. Mantener sincronizadas y seguras las acciones durante
la pausa; no depender de `_process()` para confirmar una misión.

## 7. Inventario real: almacenamiento separado de la interfaz

### 7.1. Modelo y propietario

Proponer un modelo `Inventario`, independiente de nodos visuales, con posiciones
y pilas de objetos. Un autoload `InventarioJugador` mantiene una instancia de ese
modelo por partida y ofrece acceso a sus operaciones.

El modelo puede ser `RefCounted` y reutilizar `ItemStack`. No guardar el inventario
activo como un recurso compartido de contenido ni conservar referencias a nodos
de interfaz como si fueran objetos del jugador.

- `Item` sigue siendo la definición compartida del tipo de objeto.
- `ItemStack` contiene cantidades de ejecución, propiedad del inventario.
- La capacidad es configurable y no está limitada a los diez espacios visibles.
- Definir una capacidad inicial al implementar; «inventario completo» no implica
  almacenamiento infinito. Cualquier límite debe tener un comportamiento explícito.
- Cerrar una ventana o cambiar una escena visual no elimina los objetos.
- Una partida nueva reinicia inventario y misiones; un autoload no equivale a guardado.

### 7.2. Barra rápida y mochila

La barra rápida será una vista de diez posiciones del inventario, no otro almacén
con copias de los mismos objetos. Para empezar puede mostrar sus primeras diez
posiciones. La futura pantalla de mochila mostrará el resto del mismo modelo.

La selección debe identificar una posición del modelo. Mover, consumir o agotar
su pila actualiza la selección y las vistas; nunca debe quedar un `slotEnUso`
apuntando a un nodo destruido ni a una copia desactualizada de la pila.

El diseño admite después accesos rápidos reasignables sin duplicar existencias.
Los cofres podrían tener otras instancias de `Inventario`, pero las misiones
consultarán solo el del jugador hasta definir expresamente otra política.

### 7.3. API mínima y contratos

| Operación propuesta | Contrato |
| --- | --- |
| `contar_item(item_id)` | Suma existencias válidas en todo el inventario del jugador. |
| `agregar_item(item, cantidad)` | Completa pilas compatibles, abre nuevas respetando `max_stack` y devuelve el sobrante. |
| `intentar_quitar_item(item_id, cantidad)` | Quita exactamente esa cantidad o no modifica nada si no alcanza. |
| `intentar_quitar_items(requisitos)` | Valida requisitos agregados y los retira juntos o no retira ninguno. |
| `obtener_stack(indice)` | Permite consultar una posición; las modificaciones pasan por el modelo. |
| `inventario_cambiado` | Notifica cambios confirmados para refrescar vistas y reevaluar entregas. |

Usar identificadores estables para comparar tipos, validar cantidades positivas y
limpiar pilas consumibles agotadas. Los métodos de alto nivel no deben depender
del comportamiento de `ItemStack.quitar()`, que por sí solo no prueba que alcanzara.

No perder sobrantes: hoy la recolección devuelve después de intentar agregar a
la primera pila coincidente y no procesa el sobrante de `ItemStack.agregar()`.
La nueva API debe devolver lo que no entra para que quien recolecta lo conserve
en el mundo o informe la falta de espacio, en vez de descartarlo silenciosamente.

Revisar también los usos actuales de `cantidad` como carga de herramientas, como
la regadera: no confundir cargas con unidades entregables. Separar durabilidad o
cargas del conteo de objetos cuando se amplíe ese comportamiento.

### 7.4. Migración gradual

1. Crear el modelo y trasladar allí la inicialización temporal de objetos.
2. Hacer que los espacios existentes muestren sus posiciones del modelo.
3. Adaptar recolección y resolver explícitamente el sobrante.
4. Adaptar selección, uso de herramientas y semillas, y venta a la misma API.
5. Eliminar escrituras directas de cantidades desde la interfaz y los NPC.
6. Conectar misiones al modelo, sin rutas como `/root/escenaPrincipal/interfaz`.
7. Agregar más adelante la ventana completa de mochila y la reorganización visual.

No es necesario terminar esa ventana para probar la misión. Sí es importante
establecer primero el almacenamiento independiente para no construir el sistema
de misiones encima de los diez nodos actuales.

## 8. Finalización y recompensas sin duplicaciones

`intentar_finalizar()` será la única operación autorizada para cerrar una misión:

1. Verificar que existe, está activa y el NPC receptor es el correcto.
2. Verificar objetivos históricos y agregar todos los requisitos de entrega.
3. Comprobar existencias y viabilidad de las recompensas antes de modificar datos.
4. Confirmar juntos el consumo, el estado completado y las recompensas.
5. Emitir notificaciones después de dejar todo consistente.

Esta operación no debe tener esperas entre validación y confirmación. Si falla
una condición, no consume objetos, no cambia el estado y no entrega premios.
Bloquear la reentrada mientras se confirma y rechazar una misión ya completada.

Para el prototipo usar dinero, aprovechando `agregarPlata()` mediante un punto de
integración explícito. No crear todavía piezas del bote solo para probar la entrega.

Cuando haya recompensas de objetos, simular primero el espacio disponible después
de consumir los requisitos. Política inicial propuesta: si no entra toda la
recompensa, rechazar la finalización sin cambios y avisar al jugador. No eliminar
requisitos para después descubrir que el premio no entra.

## 9. Primera misión: tres papas para el Gallo

Definición propuesta:

- `id`: `gallo_papas`.
- Otorgante y receptor: `gallo`.
- Un `ObjetivoEntregarItems`: `cultivo_2`, cantidad `3`.
- Recompensa: cantidad pequeña de dinero, a definir al implementar.
- Recurso existente: [papa cosechada](recursos/items/cultivo_2.tres).
- Las semillas de papa, `semilla_2`, no cuentan.

| Situación | Diálogo y acción |
| --- | --- |
| Disponible | «¿Me traés tres papas?»; aceptar o dejar para después. |
| Activa, faltan objetos | Recordatorio con la cantidad disponible, sin consumir nada. |
| Activa, requisitos satisfechos | Opción de entregar o conservar los objetos. |
| Confirmación correcta | Consumir tres, aplicar recompensa y agradecer. |
| Completada | Diálogo de agradecimiento sin volver a premiar. |

Conservar la introducción existente del Gallo separada del estado de la misión.
Rechazar la oferta no la acepta ni la bloquea. Evitar que el diálogo anuncie éxito
sin consultar el resultado real de la operación de finalización.

## 10. Etapas de implementación

### Etapa 1: base del inventario

- Modelo, propietario por partida y API con cantidades y sobrantes explícitos.
- Adaptación de los diez espacios actuales como vista, sin una mochila nueva aún.
- Recolección, selección, uso y venta sin mutaciones directas desde la interfaz.

### Etapa 2: núcleo de misiones

- Definiciones `Mision` y `ObjetivoMision` con sus tipos concretos.
- Registros de ejecución separados y catálogo con IDs validados.
- Gestor, transiciones, señales y finalización segura.
- Objetivo de entrega conectado al inventario completo.

### Etapa 3: prueba del Gallo

- Crear la definición de tres papas y conectar aceptación y entrega al diálogo.
- Mostrar recordatorio y agradecimiento según el gestor.
- Mantener dinero como premio inicial y comprobar la operación durante la pausa.

### Etapa 4: validar la generalidad

- Una misión de hablar con la Vaca, ligada a un hito concreto del diálogo.
- Una misión de derrotas con enemigos de prueba: señal de muerte, atribución y
  protección contra duplicados antes de conectar su objetivo.
- Una misión con objetivos combinados, sin agregar campos específicos a `Mision`.
- Varias misiones activas simultáneamente y requisitos de objetos compartidos.

Estas pruebas demuestran que el diseño no es un sistema de entregas renombrado.

### Etapa 5: ampliaciones posteriores

- Ventana de inventario completo, movimiento de objetos y accesos rápidos.
- Diario de misiones y notificaciones visuales de progreso.
- Guardado conjunto de inventario, misiones y recompensas ya confirmadas.
- Recompensas de objetos y partes del bote.
- Objetivos nuevos, etapas, prerrequisitos, plazos, fracaso o repetición si el juego
  los necesita; no implementarlos preventivamente en el prototipo.

Para guardar en el futuro: IDs de misión y objetivo, estado, progreso e inventario
con cantidades e identificadores de objeto. No serializar nodos de UI ni editar
recursos de definición para guardar la partida.

## 11. Comprobaciones de aceptación

### Inventario y entrega

- Con cero o dos papas, no se consume nada ni se entrega premio.
- Con tres, se retiran exactamente tres y se limpian las pilas agotadas.
- Con cinco, quedan dos; también funciona con las papas repartidas entre pilas.
- Se cuentan objetos fuera de la barra rápida y se excluyen semillas.
- Vender o consumir una papa antes de confirmar vuelve a bloquear la entrega.
- Inventario lleno o pila llena no ocasionan pérdida silenciosa de cosechas.
- Abrir o cerrar la interfaz no crea, elimina ni duplica objetos.

### Misiones y eventos

- Aceptar dos veces no crea registros duplicados; completar dos veces no paga dos veces.
- Las misiones pueden tener uno o varios objetivos y coexistir sin compartir su progreso.
- Dos entregas del mismo objeto se suman antes de consumir.
- La muerte cuenta una vez; los golpes no cuentan como derrotas.
- Derrotas anteriores a aceptar no cuentan, ni eliminaciones por limpieza de escena.
- Hablar con otro NPC o abandonar antes del hito requerido no cumple el objetivo.
- Las conversaciones anteriores a aceptar no satisfacen la misión de hablar.
- Un mismo recurso de definición no acumula progreso entre partidas o registros.
- Aceptar y entregar funcionan durante la pausa del diálogo, sin esperar un fotograma.
- Una partida nueva limpia los datos; cambiar de vista no reinicia la misión.

## 12. Decisiones pendientes de contenido

La arquitectura propuesta no depende de cerrar ahora estas decisiones:

- Forma de ampliar la mochila; la capacidad inicial implementada es treinta.
- Balance definitivo de los premios; el prototipo usa 30/20/20 monedas.
- Ajustes narrativos de los encargos; la Vaca ya tiene un hito de conversación concreto.
- Más enemigos y reposición de enemigos; el prototipo usa el esqueleto existente.
- Diseño visual del diario y de la mochila completa.

Las clases implementadas y su alcance se indican al principio de este documento.
Los complementos de terceros permanecen sin modificaciones.