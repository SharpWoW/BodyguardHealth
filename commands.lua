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

for i, v in pairs({"bodyguardhealth", "bgh"}) do
    _G["SLASH_" .. NAME:upper() .. i] = "/" .. v
end

local wasShowing = false

SlashCmdList[NAME:upper()] = function(msg, editBox)
    local cmd = (msg:match("%w+") or ""):lower()
    if cmd:match("^o") or cmd:match("^c") then -- Options
        -- TODO: Open options
    elseif cmd:match("^u") then -- Unlock frame
        wasShowing = T.BodyguardFrame:IsShowing()
        T.BodyguardFrame:Unlock()
    elseif cmd:match("^l") then -- Lock frame
        T.BodyguardFrame:Lock()
        if not wasShowing and T.LBG:GetStatus() == T.LBG.Status.Inactive then
            T.BodyguardFrame:Hide()
        end
    elseif cmd:match("^r") then -- Reset frame
        T.BodyguardFrame:ResetSettings()
    elseif cmd:match("^d") then -- Debug
        T.DB.Debug = not T.DB.Debug
        T:Log(("Debug %s"):format(T.DB.Debug and "enabled" or "disabled"))
    else
        T:Log("Available commands:")
        T:Log("options: Open the options")
        T:Log("unlock: Unlock the frame to move around")
        T:Log("lock: Locks the frame again")
        T:Log("reset: Resets the frame position")
        T:Log("debug: Toggles debug mode")
    end
end
