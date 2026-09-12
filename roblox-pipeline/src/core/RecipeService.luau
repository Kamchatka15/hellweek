-- RecipeService — turn a bag of things into better things.
--
-- A recipe is inputs (kind -> count) and outputs (kind -> count). `resolve` takes a
-- bag and applies whatever recipes fit, repeatedly, until nothing more matches, then
-- hands back the products and whatever would not combine.
--
-- Order matters and is explicit: recipes are tried in the order the pack lists them,
-- so a pack decides that two cactus become water BEFORE water and wood become
-- tempered wood. Leaving that to a sort would make the pack's behaviour depend on a
-- comparison function nobody can see.
--
-- Nothing here knows what a cactus is, and no recipe can run on a client.

local RecipeService = {}

export type Recipe = {
	id: string,
	label: string,
	inputs: { [string]: number },
	outputs: { [string]: number }?,
	effect: string?, -- a named consequence the loop applies (e.g. lift a penalty)
	limit: number?, -- most times this may fire in one resolve
}

local recipes: { Recipe } = {}

function RecipeService.configure(list: { Recipe })
	recipes = list or {}
end

function RecipeService.all(): { Recipe }
	return recipes
end

local function fits(bag: { [string]: number }, recipe: Recipe): boolean
	for kind, need in recipe.inputs do
		if (bag[kind] or 0) < need then
			return false
		end
	end
	return true
end

export type Result = {
	products: { [string]: number },
	leftovers: { [string]: number },
	applied: { { recipe: Recipe, count: number } },
	effects: { [string]: number },
}

--- Resolve a bag. The bag is not modified; a copy is worked.
function RecipeService.resolve(bag: { [string]: number }): Result
	local pool: { [string]: number } = table.clone(bag)

	local products: { [string]: number } = {}
	local effects: { [string]: number } = {}
	local applied: { { recipe: Recipe, count: number } } = {}
	local firedBy: { [string]: number } = {}

	-- Keep sweeping the list: a later recipe can produce an input an earlier one
	-- wants, and one pass would miss that. Bounded so a pack that writes a recipe
	-- turning A into A cannot hang a server.
	local MAX_PASSES = 24
	for _ = 1, MAX_PASSES do
		local fired = false
		for _, recipe in recipes do
			local cap = recipe.limit
			while fits(pool, recipe) and (cap == nil or (firedBy[recipe.id] or 0) < cap) do
				for kind, need in recipe.inputs do
					pool[kind] -= need
					if pool[kind] <= 0 then
						pool[kind] = nil
					end
				end
				for kind, count in recipe.outputs or {} do
					products[kind] = (products[kind] or 0) + count
					pool[kind] = (pool[kind] or 0) + count
				end
				if recipe.effect then
					effects[recipe.effect] = (effects[recipe.effect] or 0) + 1
				end
				firedBy[recipe.id] = (firedBy[recipe.id] or 0) + 1
				fired = true
			end
		end
		if not fired then
			break
		end
	end

	-- Anything a recipe produced and a later recipe did not eat is a product the
	-- player should receive; anything that was never touched is a leftover. The pool
	-- holds both, so split it by whether the kind was ever produced.
	local leftovers: { [string]: number } = {}
	for kind, count in pool do
		local made = products[kind] or 0
		if made >= count then
			products[kind] = count
		else
			products[kind] = if made > 0 then made else nil
			leftovers[kind] = count - made
		end
	end
	for kind, count in products do
		if count <= 0 then
			products[kind] = nil
		end
	end

	for _, recipe in recipes do
		local count = firedBy[recipe.id]
		if count and count > 0 then
			table.insert(applied, { recipe = recipe, count = count })
		end
	end

	return { products = products, leftovers = leftovers, applied = applied, effects = effects }
end

return RecipeService
