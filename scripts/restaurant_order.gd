extends RefCounted
class_name RestaurantOrder

enum OrderState { PENDING, IN_PROGRESS, DONE, LEAVES }

var table_id: int = 0
var item_count: int = 1

var state: OrderState = OrderState.PENDING
var quality: float = 0.0

var patience: float = 8.0      # total seconds the customer waits
var patience_left: float = 8.0 # seconds remaining

func was_served_on_time() -> bool:
	return patience_left >= patience * 0.5
