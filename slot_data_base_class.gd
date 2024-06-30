extends Resource
class_name SlotData


const MAX_QUANTITY = 99
@export var item : Item
@export_range(0, MAX_QUANTITY) var quantity : int = 0 : set = set_quantity


func set_quantity(value : int):
	if item:
		if item.stackable:
			quantity = value
		if item.stackable == false and value > 1:
			quantity = 1
			push_error("You tried to add %s to an unstackable items" % value)
		if quantity > MAX_QUANTITY:
			quantity = MAX_QUANTITY
