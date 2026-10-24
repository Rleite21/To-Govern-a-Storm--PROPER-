@tool
extends EditorScript

# Replaces the MeshInstance3D(s) inside each city node with a Marker3D named after the city,
# positioned at the geometry's center. The province's own mesh is never touched.
# After running, save the scene (Ctrl+S).

func _run() -> void:
	var root := get_scene()
	if root == null:
		push_error("Open the map scene first.")
		return

	var provinces := root.find_child("Provinces", true, false)
	if provinces == null:
		push_error("Couldn't find 'Provinces' in scene '%s'." % root.name)
		return

	var replaced := 0
	var skipped := 0
	var problems := 0
	var province_meshes_ignored := 0

	for province in provinces.get_children():
		for city in province.get_children():
			# The province's own mesh is a direct MeshInstance3D child: never touch it.
			if city is MeshInstance3D:
				province_meshes_ignored += 1
				continue
			# Cities are plain Node3D children; ignore anything else.
			if not city is Node3D:
				continue

			# Already converted in a previous run?
			if _has_marker(city):
				skipped += 1
				continue

			# Only searches INSIDE this city node, so the province mesh (a sibling) is never included.
			var meshes := city.find_children("*", "MeshInstance3D", true, false)
			var center = _center_of_meshes(meshes)
			if center == null:
				push_warning("'%s': no mesh with valid geometry, skipped" % city.name)
				problems += 1
				continue

			# Delete the city's meshes (free immediately so the name is available)
			for m in meshes:
				var mi := m as Node
				# Safety: never delete anything that isn't inside this city
				if not city.is_ancestor_of(mi):
					push_error("Refusing to delete '%s': not inside city '%s'" % [mi.get_path(), city.name])
					continue
				if mi.get_parent() != null:
					mi.get_parent().remove_child(mi)
				mi.free()

			# Create the marker named after the city
			var marker := Marker3D.new()
			marker.name = city.name
			marker.gizmo_extents = 0.15
			city.add_child(marker)
			marker.owner = root  # needed so it's saved with the scene
			marker.global_position = center
			replaced += 1

	EditorInterface.mark_scene_as_unsaved()
	print("Markers created: %d | already converted: %d | problems: %d | province meshes left untouched: %d"
		% [replaced, skipped, problems, province_meshes_ignored])
	print("Save the scene (Ctrl+S) to keep the changes.")

func _has_marker(city: Node) -> bool:
	for c in city.get_children():
		if c is Marker3D:
			return true
	return false

# Center of the combined AABB (in global space) of all given meshes.
func _center_of_meshes(meshes: Array) -> Variant:
	var merged := AABB()
	var first := true
	for m in meshes:
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var local_aabb := mi.get_aabb()
		if local_aabb.size == Vector3.ZERO:
			continue
		var aabb: AABB = mi.global_transform * local_aabb
		if first:
			merged = aabb
			first = false
		else:
			merged = merged.merge(aabb)
	if first:
		return null
	return merged.get_center()
