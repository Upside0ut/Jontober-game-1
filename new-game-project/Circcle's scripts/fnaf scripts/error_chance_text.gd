extends LineEdit

var error_chance := 0.0

func _on_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	
	if not new_text.is_valid_int():
		text = str(roundi(error_chance * 100))
		caret_column = text.length()
		return
	
	var percent := clampi(new_text.to_int(), 0, 100)
	error_chance = percent / 100.0
	print(error_chance)
	
	if str(percent) != new_text:
		text = str(percent)
		caret_column = text.length()


func _on_text_submitted(_new_text: String) -> void:
	if "%" in text: return
	print("asd")
	text += "%"


func _on_editing_toggled(toggled_on: bool) -> void:
	if toggled_on: 
		text = ""
		return
	if "%" in text: return
	if text.is_empty(): 
		text = "0%"
		return
	text += "%"
