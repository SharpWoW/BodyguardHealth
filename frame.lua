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

local frame
local created = false

local function Create()
    if created then return end

    frame = CreateFrame("Frame", nil, UIParent)

    -- DEBUG
    bf.Frame = frame

    frame:Hide()

    frame:EnableMouse(false)
    frame:SetMovable(false)

    frame.statusLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.statusLabel:SetWidth(70)
    frame.statusLabel:SetHeight(16)
    frame.statusLabel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    frame.statusLabel:SetText("Unknown")
    frame.statusLabel:SetJustifyH("RIGHT")

    frame.nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.nameLabel:SetWidth(100)
    frame.nameLabel:SetHeight(16)
    frame.nameLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -5)
    frame.nameLabel:SetPoint("RIGHT", frame.statusLabel, "LEFT", -5, 0)
    frame.nameLabel:SetText("Bodyguard")
    frame.nameLabel:SetJustifyH("LEFT")

    frame.healthBar = CreateFrame("StatusBar", nil, frame)
    local hb = frame.healthBar
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
    
    created = true

    bf:UpdateSettings()
end

function bf:ResetSettings()
    Create()
    frame:ClearAllPoints()
    frame:SetWidth(200)
    frame:SetHeight(60)
    frame:SetScale(1)
    frame:SetPoint("CENTER")
    self:SaveSettings()
end

function bf:UpdateSettings()
    Create()

    local settings = T.DB.profile.FrameSettings

    frame:ClearAllPoints()
    frame:SetWidth(settings.Width or 200)
    frame:SetHeight(settings.Height or 60)
    if settings.RelPoint then
        frame:SetPoint(settings.Point or "CENTER", nil, settings.RelPoint, settings.Offset.X or 0, settings.Offset.Y or 0)
    else
        frame:SetPoint(settings.Point or "CENTER", settings.Offset.X or 0, settings.Offset.Y or 0)
    end

    frame:SetScale(settings.Scale)

    local lsm = T.LSM

    local backdrop = {
        bgFile = lsm:Fetch(lsm.MediaType.BACKGROUND, settings.Backdrop.Background),
        edgeFile = lsm:Fetch(lsm.MediaType.BORDER, settings.Backdrop.Border),
        tile = settings.Backdrop.Tile,
        edgeSize = settings.Backdrop.BorderSize,
        tileSize = settings.Backdrop.TileSize,
        insets = {
            left = settings.Backdrop.Insets.Left,
            right = settings.Backdrop.Insets.Right,
            top = settings.Backdrop.Insets.Top,
            bottom = settings.Backdrop.Insets.Bottom
        }
    }

    frame:SetBackdrop(backdrop)
    local bdcolor = settings.Backdrop.Color
    frame:SetBackdropColor(bdcolor.R, bdcolor.G, bdcolor.B, bdcolor.A)
    local bdbcolor = settings.Backdrop.BorderColor
    frame:SetBackdropBorderColor(bdbcolor.R, bdbcolor.G, bdbcolor.B, bdbcolor.A)

    frame.healthBar:SetStatusBarTexture(lsm:Fetch(lsm.MediaType.STATUSBAR, settings.Texture), "ARTWORK")

    frame.healthLabel:SetFont(lsm:Fetch(lsm.MediaType.FONT, settings.Font), settings.FontSize, settings.FontFlags)

    self:SaveSettings()
end

function bf:SaveSettings()
    Create()

    local settings = T.DB.profile.FrameSettings

    settings.Width = frame:GetWidth()
    settings.Height = frame:GetHeight()
    settings.Scale = frame:GetScale()
    local point, _, relPoint, x, y = frame:GetPoint(1)
    settings.Point = point
    settings.RelPoint = relPoint
    settings.Offset.X = x
    settings.Offset.Y = y
    --settings.Texture = hb:GetStatusBarTexture():GetTexture()
end

function bf:UpdateName(name)
    Create()
    frame.nameLabel:SetText(name)
end

function bf:UpdateStatus(status)
    Create()
    local text = "Unknown"
    for label, id in pairs(T.LBG.Status) do
        if id == status then text = label break end
    end
    frame.statusLabel:SetText(text)
end

local function round(num)
    return math.floor(num + 0.5)
end

local at_warn_threshold = false
local health_warnings = {5, 10, 20, 30}
local health_warns = {}

function bf:UpdateHealthBar(health, maxHealth)
    Create()
    local ratio = (maxHealth > 0) and (health / maxHealth) or 0

    local red = 1
    local green = 1

    if ratio > 0.5 then
        red = 2 - ratio * 2
    elseif ratio < 0.5 then
        green = ratio * 2
    end

    local hb = frame.healthBar

    hb:SetStatusBarColor(red, green, 0)

    hb:SetMinMaxValues(0, maxHealth)
    hb:SetValue(health)

    local percentage = round(ratio * 100)

    frame.healthLabel:SetText(("%d%%"):format(percentage))

    if T.LBG:GetStatus() == T.LBG.Status.Inactive then return end

    if percentage <= 30 then
        at_warn_threshold = true
        for i = 1, #health_warnings do
            local threshold = health_warnings[i]
            if percentage <= threshold then
                if not health_warns[i] then
                    PlaySoundFile(T.LSM.Fetch(T.LSM.MediaType.SOUND, T.DB.WarnSound), "Master")
                    RaidNotice_AddMessage(RaidWarningFrame, ("%s @ %d%%!"):format(T.LBG:GetName(), percentage), ChatTypeInfo["RAID_WARNING"])
                    health_warns[i] = true
                end
                break
            end
        end
    elseif at_warn_threshold then
        at_warn_threshold = false
        for i = 1, #health_warnings do
            health_warns[i] = false
        end
    end
end

function bf:Show()
    if self:IsShowing() then return end
    Create()
    self:UpdateSettings()
    frame:Show()
end

function bf:Hide()
    if not self:IsShowing() then return end
    Create()
    frame:Hide()
end

function bf:IsShowing()
    return created and frame:IsVisible()
end

function bf:IsLocked()
    return locked
end

function bf:Unlock()
    Create()
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
    Create()
    frame:EnableMouse(false)
    frame:SetMovable(false)

    frame:SetScript("OnMouseDown", nil)
    frame:SetScript("OnMouseUp", nil)

    self:SaveSettings()

    locked = true
end
