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

local bgframe = T.BodyguardFrame

local interfacePanel
local framePanel

local options = {
    name = "Bodyguard Health",
    type = "group",
    args = {
        options = {
            name = "Interface options",
            desc = "Opens the GUI interface for configuring",
            type = "execute",
            guiHidden = true,
            func = function()
                if not interfacePanel then return end
                InterfaceOptionsFrame_OpenToCategory(framePanel)
                InterfaceOptionsFrame_OpenToCategory(interfacePanel) 
            end
        },
        general = {
            order = 1,
            name = "General options",
            type = "group",
            args = {
                debug = {
                    order = 1,
                    name = "Debug mode",
                    desc = "With debug mode enabled, more diagnostic messages will be printed to chat",
                    type = "toggle",
                    get = function(info) return T.DB.profile.Debug end,
                    set = function(info, val) T.DB.profile.Debug = val end
                },
                lock = {
                    order = 2,
                    name = "Lock frame",
                    desc = "Locks frame to prevent movement and enable click-through",
                    type = "toggle",
                    get = function(info) return bgframe:IsLocked() end,
                    set = function(info, val) if val then bgframe:Lock() else bgframe:Unlock() end end
                },
                reset = {
                    order = 3,
                    name = "Reset frame",
                    desc = "Resets frame position and size",
                    type = "execute",
                    func = function() bgframe:ResetSettings() end
                }
            }
        },
        frame = {
            order = 2,
            type = "group",
            name = "Frame settings",
            desc = "Settings for the health frame",
            args = {
                point = {
                    order = 1,
                    name = "Anchor point",
                    desc = "The anchor point for the frame",
                    type = "select",
                    style = "dropdown",
                    values = {TOP = "TOP", TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT",
                              BOTTOM = "BOTTOM", BOTTOMLEFT = "BOTTOMLEFT", BOTTOMRIGHT = "BOTTOMRIGHT",
                              CENTER = "CENTER", LEFT = "LEFT", RIGHT = "RIGHT"},
                    get = function(info) return T.DB.profile.FrameSettings.Point end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Point = val
                        bgframe:UpdateSettings()
                    end
                },
                relpoint = {
                    order = 2,
                    name = "Relative point",
                    desc = "The point which the frame will anchor relative to",
                    type = "select",
                    style = "dropdown",
                    values = {TOP = "TOP", TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT",
                              BOTTOM = "BOTTOM", BOTTOMLEFT = "BOTTOMLEFT", BOTTOMRIGHT = "BOTTOMRIGHT",
                              CENTER = "CENTER", LEFT = "LEFT", RIGHT = "RIGHT", NIL = "None"},
                    get = function(info) return T.DB.profile.FrameSettings.RelPoint or "NIL" end,
                    set = function(info, val)
                        if val == "NIL" then
                            T.DB.profile.FrameSettings.RelPoint = nil
                        else
                            T.DB.profile.FrameSettings.RelPoint = val
                        end
                        bgframe:UpdateSettings()
                    end
                },
                x = {
                    order = 7,
                    name = "X offset",
                    desc = "Amount of UI units to offset the frame horizontally",
                    type = "range",
                    min = -1000,
                    max = 1000,
                    step = 1,
                    bigStep = 10,
                    get = function(info) return T.DB.profile.FrameSettings.Offset.X end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Offset.X = val
                        bgframe:UpdateSettings()
                    end
                },
                y = {
                    order = 8,
                    name = "Y offset",
                    desc = "Amount of UI units to offset the frame vertically",
                    type = "range",
                    min = -1000,
                    max = 1000,
                    step = 1,
                    bigStep = 10,
                    get = function(info) return T.DB.profile.FrameSettings.Offset.Y end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Offset.Y = val
                        bgframe:UpdateSettings()
                    end
                },
                width = {
                    order = 4,
                    name = "Width",
                    desc = "Width of the health frame",
                    type = "range",
                    min = 200,
                    max = 800,
                    step = 1,
                    bigStep = 10,
                    get = function(info) return T.DB.profile.FrameSettings.Width end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Width = val
                        bgframe:UpdateSettings()
                    end
                },
                height = {
                    order = 5,
                    name = "Height",
                    desc = "Height of the health frame",
                    type = "range",
                    min = 40,
                    max = 800,
                    step = 1,
                    bigStep = 10,
                    get = function(info) return T.DB.profile.FrameSettings.Height end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Height = val
                        bgframe:UpdateSettings()
                    end
                },
                scale = {
                    order = 6,
                    name = "Scale",
                    desc = "Frame scale",
                    type = "range",
                    min = 0,
                    max = 10,
                    step = 0.01,
                    bigStep = 0.1,
                    get = function(info) return T.DB.profile.FrameSettings.Scale end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Scale = val
                        bgframe:UpdateSettings()
                    end
                }
            }
        }
    }
}

T.Options = {}

function T.Options:Initialize()
    local media = LibStub("LibSharedMedia-3.0", true)
    if media then
        options.args.general.args.warnsound = {
            order = 4,
            name = "Health warning sound",
            desc = "Sound to play when bodyguard health is dangerously low",
            type = "select",
            values = function(info)
                return media:HashTable(media.MediaType.SOUND)
            end,
            dialogControl = "LSM30_Sound",
            get = function(info) return T.DB.profile.WarnSound end,
            set = function(info, val) T.DB.profile.WarnSound = val end
        }

        options.args.frame.args.texture = {
            order = 3,
            name = "Health bar texture",
            desc = "Select the texture to use for the health bar",
            type = "select",
            values = function(info)
                return media:HashTable(media.MediaType.STATUSBAR)
            end,
            dialogControl = "LSM30_Statusbar",
            get = function(info) return T.DB.profile.FrameSettings.Texture end,
            set = function(info, val)
                T.DB.profile.FrameSettings.Texture = val
                bgframe:UpdateSettings()
            end
        }
    end
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(T.DB)
    LibStub("AceConfig-3.0"):RegisterOptionsTable(NAME, options, {"bodyguardhealth", "bgh"})
    local acd = LibStub("AceConfigDialog-3.0")
    interfacePanel = acd:AddToBlizOptions(NAME, "Bodyguard Health", nil, "general")
    framePanel = acd:AddToBlizOptions(NAME, "Frame settings", "Bodyguard Health", "frame")
    acd:AddToBlizOptions(NAME, "Profile", "Bodyguard Health", "profile")
end