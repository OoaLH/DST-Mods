modimport("petbrain.lua")
local require = GLOBAL.require
require 'constants'
require 'tuning'
local ImageButton = require 'widgets/imagebutton'

local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer()
local player = nil
local margin_size_x = 50
local margin_size_y = 50

local function PositionText(controls, newWidget, screensize, x_align, y_align, x_offset, y_offset)
    local dir_vert = 0
    local dir_horiz = 0
    local anchor_vert = 0
    local anchor_horiz = 0
    local margin_dir_vert = 0
    local margin_dir_horiz = 0
    if x_align == "left" then
        dir_horiz = -1
        anchor_horiz = 1
        margin_dir_horiz = 1
    elseif x_align == "center" then
        dir_horiz = 0
        anchor_horiz = 0
        margin_dir_horiz = 0
    elseif x_align == "right" then
        dir_horiz = 1
        anchor_horiz = -1
        margin_dir_horiz = -1
    end
    
    if y_align == "top" then
        dir_vert = 0
        anchor_vert = -1
        margin_dir_vert = -1
    elseif y_align == "middle" then
        dir_vert = -1
        anchor_vert = 0
        margin_dir_vert = 0
    elseif y_align == "bottom" then
        dir_vert = -2
        anchor_vert = 1
        margin_dir_vert = 1
    end
	local hudscale = controls.top_root:GetScale()
	local screenw_full, screenh_full = GLOBAL.unpack(screensize)
	local screenw = screenw_full/hudscale.x
	local screenh = screenh_full/hudscale.y
	newWidget:SetPosition(
		(anchor_horiz*margin_size_x)+(dir_horiz*screenw/2)+(margin_dir_horiz*margin_size_x)+x_offset, 
		(anchor_vert*margin_size_y)+(dir_vert*screenh/2)+(margin_dir_vert*margin_size_y)+y_offset, 
		0
    )
end

local function RetargetFn(inst)
    return player.components.combat.target, true
end

function GetClosestPet()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 100, {}, {}, {'rabbit', 'dragonfly', 'deerclops', 'bishop', 'spider', 'hound', 'deergemresistance', 'knight', 'rook', 'tallbird', 'frog', 'pig', 'penguine', 'beefalo', 'walrus', 'monkey', 'bearger', 'moose', 'snake', 'deer', 'lavae'})
    return ents[1] ~= player and ents[1] or ents[2]
end

local function Petify()
    local inst = GetClosestPet()
    print(inst)
    if inst ~= nil and (not inst:HasTag('player')) and (inst.components.follower == nil or inst.components.follower.leader == nil) then
        if inst:HasTag("hostile") then
            inst:RemoveTag("hostile")
        end
        if inst:HasTag("scarytoprey") then
            inst:RemoveTag("scarytoprey")
        end
        if inst.components.follower == nil then
            inst:AddComponent("follower")
        end
        inst._playerlink = player
        inst.components.follower:SetLeader(player)
        inst.components.combat:SetTarget(nil)
        inst.components.combat:SetRetargetFunction(3, RetargetFn)
        inst:SetBrain(PetBrain)
    end
end

local function ClickEvent()
    SendModRPCToServer(GetModRPC("petify", "Petify"))
end

local function AddPetButton()
    AddClassPostConstruct("widgets/controls", function(controls)
        controls.inst:DoTaskInTime(0, function()
            local screensize = {GLOBAL.TheSim:GetScreenSize()}
            controls.position_button_widget = controls.top_root:AddChild(ImageButton())
            PositionText(controls, controls.position_button_widget, screensize, 'left', 'top', 0, -5)
            controls.position_button_widget.image:SetScale(0.75, 0.5)
            controls.position_button_widget:SetOnClick(ClickEvent)
            controls.position_button_widget:SetText('find a pet')
            controls.position_button_widget:Enable()
            controls.position_button_widget:SetClickable(true)
            controls.position_button_widget:Show()
        end)
    end)
end

AddPetButton()

AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function()
        player = GLOBAL.ThePlayer
    end)
end)

AddModRPCHandler("petify", "Petify", Petify)