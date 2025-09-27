------------------------------------------------------------------------------------------------------------------------------------------------
-------- Audio Engine


--Functions
function stream_stop_all()
	--audio_stream_stop(metalcap)
	currentlyPlaying = nil
end

function loop(music) audio_stream_set_looping(music, true) end
currentlyPlaying = nil
ambientPlaying = nil
local fadeTimer = 0
local fadePeak = 0
local volume = 1
local itemVolume = 0
PACKET_SOUND = 1

function stream_play(a)
	if currentlyPlaying then audio_stream_stop(currentlyPlaying) end
	audio_stream_play(a, true, 1)
	currentlyPlaying = a
	fadeTimer = 0
end

function ambient_play(a)
	if ambientPlaying then audio_stream_stop(ambientPlaying) end
	audio_stream_play(a, true, 0)
	ambientPlaying = a
	fadeTimer = 0
end

function stream_fade(time)
	fadePeak = time
	fadeTimer = time
end
function stream_set_volume(vol)
	volume = vol
end
function stream_item_nearby_volume(vol)
    itemVolume = vol
end

hook_event(HOOK_UPDATE, function ()
	local m = gMarioStates[0]
	local nearbyItem = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvItemPowerup)

	if fadeTimer > 0 then
		fadeTimer = fadeTimer - 1
		if fadeTimer == 0 then
			stream_stop_all()
		end
	end
	if currentlyPlaying then
		audio_stream_set_volume(currentlyPlaying, (is_game_paused() and 0.2 or (fadeTimer ~= 0 and fadeTimer/fadePeak or 1)) * volume)
	end
    if ambientPlaying then
        audio_stream_set_volume(ambientPlaying, (is_game_paused() and 0.2 or (fadeTimer ~= 0 and fadeTimer/fadePeak or 1)) * itemVolume)
    end

    if nearbyItem then
        local dist = lateral_dist_between_objects(nearbyItem, m.marioObj)
        if dist < 3800 then
            if ambientPlaying == nil then
                ambient_play(amb_ItemNearby)
            end
            local t = 1 - (dist / 3800)
            if t < 0 then t = 0 end
            if t > 1 then t = 1 end
            stream_item_nearby_volume(t)
        else
            stream_item_nearby_volume(0)
        end
    else
        stream_item_nearby_volume(0)
        audio_stream_stop(amb_ItemNearby)
        ambientPlaying = nil
    end
end)
function local_play(id, pos, vol)
	audio_sample_play(gSamples[id], pos, (is_game_paused() and 0 or vol))
end
function network_play(id, pos, vol, i)
    local_play(id, pos, vol)
    network_send(true, {type = PACKET_SOUND, id = id, x = pos.x, y = pos.y, z = pos.z, vol = vol, i = network_global_index_from_local(i)})
end
function stop_all_samples()
	for _, audio in pairs(gSamples) do
		audio_sample_stop(audio)
	end
end
hook_event(HOOK_ON_PACKET_RECEIVE, function (data)
	if data.type == PACKET_SOUND and is_player_active(gMarioStates[network_local_index_from_global(data.i)]) ~= 0 then
		local_play(data.id, {x=data.x, y=data.y, z=data.z}, data.vol)
	end
end)

--Music Streams
mus_TallonOverworld2 = audio_stream_load("TallonOverworld2.ogg")     audio_stream_set_looping(mus_TallonOverworld2, true)

--Ambient Streams
amb_ItemNearby = audio_stream_load("item_nearby.ogg")     audio_stream_set_looping(amb_ItemNearby, true)

--Samples
gSamples = {
	audio_sample_load("fpsTransition.ogg"),
    audio_sample_load("itemGrab.ogg"),
    audio_sample_load("powBeam.ogg"),
    audio_sample_load("jump1.ogg"),
    audio_sample_load("jump2.ogg"),
}
sFpsTransition = 1
sItemGrab = 2
sPowBeam = 3
sJump1 = 4
sJump2 = 5