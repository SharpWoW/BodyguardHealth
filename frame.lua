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

local frame

local created = false

local function Create()
    if frame and created then return end

    local WIDTH = 200
    local HEIGHT = 93

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

    frame = CreateFrame("Frame", nil, UIParent)

    frame:Hide()

    frame:EnableMouse(false)
    frame:SetMovable(false)

    frame:SetSize(WIDTH, HEIGHT)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER")

    frame:SetBackdrop(backdrop)

    frame.nameLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.nameLabel:SetWidth(WIDTH)
    frame.nameLabel:SetHeight(16)
    frame.nameLabel:SetPoint("TOP", frame, "TOP", 0, -5)
    frame.nameLabel:SetText("Bodyguard")

    frame.healthBar = frame:CreateTexture(nil, "ARTWORK")
    frame.healthBar:SetTexture("Interface\TargetingFrame\UI-StatusBar")
    frame.healthBar:SetVertexColor(0, 1, 0)
    frame.healthBar:SetWidth())

    frame.healthLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.healthLabel:SetWidth(WIDTH)
    frame.healthLabel:SetHeight(16)
    frame.healthLabel:SetPoint("CENTER", frame.healthBar, "CENTER")

    created = true
end

function bf:UpdateSettings()
    local settings = T.Global.FrameSettings

    frame:ClearAllPoints()
    frame:SetWidth(settings.Width)
    frame:SetHeight(settings.Height)
    frame:SetPoint(settings.Point, settings.Offset.X, settings.Offset.Y)
end

function bf:SaveSettings()
    local settings = T.Global.FrameSettings

    settings.Width = frame:GetWidth()
    settings.Height = frame:GetHeight()
    settings.Scale = frame:GetScale()
    local point, _, _, x, y = frame:GetPoint(1)
    settings.Point = point
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

function bf:UpdateHealthBar(health, maxHealth)
    local ratio = (maxHealth > 0) and (health / maxHealth) or 0

    frame.healthBar:SetTexCoord(0, ratio, 0, 1)
end

function bf:Show()
    Create()
    frame:Show()
end

function bf:Hide()
    frame:Hide()
end

function bf:Unlock()
    frame:EnableMouse(true)
    frame:SetMovable(true)

    frame:SetScript("OnMouseDown", function(f) f:StartMoving() end)
    frame:SetScript("OnMouseUp", function(f) f:StopMovingOrSizing() end)
end

function bf:Lock()
    frame:EnableMouse(false)
    frame:SetMovable(false)

    frame:SetScript("OnMouseDown", nil)
    frame:SetScript("OnMouseUp", nil)

    self:SaveSettings()
end
