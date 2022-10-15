local require = GLOBAL.require
require 'constants'
require 'tuning'
require 'behaviourtree'
require "behaviours/follow"
require "behaviours/faceentity"
require "behaviours/standstill"
require "behaviours/chaseandattack"
require "behaviours/doaction"

local Follow = GLOBAL.Follow
local FaceEntity = GLOBAL.FaceEntity
local StandStill = GLOBAL.StandStill
local PriorityNode = GLOBAL.PriorityNode
local ChaseAndAttack = GLOBAL.ChaseAndAttack
local DoAction = GLOBAL.DoAction
local BT = GLOBAL.BT
local WhileNode = GLOBAL.WhileNode
local SequenceNode = GLOBAL.SequenceNode
local WaitNode = GLOBAL.WaitNode

PetBrain = require('brains/chesterbrain')

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 7
local MAX_FOLLOW_DIST = 12
local MAX_CHASE_DIST = 32
local MAX_CHASE_TIME = 20

local function GetOwner(inst)
    return inst.components.follower.leader
end

local function GetAttackTarget(inst)
    if inst.components.follower ~= nil and inst.components.follower.leader ~= nil then
        return inst.components.follower.leader.components.combat.target
    end
    return nil
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function OwnerIsClose(inst)
    local owner = GetOwner(inst)
    return owner ~= nil and owner:IsNear(inst, MAX_FOLLOW_DIST)
end

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function LoveOwner(inst)
    if inst.sg:HasStateTag("busy") then
        return nil
    end

    local owner = GetOwner(inst)
    return owner ~= nil
        and not owner:HasTag("playerghost")
        and (GetTime() - (inst.sg.mem.prevnuzzletime or 0) > TUNING.CRITTER_NUZZLE_DELAY)
        and math.random() < 0.05
        and BufferedAction(inst, owner, ACTIONS.NUZZLE)
        or nil
end

function PetBrain:OnStart()
    local root =
    PriorityNode({
        ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST, nil, GetAttackTarget),
        Follow(self.inst, function() return self.inst.components.follower.leader end, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        FaceEntity(self.inst, GetOwner, KeepFaceTargetFn),
        WhileNode(function() return OwnerIsClose(self.inst) end, "Affection",
        SequenceNode{
            WaitNode(4),
            DoAction(self.inst, LoveOwner),
        }),
        StandStill(self.inst),
    }, .25)
    self.bt = BT(self.inst, root)
end