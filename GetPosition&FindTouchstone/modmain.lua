local require = GLOBAL.require
local ImageButton = require 'widgets/imagebutton'
local Tex = require 'widgets/text'
require 'constants'
local margin_size_x = 50
local margin_size_y = 50
local nearestPlayer = nil
local x = 0
local y = 0
local z = 0
local TextWidget = nil
local player = nil

local function PositionText(controls, newwidget, screensize, x_align, y_align, offset)
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
	newwidget:SetPosition(
		(anchor_horiz*margin_size_x)+(dir_horiz*screenw/2)+(margin_dir_horiz*margin_size_x), 
		(anchor_vert*margin_size_y)+(dir_vert*screenh/2)+(margin_dir_vert*margin_size_y)+offset, 
		0
    )
end

local function updateposition()
    x, y, z = player.Transform:GetWorldPosition()
    local nearby_player = GLOBAL.GetClosestInstWithTag('player', player, 1000)
    if nearby_player~=nil then
        print(nearby_player)
    end
    print('position')
    print(x..", "..z)
    if TextWidget ~= nil then
        TextWidget:SetString(x..", "..z)
    end   
end

local function showtouchstone()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10000, {'resurrector'}, {'multiplayer_portal'})
    local touchstone = ents[1] or ents[2]
    --local portal = GLOBAL.GetClosestInstWithTag('multiplayer_portal', player, 10000)
    if touchstone~=nil then
        print(touchstone)
        if touchstone:HasTag('structure')==false and GLOBAL.TheNet:GetIsMasterSimulation() and player:CanUseTouchStone(touchstone)==false then
            print(' is touchstone')
            touchstone.AnimState:PlayAnimation("activate")
            touchstone.AnimState:PushAnimation("idle_activate", false)
            touchstone.AnimState:SetLayer(GLOBAL.LAYER_WORLD)
            touchstone.AnimState:SetSortOrder(0)
            touchstone.Physics:CollidesWith(GLOBAL.COLLISION.CHARACTERS)
            touchstone.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")
            touchstone._enablelights:set(true)
        end
        local stonex, stoney, stonez = touchstone.Transform:GetWorldPosition()
        --player:FacePoint(stonex, stoney, stonez)
        if TextWidget ~= nil then
            TextWidget:SetString('nearest touchstone is at '..stonex..", "..stonez)
        end
        player.components.locomotor:GoToPoint(Point(stonex, stoney, stonez), nil, true)
    end
     
end

local function AddPositionText()
    AddClassPostConstruct( "widgets/controls", function(controls)
        controls.inst:DoTaskInTime( 0, function()
            controls.position_text_widget = controls.top_root:AddChild( Tex('talkingfont',40) )
            controls.position_button_widget = controls.top_root:AddChild( ImageButton() )
            controls.touchstone_button_widget = controls.top_root:AddChild( ImageButton() )
            local screensize = {GLOBAL.TheSim:GetScreenSize()}
            PositionText(controls, controls.position_text_widget, screensize, 'center', 'top', 15)
            PositionText(controls, controls.position_button_widget, screensize, 'left', 'top', 15)
            PositionText(controls, controls.touchstone_button_widget, screensize, 'left', 'bottom', -5)
            local OnUpdate_base = controls.OnUpdate
            controls.OnUpdate = function(self, dt)
                OnUpdate_base(self, dt)
                local curscreensize = {GLOBAL.TheSim:GetScreenSize()}
                if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
                    PositionText(controls, controls.position_text_widget, curscreensize, 'center', 'top', 15)
                    PositionText(controls, controls.position_button_widget, curscreensize, 'left', 'top', 15)
                    PositionText(controls, controls.touchstone_button_widget, screensize, 'left', 'bottom', -5)
                    screensize = curscreensize
                end
            end
            controls.position_text_widget:Show()
            controls.touchstone_button_widget.image:SetScale(1, 0.5)
            controls.touchstone_button_widget:SetText('find touchstone')
            controls.touchstone_button_widget:SetOnClick(showtouchstone)
            controls.touchstone_button_widget:Enable()
            controls.touchstone_button_widget:SetClickable(true)
            controls.touchstone_button_widget:Show()
            controls.position_button_widget.image:SetScale(0.75, 0.5)
            controls.position_button_widget:SetOnClick(updateposition)
            controls.position_button_widget:SetText('get position')
            controls.position_button_widget:Enable()
            controls.position_button_widget:SetClickable(true)
            controls.position_button_widget:Show()
            TextWidget = controls.position_text_widget
        end)
    end)
    
end

AddPositionText()

AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function()
        player = GLOBAL.ThePlayer
    end)
end)