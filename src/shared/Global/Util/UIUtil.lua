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

function UIUtil.untypewrite(
	text: string,
	label: TextLabel,
	properties: { typeSpeed: number?, grammarDelay: number?, _destroy: boolean?, _todestroy: GuiObject? }
)
	local goalText = text
	local metaProperties = setmetatable(
		properties,
		{ __index = { typeSpeed = 0.1, grammarDelay = 0.25, _destroy = false } }
	)

	for index = #text, 0, -1 do
		local currentText = string.sub(text, 1, index)
		goalText = currentText
		label.Text = goalText

		task.wait(metaProperties.typeSpeed)
	end

	if metaProperties._destroy and properties._todestroy then return properties._todestroy:Destroy() end
end

return UIUtil
