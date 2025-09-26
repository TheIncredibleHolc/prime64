-- RTD Utilities n' shit

------------------------------------------------------------------------------------------------------------------------------------------------

define_custom_obj_fields({
    oAmmo = "u32",
    oTracerScale = "u32",
	oGunAngle = "s32",
	oBulletPosX = "s32",
	oBulletPosY = "s32",
	oBulletPosZ = "s32",
	oAngleFromMario = "s32",
	oThrowDistance = "u32",
	oDestroyTimer = "u32",
	oBulletHit = "u32"
})



------------------------------------------------------------------------------------------------------------------------------------------------
local function modsupport() --Allows detection of other mods for any needed fixes.
    for key,value in pairs(gActiveMods) do
        if (value.name == "Flood") or _G.floodExpanded then
            if network_is_server() then
                --djui_chat_message_create("Gore/HM Flood compatibility enabled.")
                gGlobalSyncTable.floodenabled = true

            end
        else
            if network_is_server() then
                gGlobalSyncTable.floodenabled = false
                --djui_chat_message_create("no flood")
            end
        end
    end
end
hook_event(HOOK_ON_LEVEL_INIT, modsupport)

------------------------------------------------------------------------------------------------------------------------------------------------
-------- Mod Menu

local function disable_bullshit()
	bullshit = false
end
hook_mod_menu_checkbox("Disable Bullshit", false, disable_bullshit)

------------------------------------------------------------------------------------------------------------------------------------------------
-------- gStateExtras
gStateExtras = {}
for i = 0, MAX_PLAYERS-1 do
	gStateExtras[i] = {
		invisible = 0,
		scopeZoom = false,
		enemyTargeted = nil
	}
end

-------- PlayerSync
gPlayerSyncTable[0].lunging = false


------------------------------------------------------------------------------------------------------------------------------------------------
-------- Helper Functions


function is_lowest_active_player()
	return get_network_player_smallest_global().localIndex == 0
end

function ia(m)
	return m.playerIndex == 0
end
function lerp(a, b, t) return a * (1 - t) + b * t end

function vec3f() return {x=0,y=0,z=0} end

function limit_angle(a) return (a + 0x8000) % 0x10000 - 0x8000 end

function clamp_s16(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function spawn_sync_if_main(behaviorId, modelId, x, y, z, objSetupFunction, i)
	print("index:", i)
	print("attempt by "..get_network_player_smallest_global().name)
	print(get_network_player_smallest_global().localIndex + i)
	if get_network_player_smallest_global().localIndex + i == 0 then print("passed!") return spawn_sync_object(behaviorId, modelId, x, y, z, objSetupFunction) end
end



------------------------------------------------------------------------------------------------------------------------------------------------
-------- Custom Actions

ACT_INVISIBLE = allocate_mario_action(ACT_FLAG_MOVING)
function act_invisible(m)
	local s = gStateExtras[m.playerIndex]
    m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_ACTIVE
	m.actionTimer = m.actionTimer + 1
	if m.actionTimer == m.actionArg then
		local savedY = m.pos.y
		m.pos.y = savedY
	end
	if m.actionTimer == 30 then
		set_mario_action(m, ACT_IDLE, 0)
	elseif m.actionTimer >= 150 then
		m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
		set_mario_action(m, ACT_IDLE, 0)
	end
	if m.action == ACT_PUNCHING or m.action == ACT_GROUND_BONK or m.action == ACT_FORWARD_GROUND_KB or m.action == ACT_BACKWARD_GROUND_KB or m.action == ACT_HARD_FORWARD_GROUND_KB or m.action == ACT_HARD_BACKWARD_GROUND_KB or m.action == ACT_SOFT_FORWARD_GROUND_KB or m.action == ACT_SOFT_BACKWARD_GROUND_KB then
		set_mario_action(m, ACT_IDLE, 0)
		--djui_chat_message_create("reset")
	end

end
hook_mario_action(ACT_INVISIBLE, act_invisible)

ACT_RAGDOLL = allocate_mario_action(ACT_GROUP_CUTSCENE|ACT_FLAG_STATIONARY|ACT_FLAG_INTANGIBLE)
function act_ragdoll(m)
    local stepResult = perform_air_step(m, 0)

    if stepResult == AIR_STEP_LANDED then
        if m.floor.type == SURFACE_BURNING then
            set_mario_action(m, ACT_LAVA_BOOST, 0)
		elseif m.health ~= 0xff then
			set_mario_action(m, ACT_FORWARD_GROUND_KB, 0)
			m.faceAngle.x = 0
			--m.faceAngle.y = 0
			m.faceAngle.z = 0

		elseif m.health == 0xFF then
			set_mario_action(m, ACT_HARD_FORWARD_GROUND_KB, 0)
		end
    end
    set_character_animation(m, CHAR_ANIM_AIRBORNE_ON_STOMACH)
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    if m.actionArg == 1 then
        local l = gLakituState
        l.posHSpeed, l.posVSpeed, l.focHSpeed, l.focVSpeed = 0, 0, 0, 0
    end
    vec3s_set(m.angleVel, 2000, 1000, 400)
    vec3s_add(m.faceAngle, m.angleVel)
    vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)
end
hook_mario_action(ACT_RAGDOLL, act_ragdoll)

ACT_BULLET_DEATH = allocate_mario_action(ACT_GROUP_AUTOMATIC|ACT_FLAG_INVULNERABLE|ACT_FLAG_STATIONARY)
function act_bullet_death(m)
    common_death_handler(m, MARIO_ANIM_ELECTROCUTION, 50)
end
hook_mario_action(ACT_BULLET_DEATH, act_bullet_death)

ACT_HIT_BY_BULLET = allocate_mario_action(ACT_GROUP_AUTOMATIC|ACT_FLAG_INVULNERABLE|ACT_FLAG_STATIONARY)
function act_hit_by_bullet(m)
	m.actionTimer = m.actionTimer + 1
    set_mario_animation(m, MARIO_ANIM_SHOCKED)
    if m.actionTimer > 0 then
        m.marioBodyState.eyeState = MARIO_EYES_DEAD
    end
	if m.actionTimer == 1 then
		play_character_sound(m, CHAR_SOUND_ATTACKED)
	end
    if m.actionTimer == 8 then
        if m.health < 255 then
			set_mario_action(m, ACT_BULLET_DEATH, 0)
		else
			set_mario_action(m, ACT_IDLE, 0)
		end
    end
end
hook_mario_action(ACT_HIT_BY_BULLET, act_hit_by_bullet)