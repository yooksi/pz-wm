----------------- Recipe TEST Functions -----------------

--- Test if cassette player has no battery power left ---
function Recipe_InsertBatteryIntoCassettePlayer_TestIsValid(sourceItem, result)

	if sourceItem:getType() == "Walkman" then
		return sourceItem:getUsedDelta() == 0;
	else
		return true; -- the battery
	end
end

--- Test if cassette player has battery power left ---
function Recipe_RemoveBatteryFromCassettePlayer_TestIsValid(sourceItem, result)
	return sourceItem:getUsedDelta() > 0;
end

--- Test if cassette player is turned off ---
function Recipe_TurnOnCassettePlayer_TestIsValid(sourceItem, result)
	return not sourceItem:getModData().power_state;
end

--- Test if cassette player is turned on ---
function Recipe_TurnOffCassettePlayer_TestIsValid(sourceItem, result)
	return sourceItem:getModData().power_state;
end

--- Test if cassette player has no tape inserted ---
function Recipe_InsertCassetteIntoCassettePlayer_TestIsValid(sourceItem, result)

	if sourceItem:getType() == "Walkman" then
		return not isCassetteInserted(sourceItem:getModData());
	else
		return true; -- the cassette
	end
end

------------------- Recipe Functions -------------------

function Recipe_InsertBatteryIntoCassettePlayer(items, result, player)

	local battery, device = items:get(0), items:get(1);

	-- transfer battery power to cassette player
	device:setUsedDelta(battery:getUsedDelta());

	-- copy mod data from ingredient to result
	result:CopyModData(device:getModData());
end

function Recipe_RemoveBatteryFromCassettePlayer(items, result, player)

	local device = items:get(0);

	-- transfer power from cassette player to battery
	result:setUsedDelta(device:getUsedDelta());
	device:setUsedDelta(0);
end

function Recipe_TurnOnCassettePlayer(items, result, player)

	result:CopyModData(items:get(0):getModData());
	result:getModData().power_state = true;
end

function Recipe_TurnOffCassettePlayer(items, result, player)

	result:CopyModData(items:get(0):getModData());
	result:getModData().power_state = false;
end

function Recipe_InsertCassetteIntoCassettePlayer(items, result, player)

	local tape = items:get(0);
	result:CopyModData(items:get(1):getModData());

	local wm_data = result:getModData();
	local tape_data = tape:hasModData() and tape:getModData() or InitCassetteItem(tape);

	wm_data.tape_num = tape_data.num;
	wm_data.track_num = tape_data.track;
end

function Recipe_RemoveCassetteFromCase(items, result, player)

	player:getInventory():AddItem("WM.CassetteCaseEmpty");
	InitCassetteItem(result);
end