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
                T.Options:Open()
            end
        },
        general = {
            order = 1,
            name = "General options",
            type = "group",
            args = {
                enabled = {
                    order = 1,
                    name = "Enabled",
                    desc = "When AddOn is disabled, the frame will be hidden from view",
                    type = "toggle",
                    get = function(info) return T.DB.profile.Enabled end,
                    set = function(info, val)
                        if val then
                            T:Enable()
                        else
                            T:Disable()
                        end
                    end
                },
                debug = {
                    order = 2,
                    name = "Debug mode",
                    desc = "With debug mode enabled, more diagnostic messages will be printed to chat",
                    type = "toggle",
                    get = function(info) return T.DB.profile.Debug end,
                    set = function(info, val) T.DB.profile.Debug = val end
                },
                lock = {
                    order = 3,
                    name = "Lock frame",
                    desc = "Locks frame to prevent movement and enable click-through",
                    type = "toggle",
                    get = function(info) return bgframe:IsLocked() end,
                    set = function(info, val) if val then bgframe:Lock() else bgframe:Unlock() end end
                },
                reset = {
                    order = 4,
                    name = "Reset frame",
                    desc = "Resets frame position and size",
                    type = "execute",
                    func = function() bgframe:ResetSettings() end
                },
                enablewarn = {
                    order = 5,
                    name = "Enable health warnings",
                    desc = "Enables the playing of sound and display of a raid warning when bodyguard is low on health",
                    type = "toggle",
                    get = function(info) return T.DB.profile.EnableWarn end,
                    set = function(info, val) T.DB.profile.EnableWarn = val end
                },
                show = {
                    order = 6,
                    name = "Show frame",
                    desc = "Forces the frame to show",
                    type = "execute",
                    func = function() bgframe:Show(true) end
                },
                hide = {
                    order = 7,
                    name = "Hide frame",
                    desc = "Forces the frame to hide",
                    type = "execute",
                    func = function() bgframe:Hide() end
                },
                gossipclose = {
                    order = 8,
                    name = "Auto-close gossip",
                    desc = "With this enabled, the bodyguard gossip window will automatically close when opened unless the configured modifier key is held",
                    type = "toggle",
                    get = function(info) return T.DB.profile.CloseGossip end,
                    set = function(info, val) T.DB.profile.CloseGossip = val end
                },
                gossipclosemodifier = {
                    order = 9,
                    name = "Gossip close override modifier",
                    desc = "When auto-close gossip is enabled, holding this modifier key down will prevent it from closing automatically",
                    type = "select",
                    values = {
                        control = "Control",
                        shift = "Shift",
                        alt = "Alt"
                    },
                    get = function(info) return T.DB.profile.CloseGossipModifier end,
                    set = function(info, val) T.DB.profile.CloseGossipModifier = val end
                }
            }
        },
        frame = {
            order = 2,
            type = "group",
            name = "Frame settings",
            desc = "Settings for the health frame",
            args = {
                header1 = { name = "General options", type = "header", order = 1 },
                point = {
                    order = 2,
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
                    order = 3,
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
                width = {
                    order = 5,
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
                    order = 6,
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
                    order = 7,
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
                },
                x = {
                    order = 8,
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
                    order = 9,
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
                header2 = { name = "Background and Border", type = "header", order = 10 },
                tile = {
                    order = 13,
                    name = "Tile background",
                    desc = "Tile the background texture",
                    type = "toggle",
                    get = function(info) return T.DB.profile.FrameSettings.Backdrop.Tile end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Backdrop.Tile = val
                        bgframe:UpdateSettings()
                    end
                },
                color = {
                    order = 14,
                    name = "Background color",
                    desc = "The color of the frame background",
                    type = "color",
                    hasAlpha = true,
                    get = function(info)
                        local color = T.DB.profile.FrameSettings.Backdrop.Color
                        return color.R, color.G, color.B, color.A
                    end,
                    set = function(info, r, g, b, a)
                        local color = T.DB.profile.FrameSettings.Backdrop.Color
                        color.R = r
                        color.G = g
                        color.B = b
                        color.A = a
                        bgframe:UpdateSettings()
                    end
                },
                borderColor = {
                    order = 15,
                    name = "Border color",
                    desc = "The color of the frame border",
                    type = "color",
                    hasAlpha = true,
                    get = function(info)
                        local color = T.DB.profile.FrameSettings.Backdrop.BorderColor
                        return color.R, color.G, color.B, color.A
                    end,
                    set = function(info, r, g, b, a)
                        local color = T.DB.profile.FrameSettings.Backdrop.BorderColor
                        color.R = r
                        color.G = g
                        color.B = b
                        color.A = a
                        bgframe:UpdateSettings()
                    end
                },
                borderSize = {
                    order = 16,
                    name = "Border size",
                    desc = "The size of the frame border",
                    type = "range",
                    min = 0,
                    max = 128,
                    step = 1,
                    get = function(info) return T.DB.profile.FrameSettings.Backdrop.BorderSize end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Backdrop.BorderSize = val
                        bgframe:UpdateSettings()
                    end
                },
                tileSize = {
                    order = 17,
                    name = "Tile size",
                    type = "range",
                    min = 0,
                    max = 128,
                    step = 1,
                    get = function(info) return T.DB.profile.FrameSettings.Backdrop.TileSize end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Backdrop.TileSize = val
                        bgframe:UpdateSettings()
                    end
                },
                inset = {
                    order = 18,
                    name = "Inset",
                    type = "range",
                    min = -64,
                    max = 64,
                    step = 0.1,
                    bigStep = 0.5,
                    -- We return just left, as currently we sync all of them
                    get = function(info) return T.DB.profile.FrameSettings.Backdrop.Insets.Left end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.Backdrop.Insets.Left = val
                        T.DB.profile.FrameSettings.Backdrop.Insets.Right = val
                        T.DB.profile.FrameSettings.Backdrop.Insets.Top = val
                        T.DB.profile.FrameSettings.Backdrop.Insets.Bottom = val
                        bgframe:UpdateSettings()
                    end
                },
                header3 = { order = 19, name = "Healthbar", type = "header" },
                bartextflags = {
                    order = 21,
                    name = "Bar text outline",
                    type = "select",
                    style = "dropdown",
                    values = {
                        NONE = "None",
                        OUTLINE = "Outline",
                        THICKOUTLINE = "Thick outline",
                        ["OUTLINE, MONOCHROME"] = "Monochrome outline",
                        ["THICKOUTLINE, MONOCHROME"] = "Monochrome thick outline"
                    },
                    get = function(info) return T.DB.profile.FrameSettings.FontFlags or "NONE" end,
                    set = function(info, val)
                        if val == "NONE" then
                            T.DB.profile.FrameSettings.FontFlags = nil
                        else
                            T.DB.profile.FrameSettings.FontFlags = val
                        end
                        bgframe:UpdateSettings()
                    end
                },
                bartextsize = {
                    order = 22,
                    name = "Bar text size",
                    type = "range",
                    min = 1,
                    max = 128,
                    step = 1,
                    get = function(info) return T.DB.profile.FrameSettings.FontSize end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.FontSize = val
                        bgframe:UpdateSettings()
                    end
                },
                bartextcolor = {
                    order = 23,
                    name = "Bar text color",
                    type = "color",
                    hasAlpha = true,
                    get = function(info)
                        local color = T.DB.profile.FrameSettings.FontColor
                        return color.R, color.G, color.B, color.A
                    end,
                    set = function(info, r, g, b, a)
                        local color = T.DB.profile.FrameSettings.FontColor
                        color.R = r
                        color.G = g
                        color.B = b
                        color.A = a
                        bgframe:UpdateSettings()
                    end
                },
                barhealthcolored = {
                    order = 24,
                    name = "Color based on health",
                    desc = "Colors the health bar based on bodyguard health (red at 0%, green at 100%).",
                    type = "toggle",
                    get = function(info) return T.DB.profile.FrameSettings.HealthBasedColor end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.HealthBasedColor = val
                        bgframe:UpdateHealthBar()
                    end
                },
                barcustomcolor = {
                    order = 25,
                    name = "Custom health bar color",
                    desc = "Configures a static color to use for the health bar, only used if health based coloring is disabled.",
                    type = "color",
                    hasAlpha = false,
                    get = function(info)
                        local color = T.DB.profile.FrameSettings.CustomColor
                        return color.R, color.G, color.B
                    end,
                    set = function(info, r, g, b)
                        local color = T.DB.profile.FrameSettings.CustomColor
                        color.R = r
                        color.G = g
                        color.B = b
                        bgframe:UpdateHealthBar()
                    end
                },
                header4 = { order = 26, name = "Other options", type = "header" },
                menuenabled = {
                    order = 27,
                    name = "Menu enabled",
                    desc = "Enables a right click menu on the health frame with some convenient options, frame is click-through when menu is disabled.",
                    type = "toggle",
                    get = function(info) return T.DB.profile.FrameSettings.MenuEnabled end,
                    set = function(info, val)
                        T.DB.profile.FrameSettings.MenuEnabled = val
                        bgframe:SetMenu(val)
                    end
                }
            }
        }
    }
}

T.Options = {}

function T.Options:Initialize()
    local media = T.LSM
    if media then
        options.args.general.args.warnsound = {
            order = 5,
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
            order = 4,
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

        options.args.frame.args.background = {
            order = 11,
            name = "Frame background",
            desc = "Select the texture to use for the frame background",
            type = "select",
            values = function(info)
                return media:HashTable(media.MediaType.BACKGROUND)
            end,
            dialogControl = "LSM30_Background",
            get = function(info) return T.DB.profile.FrameSettings.Backdrop.Background end,
            set = function(info, val)
                T.DB.profile.FrameSettings.Backdrop.Background = val
                bgframe:UpdateSettings()
            end
        }

        options.args.frame.args.border = {
            order = 12,
            name = "Frame border",
            desc = "Select the border texture to use for the frame",
            type = "select",
            values = function(info)
                return media:HashTable(media.MediaType.BORDER)
            end,
            dialogControl = "LSM30_Border",
            get = function(info) return T.DB.profile.FrameSettings.Backdrop.Border end,
            set = function(info, val)
                T.DB.profile.FrameSettings.Backdrop.Border = val
                bgframe:UpdateSettings()
            end
        }

        options.args.frame.args.barfont = {
            order = 20,
            name = "Bar font",
            desc = "Set the font to use for displaying the health percentage",
            type = "select",
            values = function(info)
                return media:HashTable(media.MediaType.FONT)
            end,
            dialogControl = "LSM30_Font",
            get = function(info) return T.DB.profile.FrameSettings.Font end,
            set = function(info, val)
                T.DB.profile.FrameSettings.Font = val
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

function T.Options:Open()
    if not interfacePanel then return end
    InterfaceOptionsFrame_OpenToCategory(framePanel)
    InterfaceOptionsFrame_OpenToCategory(interfacePanel) 
end
