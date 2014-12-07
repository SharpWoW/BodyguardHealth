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

local defaults = {
    profile = {
        Debug = false,
        WarnSound = "BGH: Health Warning",
        FrameSettings = {
            Width = 200,
            Height = 60,
            Scale = 1,
            Point = "CENTER",
            RelPoint = nil,
            Offset = {
                X = 0,
                Y = 0
            },
            Texture = "Blizzard"
        }
    },
    char = {
        HasBodyguard = false
    }
}

function T:ADDON_LOADED(name)
    if name ~= NAME then return end

    self.LSM = LibStub("LibSharedMedia-3.0")
    self.LBG = LibStub("LibBodyguard-1.0")
    self.DB = LibStub("AceDB-3.0"):New("BodyguardHealthDB", defaults, true)

    self.LSM:Register(self.LSM.MediaType.SOUND, "BGH: Health Warning", "Interface\\AddOns\\BodyguardHealth\\audio\\warn_health.ogg")

    self.DB:RegisterCallback("OnProfileChanged", function()
        T.BodyguardFrame:UpdateSettings()
    end)

    local lbg = self.LBG

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

    lbg:RegisterCallback("health", function(lib, health, maxhealth)
        T.BodyguardFrame:UpdateHealthBar(health, maxhealth)
        T.DB.char.Health = health
        T.DB.char.MaxHealth = maxhealth
    end)

    lbg:RegisterCallback("name", function(lib, name)
        T.BodyguardFrame:UpdateName(name)
    end)

    if self.DB.char.HasBodyguard then
        self.BodyguardFrame:Show()
        self.BodyguardFrame:UpdateHealthBar(self.DB.char.Health, self.DB.char.MaxHealth)
    end

    self.Options:Initialize()

    -- DEBUG
    _G["BodyguardHealth"] = self
end

function T:PLAYER_ENTERING_WORLD()
    local showing = self.BodyguardFrame:IsShowing()
    SetMapToCurrentZone()
    local areaId = GetCurrentMapAreaID()
    if showing and (GetCurrentMapContinent() ~= CONTINENT_DRAENOR or BODYGUARD_BANNED_ZONES[areaId]) then
        self.BodyguardFrame:Hide()
    elseif showing then
        self.BodyguardFrame:UpdateSettings()
    elseif self.LBG:GetStatus() ~= self.LBG.Status.Inactive then
        self.BodyguardFrame:Show()
    end
end

function T:ZONE_CHANGED_NEW_AREA()
    T:Log("ZONE_CHANGED_NEW_AREA", true)
    if not self.BodyguardFrame:IsShowing() then return end
    SetMapToCurrentZone()
    local areaId = GetCurrentMapAreaID()
    T:Log("Current area ID: " .. areaId, true)
    if BODYGUARD_BANNED_ZONES[areaId] then
        T:Log("Banned zone, hiding", true)
        self.BodyguardFrame:Hide()
    elseif self.LBG:GetStatus() ~= self.LBG.Status.Inactive then
        self.BodyguardFrame:Show()
    end
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
