extends CanvasLayer
class_name MainMenu

@onready var cash_label: Label = $CashLabel
@onready var rep_label: Label = $RepLabel
@onready var shift_label: Label = $ShiftLabel
@onready var result_label: Label = $ResultLabel
@onready var start_button: Button = $StartButton

var manager: ShiftManager

func _ready() -> void:
	manager = get_parent().get_node("ShiftManager")
	manager.round_ended.connect(_on_round_ended)
	start_button.pressed.connect(_on_start_pressed)
	_show_values(manager.cash, manager.reputation, manager.shift_number)
	result_label.text = "First shift — let's go!"

func _on_start_pressed() -> void:
	visible = false
	manager.start_shift()

func _on_round_ended(summary: Dictionary) -> void:
	_show_values(
		summary["cash"],
		summary["reputation"],
		summary["shift_number"]
	)
	result_label.text = "Served %d  |  Walked out %d  |  Avg quality %d%%" % [
		int(summary["served"]),
		int(summary["lost"]),
		int(summary["quality_avg"] * 100.0),
	]
	visible = true

func _show_values(cash: float, rep: float, shift: int) -> void:
	cash_label.text = "Cash: $%d" % int(cash)
	rep_label.text = "Reputation: %d%%" % int(rep * 100.0)
	shift_label.text = "Shift: %d" % shift
