-- UIKit — the few widgets this game needs, built in code.
--
-- No .rbxmx assets: the HUD has to diff like everything else, and a grey-box slice
-- should not need a Studio round-trip to change a label. This is engine-shaped code
-- currently parked in src/client/ — see docs/runs/ for the extraction note.

local UIKit = {}

--- Declarative Instance.new. Parent is applied last so nothing renders half-built.
function UIKit.create(className: string, props: { [string]: any }?, children: { Instance }?): any
	local instance = Instance.new(className)
	local parent = nil
	for key, value in props or {} do
		if key == "Parent" then
			parent = value
		else
			(instance :: any)[key] = value
		end
	end
	for _, child in children or {} do
		child.Parent = instance
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

function UIKit.corner(radius: number): UICorner
	return UIKit.create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

function UIKit.padding(amount: number): UIPadding
	return UIKit.create("UIPadding", {
		PaddingTop = UDim.new(0, amount),
		PaddingBottom = UDim.new(0, amount),
		PaddingLeft = UDim.new(0, amount),
		PaddingRight = UDim.new(0, amount),
	})
end

function UIKit.stroke(color: Color3, thickness: number): UIStroke
	return UIKit.create("UIStroke", { Color = color, Thickness = thickness, Transparency = 0.4 })
end

function UIKit.list(padding: number, direction: Enum.FillDirection?): UIListLayout
	return UIKit.create("UIListLayout", {
		Padding = UDim.new(0, padding),
		FillDirection = direction or Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
end

return UIKit
