class_name RecompensaItem
extends Resource
## Contenido del editor; cada intercambio crea sus propios ItemStack temporales.

@export var item: Item
@export var cantidad: int = 1


func es_valida() -> bool:
	return item != null and not item.id.strip_edges().is_empty() and item.max_stack > 0 and cantidad > 0


func crear_stack() -> ItemStack:
	return ItemStack.new(item, cantidad)