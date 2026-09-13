extends Node
class_name AttackSystem

var attacks = {
	"JAB": {"damage": 5, "range": 110, "kb": 100, "startup": 0.1, "active": 0.1, "recovery": 0.15, "energy": 2, "anim": "JAB", "type": "high"},
	"CROSS": {"damage": 12, "range": 130, "kb": 300, "startup": 0.2, "active": 0.1, "recovery": 0.25, "energy": 5, "anim": "CROSS", "type": "high"},
	"UPPERCUT": {"damage": 18, "range": 110, "kb": 400, "startup": 0.25, "active": 0.15, "recovery": 0.3, "energy": 8, "anim": "UPPERCUT", "type": "uppercut"},
	"LOW_KICK": {"damage": 8, "range": 140, "kb": 150, "startup": 0.15, "active": 0.1, "recovery": 0.2, "energy": 4, "anim": "LOW_KICK", "type": "low"},
	"HIGH_KICK": {"damage": 15, "range": 160, "kb": 450, "startup": 0.25, "active": 0.15, "recovery": 0.3, "energy": 8, "anim": "HIGH_KICK", "type": "high"},
	"SPECIAL": {"damage": 30, "range": 220, "kb": 800, "startup": 0.4, "active": 0.2, "recovery": 0.4, "energy": -50, "anim": "SPECIAL", "type": "special"},
	"GRAB": {"damage": 0, "range": 90, "kb": 0, "startup": 0.15, "active": 0.1, "recovery": 0.3, "energy": 10, "anim": "GRAB_REACH", "type": "grab"}
}
