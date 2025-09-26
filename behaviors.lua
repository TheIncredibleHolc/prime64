--Custom actors n' shit

-----------------------------------------------------------
--Item: Varia Suit
E_MODEL_ITEM_VARIASUIT = smlua_model_util_get_id("item_variaSuit_geo")

local function item_powerup_init(o)
    o.oFlags = OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_MOVE_XZ_USING_FVEL | OBJ_FLAG_MOVE_Y_WITH_TERMINAL_VEL
    o.header.gfx.skipInViewCheck = true
	o.hitboxRadius = 100
	o.hitboxHeight = 100
	o.oFaceAnglePitch = 0
	o.oFaceAngleRoll = 0
	o.oFaceAngleYaw = 0
    o.oGraphYOffset = 50
    if o.oBehParams == 1 then --VARIA SUIT
        obj_set_model_extended(o, E_MODEL_ITEM_VARIASUIT)
        obj_scale(o, 1.2)
    end
end

local function item_powerup_loop(o)
    local m = nearest_mario_state_to_object(o)
    local s = gStateExtras[m.playerIndex]
    o.oFaceAngleYaw = o.oFaceAngleYaw - 800

    if obj_check_hitbox_overlap(m.marioObj, o) then
        if o.oBehParams == 1 then --VARIA SUIT
            s.variaSuit = true
            spawn_non_sync_object(id_bhvArmCannon, E_MODEL_ARM_CANNON, m.pos.x, m.pos.y, m.pos.z, nil)
            stream_play(mus_TallonOverworld2)
            set_lighting_color(0, 150)
            set_lighting_color(1, 150)
            set_lighting_color(2, 150)
            set_vertex_color(0, 150)
            set_vertex_color(1, 150)
            set_vertex_color(2, 150)
            set_fog_color(0, 150)
            set_fog_color(1, 150)
            set_fog_color(2, 150)
            local_play(sItemGrab, m.pos, 1)
            local_play(sFpsTransition, m.pos, 1)
            play_transition(WARP_TRANSITION_FADE_FROM_COLOR, 90, 255, 255, 255)
            hud_hide()
            set_first_person_enabled(true)
            obj_mark_for_deletion(o)
        end
    end
end

id_bhvItemPowerup = hook_behavior(nil, OBJ_LIST_GENACTOR, false, item_powerup_init, item_powerup_loop, "bhvItemPowerup")
-----------------------------------------------------------
--Item: Arm Cannon (HUD Version)
E_MODEL_ARM_CANNON = smlua_model_util_get_id("arm_cannon_geo")

local function arm_cannon_init(o)
    o.oFlags = OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_MOVE_XZ_USING_FVEL | OBJ_FLAG_MOVE_Y_WITH_TERMINAL_VEL
    o.header.gfx.skipInViewCheck = true
	o.oFaceAnglePitch = 0
	o.oFaceAngleRoll = 0
	o.oFaceAngleYaw = 0
end

local function arm_cannon_loop(o)
    local m = gMarioStates[0]
    local cam = gLakituState

    -- base position = Mario's body
    local px, py, pz = m.pos.x, m.pos.y, m.pos.z

    -- offsets relative to camera view
    local sideOffset    =  16  -- right/left relative to camera
    local upOffset      = 100   -- up
    local forwardOffset = -10 -- forward relative to camera

    -- camera yaw instead of Mario yaw
    local yaw = cam.yaw
    local sinYaw = sins(yaw)
    local cosYaw = coss(yaw)

    -- forward/back offset
    local fx = forwardOffset * sinYaw
    local fz = forwardOffset * cosYaw

    -- right/left offset (yaw + 90°)
    local rx = sideOffset * cosYaw
    local rz = -sideOffset * sinYaw

    -- apply offsets
    o.oPosX = px + fx + rx
    o.oPosY = py + upOffset
    o.oPosZ = pz + fz + rz

    -- face the same direction as the camera
    o.oFaceAngleYaw = yaw + 32768
    o.oMoveAngleYaw = yaw + 32768
end


id_bhvArmCannon = hook_behavior(nil, OBJ_LIST_GENACTOR, false, arm_cannon_init, arm_cannon_loop, "bhvArmCannon")