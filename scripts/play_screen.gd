extends CanvasLayer
class_name PlayScreen

@onready var feedback: Label = $Feedback

var manager: ShiftManager
var spawner: CustomerSpawner
var station: ServiceStation

var queue: Array[RestaurantOrder] = []
var current: RestaurantOrder = null
var grabbed: bool = false

func _ready() -> void:
	feedback = get_node_or_null("Feedback")
	manager = get_parent().get_node("ShiftManager")
	spawner = get_parent().get_node("Spawner")
	station = get_parent().get_node("Station")

	spawner.order_spawned.connect(_on_order_spawned)
	manager.shift_started.connect(_on_shift_started)
	manager.round_ended.connect(_on_round_ended)
	feedback.text = "Press Start Shift"

func _on_shift_started() -> void:
	queue.clear()
	current = null
	grabbed = false
	feedback.text = "SPACE grab order | LEFT cut corners | RIGHT do it properly"

func _on_round_ended(_summary: Dictionary) -> void:
	queue.clear()
	current = null
	grabbed = false

func _on_order_spawned(order: RestaurantOrder) -> void:
	queue.append(order)

func _process(delta: float) -> void:
	if manager == null or not manager.shift_active:
		return

	# patience for queued orders
	var i := queue.size() - 1
	while i >= 0:
		var o: RestaurantOrder = queue[i]
		o.patience_left -= delta
		if o.patience_left <= 0.0:
			queue.remove_at(i)
			manager.add_lost()
			feedback.text = "Customer left!  Reputation %d%%" % int(manager.reputation * 100)
		i -= 1

	# patience for the order being made
	if grabbed and current != null:
		current.patience_left -= delta
		if current.patience_left <= 0.0:
			current = null
			grabbed = false
			manager.add_lost()
			feedback.text = "Customer walked away mid-order!"

func _unhandled_input(event: InputEvent) -> void:
	if manager == null or not manager.shift_active:
		return
	if event.is_action_pressed("ui_accept"):
		_grab()
	elif event.is_action_pressed("ui_left"):
		_serve_cut()
	elif event.is_action_pressed("ui_right"):
		_serve_quality()

func _grab() -> void:
	if grabbed or queue.is_empty():
		return
	current = queue.pop_front()
	station.start_order(current)
	grabbed = true
	feedback.text = "LEFT = cut corners (fast, low quality)   RIGHT = do it properly"

func _serve_cut() -> void:
	if not grabbed or current == null:
		return
	var q: float = randf_range(0.2, 0.4)
	station.finish_order(current, q)
	manager.add_served(current, q)
	feedback.text = "CUT! Quality %d%%  |  $%d" % [int(q * 100), int(manager.cash)]
	current = null
	grabbed = false

func _serve_quality() -> void:
	if not grabbed or current == null:
		return
	var q: float = randf_range(0.75, 0.95)
	station.finish_order(current, q)
	manager.add_served(current, q)
	feedback.text = "QUALITY! Quality %d%%  |  $%d" % [int(q * 100), int(manager.cash)]
	current = null
	grabbed = false
