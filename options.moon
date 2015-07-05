-- Copyright (c) 2014 by Adam Hellberg.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

NAME, T = ...
bgframe = T.BodyguardFrame
local interfacePanel, framePanel
options =
    name: 'Bodyguard Health'
    type: 'group'
    args:
        options:
            name: 'Interface options'
            desc: 'Opens the GUI interface for configuring'
            type: 'execute'
            guiHidden: true
            func: () ->
                T.Options\Open!
        general:
            order: 1
            name: 'General options'
            type: 'group'
            args:
                enabled:
                    order: 1
                    name: 'Enabled'
                    desc: 'When AddOn is disabled, the frame will be hidden from view'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.Enabled
                    set: (info, val) ->
                        if val then T\Enable! else T\Disable!
                debug:
                    order: 2
                    name: 'Debug mode'
                    desc: 'With debug mode enabled, more diagnostic messages will be printed to chat'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.Debug
                    set: (info, val) -> T.DB.profile.Debug = val
                lock:
                    order: 3
                    name: 'Lock frame'
                    desc: 'Locks frame to prevent movement and enable click-through'
                    type: 'toggle'
                    get: (info) -> bgframe\IsLocked!
                    set: (info, val) ->
                        if val then bgframe\Lock! else bgframe\Unlock!
                reset:
                    order: 4
                    name: 'Reset frame'
                    desc: 'Resets frame position and size'
                    type: 'execute'
                    func: () -> bgframe\ResetSettings!
                enablewarn:
                    order: 5
                    name: 'Enable health warnings'
                    desc: 'Enables the playing of sound and display of a raid warning when bodyguard is low on health'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.EnableWarn
                    set: (info, val) -> T.DB.profile.EnableWarn = val
                show:
                    order: 6
                    name: 'Show frame'
                    desc: 'Forces the frame to show'
                    type: 'execute'
                    func: () -> bgframe\Show true
                hide:
                    order: 7
                    name: 'Hide frame'
                    desc: 'Forces the frame to hide'
                    type: 'execute'
                    func: () -> bgframe\Hide!
                gossipclose:
                    order: 8
                    name: 'Auto-close gossip'
                    desc: 'With this enabled, the bodyguard gossip window will automatically close when opened unless the configured modifier key is held'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.CloseGossip
                    set: (info, val) -> T.DB.profile.CloseGossip = val
                gossipclosemodifier:
                    order: 9
                    name: 'Gossip close override modifier'
                    desc: 'When auto-close gossip is enabled, holding this modifier key down will prevent it from closing automatically'
                    type: 'select'
                    values:
                        control: 'Control'
                        shift: 'Shift'
                        alt: 'Alt'
                    get: (info) -> T.DB.profile.CloseGossipModifier
                    set: (info, val) -> T.DB.profile.CloseGossipModifier = val
        frame:
            order: 2
            type: 'group'
            name: 'Frame settings'
            desc: 'Settings for the health frame'
            args:
                header1:
                    name: 'General options'
                    type: 'header'
                    order: 1
                point:
                    order: 2
                    name: 'Anchor point'
                    desc: 'The anchor point for the frame'
                    type: 'select'
                    style: 'dropdown'
                    values:
                        TOP: 'TOP'
                        TOPLEFT: 'TOPLEFT'
                        TOPRIGHT: 'TOPRIGHT'
                        BOTTOM: 'BOTTOM'
                        BOTTOMLEFT: 'BOTTOMLEFT'
                        BOTTOMRIGHT: 'BOTTOMRIGHT'
                        CENTER: 'CENTER'
                        LEFT: 'LEFT'
                        RIGHT: 'RIGHT'
                    get: (info) -> T.DB.profile.FrameSettings.Point
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Point = val
                        bgframe\UpdateSettings!
                relpoint:
                    order: 3
                    name: 'Relative point'
                    desc: 'The point which the frame will anchor relative to'
                    type: 'select'
                    style: 'dropdown'
                    values:
                        TOP: 'TOP'
                        TOPLEFT: 'TOPLEFT'
                        TOPRIGHT: 'TOPRIGHT'
                        BOTTOM: 'BOTTOM'
                        BOTTOMLEFT: 'BOTTOMLEFT'
                        BOTTOMRIGHT: 'BOTTOMRIGHT'
                        CENTER: 'CENTER'
                        LEFT: 'LEFT'
                        RIGHT: 'RIGHT'
                        NIL: 'None'
                    get: (info) -> T.DB.profile.FrameSettings.RelPoint or 'NIL'
                    set: (info, val) ->
                        if val == 'NIL'
                            T.DB.profile.FrameSettings.RelPoint = nil
                        else
                            T.DB.profile.FrameSettings.RelPoint = val
                        bgframe\UpdateSettings!
                width:
                    order: 5
                    name: 'Width'
                    desc: 'Width of the health frame (values below 200 not recommended)'
                    type: 'range'
                    min: 1
                    max: 1000
                    step: 1
                    bigStep: 10
                    get: (info) -> T.DB.profile.FrameSettings.Width
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Width = val
                        bgframe\UpdateSettings!
                height:
                    order: 6
                    name: 'Height'
                    desc: 'Height of the health frame (values below 40 not recommended)'
                    type: 'range'
                    min: 1
                    max: 1000
                    step: 1
                    bigStep: 10
                    get: (info) -> T.DB.profile.FrameSettings.Height
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Height = val
                        bgframe\UpdateSettings!
                scale:
                    order: 7
                    name: 'Scale'
                    desc: 'Frame scale'
                    type: 'range'
                    min: 0.01
                    max: 10
                    step: 0.01
                    bigStep: 0.1
                    get: (info) -> T.DB.profile.FrameSettings.Scale
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Scale = val
                        bgframe\UpdateSettings!
                x:
                    order: 8
                    name: 'X offset'
                    desc: 'Amount of UI units to offset the frame horizontally'
                    type: 'range'
                    min: -1000
                    max: 1000
                    step: 1
                    bigStep: 10
                    get: (info) -> T.DB.profile.FrameSettings.Offset.X
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Offset.X = val
                        bgframe\UpdateSettings!
                y:
                    order: 9
                    name: 'Y offset'
                    desc: 'Amount of UI units to offset the frame vertically'
                    type: 'range'
                    min: -1000
                    max: 1000
                    step: 1
                    bigStep: 10
                    get: (info) -> T.DB.profile.FrameSettings.Offset.Y
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Offset.Y = val
                        bgframe\UpdateSettings!
                header2:
                    name: 'Background and Border'
                    type: 'header'
                    order: 10
                tile:
                    order: 13
                    name: 'Tile background'
                    desc: 'Tile the background texture'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.FrameSettings.Backdrop.Tile
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Backdrop.Tile = val
                        bgframe\UpdateSettings!
                color:
                    order: 14
                    name: 'Background color'
                    desc: 'The color of the frame background'
                    type: 'color'
                    hasAlpha: true
                    get: (info) ->
                        with T.DB.profile.FrameSettings.Backdrop.Color
                            .R, .G, .B, .A
                    set: (info, r, g, b, a) ->
                        with T.DB.profile.FrameSettings.Backdrop.Color
                            .R, .G, .B, .A = r, g, b, a
                        bgframe\UpdateSettings!
                borderColor:
                    order: 15
                    name: 'Border color'
                    desc: 'The color of the frame border'
                    type: 'color'
                    hasAlpha: true
                    get: (info) ->
                        with T.DB.profile.FrameSettings.Backdrop.BorderColor
                            .R, .G, .B, .A
                    set: (info, r, g, b, a) ->
                        with T.DB.profile.FrameSettings.Backdrop.BorderColor
                            .R, .G, .B, .A = r, g, b, a
                        bgframe\UpdateSettings!
                borderSize:
                    order: 16
                    name: 'Border size'
                    desc: 'The size of the frame border'
                    type: 'range'
                    min: 0
                    max: 128
                    step: 1
                    get: (info) -> T.DB.profile.FrameSettings.Backdrop.BorderSize
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Backdrop.BorderSize = val
                        bgframe\UpdateSettings!
                tileSize:
                    order: 17
                    name: 'Tile size'
                    type: 'range'
                    min: 0
                    max: 128
                    step: 1
                    get: (info) -> T.DB.profile.FrameSettings.Backdrop.TileSize
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.Backdrop.TileSize = val
                        bgframe\UpdateSettings!
                inset:
                    order: 18
                    name: 'Inset'
                    type: 'range'
                    min: -64
                    max: 64
                    step: 0.1
                    bigStep: 0.5
                    -- We return just left, as currently we sync all of them
                    get: (info) -> T.DB.profile.FrameSettings.Backdrop.Insets.Left
                    set: (info, val) ->
                        with T.DB.profile.FrameSettings.Backdrop.Insets
                            .Left = val
                            .Right = val
                            .Top = val
                            .Bottom = val
                        bgframe\UpdateSettings!
                header3:
                    order: 19
                    name: 'Healthbar'
                    type: 'header'
                bartextflags:
                    order: 21
                    name: 'Bar text outline'
                    type: 'select'
                    style: 'dropdown'
                    values:
                        NONE: 'None'
                        OUTLINE: 'Outline'
                        THICKOUTLINE: 'Thick outline'
                        ['OUTLINE, MONOCHROME']: 'Monochrome outline'
                        ['THICKOUTLINE, MONOCHROME']: 'Monochrome thick outline'
                    get: (info) -> T.DB.profile.FrameSettings.FontFlags or 'NONE'
                    set: (info, val) ->
                        if val == 'NONE'
                            T.DB.profile.FrameSettings.FontFlags = nil
                        else
                            T.DB.profile.FrameSettings.FontFlags = val
                        bgframe\UpdateSettings!
                bartextsize:
                    order: 22
                    name: 'Bar text size'
                    type: 'range'
                    min: 1
                    max: 128
                    step: 1
                    get: (info) -> T.DB.profile.FrameSettings.FontSize
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.FontSize = val
                        bgframe\UpdateSettings!
                bartextcolor:
                    order: 23
                    name: 'Bar text color'
                    type: 'color'
                    hasAlpha: true
                    get: (info) ->
                        with T.DB.profile.FrameSettings.FontColor
                            .R, .G, .B, .A
                   
                    set: (info, r, g, b, a) ->
                        with T.DB.profile.FrameSettings.FontColor
                            .R, .G, .B, .A = r, g, b, a
                        bgframe\UpdateSettings!
                barhealthcolored:
                    order: 24
                    name: 'Color based on health'
                    desc: 'Colors the health bar based on bodyguard health (red at 0%, green at 100%).'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.FrameSettings.HealthBasedColor
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.HealthBasedColor = val
                        bgframe\UpdateHealthBar!
                barcustomcolor:
                    order: 25
                    name: 'Custom health bar color'
                    desc: 'Configures a static color to use for the health bar, only used if health based coloring is disabled.'
                    type: 'color'
                    hasAlpha: false
                    get: (info) ->
                        with T.DB.profile.FrameSettings.CustomColor
                            .R, .G, .B
                   
                    set: (info, r, g, b) ->
                        with T.DB.profile.FrameSettings.CustomColor
                            .R, .G, .B = r, g, b
                        bgframe\UpdateHealthBar!
                bartextstyle:
                    order: 26
                    name: 'Health text style'
                    desc: 'Configures how the health text should be displayed on the bar.'
                    type: 'select'
                    style: 'dropdown'
                    values:
                        NONE: 'None (empty)'
                        PERCENTAGE: '100%'
                        SHORT: '18.3k'
                        LONG: '18,300'
                        MIXED: '18.3k (100%)'
                    get: (info) -> T.DB.profile.FrameSettings.HealthTextStyle
                    set: (info, value) ->
                        T.DB.profile.FrameSettings.HealthTextStyle = value
                        bgframe\UpdateSettings!
                        bgframe\UpdateHealthBar!
                header4:
                    order: 27
                    name: 'Other options'
                    type: 'header'
                menuenabled:
                    order: 28
                    name: 'Click-through'
                    desc: 'When frame is click-through, the menu and targeting capabilities are disabled.'
                    type: 'toggle'
                    get: (info) -> T.DB.profile.FrameSettings.ClickThrough
                    set: (info, val) ->
                        T.DB.profile.FrameSettings.ClickThrough = val
                        bgframe\SetMenu not val

T.Options = {}
T.Options.Initialize = () =>
    media = T.LSM
    if media
        options.args.general.args.warnsound =
            order: 5
            name: 'Health warning sound'
            desc: 'Sound to play when bodyguard health is dangerously low'
            type: 'select'
            values: (info) -> media\HashTable media.MediaType.SOUND
            dialogControl: 'LSM30_Sound'
            get: (info) -> T.DB.profile.WarnSound
            set: (info, val) -> T.DB.profile.WarnSound = val

        options.args.frame.args.texture =
            order: 4
            name: 'Health bar texture'
            desc: 'Select the texture to use for the health bar'
            type: 'select'
            values: (info) -> media\HashTable media.MediaType.STATUSBAR
            dialogControl: 'LSM30_Statusbar'
            get: (info) -> T.DB.profile.FrameSettings.Texture
            set: (info, val) ->
                T.DB.profile.FrameSettings.Texture = val
                bgframe\UpdateSettings!

        options.args.frame.args.background =
            order: 11
            name: 'Frame background'
            desc: 'Select the texture to use for the frame background'
            type: 'select'
            values: (info) -> media\HashTable media.MediaType.BACKGROUND
            dialogControl: 'LSM30_Background'
            get: (info) -> T.DB.profile.FrameSettings.Backdrop.Background
            set: (info, val) ->
                T.DB.profile.FrameSettings.Backdrop.Background = val
                bgframe\UpdateSettings!

        options.args.frame.args.border =
            order: 12
            name: 'Frame border'
            desc: 'Select the border texture to use for the frame'
            type: 'select'
            values: (info) -> media\HashTable media.MediaType.BORDER
            dialogControl: 'LSM30_Border'
            get: (info) -> T.DB.profile.FrameSettings.Backdrop.Border
            set: (info, val) ->
                T.DB.profile.FrameSettings.Backdrop.Border = val
                bgframe\UpdateSettings!

        options.args.frame.args.barfont =
            order: 20
            name: 'Bar font'
            desc: 'Set the font to use for displaying the health percentage'
            type: 'select'
            values: (info) ->
                media\HashTable media.MediaType.FONT
            dialogControl: 'LSM30_Font'
            get: (info) -> T.DB.profile.FrameSettings.Font
            set: (info, val) ->
                T.DB.profile.FrameSettings.Font = val
                bgframe\UpdateSettings!

    options.args.profile = LibStub('AceDBOptions-3.0')\GetOptionsTable T.DB

    LibStub('AceConfig-3.0')\RegisterOptionsTable NAME, options, {'bodyguardhealth', 'bgh'}
    
    acd = LibStub 'AceConfigDialog-3.0'
    interfacePanel = acd\AddToBlizOptions NAME, 'Bodyguard Health', nil, 'general'
    framePanel = acd\AddToBlizOptions NAME, 'Frame settings', 'Bodyguard Health', 'frame'
    acd\AddToBlizOptions NAME, 'Profile', 'BodyguardHealth', 'profile'

T.Options.Open = () =>
    return unless interfacePanel
    InterfaceOptionsFrame_OpenToCategory framePanel
    InterfaceOptionsFrame_OpenToCategory interfacePanel
