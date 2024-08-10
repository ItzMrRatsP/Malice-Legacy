return {
	Name = "setCash",
	Aliases = { "sc" },
	Description = "Set player cash amount to given amount!",
	Group = "devs",
	Args = {
		{
			Type = "players",
			Name = "target",
			Description = "players that will get the given amount of cash.",
		},
		{
			Type = "number",
			Name = "amount",
			Description = "amount of cash that players will receive.",
		},
	},
}
