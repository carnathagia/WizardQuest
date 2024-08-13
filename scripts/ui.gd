extends Control

@onready var health_numbers: Label = %HealthBar/HealthNumbers
@onready var health_bar: ProgressBar = %HealthBar

@onready var magic_numbers: Label = %MagicBar/MagicNumbers
@onready var magic_bar: ProgressBar = %MagicBar

@onready var pickup_text: Label = %PickupText
@onready var interact_text: Label = %InteractText
@onready var aim_text: Label = %AimText
@onready var win_game: Label = %WinGame
@onready var tutorial: Label = %Tutorial


func _ready():
	self.pickup_text.hide()
	self.interact_text.hide()
	self.aim_text.hide()
	self.win_game.hide()
	self.tutorial.show()


func _process(delta):
	pass


func _on_player_health_changed(new_health, max_health) -> void:
	self.health_bar.max_value = max_health
	self.health_bar.value = new_health
	
	self.health_numbers.current = new_health
	self.health_numbers.max = max_health


func _on_player_magic_changed(new_magic, max_magic) -> void:
	self.magic_bar.max_value = max_magic
	self.magic_bar.value = new_magic
	
	self.magic_numbers.current = new_magic
	self.magic_numbers.max = max_magic


func _on_player_new_pickupable(item):
	self.pickup_text.pickup_name = item.display_name
	self.pickup_text.show()


func _on_player_no_pickupable():
	self.pickup_text.hide()


func _on_player_new_aimable(body):
	self.aim_text.aim_name = body.display_name
	self.aim_text.show()


func _on_player_no_aimable():
	self.aim_text.hide()


func _on_player_win_game():
	self.win_game.show()


func _on_player_tutorial_over():
	self.tutorial.hide()
