extends Node2D
class_name CustomerSpawner

signal order_spawned(order: RestaurantOrder)

@export var min_interval: float = 1.5
@export var max_interval: float = 3.0

var manager: ShiftManager
var _timer: float = 0.0
var _next: float = 2.0

func _ready() -> void:
	manager = get_parent().get_node("ShiftManager")

func _process(delta: float) -> void:
	if manager == null or not manager.shift_active:
		return
	_timer += delta
	if _timer < _next:
		return
	_timer = 0.0
	_next = randf_range(min_interval, max_interval)

	var order := RestaurantOrder.new()
	order.item_count = 1 + (1 if randf() < 0.3 else 0)
	order.patience = randf_range(7.0, 10.0)
	order.patience_left = order.patience
	order_spawned.emit(order)
