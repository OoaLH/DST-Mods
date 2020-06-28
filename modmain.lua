local require = GLOBAL.require
local ImageButton = require 'widgets/imagebutton'
local Tex = require 'widgets/text'
require 'constants'
local flag = false
local index = 0
local margin_size_x = 50
local margin_size_y = 50
local TextWidget = nil
local player = nil

local function PositionText(controls, newwidget, screensize, x_align, y_align)
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
		(anchor_vert*margin_size_y)+(dir_vert*screenh/2)+(margin_dir_vert*margin_size_y)+10, 
		0
    )
end

local function UpdatePosition()
    local x,y,z = player.Transform:GetWorldPosition()
    print('position')
    print(x..", "..z)    
    if TextWidget ~= nil then
        TextWidget:SetString(x..", "..z)
    end   
end

local function AddPositionText()
    AddClassPostConstruct( "widgets/controls", function(controls)
        controls.inst:DoTaskInTime( 0, function()


            controls.position_text_widget = controls.top_root:AddChild( Tex('talkingfont',40) )
            controls.position_button_widget = controls.top_root:AddChild( ImageButton() )
            local screensize = {GLOBAL.TheSim:GetScreenSize()}
            PositionText(controls, controls.position_text_widget, screensize, 'center', 'top')
            PositionText(controls, controls.position_button_widget, screensize, 'left', 'top')
            local OnUpdate_base = controls.OnUpdate
            controls.OnUpdate = function(self, dt)
                OnUpdate_base(self, dt)
                local curscreensize = {GLOBAL.TheSim:GetScreenSize()}
                if curscreensize[1] ~= screensize[1] or curscreensize[2] ~= screensize[2] then
                    PositionText(controls, controls.position_text_widget, curscreensize, 'center', 'top')
                    PositionText(controls, controls.position_button_widget, curscreensize, 'left', 'top')
                    screensize = curscreensize
                end
            end
            controls.position_text_widget:Show()
            controls.position_button_widget.image:SetScale(1, 0.75)
            controls.position_button_widget:SetOnClick(UpdatePosition)
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

    
[[
local function CreateButton(name, x, y, axisX, axisY, parent, onClickFunc)
    -- body
    local newButton = parent:AddChild(ImageButton())
    newButton.image:SetScale(x, y)
    newButton:SetPosition(axisX, axisY)
    newButton:SetOnClick(onClickFunc)
    newButton:Show()
    newButton:SetText(name)
    newButton:Enable()
    newButton:SetClickable(true)
    return newButton
end

local function ButtonExists(buttonPointer)
    if buttonPointer==nil or buttonPointer.parent==nil then
        return false
    else
        return true
    end
end

local function CreateText(name, parent)
    local tex = parent:AddChild(Tex('talkingfont',40))
    tex:SetPosition(320, -250, 0)
    tex:SetString(name)
    tex:Hide()
    return tex
end
]]

