extends Control
class_name Inventory

# Completed 25/6/24

const GOLDEN_PICKAXE = preload("res://Items/Data/golden_pickaxe.tres")
const GOLD_INGOT = preload("res://Items/Data/gold_ingot.tres")
const SLOT = preload("res://Inventory/Scenes/slot.tscn")

@onready var slot_container = $SlotContainer
@onready var equipment_container = $EquipmentContainer
@onready var grabbed_slot = $GrabbedSlot


@export var inventory_data : InventoryData


var is_open : bool = false


func _physics_process(_delta):
	grabbed_slot.global_position = get_global_mouse_position() 
	if Input.is_action_just_pressed("Inventory"):
		if is_open:
			close()
			is_open = false
			return
		if is_open == false:
			open()
			is_open = true
			return
	if Input.is_key_pressed(KEY_0):
		inventory_data.add_item(GOLD_INGOT, 1)
		breakpoint


func close():
	visible = false


func open():
	visible = true


func _ready():
	inventory_data.inventory_updated.connect(_on_inventory_updated)
	fill_slot_container()
	inventory_data.add_item(GOLDEN_PICKAXE, 1)


func _on_inventory_updated():
	for index in inventory_data.slot_datas.size():
		var current_slot : Slot =  slot_container.get_child(index)
		current_slot.set_slot_data(inventory_data.slot_datas[index])
		
		
func fill_slot_container():
	for slot_data in inventory_data.slot_datas:
		var slot = SLOT.instantiate()
		slot_container.add_child(slot)
		slot.set_slot_data(slot_data)
		slot.gui_input.connect(_on_slot_gui_input.bind(slot))


func _on_slot_gui_input(event: InputEvent, slot: Slot):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			handle_left_click(slot)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			handle_right_click(slot)

#region Helper Functions
func handle_left_click(slot: Slot):
	if grabbed_slot.slot_data.item == null:
		if slot.slot_data.item:
			grabbed_slot.set_slot_data(slot.slot_data.duplicate())
			set_physics_process(true)
			slot.reset_slot_data()
	else:
		if !slot.slot_data.item:
			if slot.type_check(grabbed_slot.slot_data.item):
				slot.set_slot_data(grabbed_slot.slot_data.duplicate())
				grabbed_slot.reset_slot_data()
		elif slot.slot_data.item != grabbed_slot.slot_data.item:
			if slot.type_check(grabbed_slot.slot_data.item):
				swap_items(slot)
		elif slot.slot_data.item.stackable:
			stack_items(slot)


func handle_right_click(slot: Slot):
	if grabbed_slot.slot_data.item == null:
		return # Show item information
	elif slot.slot_data.item == null:
		if slot.type_check(grabbed_slot.slot_data.item):
			split_item(slot)
	elif slot.slot_data.item == grabbed_slot.slot_data.item and slot.slot_data.item.stackable:
		add_item_to_stack(slot)


func swap_items(slot: Slot):
	var grabbed_slot_data : SlotData = grabbed_slot.slot_data.duplicate()
	var slots_data = slot.slot_data.duplicate()
	slot.set_slot_data(grabbed_slot_data)
	grabbed_slot.set_slot_data(slots_data)


func stack_items(slot: Slot):
	if grabbed_slot.slot_data.quantity + slot.slot_data.quantity > slot.slot_data.MAX_QUANTITY:
		var slot_quantity = slot.slot_data.quantity
		slot.slot_data.quantity = slot.slot_data.MAX_QUANTITY
		grabbed_slot.slot_data.quantity -= (slot.slot_data.quantity - slot_quantity)
	else:
		slot.slot_data.quantity += grabbed_slot.slot_data.quantity
		grabbed_slot.reset_slot_data()
	grabbed_slot.update_ui()
	slot.update_ui()


func split_item(slot: Slot):
	var new_slot_data = grabbed_slot.slot_data.duplicate()
	new_slot_data.quantity = 1
	slot.set_slot_data(new_slot_data)
	grabbed_slot.slot_data.quantity -= 1
	grabbed_slot.update_ui()
	if grabbed_slot.slot_data.quantity == 0:
		grabbed_slot.slot_data.item = null
		grabbed_slot.update_ui()


func add_item_to_stack(slot: Slot):
	if slot.slot_data.quantity < slot.slot_data.MAX_QUANTITY:
		slot.slot_data.quantity += 1
		grabbed_slot.slot_data.quantity -= 1
		slot.update_ui()
		grabbed_slot.update_ui()
		if grabbed_slot.slot_data.quantity == 0:
			grabbed_slot.slot_data.item = null
			grabbed_slot.update_ui()

#endregion
