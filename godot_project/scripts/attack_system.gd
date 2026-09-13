extends Node
class_name AttackSystem

var attacks = {
	"PUNCH": {"damage": 10, "range": 120, "kb": 300, "cooldown": 0.3, "energy": 5},
	"HEAVY": {"damage": 20, "range": 130, "kb": 600, "cooldown": 0.6, "energy": 10},
	"KICK": {"damage": 15, "range": 160, "kb": 450, "cooldown": 0.5, "energy": 10},
	"SPECIAL": {"damage": 30, "range": 200, "kb": 800, "cooldown": 1.0, "energy": -50}
}
