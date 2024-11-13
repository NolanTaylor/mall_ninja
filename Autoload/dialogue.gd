extends Node

const NAMES : Dictionary = { # <String, String>
	"ethan": "Ethan",
	"paul": "Paul Ball, Maul Call",
}

const INTRO : Array = [ # <String>
	["ethan_neutral", "Ah, the American shopping mall."],
	["ethan_angry", "Many worthy champions have tried and failed to conquer the great pillar of Western Consumerism."],
	["ethan_glasses", "But none have had my delicate skill and raw determination."],
	["ethan_triumph", "I shall be the first to prove my skill and defeat the residents of this shopping mall!"],
]

const INTRO_PAUL : Array = [ # <String>
	["show", "ethan_neutral"],
	["paul_neutral", "Hey kid, you can't bring a weapon into the mall."],
	["ethan_shock", "Tch, who is this menace of authority to deny my entrance into a public shopping mall."],
	["paul_neutral", "I'm Paul Ball, Maul Call. And these are the rules of the mall."],
	["ethan_glasses", "Allow me to allay your fears officer! This is a mere replica, not a real sword, and certainly not capable of harming another individual."],
	["paul_flat", "Sorry kid, I just watched you impale a homeless man in the parking lot. You'll have to leave the sword outside."],
	["ethan_shock", "Hng, the watchful government surveillance tracks my every motion. Foiled again!"],
	["paul_side", "Are you going to leave? Or am I going to have to call security?"],
	["show", "ethan_neutral"],
	["choice", "Apologize profusely", "Reach for his service weapon"],
	["branch", INTRO_PAUL_APOLOGIZE, INTRO_PAUL_REACH],
]

const INTRO_PAUL_APOLOGIZE : Array = [ # <String>
	["ethan_bow", "My deepest and most sincere apologies officer."],
	["paul_neutral", "fortnite balls im gay i like boys"],
]

const INTRO_PAUL_REACH : Array = [ # <String>
	["ethan_point", "Hey is that your service weapon?"],
	["paul_neutral", "battlepass"],
]
