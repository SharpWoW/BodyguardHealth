--[[
    Copyright (c) 2014 by Adam Hellberg.

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
]]

local NAME, T = ...

local CONTINENT_DRAENOR = 7

-- Draenor zones in which the bodyguard can't be active,
-- the frame is hidden if player is in one of these zones
local BODYGUARD_BANNED_ZONES = {
    [978] = true,  -- Ashran
    [1009] = true, -- Stormshield
    [1011] = true  -- Warspear
}

local function IsValidZone()
    SetMapToCurrentZone()
    local cid = GetCurrentMapContinent()
    local aid = GetCurrentMapAreaID()
    T:Log(("IVZ: cid == %d, aid == %d (%s)"):format(cid, aid, GetMapNameByID(aid) or "Unknown"), true)
    local valid = cid == CONTINENT_DRAENOR and not BODYGUARD_BANNED_ZONES[aid]
    T.DB.char.IsInValidZone = valid
    return valid
end

local defaults = {
    profile = {
        Enabled = true,
        Debug = false,
        EnableWarn = true,
        WarnSound = "BGH: Health Warning",
        CloseGossip = false,
        CloseGossipModifier = "control",
        FrameSettings = {
            ClickThrough = false,
            Width = 200,
            Height = 60,
            Scale = 1,
            Point = "CENTER",
            RelPoint = nil,
            Offset = {
                X = 0,
                Y = 0
            },
            Font = "Friz Quadrata TT",
            FontSize = 20,
            FontFlags = "OUTLINE",
            FontColor = {
                R = 1,
                G = 1,
                B = 1,
                A = 1
            },
            Texture = "Blizzard",
            HealthBasedColor = true,
            CustomColor = {
                R = 1,
                G = 1,
                B = 1
            },
            Backdrop = {
                Background = "Blizzard Dialog Background",
                Border = "Blizzard Tooltip",
                Color = {
                    R = 1,
                    G = 1,
                    B = 1,
                    A = 1
                },
                BorderColor = {
                    R = 1,
                    G = 1,
                    B = 1,
                    A = 1
                },
                Tile = true,
                BorderSize = 16,
                TileSize = 32,
                Insets = {
                    Left = 2.5,
                    Right = 2.5,
                    Top = 2.5,
                    Bottom = 2.5
                }
            }
        }
    },
    char = {
        HasBodyguard = false
    }
}

local modifier_funcs = {
    control = IsControlKeyDown,
    shift = IsShiftKeyDown,
    alt = IsAltKeyDown
}

function T:ADDON_LOADED(name)
    if name ~= NAME then return end

    self.LSM = LibStub("LibSharedMedia-3.0")
    self.LBG = LibStub("LibBodyguard-1.0")
    self.DB = LibStub("AceDB-3.0"):New("BodyguardHealthDB", defaults, true)

    self.LSM:Register(self.LSM.MediaType.SOUND, "BGH: Health Warning", "Interface\\AddOns\\BodyguardHealth\\audio\\warn_health.ogg")

    local function refresh() T.BodyguardFrame:UpdateSettings() end

    self.DB:RegisterCallback("OnProfileChanged", refresh)
    self.DB:RegisterCallback("OnProfileCopied", refresh)
    self.DB:RegisterCallback("OnProfileReset", refresh)

    local lbg = self.LBG

    lbg:UpdateFromBuilding()

    lbg:RegisterCallback("status", function(lib, status)
        T.BodyguardFrame:UpdateStatus(status)

        if status == lib.Status.Active then
            T.BodyguardFrame:UpdateName(lib:GetName())
            T.BodyguardFrame:UpdateHealthBar(lib:GetHealth(), lib:GetMaxHealth())
            T.BodyguardFrame:Show()
        elseif status == lib.Status.Inactive and T.BodyguardFrame:IsLocked() then
            T.BodyguardFrame:Hide()
        end

        T.DB.char.HasBodyguard = status ~= lib.Status.Inactive
    end)

    local login_health_flag = true

    lbg:RegisterCallback("health", function(lib, health, maxhealth)
        -- Don't update health values if addon has restored them from savedvars
        -- This essentially ignores the initial health update from LibBodyguard as it's inaccurate
        -- if the player logged out with an active bodyguard
        if maxHealth == 0 and (T.DB.char.HasBodyguard and T.DB.char.MaxHealth ~= 0) and login_health_flag then
            login_health_flag = false
            return
        end
        T.BodyguardFrame:UpdateHealthBar(health, maxhealth)
        T.DB.char.Health = health
        T.DB.char.MaxHealth = maxhealth
    end)

    lbg:RegisterCallback("name", function(lib, name)
        T.BodyguardFrame:UpdateName(name)
    end)

    lbg:RegisterCallback("gossip_opened", function(lib)
        if not T.DB.profile.Enabled or not T.DB.profile.CloseGossip then return end
        local func = modifier_funcs[T.DB.profile.CloseGossipModifier]
        if func and func() then return end
        CloseGossip()
    end)

    if type(self.DB.char.IsInValidZone) ~= "boolean" then
        self.DB.char.IsInValidZone = IsValidZone()
    end

    if self.DB.char.HasBodyguard and self.DB.char.IsInValidZone then
        self.BodyguardFrame:Show()
        self.BodyguardFrame:UpdateHealthBar(self.DB.char.Health, self.DB.char.MaxHealth)
    end

    self.Dropdown:Create()
    self.BodyguardFrame:SetMenu(not self.DB.profile.FrameSettings.ClickThrough)

    self.Options:Initialize()

    -- DEBUG
    _G["BodyguardHealth"] = self
end

function T:PLAYER_ENTERING_WORLD()
    self:Log("PLAYER_ENTERING_WORLD", true)
    local showing = self.BodyguardFrame:IsShowing()
    if not self.LBG:Exists() and not self.DB.char.HasBodyguard then
        if showing then self.BodyguardFrame:Hide() end
        return
    end
    if not IsValidZone() then
        self:Log("PEW: Not in Draenor, hiding.", true)
        self.BodyguardFrame:Hide()
    elseif showing then
        self.BodyguardFrame:UpdateSettings()
    elseif self.LBG:GetStatus() ~= self.LBG.Status.Inactive and self.DB.char.HasBodyguard then
        self.BodyguardFrame:Show()
    end
end

function T:ZONE_CHANGED_NEW_AREA()
    self:Log("ZONE_CHANGED_NEW_AREA", true)
    local validZone = IsValidZone()
    if not validZone then
        if not self.BodyguardFrame:IsShowing() then return end
        self:Log("Banned zone, hiding", true)
        self.BodyguardFrame:Hide()
    elseif self.DB.char.HasBodyguard and self.LBG:GetStatus() ~= self.LBG.Status.Inactive then
        self.BodyguardFrame:Show()
    end
end

function T:PLAYER_REGEN_DISABLED()
    self.InCombat = true
end

function T:PLAYER_REGEN_ENABLED()
    self.InCombat = false
    if self.QueuedShow then
        self.QueuedShow = false
        self.BodyguardFrame:Show()
    elseif self.QueuedHide then
        self.QueuedHide = false
        self.BodyguardFrame:Hide()
    end
    self.BodyguardFrame:UpdateSettings()
end

function T:PET_BATTLE_OPENING_START()
    self.InPetBattle = true
    self.FrameShowingPrePetBattle = self.BodyguardFrame:IsShowing()
    if self.FrameShowingPrePetBattle then
        self.BodyguardFrame:Hide()
    end
end

function T:PET_BATTLE_CLOSE()
    -- [petbattle] conditional returns false on second fire of PET_BATTLE_CLOSE
    if SecureCmdOptionParse("[petbattle]") then return end
    self.InPetBattle = false
    if self.FrameShowingPrePetBattle then
        self.FrameShowingPrePetBattle = false
        self.BodyguardFrame:Show()
    end
end

function T:QueueShow()
    if not self.InCombat then return end
    self.QueuedShow = true
    self.QueuedHide = false
end

function T:QueueHide()
    if not self.InCombat then return end
    self.QueuedHide = true
    self.QueuedShow = false
end

function T:Enable()
    self.DB.profile.Enabled = true
end

function T:Disable()
    self.DB.profile.Enabled = false
    self.BodyguardFrame:Hide()
end

T.Frame = CreateFrame("Frame")

T.Frame:SetScript("OnEvent", function(frame, event, ...)
    if T[event] then
        T[event](T, ...)
    end
end)

for k, _ in pairs(T) do
    if k:match("^[A-Z0-9_]+$") then
        T.Frame:RegisterEvent(k)
    end
end

function T:Log(msg, debug)
    if debug and not T.DB.profile.Debug then return end
    DEFAULT_CHAT_FRAME:AddMessage(("|cff00B4FF[BGH]|r%s %s"):format(debug and " |cff00FF00Debug:|r" or "", msg))
end
