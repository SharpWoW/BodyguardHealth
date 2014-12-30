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

T.Dropdown = {}

local D = T.Dropdown

StaticPopupDialogs.BODYGUARDHEALTH_LOCK = {
    text = "Health frame is unlocked, you can move it around freely.",
    button2 = "Lock",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    OnCancel = function() T.BodyguardFrame:Lock() end
}

function D:Create()
    if self.Created then return end
    self.Frame = CreateFrame("Frame", "BodyguardHealthFrameDropdown", UIParent, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(self.Frame, self.Initialize, "MENU")
    self.Created = true
end

function D.Initialize(frame, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Hide"
    info.func = function() T.BodyguardFrame:Hide() end
    info.notCheckable = true
    UIDropDownMenu_AddButton(info)
    info.text = "Unlock"
    info.func = function()
        T.BodyguardFrame:Unlock()
        StaticPopup_Show("BODYGUARDHEALTH_LOCK")
    end
    UIDropDownMenu_AddButton(info)
    info.text = "Open options"
    info.func = function() T.Options:Open() end
    UIDropDownMenu_AddButton(info)
    info.text = "Disable this menu"
    info.func = function() T.BodyguardFrame:DisableMenu() end
    UIDropDownMenu_AddButton(info)
    info.text = "Disable AddOn"
    info.func = function() T:Disable() end
    UIDropDownMenu_AddButton(info)
end

function D:Show(frame)
    self:Create()
    ToggleDropDownMenu(1, nil, self.Frame, "cursor", 3, -3)
end
