Lights1 powerBeamProj_f3dlite_material_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x28, 0x28, 0x28);

Texture powerBeamProj_Untitled_2_rgba16[] = {
	#include "actors/powerBeamProj/Untitled-2.rgba16.inc.c"
};

Vtx powerBeamProj_powerBeamProj_mesh_layer_5_vtx_cull[8] = {
	{{{-100, -100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{-100, 100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{-100, 100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{-100, -100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, -100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, 100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, 100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, -100, 0}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
};

Vtx powerBeamProj_powerBeamProj_mesh_layer_5_vtx_0[4] = {
	{{{100, -100, 0}, 0, {-16, 8176}, {0x00, 0x00, 0x81, 0xFF}}},
	{{{-100, -100, 0}, 0, {8176, 8176}, {0x00, 0x00, 0x81, 0xFF}}},
	{{{-100, 100, 0}, 0, {8176, -16}, {0x00, 0x00, 0x81, 0xFF}}},
	{{{100, 100, 0}, 0, {-16, -16}, {0x00, 0x00, 0x81, 0xFF}}},
};

Gfx powerBeamProj_powerBeamProj_mesh_layer_5_tri_0[] = {
	gsSPVertex(powerBeamProj_powerBeamProj_mesh_layer_5_vtx_0 + 0, 4, 0),
	gsSP2Triangles(0, 1, 2, 0, 0, 2, 3, 0),
	gsSPEndDisplayList(),
};


Gfx mat_powerBeamProj_f3dlite_material[] = {
	gsSPGeometryMode(G_CULL_BACK, 0),
	gsSPSetLights1(powerBeamProj_f3dlite_material_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, PRIMITIVE, 0),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, powerBeamProj_Untitled_2_rgba16),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 65535, 32),
	gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 64, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 8, 0, G_TX_WRAP | G_TX_NOMIRROR, 8, 0),
	gsDPSetTileSize(0, 0, 0, 1020, 1020),
	gsSPEndDisplayList(),
};

Gfx mat_revert_powerBeamProj_f3dlite_material[] = {
	gsSPGeometryMode(0, G_CULL_BACK),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx powerBeamProj_powerBeamProj_mesh_layer_5[] = {
	gsSPClearGeometryMode(G_LIGHTING),
	gsSPVertex(powerBeamProj_powerBeamProj_mesh_layer_5_vtx_cull + 0, 8, 0),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPCullDisplayList(0, 7),
	gsSPDisplayList(mat_powerBeamProj_f3dlite_material),
	gsSPDisplayList(powerBeamProj_powerBeamProj_mesh_layer_5_tri_0),
	gsSPDisplayList(mat_revert_powerBeamProj_f3dlite_material),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

