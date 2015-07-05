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
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

NAME, T = ...

T.Log = (msg, debug) =>
    return if debug and not T.DB.profile.Debug
    DEFAULT_CHAT_FRAME\AddMessage "|cff00B4FF[BGH]|r#{debug and ' |cff00FF00Debug:|r' or ''} #{msg}"

import \Log from T

CONTINENT_DRAENOR = 7

-- Draenor zones in which the bodyguard can't be active
-- the frame is hidden if player is in one of these zones
BODYGUARD_BANNED_ZONES:
    [978]: true  -- Ashran
    [1009]: true -- Stormshield
    [1011]: true -- Warspear

IsValidZone = ->
    SetMapToCurrentZone!
    cid = GetCurrentMapContinent!
    aid = GetCurrentMapAreaID!

    Log "IVZ: cid == #{cid}, aid == #{aid} #{GetMapNameByID(aid) or 'Unknown'}", true

    valid = cid == CONTINENT_DRAENOR and not BODYGUARD_BANNED_ZONES[aid]
    T.DB.char.IsInValidZone = valid
    valid

defaults =
    profile:
        Enabled: true
        Debug: false
        EnableWarn: true
        WarnSound: 'BGH: Health Warning'
        CloseGossip: false
        CloseGossipModifier: 'control'
        FrameSettings:
            ClickThrough: false
            Width: 200
            Height: 60
            Scale: 1
            Point: 'CENTER'
            RelPoint: nil
            Offset:
                X: 0, Y: 0
            Font: 'Friz Quadrata TT'
            FontSize: 20
            FontFlags: 'OUTLINE'
            FontColor:
                R: 1, G: 1, B: 1, A: 1
            Texture: 'Blizzard'
            HealthBasedColor: true
            CustomColor:
                R: 1, G: 1, B: 1
            HealthTextStyle: 'PERCENTAGE'
            Backdrop:
                Background: 'Blizzard Dialog Background'
                Border: 'Blizzard Tooltip'
                Color:
                    R: 1, G: 1, B: 1, A: 1
                BorderColor:
                    R: 1, G: 1, B: 1, A: 1
                Tile: true
                BorderSize: 16
                TileSize: 32
                Insets:
                    Left: 2.5
                    Right: 2.5
                    Top: 2.5
                    Bottom: 2.5
    char:
        HasBodyguard: false

modifier_funcs =
    control: IsControlKeyDown
    shift: IsShiftKeyDown
    alt: IsAltKeyDown

T.ADDON_LOADED = (name) =>
    return unless name == NAME

    @LSM = LibStub 'LibSharedMedia-3.0'
    @LBG = LibStub 'LibBodyguard-1.0'
    @DB = LibStub('AceDB-3.0')\New 'BodyguardHealthDB', defaults, true

    @LSM\Register @LSM.MediaType.SOUND, 'BGH: Health Warning', 'Interface\\AddOns\\BodyguardHealth\\audio\\warn_health.ogg'

    with refresh = T.BodyguardFrame\UpdateSettings
        @DB\RegisterCallback 'OnProfileChanged', refresh
        @DB\RegisterCallback 'OnProfileCopied', refresh
        @DB\RegisterCallback 'OnProfileReset', refresh

    lbg = @LBG

    lbg\UpdateFromBuilding!

    lbg\RegisterCallback 'status', (lib, status) ->
        T.BodyguardFrame\UpdateStatus status

        if status == lib.Status.Active
            T.BodyguardFrame\UpdateName lib\GetName!
            T.BodyguardFrame\UpdateHealthBar lib\GetHealth!, lib\GetMaxHealth!
            T.BodyguardFrame\Show!
        elseif status == lib.Status.Inactive and T.BodyguardFrame\IsLocked!
            T.BodyguardFrame\Hide!

        T.DB.char.HasBodyguard = status != lib.Status.Inactive

    login_health_flag = true

    lbg\RegisterCallback 'health', (lib, health, maxhealth) ->
        -- Don't update health values if addon has restored them from savedvars
        -- This essentially ignores the initial health update from LibBodyguard as it's inaccurate
        -- if the player logged out with an active bodyguard
        if maxhealth == 0 and (T.DB.char.HasBodyguard and T.DB.char.MaxHealth != 0) and login_health_flag
            login_health_flag = false
            return

        T.BodyguardFrame\UpdateHealthBar health, maxhealth
        T.DB.char.Health = health
        T.DB.char.MaxHealth = maxhealth

    lbg\RegisterCallback 'name', (lib, name) ->
        T.BodyguardFrame\UpdateName name

    lbg\RegisterCallback 'gossip_opened', (lib) ->
        return unless T.DB.profile.Enabled and T.DB.profile.CloseGossip
        func = modifier_funcs[T.DB.profile.CloseGossipModifier]
        return if func and func!
        CloseGossip!

    if type(@DB.char.IsInValidZone) != 'boolean'
        @DB.char.IsInValidZone = IsValidZone!

    if @DB.char.HasBodyguard and @DB.char.IsInValidZone
        @BodyguardFrame\Show!
        @BodyguardFrame\UpdateHealthBar @DB.char.Health, @DB.char.MaxHealth

    @Dropdown\Create!
    @BodyguardFrame\SetMenu not @DB.profile.FrameSettings.ClickThrough

    @Options\Initialize!

    -- DEBUG
    export BodyguardHealth = self

T.PLAYER_ENTERING_WORLD = =>
    Log 'PLAYER_ENTERING_WORLD', true
    showing = @BodyguardFrame\IsShowing!
    if not @LBG\Exists! and not @DB.char.HasBodyguard
        @BodyguardFrame\Hide! if showing
        return

    if not IsValidZone!
        Log 'PEW: Not in Draenor, hiding.', true
        @BodyguardFrame\Hide!
    elseif showing
        @BodyguardFrame\UpdateSettings!
    elseif @LBG\GetStatus! != @LBG.Status.Inactive and @DB.char.HasBodyguard
        @BodyguardFrame\Show!

T.ZONE_CHANGED_NEW_AREA = =>
    Log 'ZONE_CHANGED_NEW_AREA', true
    validZone = IsValidZone!
    if not validZone
        return unless @BodyguardFrame\IsShowing!
        Log 'Banned zone, hiding', true
        @BodyguardFrame\Hide!
    elseif @DB.char.HasBodyguard and @LBG\GetStatus! != @LBG.Status.Inactive
        @BodyguardFrame\Show!

T.PLAYER_REGEN_DISABLED = =>
    @InCombat = true

T.PLAYER_REGEN_ENABLED = =>
    @InCombat = false
    if @QueuedShow
        @QueuedShow = false
        @BodyguardFrame\Show!
    elseif @QueuedHide
        @QueuedHide = false
        @BodyguardFrame\Hide!
    @BodyguardFrame\UpdateSettings!

T.PET_BATTLE_OPENING_START = =>
    @InPetBattle = true
    @FrameShowingPrePetBattle = @BodyguardFrame\IsShowing!
    if @FrameShowingPrePetBattle
        @BodyguardFrame\Hide!

T.PET_BATTLE_CLOSE = =>
    -- [petbattle] conditional returns false on second fire of PET_BATTLE_CLOSE
    return if SecureCmdOptionParse '[petbattle]'
    @InPetBattle = false
    if @FrameShowingPrePetBattle
        @FrameShowingPrePetBattle = false
        @BodyguardFrame\Show!

T.QueueShow = =>
    return unless @InCombat
    @QueuedShow = true
    @QueuedHide = false

T.QueueHide = =>
    return unless @InCombat
    @QueuedHide = true
    @QueuedShow = false

T.Enable = =>
    @DB.profile.Enabled = true

T.Disable = =>
    @DB.profile.Enabled = false
    @BodyguardFrame\Hide!

T.Frame = CreateFrame 'Frame'

T.Frame\SetScript 'OnEvent', (frame, event, ...) ->
    T[event] T, ... if T[event]

for k in pairs T do
    T.Frame\RegisterEvent k if k\match '^[A-Z0-9_]+$'
