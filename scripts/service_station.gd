extends Node2D
class_name ServiceStation

signal order_started(order: RestaurantOrder)
signal order_finished(order: RestaurantOrder, quality: float)

func can_accept(order: RestaurantOrder) -> bool:
	return order.state == RestaurantOrder.OrderState.PENDING

func start_order(order: RestaurantOrder) -> void:
	if not can_accept(order):
		return
	order.state = RestaurantOrder.OrderState.IN_PROGRESS
	order_started.emit(order)

func finish_order(order: RestaurantOrder, quality: float) -> void:
	if order.state != RestaurantOrder.OrderState.IN_PROGRESS:
		return
	order.state = RestaurantOrder.OrderState.DONE
	order.quality = clamp(quality, 0.0, 1.0)
	order_finished.emit(order, order.quality)
