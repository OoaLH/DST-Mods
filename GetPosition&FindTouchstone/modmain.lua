local require = GLOBAL.require
local ImageButton = require 'widgets/imagebutton'
local Text = require 'widgets/text'
local Menu = require 'widgets/menu'
require 'constants'
local margin_size_x = 50
local margin_size_y = 50
local TextWidget = nil
local player = nil
local tabsToFind = {'beefalo', 'bishop', 'boat', 'dragonfly', 'eyebone', 'hound', 'pigking', 'spider', 'tallbird', 'teleporter'}

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

local function UpdatePosition()
    local x, y, z = player.Transform:GetWorldPosition()
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

local function ShowTouchStone()
    local x, y, z = player.Transform:GetWorldPosition()
    local ents = GLOBAL.TheSim:FindEntities(x, y, z, 10000, {'resurrector'}, {'multiplayer_portal'})
    local touchstone = ents[1] or ents[2]
    if touchstone~=nil then
        print(touchstone)
        if touchstone:HasTag('structure')==false and GLOBAL.TheNet:GetIsMasterSimulation() and player:CanUseTouchStone(touchstone)==false then
            print('touch stone will be activated')
            touchstone.AnimState:PlayAnimation("activate")
            touchstone.AnimState:PushAnimation("idle_activate", false)
            touchstone.AnimState:SetLayer(GLOBAL.LAYER_WORLD)
            touchstone.AnimState:SetSortOrder(0)
            touchstone.Physics:CollidesWith(GLOBAL.COLLISION.CHARACTERS)
            touchstone.SoundEmitter:PlaySound("dontstarve/common/resurrectionstone_activate")
            touchstone._enablelights:set(true)
        end
        local stonex, stoney, stonez = touchstone.Transform:GetWorldPosition()
        if TextWidget ~= nil then
            TextWidget:SetString('nearest touchstone is at '..stonex..", "..stonez)
        end
        player.components.locomotor:GoToPoint(Point(stonex, stoney, stonez), nil, true)
    end
end

local function FindTag(tag)
    local tab = ''
    if tag == 'pigking' then
        tab = 'king'
    elseif tag == 'eyebone' then
        tab = 'chester_eyebone'
    else
        tab = tag
    end
    print('finding '..tag)
    local ent = GLOBAL.GetClosestInstWithTag(tab, player, 10000)
    if ent~=nil then
        local entx, enty, entz = ent.Transform:GetWorldPosition()
        if TextWidget ~= nil then
            TextWidget:SetString('nearest '..tag..' is at '..entx..", "..entz)
        end
        player.components.locomotor:GoToPoint(Point(entx, enty, entz), nil, true)
    end
end

local function AddFindButton()
    AddClassPostConstruct("widgets/controls", function(controls)
        controls.inst:DoTaskInTime(0, function()
            local menu = Menu(nil, -40, false, 'tabs')
            menu:AddItem('myself', function()
                print('finding myself')
                UpdatePosition()
                menu:Hide()
                controls.menu_showed = false
                controls.find_button_widget:SetText('find')
            end)
            menu:AddItem('touchstone', function()
                print('finding touchstone')
                ShowTouchStone()
                menu:Hide()
                controls.menu_showed = false
                controls.find_button_widget:SetText('find')
            end)
            for i = 1, #tabsToFind do
                menu:AddItem(tabsToFind[i], function()
                    FindTag(tabsToFind[i])
                    menu:Hide()
                    controls.menu_showed = false
                    controls.find_button_widget:SetText('find')
                end)
            end
            menu:Hide()
            controls.position_text_widget = controls.top_root:AddChild(Text('talkingfont', 40))
            controls.find_button_widget = controls.top_root:AddChild(ImageButton())
            controls.menu_widget = controls.top_root:AddChild(menu)
            controls.menu_showed = false
            local screensize = {GLOBAL.TheSim:GetScreenSize()}
            PositionText(controls, controls.position_text_widget, screensize, 'center', 'top', 0, 15)
            PositionText(controls, controls.find_button_widget, screensize, 'left', 'bottom', 0, -5)
            PositionText(controls, controls.menu_widget, screensize, 'left', 'top', 30, 15)
            local OnUpdate_base = controls.OnUpdate
            controls.OnUpdate = function(self, dt)
                OnUpdate_base(self, dt)
                local curscreensize = {GLOBAL.TheSim:GetScreenSize()}
                if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
                    PositionText(controls, controls.position_text_widget, curscreensize, 'center', 'top', 0, 15)
                    PositionText(controls, controls.find_button_widget, screensize, 'left', 'bottom', 0, -5)
                    PositionText(controls, controls.menu_widget, screensize, 'left', 'top', 30, 15)
                    screensize = curscreensize
                end
            end
            controls.position_text_widget:Show()
            controls.find_button_widget.image:SetScale(1, 0.5)
            controls.find_button_widget:SetText('find')
            controls.find_button_widget:SetOnClick(function()
                if controls.menu_showed then
                    print('hide menu')
                    controls.menu_widget:Hide()
                    controls.find_button_widget:SetText('find')
                    controls.menu_showed = false
                else
                    print('show menu')
                    controls.menu_widget:Show()
                    controls.find_button_widget:SetText('close tabs')
                    controls.menu_showed = true
                end
            end)
            controls.find_button_widget:Enable()
            controls.find_button_widget:SetClickable(true)
            controls.find_button_widget:Show()
            TextWidget = controls.position_text_widget
        end)
    end)
    
end

AddFindButton()

AddPlayerPostInit(function(inst)
    inst:DoTaskInTime(0, function()
        player = GLOBAL.ThePlayer
    end)
end)