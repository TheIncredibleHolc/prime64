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
            --[[set_lighting_color(0, 150)
            set_lighting_color(1, 150)
            set_lighting_color(2, 150)
            set_vertex_color(0, 150)
            set_vertex_color(1, 150)
            set_vertex_color(2, 150)
            set_fog_color(0, 150)
            set_fog_color(1, 150)
            set_fog_color(2, 150)]]
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
    obj_scale(o, 0.3)
end

local function arm_cannon_loop(o)
    local m = gMarioStates[0]
    
    local cam = gFirstPersonCamera
    local pitch = cam.pitch
    local yaw = cam.yaw

    -- base position = Mario's body
    local px, py, pz = m.pos.x, m.pos.y, m.pos.z

    -- offsets relative to camera view
    local sideOffset    =  16   -- right/left
    local upOffset      = 100   -- up
    local forwardOffset = -10   -- forward

    -- convert yaw/pitch to sin/cos
    local sinYaw = sins(yaw)
    local cosYaw = coss(yaw)
    local sinPitch = sins(pitch)
    local cosPitch = coss(pitch)

    -- forward/back offset (apply pitch here too)
    local fx = forwardOffset * cosPitch * sinYaw
    local fy = forwardOffset * -sinPitch
    local fz = forwardOffset * cosPitch * cosYaw

    -- right/left offset (yaw + 90°)
    local rx = sideOffset * cosYaw
    local rz = -sideOffset * sinYaw

    -- apply offsets
    o.oPosX = px + fx + rx
    o.oPosY = py + upOffset + fy
    o.oPosZ = pz + fz + rz

    -- face the same direction as the camera
    o.oFaceAngleYaw   = yaw + 32768
    o.oMoveAngleYaw   = yaw + 32768
    o.oFaceAnglePitch = pitch
    o.oMoveAnglePitch = pitch

end


id_bhvArmCannon = hook_behavior(nil, OBJ_LIST_GENACTOR, false, arm_cannon_init, arm_cannon_loop, "bhvArmCannon")
-----------------------------------------------------------
--Projectile: Power Beam
E_MODEL_PROJ_PBEAM = smlua_model_util_get_id("powerBeamProj_geo")

local function pbeam_proj_init(o)
    o.oFlags = OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_MOVE_XZ_USING_FVEL | OBJ_FLAG_MOVE_Y_WITH_TERMINAL_VEL
    o.header.gfx.skipInViewCheck = true
    obj_scale(o, 1)
end

local function pbeam_proj_loop(o)
    cur_obj_update_floor_height_and_get_floor()
    o.oForwardVel = 75
    local pitch = o.oMoveAnglePitch
    local yaw   = o.oMoveAngleYaw
    local speed = o.oForwardVel
    
    -- true 3D forward velocity
    local cosPitch = coss(pitch)
    local sinPitch = sins(pitch)

    o.oVelX = speed * sins(yaw) * cosPitch
    o.oVelY = speed * -sinPitch           -- negative because pitch+ = looking down
    o.oVelZ = speed * coss(yaw) * cosPitch

    stepresult = object_step()

    if stepresult & OBJ_COL_FLAG_HIT_WALL ~= 0 or
       stepresult & OBJ_COL_FLAG_GROUNDED ~= 0 or
       o.oPosY == o.oFloorHeight then
        obj_mark_for_deletion(o)
    end
end
id_bhvPbeamProj = hook_behavior(nil, OBJ_LIST_GENACTOR, false, pbeam_proj_init, pbeam_proj_loop, "bhvPbeamProj")
