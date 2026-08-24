@tool
@icon("res://addons/escoria-core/design/esc_location.svg")
## A simple node extending Position2D with a global ID so that it can be
## referenced in ESC Scripts. Movement-based commands like `walk_to_pos` will
## automatically use an `ESCLocation` that is a child of the destination node.
## Commands like `turn_to`--which are not movement-based--will ignore child
## `ESCLocation`s and refer to the parent node.
class_name ESCLocation
extends Marker2D


## Escoria Plugin signal emitted to the `ESCRoom` when a start location is set in the `ESCLocation` node in order to check whether multiple start locations are set.[br]
## [br]
## #### Parameters[br]
## [br]
## | Name | Type | Description | Required? |[br]
## |:-----|:-----|:------------|:----------|[br]
## |node_to_ignore|`ESCLocation`| `ESCLocation` that should be ignored while validating start locations. Defaults to `null`.|no|[br]
## [br]
signal editor_is_start_location_set(node_to_ignore: ESCLocation)

## Warning message: multiple start locations set in the room..
const MULTIPLE_START_LOCATIONS_WARNING = \
	"Only 1 ESCLocation should have is_start_location set to true in an ESCRoom"


## The global ID of this ESCLocation
@export var global_id: String

## If enabled, this `ESCLocation` is considered as a player start location
## for this room.
@export var is_start_location: bool = false:
	set = set_is_start_location


@export_group("Player behavior on arrival")

## Whether player character orients towards 'interaction_angle' as it arrives at
## the item's interaction position.
@export var player_orients_on_arrival: bool = true:
	set = set_player_orients_on_arrival

## If 'player_orients_on_arrival' is enabled, let the player character turn to
## this angle when it arrives at the item's interaction position.
@export var interaction_angle: int:
	set = set_interaction_angle

@export_group("","")

## Escoria plugin variable to check the existence of multiple start locations.
var _multiple_start_locations_exist: bool = false:
	set = set_multiple_start_locations_exist


## Used by "is" keyword to check whether a node's class_name is the same as p_classname.[br]
## [br]
## #### Parameters[br]
## [br]
## | Name | Type | Description | Required? |[br]
## |:-----|:-----|:------------|:----------|[br]
## |p_classname|`String (4.6.x), StringName (4.7.x)`|Class name to compare against this location.|yes|[br]
## [br]
## #### Returns[br]
## [br]
## Returns a `bool` value. (`bool`)
func is_class(p_classname) -> bool:
	return p_classname == "ESCLocation"


## Ready function. Registers the ESCLocation to Object Manager.[br]
## [br]
## #### Parameters[br]
## [br]
## None.
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func _ready():
	if not Engine.is_editor_hint():
		if not self.global_id.is_empty():
			var force_registration = false
			if escoria.save_manager.is_loading_game:
				force_registration = true
			escoria.object_manager.register_object(
				ESCObject.new(
					self.global_id,
					self
				),
				null,
				force_registration
			)
	else:
		queue_redraw()
		var selection: EditorSelection = EditorInterface.get_selection()
		if not selection.selection_changed.is_connected(queue_redraw):
			selection.selection_changed.connect(queue_redraw)


## Escoria editor plugin: on tree exit (ie. this node was removed), notify ESCRoom to update the
## list of start locations, and stop listening to editor selection changes.[br]
## [br]
## #### Parameters[br]
## [br]
## None.
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func _exit_tree():
	if Engine.is_editor_hint() and is_start_location:
			editor_is_start_location_set.emit(self)

	if Engine.is_editor_hint():
		var selection: EditorSelection = EditorInterface.get_selection()
		if selection.selection_changed.is_connected(queue_redraw):
			selection.selection_changed.disconnect(queue_redraw)


## Escoria editor plugin: overriden method that returns the list of warnings for these nodes.[br]
## [br]
## #### Parameters[br]
## [br]
## None.
## [br]
## #### Returns[br]
## [br]
## Returns a `PackedStringArray` value. (`PackedStringArray`)
func _get_configuration_warnings() -> PackedStringArray:
	return [MULTIPLE_START_LOCATIONS_WARNING] \
		if _multiple_start_locations_exist else []


## Escoria editor plugin: Setter for _multiple_start_locations_exist member. Updates the warnings
## displayed in the editor's scene tree.[br]
## [br]
## #### Parameters[br]
## [br]
## | Name | Type | Description | Required? |[br]
## |:-----|:-----|:------------|:----------|[br]
## |value|`bool`|true whether multiple start locations exist in the room.|yes|[br]
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func set_multiple_start_locations_exist(value: bool) -> void:
	_multiple_start_locations_exist = value
	update_configuration_warnings()


## Escoria editor plugin: Setter for is_start_location member. Notifies the ESCRoom of the
## change.[br]
## [br]
## #### Parameters[br]
## [br]
## | Name | Type | Description | Required? |[br]
## |:-----|:-----|:------------|:----------|[br]
## |value|`bool`|true whether the ESCLocation node was set as start location.|yes|[br]
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func set_is_start_location(value: bool) -> void:
	is_start_location = value
	if Engine.is_editor_hint() and is_instance_valid(get_owner()):
		editor_is_start_location_set.emit()


## Escoria editor plugin: Setter for player_orients_on_arrival member. Triggers a redraw of the
## editor crosshair/arrow gizmo.[br]
## [br]
## #### Parameters[br]
## [br]
## | Name | Type | Description | Required? |[br]
## |:-----|:-----|:------------|:----------|[br]
## |value|`bool`|true whether the player character should orient towards `interaction_angle` on
## arrival.|yes|[br]
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func set_player_orients_on_arrival(value: bool) -> void:
	player_orients_on_arrival = value
	if Engine.is_editor_hint():
		queue_redraw()


## Escoria editor plugin: Setter for interaction_angle member. Triggers a redraw of the editor
## crosshair/arrow gizmo.[br]
## [br]
## #### Parameters[br]
## [br]
## | Name | Type | Description | Required? |[br]
## |:-----|:-----|:------------|:----------|[br]
## |value|`int`|Angle (in degrees) the player character turns to when `player_orients_on_arrival`
## is enabled.|yes|[br]
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func set_interaction_angle(value: int) -> void:
	interaction_angle = value
	if Engine.is_editor_hint():
		queue_redraw()


## Escoria editor plugin: whether the crosshair/arrow gizmo should currently be drawn. `ESCLocation`
## nodes that are children of an `ESCItem` are hidden by default, and only shown while either the
## `ESCLocation` or its parent `ESCItem` is selected in the editor. `ESCLocation` nodes with any
## other parent (eg. free-standing locations in an `ESCRoom`) are always shown.[br]
## [br]
## #### Parameters[br]
## [br]
## None.
## [br]
## #### Returns[br]
## [br]
## Returns a `bool` value. (`bool`)
func _is_gizmo_visible() -> bool:
	var parent: Node = get_parent()
	if not (parent is ESCItem):
		return true

	var selected_nodes: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	return selected_nodes.has(self) or selected_nodes.has(parent)


## Escoria editor plugin: draws a crosshair to indicate the position of the ESCLocation node, in
## red. If `player_orients_on_arrival` is `true`, also draws a green arrow indicating the
## `interaction_angle` the player character will turn to on arrival. Editor only, not drawn in
## game.[br]
## [br]
## #### Parameters[br]
## [br]
## None.
## [br]
## #### Returns[br]
## [br]
## Returns nothing.
func _draw():
	if not Engine.is_editor_hint():
		return

	if not _is_gizmo_visible():
		return

	var crosshair_size: float = 20.0
	var crosshair_color: Color = Color.RED

	draw_line(
		Vector2(-crosshair_size, 0),
		Vector2(crosshair_size, 0),
		crosshair_color,
		2.0
	)
	draw_line(
		Vector2(0, -crosshair_size),
		Vector2(0, crosshair_size),
		crosshair_color,
		2.0
	)

	if player_orients_on_arrival:
		var arrow_color: Color = Color.GREEN
		var arrow_length: float = 24.0
		var arrow_head_length: float = 6.0
		var arrow_head_angle: float = deg_to_rad(150)

		# interaction_angle is defined relative to "up" (0°), growing clockwise:
		# up=[315°,45°], right=[45°,135°], down=[135°,225°], left=[225°,315°],
		# and similarly for the intermediate 8-direction angles. Snap it to the
		# nearest 45° so the arrow only ever points in one of the 8 directions.
		var snapped_angle: float = wrapf(round(interaction_angle / 45.0) * 45.0, 0.0, 360.0)
		var direction: Vector2 = Vector2.UP.rotated(deg_to_rad(snapped_angle))
		var arrow_end: Vector2 = direction * arrow_length

		draw_line(Vector2.ZERO, arrow_end, arrow_color, 2.0)
		draw_line(
			arrow_end,
			arrow_end + direction.rotated(arrow_head_angle) * arrow_head_length,
			arrow_color,
			2.0
		)
		draw_line(
			arrow_end,
			arrow_end + direction.rotated(-arrow_head_angle) * arrow_head_length,
			arrow_color,
			2.0
		)
