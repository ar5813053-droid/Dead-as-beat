extends RefCounted
class_name AnimUtil
## Helpers to locate AnimationPlayer and play clips by fuzzy name.

static func find_animation_player(root: Node) -> AnimationPlayer:
	if root == null:
		return null
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for c in root.get_children():
		var found := find_animation_player(c)
		if found:
			return found
	return null

static func list_clips(ap: AnimationPlayer) -> PackedStringArray:
	if ap == null:
		return PackedStringArray()
	return ap.get_animation_list()

static func play_fuzzy(ap: AnimationPlayer, candidates: Array, force: bool = false) -> String:
	if ap == null:
		return ""
	var names := ap.get_animation_list()
	for cand in candidates:
		var key := str(cand).to_lower()
		for n in names:
			if n.to_lower() == key or key in n.to_lower() or n.to_lower() in key:
				if force or ap.current_animation != n:
					ap.play(n)
				return n
	# partial token match
	for cand in candidates:
		var tokens := str(cand).to_lower().split(" ")
		for n in names:
			var nl := n.to_lower()
			var ok := true
			for t in tokens:
				if t.length() > 2 and t not in nl:
					ok = false
					break
			if ok and tokens.size() > 0:
				if force or ap.current_animation != n:
					ap.play(n)
				return n
	return ""
