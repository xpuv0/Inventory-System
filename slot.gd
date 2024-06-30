extends Panel
class_name Slot

@export var slot_data : SlotData 

@onready var texture_rect = $TextureRect
@onready var quantity_label = $QuantityLabel
@export_enum("Normal", "Pickaxe") var slot_type : String = "Normal"
var slot_type_dictionary = {
	"Normal" : Item as Script,
	"Pickaxe" : Pickaxe as Script,
}
	
	
func set_slot_data(value : SlotData):
	slot_data = value
	update_ui()



func update_ui():
	if slot_data.item:
		update_texture_rect()
	if !slot_data.item:
		texture_rect.hide()
	update_quantity_label()


func update_texture_rect():
	texture_rect.show()
	texture_rect.texture = slot_data.item.texture


func update_quantity_label():
	if slot_data.quantity > 1:
		quantity_label.text = "%s" % slot_data.quantity
		quantity_label.show()
	if slot_data.quantity <= 1 or slot_data.item == null:
		quantity_label.hide()


func reset_slot_data():
	slot_data.item = null
	slot_data.quantity = 1
	update_ui()


func type_check(item : Item) -> bool:
	if slot_type != "Normal":
		return (slot_type_dictionary[slot_type].instance_has(item))
	return true
