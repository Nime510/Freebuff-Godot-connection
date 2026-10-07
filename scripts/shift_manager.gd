extends Node
class_name ShiftManager

signal shift_started
signal round_ended(summary: Dictionary)

@export var shift_length: float = 60.0 # seconds per shift

var cash: float = 200.0
var reputation: float = 0.5 # 0.0 .. 1.0
var shift_number: int = 1
var shift_active: bool = false

var time_left: float = 0.0
var served_count: int = 0
var lost_count: int = 0
var quality_sum: float = 0.0

func start_shift() -> void:
	time_left = shift_length
	served_count = 0
	lost_count = 0
	quality_sum = 0.0
	shift_active = true
	shift_started.emit()

func _process(delta: float) -> void:
	if not shift_active:
		return
	time_left -= delta
	if time_left <= 0.0:
		end_shift()

func add_served(order: RestaurantOrder, quality: float) -> void:
	if not shift_active:
		return
	var tip: float = quality * 12.0
	if order.was_served_on_time():
		tip *= 1.3
	cash += 8.0 + tip
	quality_sum += quality
	served_count += 1
	reputation = clamp(reputation + (quality - 0.5) * 0.03, 0.0, 1.0)

func add_lost() -> void:
	if not shift_active:
		return
	lost_count += 1
	reputation = max(0.0, reputation - 0.05)

func end_shift() -> void:
	shift_active = false
	var avg: float = 0.0
	if served_count > 0:
		avg = quality_sum / served_count
	var summary := {
		"shift_number": shift_number,
		"cash": cash,
		"reputation": reputation,
		"served": served_count,
		"lost": lost_count,
		"quality_avg": avg,
	}
	shift_number += 1
	round_ended.emit(summary)
