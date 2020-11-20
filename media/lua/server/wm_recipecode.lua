---------------- Recipe Helper Functions ----------------

--- Copy walkman data from first to second table
local function copyWalkmanData(from, to)

	to:CopyModData(Walkman.getOrInitData(from));
	to:setUsedDelta(from:getUsedDelta());

	return to:getModData();
end

----------------- Recipe TEST Functions -----------------

--- Test if cassette player has no battery power left ---
function Recipe_InsertBatteryIntoCassettePlayer_TestIsValid(sourceItem, _)

	if sourceItem:getType() == "Walkman" then
		return sourceItem:getUsedDelta() == 0;
	else
		return true; -- the battery
	end
end

--- Test if cassette player has battery power left ---
function Recipe_RemoveBatteryFromCassettePlayer_TestIsValid(sourceItem, _)
	return sourceItem:getUsedDelta() > 0;
end

--- Test if cassette player is turned off and has delta ---
function Recipe_TurnOnCassettePlayer_TestIsValid(sourceItem, _)

	local data = Walkman.getOrInitData(sourceItem);
	return sourceItem:getUsedDelta() > 0 and not Walkman.isPoweredOn(data);
end

--- Test if cassette player is turned on ---
function Recipe_TurnOffCassettePlayer_TestIsValid(sourceItem, _)

	local data = Walkman.getOrInitData(sourceItem);
	return Walkman.isPoweredOn(data);
end

--- Test if cassette player is turned on and ready to play ---
function Recipe_PlayCassettePlayer_TestIsValid(sourceItem, _)

	local data = Walkman.getOrInitData(sourceItem);
	return Walkman.isPoweredOn(data) and
			Walkman.isCassetteInserted(data) and
			not Walkman.isPlaying(data);
end

--- Test if cassette player is currently playing ---
function Recipe_StopCassettePlayer_TestIsValid(sourceItem, _)
	return Walkman.getOrInitData(sourceItem).play_state == 1;
end

--- Test if cassette player has no tape inserted ---
function Recipe_InsertCassetteIntoCassettePlayer_TestIsValid(sourceItem, _)

	if sourceItem:getType() == "Walkman" then
		local data = Walkman.getOrInitData(sourceItem);
		return not Walkman.isCassetteInserted(data);
	else
		return true; -- the cassette
	end
end

--- Test if cassette player has tape inserted ---
function Recipe_EjectCassetteFromCassettePlayer_TestIsValid(sourceItem, _)

	local data = Walkman.getOrInitData(sourceItem);
	return Walkman.isCassetteInserted(data);
end

------------------- Recipe Functions -------------------

function Recipe_InsertBatteryIntoCassettePlayer(items, result, _)

	local battery, device = items:get(0), items:get(1);

	-- copy mod data from ingredient to result
	copyWalkmanData(device, result);

	-- transfer battery power to cassette player
	device:setUsedDelta(battery:getUsedDelta());
end

function Recipe_RemoveBatteryFromCassettePlayer(items, result, _)

	local device = items:get(0);

	-- transfer power from cassette player to battery
	result:setUsedDelta(device:getUsedDelta());
	device:setUsedDelta(0);
end

function Recipe_TurnOnCassettePlayer(items, result, _)
	copyWalkmanData(items:get(0), result).power_state = 1;
end

function Recipe_TurnOffCassettePlayer(items, result, _)

	local data = copyWalkmanData(items:get(0), result);
	data.power_state, data.play_state = 0, 0;
end

function Recipe_PlayCassettePlayer(items, result, _)
	copyWalkmanData(items:get(0), result).play_state = 1;
end

function Recipe_StopCassettePlayer(items, result, _)
	copyWalkmanData(items:get(0), result).play_state = 0;
end

function Recipe_InsertCassetteIntoCassettePlayer(items, result, _)

	local wm_data = copyWalkmanData(items:get(1), result);
	local tape_data = Cassette.getOrInitData(items:get(0));

	wm_data.tape_num = tape_data.num;
	wm_data.track_num = tape_data.track;
end

function Recipe_EjectCassetteFromCassettePlayer(items, result, _)

	local deviceData = Walkman.getOrInitData(items:get(0));
	local casData = result:getModData();

	casData.num = deviceData.tape_num;
	casData.track = deviceData.track_num;

	deviceData.tape_num = 0;
	deviceData.track_num = 0;
	deviceData.play_state = 0;
end

function Recipe_RemoveCassetteFromCase(_, result, player)

	player:getInventory():AddItem("WM.CassetteCaseEmpty");
	Cassette.Init(result);
end