-- name: Prime64 [WIP]
-- description: Prime 64 concept
--------------------------------------------------------------------------------------------------------

--------Testing--------
function spawn_guns()
    local m = gMarioStates[0]
    --djui_chat_message_create(tostring(m.intendedMag))
    if m.controller.buttonPressed & L_JPAD ~= 0 then
        spawn_non_sync_object(id_bhvItemPowerup, E_MODEL_NONE, 3983, -511, -2269, function (powerup) powerup.oBehParams = 1 end) --Spawn Varia Suit Upgrade
    end
    if m.controller.buttonPressed & R_JPAD ~= 0 then
        spawn_non_sync_object(id_bhvStaticObject, E_MODEL_ARM_CANNON, m.pos.x, m.pos.y + 130, m.pos.z, function (arm) obj_scale(arm, 3) end)
    end
    if m.controller.buttonPressed & D_JPAD ~= 0 then
        spawn_non_sync_object(id_bhvItemPowerup, E_MODEL_NONE, m.pos.x + 150, m.pos.y, m.pos.z + 150, function (powerup) powerup.oBehParams = 1 end) --Spawn Varia Suit Upgrade
    end
    if m.controller.buttonPressed & U_JPAD ~= 0 then
        warp_to_level(LEVEL_TALLON_OVERWORLD, 1, 0)
    end
end
hook_event(HOOK_UPDATE, spawn_guns)

--------locals--------
local network_player_connected_count,init_single_mario,warp_to_level,play_sound,network_is_server,network_get_player_text_color_string,djui_chat_message_create,disable_time_stop,network_player_set_description,set_mario_action,obj_get_first_with_behavior_id,obj_check_hitbox_overlap,spawn_mist_particles,vec3f_dist,play_race_fanfare,play_music,djui_hud_set_resolution,djui_hud_get_screen_height,djui_hud_get_screen_width,djui_hud_render_rect,djui_hud_set_font,djui_hud_world_pos_to_screen_pos,clampf,math_floor,djui_hud_measure_text,djui_hud_print_text,hud_render_power_meter,hud_get_value,save_file_erase_current_backup_save,save_file_set_flags,save_file_set_using_backup_slot,find_floor_height,spawn_non_sync_object,set_environment_region,vec3f_set,vec3f_copy,math_random,set_ttc_speed_setting,get_level_name,hud_hide,smlua_text_utils_secret_star_replace,smlua_audio_utils_replace_sequence = network_player_connected_count,init_single_mario,warp_to_level,play_sound,network_is_server,network_get_player_text_color_string,djui_chat_message_create,disable_time_stop,network_player_set_description,set_mario_action,obj_get_first_with_behavior_id,obj_check_hitbox_overlap,spawn_mist_particles,vec3f_dist,play_race_fanfare,play_music,djui_hud_set_resolution,djui_hud_get_screen_height,djui_hud_get_screen_width,djui_hud_render_rect,djui_hud_set_font,djui_hud_world_pos_to_screen_pos,clampf,math.floor,djui_hud_measure_text,djui_hud_print_text,hud_render_power_meter,hud_get_value,save_file_erase_current_backup_save,save_file_set_flags,save_file_set_using_backup_slot,find_floor_height,spawn_non_sync_object,set_environment_region,vec3f_set,vec3f_copy,math.random,set_ttc_speed_setting,get_level_name,hud_hide,smlua_text_utils_secret_star_replace,smlua_audio_utils_replace_sequence
local texcrosshair = get_texture_info('crosshair')
local texcrosshairActive = get_texture_info('crosshair_active')
local texSwordCrosshair = get_texture_info('sword_crosshair')
local texSwordCrosshairActive = get_texture_info('sword_crosshair_active')
local curr_sighting_range = 10000 --This will be dependent on the currently held gun. 5000 is just a placeholder until I get some tables worked in.
heldweapon = nil

------------CANCEL ATTACK BUTTON---------------
function cancel_actions(m, action)
    if action == ACT_PUNCHING and m.heldObj ~= nil then return 0 end
    if action == ACT_THROWING and m.heldObj ~= nil then return 0 end
    if action == ACT_HEAVY_THROW and m.heldObj ~= nil then return 0 end
end
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, cancel_actions)
------------------------------------------------------------------------
function on_warp()
    stream_stop_all()
end
hook_event(HOOK_ON_WARP, on_warp)
------------------------------------------------------------------------
function hud()
    local m = gMarioStates[0]
    local s = gStateExtras[0]
    local screenHeight = djui_hud_get_screen_height()
    local screenWidth = djui_hud_get_screen_width()
    ----------------------------------------
    if s.fpsEnabled then
        set_first_person_enabled(true)
        local crosshair_width = texcrosshair.width
        local crosshair_height = texcrosshair.height

        m.marioBodyState.allowPartRotation = 0
        djui_hud_set_resolution(RESOLUTION_DJUI);

        if s.enemyTargeted ~= nil then
            --djui_hud_render_texture(heldweapon.activeReticle, ((screenWidth-crosshair_width)/2), ((screenHeight-crosshair_height)/2), 1, 1)
        else
            --djui_hud_render_texture(heldweapon.reticle, ((screenWidth-crosshair_width)/2), ((screenHeight-crosshair_height)/2), 1, 1)
        end
    end
end
hook_event(HOOK_ON_HUD_RENDER, hud)

------------------------------------------------------------------------
-- Track custom jumps per player
local customJumps = {}

local inputMasks = {}
for i = 0, MAX_PLAYERS-1 do
    inputMasks[i] = {
        down = 0,
        pressed = 0
    }
end

local function change_inputs(m)
    if m.playerIndex ~= 0 then return end
    local c = m.controller
    local pressed = c.buttonPressed --Behold
    local down = c.buttonDown --Behold :thinkface:
    if not customJumps[m.playerIndex] then
        customJumps[m.playerIndex] = 0
    end
    if m.action & ACT_FLAG_AIR == 0 then
        customJumps[m.playerIndex] = 0
    end

    --Jump and Double Jump unless you walk off a cliff or something, then it starts at 1 jump already.
    if (pressed & A_BUTTON) ~= 0 and customJumps[m.playerIndex] < 2 then
        customJumps[m.playerIndex] = customJumps[m.playerIndex] + 1
        if customJumps[m.playerIndex] < 2 then
            local_play(sJump1, m.pos, 0.4)
        else
            local_play(sJump2, m.pos, 0.4)
        end
        -- give upward velocity
        if m.action & ACT_FLAG_AIR ~= 0 then
            m.vel.y = 55
        else
            m.pos.y = m.floorHeight + 5
            m.vel.y = 65
            set_mario_action(m, ACT_FREEFALL, 0)
        end
        return
    end

    if (pressed & B_BUTTON) ~= 0 then
        local armcannon = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvArmCannon)
        if armcannon ~= nil then
            local yaw   = gFirstPersonCamera.yaw
            local pitch = gFirstPersonCamera.pitch
            local spawnDist = -300
            local sx = armcannon.oPosX + spawnDist * sins(yaw) * coss(pitch)
            local sy = armcannon.oPosY + spawnDist * sins(pitch)
            local sz = armcannon.oPosZ + spawnDist * coss(yaw) * coss(pitch)
            spawn_non_sync_object(id_bhvPbeamProj, E_MODEL_PROJ_PBEAM, sx, sy, sz, function (beam)
                beam.oFaceAngleYaw   = yaw + 32768
                beam.oMoveAngleYaw   = beam.oFaceAngleYaw
                beam.oFaceAnglePitch = pitch
                beam.oMoveAnglePitch = pitch
            end)
            local_play(sPowBeam, m.pos, 0.6)
        end
        return
    end

    local mask = (A_BUTTON|B_BUTTON)
    -- going a different way about this
    inputMasks[m.playerIndex].down = down & mask
    inputMasks[m.playerIndex].pressed = pressed & mask
    c.buttonDown = down & ~mask
    c.buttonPressed = pressed & ~mask
end
hook_event(HOOK_BEFORE_MARIO_UPDATE, change_inputs)

local function return_inputs(m)
    local mask = inputMasks[m.playerIndex]
    m.controller.buttonDown = m.controller.buttonDown | mask.down -- replace mario's inputs with originals
    m.controller.buttonPressed = m.controller.buttonPressed | mask.pressed
end
hook_event(HOOK_MARIO_UPDATE, return_inputs)

------------------------------------------------------------------------
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, function(m, action) --oK ITS back to how it was.
    if action == ACT_JUMP then
        return 1
    end
    if action == ACT_PUNCHING or action == ACT_MOVE_PUNCHING or action == ACT_DIVE or action == ACT_JUMP_KICK or action == ACT_DOUBLE_JUMP then
        return 1
    end
end)

-- with the fix i'm attempting we shouldn't need this hook