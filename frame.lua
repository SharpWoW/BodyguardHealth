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

T.BodyguardFrame = {}

local bf = T.BodyguardFrame

local locked = true

local backdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    edgeSize = 16,
    tileSize = 32,
    insets = {
        left = 2.5,
        right = 2.5,
        top = 2.5,
        bottom = 2.5
    }
}

local frame = CreateFrame("Frame", nil, UIParent)

-- DEBUG
bf.Frame = frame

frame:Hide()

frame:EnableMouse(false)
frame:SetMovable(false)

frame:SetBackdrop(backdrop)

frame.nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.nameLabel:SetWidth(100)
frame.nameLabel:SetHeight(16)
frame.nameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
frame.nameLabel:SetText("Bodyguard")
frame.nameLabel:SetJustifyH("LEFT")

frame.statusLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.statusLabel:SetWidth(70)
frame.statusLabel:SetHeight(16)
frame.statusLabel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
frame.statusLabel:SetText("Unknown")
frame.statusLabel:SetJustifyH("RIGHT")

frame.healthBar = CreateFrame("StatusBar", nil, frame)
local hb = frame.healthBar
hb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar", "ARTWORK")
hb:SetMinMaxValues(0, 1)
hb:SetValue(1)
hb:SetPoint("TOP", frame.nameLabel, "BOTTOM", 0, -5)
hb:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 5, 5)
hb:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -5, 5)
hb:SetStatusBarColor(0, 1, 0)

frame.healthLabel = hb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.healthLabel:SetHeight(25)
frame.healthLabel:SetPoint("TOPLEFT", frame.healthBar, "TOPLEFT")
frame.healthLabel:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMRIGHT")
frame.healthLabel:SetTextColor(1, 1, 1)
frame.healthLabel:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")

function bf:ResetSettings()
    frame:ClearAllPoints()
    frame:SetWidth(200)
    frame:SetHeight(60)
    frame:SetPoint("CENTER")
    self:SaveSettings()
end

function bf:UpdateSettings()
    local settings = T.DB.FrameSettings

    frame:ClearAllPoints()
    frame:SetWidth(settings.Width)
    frame:SetHeight(settings.Height)
    if settings.RelPoint then
        frame:SetPoint(settings.Point, nil, settings.RelPoint, settings.Offset.X, settings.Offset.Y)
    else
        frame:SetPoint(settings.Point, settings.Offset.X, settings.Offset.Y)
    end

    self:SaveSettings()
end

function bf:SaveSettings()
    local settings = T.DB.FrameSettings

    settings.Width = frame:GetWidth()
    settings.Height = frame:GetHeight()
    settings.Scale = frame:GetScale()
    local point, _, relPoint, x, y = frame:GetPoint(1)
    settings.Point = point
    settings.RelPoint = relPoint
    settings.Offset.X = x
    settings.Offset.Y = y
end

function bf:UpdateName(name)
    frame.nameLabel:SetText(name)
end

function bf:UpdateStatus(status)
    local text = "Unknown"
    for label, id in pairs(T.LBG.Status) do
        if id == status then text = label break end
    end
    frame.statusLabel:SetText(text)
end

local function round(num)
    return math.floor(num + 0.5)
end

local health_warnings = {
    [30] = false,
    [20] = false,
    [15] = false,
    [10] = false,
    [5] = false
}

function bf:UpdateHealthBar(health, maxHealth)
    local ratio = (maxHealth > 0) and (health / maxHealth) or 0

    local red = 1
    local green = 1

    if ratio > 0.5 then
        red = 2 - ratio * 2
    elseif ratio < 0.5 then
        green = ratio * 2
    end

    hb:SetStatusBarColor(red, green, 0)

    hb:SetMinMaxValues(0, maxHealth)
    hb:SetValue(health)

    local percentage = round(ratio * 100)

    frame.healthLabel:SetText(("%d%%"):format(percentage))

    if percentage <= 30 then
        for threshold, warned in pairs(health_warnings) do
            if percentage >= threshold and not warned then
                PlaySoundFile("Interface\\AddOns\\BodyguardHealth\\audio\\warn_health.ogg", "Master")
                RaidNotice_AddMessage(RaidWarningFrame, ("%s @ %d%%!"):format(T.LBG:GetName(), percentage), ChatTypeInfo["RAID_WARNING"])
                health_warnings[threshold] = true
            end
        end
    end
end

function bf:Show()
    if self:IsShowing() then return end
    frame:Show()
end

function bf:Hide()
    if not self:IsShowing() then return end
    frame:Hide()
end

function bf:IsShowing()
    return frame:IsVisible()
end

function bf:IsLocked()
    return locked
end

function bf:Unlock()
    frame:EnableMouse(true)
    frame:SetMovable(true)

    frame:SetScript("OnMouseDown", function(f) f:StartMoving() end)
    frame:SetScript("OnMouseUp", function(f)
        f:StopMovingOrSizing()
        bf:SaveSettings()
    end)

    if not self:IsShowing() then self:Show() end

    locked = false
end

function bf:Lock()
    frame:EnableMouse(false)
    frame:SetMovable(false)

    frame:SetScript("OnMouseDown", nil)
    frame:SetScript("OnMouseUp", nil)

    self:SaveSettings()

    locked = true
end
