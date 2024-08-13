return {
	Name = "setCash",
	Aliases = { "sc" },
	Description = "Set server cash to given amount",
	Group = "devs",
	Args = {
		{
			Type = "number",
			Name = "amount",
			Description = "The amount of cash you want to set the money to",
		},
	},
}
