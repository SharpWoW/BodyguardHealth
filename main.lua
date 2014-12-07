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

function T:ADDON_LOADED(name)
    if name ~= NAME then return end

    self.LBG = LibStub("LibBodyguard-1.0")

    if not self.LBG then error("Failed to load LibBodyguard") end

    if type(BodyguardHealthDB) ~= "table" then
        BodyguardHealthDB = {}
    end

    self.DB = BodyguardHealthDB

    if type(self.DB.FrameSettings) ~= "table" then
        self.BodyguardFrame:ResetSettings()
    else
        self.BodyguardFrame:UpdateSettings()
    end

    if type(BodyguardHealthCharDB) ~= "table" then
        BodyguardHealthCharDB = {}
    end

    self.CharDB = BodyguardHealthCharDB

    if type(self.CharDB.HasBodyguard) ~= "boolean" then
        self.CharDB.HasBodyguard = false
    end

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

        T.CharDB.HasBodyguard = status ~= lib.Status.Inactive
    end)

    lbg:RegisterCallback("health", function(lib, health, maxhealth)
        T.BodyguardFrame:UpdateHealthBar(health, maxhealth)
        T.CharDB.Health = health
        T.CharDB.MaxHealth = maxhealth
    end)

    lbg:RegisterCallback("name", function(lib, name)
        T.BodyguardFrame:UpdateName(name)
    end)

    if self.CharDB.HasBodyguard then
        self.BodyguardFrame:Show()
        self.BodyguardFrame:UpdateHealthBar(self.CharDB.Health, self.CharDB.MaxHealth)
    end

    -- DEBUG
    _G["BodyguardHealth"] = self
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
    if debug and not T.DB.Debug then return end
    DEFAULT_CHAT_FRAME:AddMessage(("|cff00B4FF[BGH]|r%s %s"):format(debug and "|cff00FF00Debug:|r " or "", msg))
end
