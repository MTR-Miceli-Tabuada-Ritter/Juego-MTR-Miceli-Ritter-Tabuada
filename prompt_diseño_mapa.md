# Prompt: Diseño de mapa en Godot 4 con los assets del proyecto

## Contexto del juego
- Motor: **Godot 4**
- Tamaño de tile: **32×32 píxeles** (todos los assets ya escalados desde 16×16)
- Vista: **top-down 2D**
- Nodo de mapa: `TileMap` con capas separadas (suelo, decoración, colisiones)

---

## Assets disponibles — Rutas relativas desde `res://`

> Base: `res://recursos/assetPack/`

---

### 🌿 Cute_Fantasy_Free — Mundo exterior estilo fantasía

#### Tiles de suelo
| Archivo | Descripción |
|---|---|
| `Cute_Fantasy_Free/Tiles/Grass_Middle.png` | Tile de césped (relleno) |
| `Cute_Fantasy_Free/Tiles/Water_Middle.png` | Tile de agua (relleno) |
| `Cute_Fantasy_Free/Tiles/Path_Middle.png` | Tile de camino (relleno) |
| `Cute_Fantasy_Free/Tiles/Beach_Tile.png` | Bordes de playa / arena |
| `Cute_Fantasy_Free/Tiles/Cliff_Tile.png` | Acantilados / escalones |
| `Cute_Fantasy_Free/Tiles/FarmLand_Tile.png` | Tierra de cultivo |
| `Cute_Fantasy_Free/Tiles/Path_Tile.png` | Bordes de camino |
| `Cute_Fantasy_Free/Tiles/Water_Tile.png` | Bordes de agua |

#### Decoración exterior
| Archivo | Descripción |
|---|---|
| `Cute_Fantasy_Free/Outdoor decoration/Outdoor_Decor_Free.png` | Hoja de decoraciones variadas |
| `Cute_Fantasy_Free/Outdoor decoration/Oak_Tree.png` | Árbol de roble grande |
| `Cute_Fantasy_Free/Outdoor decoration/Oak_Tree_Small.png` | Árbol de roble pequeño |
| `Cute_Fantasy_Free/Outdoor decoration/Fences.png` | Vallas / cercas |
| `Cute_Fantasy_Free/Outdoor decoration/Bridge_Wood.png` | Puente de madera |
| `Cute_Fantasy_Free/Outdoor decoration/House_1_Wood_Base_Blue.png` | Casa de madera azul |
| `Cute_Fantasy_Free/Outdoor decoration/Chest.png` | Cofre |

#### Animales
| Archivo | Descripción |
|---|---|
| `Cute_Fantasy_Free/Animals/Chicken/Chicken.png` | Pollo (spritesheet animado) |
| `Cute_Fantasy_Free/Animals/Cow/Cow.png` | Vaca (spritesheet animado) |
| `Cute_Fantasy_Free/Animals/Pig/Pig.png` | Cerdo (spritesheet animado) |
| `Cute_Fantasy_Free/Animals/Sheep/Sheep.png` | Oveja (spritesheet animado) |

#### Enemigos
| Archivo | Descripción |
|---|---|
| `Cute_Fantasy_Free/Enemies/Skeleton.png` | Esqueleto (spritesheet animado) |
| `Cute_Fantasy_Free/Enemies/Slime_Green.png` | Slime verde (spritesheet animado) |

#### Personaje jugador
| Archivo | Descripción |
|---|---|
| `Cute_Fantasy_Free/Player/Player.png` | Jugador principal (spritesheet) |
| `Cute_Fantasy_Free/Player/Player_Actions.png` | Acciones del jugador (spritesheet) |

---

### 🌾 Farm RPG FREE 16x16 — Mundo granja / primavera

#### Tileset de suelo
| Archivo | Descripción |
|---|---|
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Tileset/Tileset Spring.png` | Tileset completo de primavera (césped, tierra, agua, bordes) |

#### Objetos y decoración
| Archivo | Descripción |
|---|---|
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/House.png` | Casa de granja |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/Interior.png` | Tiles de interior |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/Maple Tree.png` | Árbol de arce |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/Fence's copiar.png` | Vallas de granja |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/Road copiar.png` | Camino de tierra |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/Spring Crops.png` | Cultivos de primavera |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Objects/chest.png` | Cofre de granja |

#### Animales de granja
| Archivo | Descripción |
|---|---|
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Farm Animals/Baby Chicken Yellow.png` | Pollito amarillo |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Farm Animals/Chicken Blonde  Green.png` | Gallina rubia/verde |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Farm Animals/Chicken Red.png` | Gallina roja |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Farm Animals/Female Cow Brown.png` | Vaca hembra marrón |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Farm Animals/Male Cow Brown.png` | Vaca macho marrón |

#### Personaje granjero
| Archivo | Descripción |
|---|---|
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Character/Idle.png` | Personaje en reposo |
| `Farm RPG FREE 16x16 - Tiny Asset Pack/Character/Walk.png` | Personaje caminando |

---

### 🏚️ ForgottenMemories — Mundo oscuro / bosque

| Archivo | Descripción |
|---|---|
| `ForgottenMemories/TileSet.png` | Tileset de bosque/oscuro (suelo, muros) |
| `ForgottenMemories/Trees.png` | Árboles del bosque (hoja completa) |
| `ForgottenMemories/Trees_seperated.png` | Árboles separados (uso individual) |
| `ForgottenMemories/Props.png` | Props / decoraciones del entorno |
| `ForgottenMemories/WaterTiles-6frames.png` | Agua animada (6 frames) |

---

### ⚔️ Tilesets generales

| Archivo | Descripción |
|---|---|
| `Overworld_Tileset.png` | Tileset overworld completo (césped, caminos, agua, bordes) |
| `Dungeon_Tileset.png` | Tileset de mazmorra (muros, suelo, escaleras) |

---

### 🧙 Personaje principal (Char_Sprites)

> Todos en: `Char_Sprites/Char_Sprites_Alone/`  
> También disponible como hoja completa: `Char_Sprites/char_spritesheet.png`

Animaciones disponibles (formato `anim_strip_N`):
- `idle` — up / down / left / right (6 frames)
- `run` — up / down / left / right (6 frames)
- `attack` — up / down / left / right (6 frames)
- `hit` — up / down / left / right (3 frames)
- `death` — all_dir (10 frames)
- `falling` — all_dir (6 frames)
- `climbing_up` / `climbing_down` (6 frames)
- `pushing` — up / down / left / right (6 frames)
- `shielded_hit` — up / down / left / right (5 frames)
- `shielded_static` — up / down / left / right (estático)

---

### 👾 Enemigos (Enemies_Sprites)

| Carpeta | Enemigo | Animaciones |
|---|---|---|
| `Enemies_Sprites/Bomberplant_Sprites/` | Planta bomba | idle, attack, hit, death + bomba (going_up/down, explosion, hit_marker) |
| `Enemies_Sprites/Phantom_Sprites/` | Fantasma | idle, run, hit, death (left/right) |
| `Enemies_Sprites/Pinkbat_Sprites/` | Murciélago rosa | idle, run_attack, hit, death (left/right) |
| `Enemies_Sprites/Pinkslime_Sprites/` | Slime rosa | idle, run, hit, death (all_dir) |
| `Enemies_Sprites/Spider_Sprites/` | Araña | idle, run, hit, death (all_dir) |
| `Enemies_Sprites/Spinner_Sprites/` | Spinner | idle, run_attack, hit, death (all_dir) + hitting_wall_fx |

> Cada enemigo también tiene una hoja completa `*_spritesheet.png`.

---

### ✨ Props e ítems animados (Props_Items_(animated))

| Archivo | Descripción |
|---|---|
| `Props_Items_(animated)/bonfire_prop_lit_anim_strip_5.png` | Fogata encendida |
| `Props_Items_(animated)/torch_prop_anim_strip_5.png` | Antorcha animada |
| `Props_Items_(animated)/plant_prop_anim_cut_strip_6.png` | Planta cortable |
| `Props_Items_(animated)/vase_prop_anim_broken_strip_6.png` | Vasija rompible |
| `Props_Items_(animated)/lootchest_item_anim_strip_8.png` | Cofre de botín (cerrado) |
| `Props_Items_(animated)/lootchest_item_anim_opening_strip_5.png` | Cofre abriéndose |
| `Props_Items_(animated)/lootchest_item_static_open.png` | Cofre abierto estático |
| `Props_Items_(animated)/crystal_item_anim_strip_6.png` | Cristal flotando |
| `Props_Items_(animated)/crystal_item_anim_collected_strip_5.png` | Cristal al recolectar |
| `Props_Items_(animated)/key_item_anim_strip_6.png` | Llave animada |
| `Props_Items_(animated)/key_item_collected_anim_strip_6.png` | Llave al recolectar |
| `Props_Items_(animated)/health_potion_item.png` | Poción de vida |

---

### 🌊 Tiles animados (Tiles_(animated))

#### Mazmorra
| Archivo | Descripción |
|---|---|
| `Tiles_(animated)/Dungeon/spikes_tile_trap_anim_strip_12.png` | Trampa de pinchos |
| `Tiles_(animated)/Dungeon/broken_tile_fallingdown_anim_strip_9.png` | Tile roto que cae |
| `Tiles_(animated)/Dungeon/door_tile_locked_opening_anim_strip_10.png` | Puerta con llave |
| `Tiles_(animated)/Dungeon/iron_gate_opening_anim_strip_8.png` | Reja de hierro abriéndose |
| `Tiles_(animated)/Dungeon/iron_gate_closing_anim_strip_8.png` | Reja de hierro cerrándose |

#### Overworld
| Archivo | Descripción |
|---|---|
| `Tiles_(animated)/Overworld/water_tile_anim_strip_8.png` | Agua animada (tile base) |
| `Tiles_(animated)/Overworld/edge_water_tile_anim_strip_8.png` | Borde de agua animado |
| `Tiles_(animated)/Overworld/waterplant_tile_anim_strip_8.png` | Planta acuática animada |
| `Tiles_(animated)/Overworld/regia_waterplant_tile_anim_strip_8.png` | Planta acuática grande |

---

### 🖥️ HUD / Interfaz (Hud_Ui)

| Archivo | Descripción |
|---|---|
| `Hud_Ui/health_bar_hud.png` | Barra de vida |
| `Hud_Ui/health_hud.png` | Corazones de vida |
| `Hud_Ui/item_box_hud.png` | Caja de ítem equipado |
| `Hud_Ui/select_icon_ui.png` | Ícono de selección |

---

## Instrucciones para diseñar el mapa

Sos un asistente de diseño de niveles para un juego RPG top-down 2D en Godot 4.
Usando **exclusivamente** los assets listados arriba (todos con tiles de 32×32 px),
diseñá un mapa de mundo exterior que incluya:

1. **Capa 0 — Suelo base**: usá `Grass_Middle.png` o `Tileset Spring.png` como base.
2. **Capa 1 — Transiciones**: bordes de agua, playa y caminos con `Beach_Tile`, `Water_Tile`, `Path_Tile`, `Cliff_Tile`.
3. **Capa 2 — Decoración**: árboles (`Oak_Tree`, `Maple Tree`), vallas (`Fences`), cultivos (`Spring Crops`), props animados (antorchas, fogatas).
4. **Capa 3 — Estructuras**: casas (`House`, `House_1_Wood_Base_Blue`), puentes (`Bridge_Wood`), cofres.
5. **Capa 4 — Colisiones** (invisible): marcá colisiones en árboles, muros, agua y estructuras.
6. **Ubicación de NPCs/Animales**: usá los spritesheets de `Animals/` y `Farm Animals/` como `AnimatedSprite2D`.
7. **Ubicación de enemigos**: usá los spritesheets de `Enemies_Sprites/` con `CharacterBody2D`.
8. **Ítems coleccionables**: `crystal_item`, `key_item`, `health_potion` como `Area2D`.

Para cada zona del mapa, indicá:
- Qué tileset usar como base
- Qué props decorativos colocar
- Qué enemigos spawnear y con qué densidad
- Qué ítems pueden dropearse o estar escondidos
