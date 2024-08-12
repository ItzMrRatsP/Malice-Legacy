local GameUtil = require(script.Parent.GameUtil)

local UIUtil = {}
local grammars = GameUtil.arrtodict { ".", ",", "!", "?" }

function UIUtil.typewrite(
	text: string,
	label: TextLabel,
	properties: { typeSpeed: number?, grammarDelay: number? }
)
	local goalText = ""
	local metaProperties = setmetatable(
		properties,
		{ __index = { typeSpeed = 0.1, grammarDelay = 0.25 } }
	)

	for c in utf8.graphemes(text) do
		local currentText = string.sub(text, c, c)
		goalText ..= currentText
		label.Text = goalText

		if grammars[currentText] then task.wait(metaProperties.grammarDelay) end
		task.wait(metaProperties.typeSpeed)
	end
end

return UIUtil
