@tool
class_name ProvinceTraitEntry
extends Resource

enum Strength { MINOR, MODERATE, MAJOR }

const STRENGTH_VALUES := {
	Strength.MINOR: 0.05,
	Strength.MODERATE: 0.10,
	Strength.MAJOR: 0.20,
}

@export var category: ProvinceTrait.Category = ProvinceTrait.Category.GEOGRAPHIC:
	set(v):
		category = v
		notify_property_list_changed()
@export var value: int = 0
@export var strength: Strength = Strength.MODERATE


func _validate_property(property: Dictionary) -> void:
	if property.name != "value":
		return
	var e := ProvinceTrait.get_enum(category)
	var parts := PackedStringArray()
	for k in e:
		parts.append("%s:%d" % [String(k).capitalize(), e[k]])
	property.hint = PROPERTY_HINT_ENUM
	property.hint_string = ",".join(parts)


static func make(p_category: ProvinceTrait.Category, p_value: int, p_strength: Strength = Strength.MODERATE) -> ProvinceTraitEntry:
	var e := ProvinceTraitEntry.new()
	e.category = p_category
	e.value = p_value
	e.strength = p_strength
	return e


func get_display_name() -> String:
	return ProvinceTrait.to_display(category, value)


func get_multiplier() -> float:
	return STRENGTH_VALUES.get(strength, 0.0)


func is_dynamic() -> bool:
	return ProvinceTrait.is_dynamic(category)


func strengthen() -> bool:
	if not is_dynamic() or strength == Strength.MAJOR:
		return false
	strength = (strength + 1) as Strength
	return true


func weaken() -> bool:
	if not is_dynamic():
		return false
	if strength == Strength.MINOR:
		return true
	strength = (strength - 1) as Strength
	return false
