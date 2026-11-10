; =====================================================================
;  GEARLINE  -  Game Boy Color factory simulation
;  Build: see build.sh (RGBDS)
; =====================================================================

INCLUDE "build/gfx.inc"

; ---------------------------------------------------------------- hardware
DEF rP1   EQU $FF00
DEF rDIV  EQU $FF04
DEF rIF   EQU $FF0F
DEF rNR10 EQU $FF10
DEF rNR21 EQU $FF16
DEF rNR22 EQU $FF17
DEF rNR23 EQU $FF18
DEF rNR24 EQU $FF19
DEF rNR30 EQU $FF1A
DEF rNR32 EQU $FF1C
DEF rNR33 EQU $FF1D
DEF rNR34 EQU $FF1E
DEF rNR41 EQU $FF20
DEF rNR50 EQU $FF24
DEF rNR51 EQU $FF25
DEF rNR52 EQU $FF26
DEF rLCDC EQU $FF40
DEF rSTAT EQU $FF41
DEF rSCY  EQU $FF42
DEF rSCX  EQU $FF43
DEF rLY   EQU $FF44
DEF rDMA  EQU $FF46
DEF rBGP  EQU $FF47
DEF rWY   EQU $FF4A
DEF rWX   EQU $FF4B
DEF rKEY1 EQU $FF4D
DEF rVBK  EQU $FF4F
DEF rBCPS EQU $FF68
DEF rBCPD EQU $FF69
DEF rOCPS EQU $FF6A
DEF rOCPD EQU $FF6B
DEF rIE   EQU $FFFF

DEF PAD_A      EQU $01
DEF PAD_B      EQU $02
DEF PAD_SELECT EQU $04
DEF PAD_START  EQU $08
DEF PAD_RIGHT  EQU $10
DEF PAD_LEFT   EQU $20
DEF PAD_UP     EQU $40
DEF PAD_DOWN   EQU $80

DEF WIN EQU $9C00
DEF BGM EQU $9800

DEF TA_WHITE  EQU $0F       ; font bank + palette 7
DEF TA_YELLOW EQU $0B       ; font bank + palette 3
DEF TA_CYAN   EQU $0E       ; font bank + palette 6

; ---------------------------------------------------------------- game constants
DEF BT_BELT  EQU 1
DEF BT_MINER EQU 2
DEF BT_FURN  EQU 3
DEF BT_ASM   EQU 4
DEF BT_GEN   EQU 5
DEF BT_SPLIT EQU 6
DEF BT_CROSS EQU 7
DEF BT_DRILL EQU 8
DEF BT_EFURN EQU 9
DEF BT_HUB   EQU 10
DEF NUM_BUILD EQU 9

DEF IT_IRONORE EQU 1
DEF IT_COPORE  EQU 2
DEF IT_COAL    EQU 3
DEF IT_STONE   EQU 4
DEF IT_IRON    EQU 5
DEF IT_COPPER  EQU 6
DEF IT_BRICK   EQU 7
DEF IT_GEAR    EQU 8
DEF IT_WIRE    EQU 9
DEF IT_CIRCUIT EQU 10
DEF IT_STEEL   EQU 11
DEF IT_ENGINE  EQU 12
DEF IT_FRAME   EQU 13
DEF IT_BRAIN   EQU 14
DEF IT_ROCKET  EQU 15
DEF NUM_ITEMS  EQU 15

DEF TR_GRASS  EQU 0
DEF TR_GRASS2 EQU 1
DEF TR_FLOWER EQU 2
DEF TR_TREE   EQU 3
DEF TR_WATER  EQU 4
DEF TR_IRON   EQU 5
DEF TR_COPPER EQU 6
DEF TR_COAL   EQU 7
DEF TR_STONE  EQU 8

DEF NUM_RECIPES EQU 8

DEF SIM_SLICE    EQU 64     ; cells per frame -> 16 frames per pass
DEF MINER_TIME   EQU 8
DEF DRILL_TIME   EQU 3
DEF FURN_TIME    EQU 8
DEF EFURN_TIME   EQU 3
DEF GEN_BURN     EQU 32
DEF GEN_POWER    EQU 8
DEF ASM_POWER    EQU 2
DEF DRILL_POWER  EQU 3
DEF EFURN_POWER  EQU 3
DEF TEMPO        EQU 8

MACRO hop               ; move H between the parallel map arrays
    ld a, h
    add \1
    ld h, a
ENDM

; ---------------------------------------------------------------- RAM
SECTION "Map0", WRAM0[$C000]
wMapTerr: ds 1024
wMapType: ds 1024
wMapItem: ds 1024
wMapData: ds 1024

SECTION "Map1", WRAMX[$D000], BANK[1]
wMapBufA: ds 1024
wMapBufB: ds 1024

wSaveVars:
wStock:      ds 32
wGoal:       db
wTool:       db
wDir:        db
wCurX:       db
wCurY:       db
wCamX:       db
wCamY:       db
wSimIdx:     dw
wSimDir:     db
wParity:     db
wPowSupply:  dw
wPowDemand:  dw
wPowSupAcc:  dw
wPowDemAcc:  dw
wPowFrac:    dw
wPowOK:      db
wPlayFrames: db
wPlaySec:    db
wPlayMin:    db
wPlayHour:   db
wMusicOn:    db
wRng:        dw
wGoalNote:   db
wSaveVarsEnd:

wNotify:     db
wMsgTimer:   db
wDigits:     ds 5
wMenuList:   ds 16
wMenuCount:  db
wMenuSel:    db
wMenuTop:    db
wTmpK:       db
wTmpItem:    db
wTmpQty:     dw
wTitlePos:   db
wMusTimer:   db
wMusStep:    db
wMusOrd:     db
wJingPtr:    dw
wJingTimer:  db

SECTION "OAMBuf", WRAMX[$DE00], BANK[1]
wOAM: ds 160

SECTION "HRAM", HRAM
hIsCGB:      db
hVBlankFlag: db
hFrame:      db
hJoyHeld:    db
hJoyPressed: db
hJoyRepeat:  db
hRepTimer:   db
hSCX:        db
hSCY:        db
hTextAttr:   db
hHudDirty:   db
hMenuOpen:   db
hQuiet:      db
hMoveDir:    db
hPrevLo:     db
hPrevHi:     db
hPeriod:     db
hRecLo:      db
hRecHi:      db
hSplitIdx:   db
hSplitCnt:   db
hSplitDir:   db
hBX:         db
hBY:         db
hCX0:        db
hCY0:        db
hInfoLo:     db
hInfoHi:     db
hOAMDMA:     ds 12

; ---------------------------------------------------------------- vectors / header
SECTION "VBlankVec", ROM0[$40]
    jp VBlankISR

SECTION "Header", ROM0[$100]
    nop
    jp Start
    ds $150 - @, 0

; =====================================================================
SECTION "Main", ROM0
; =====================================================================
Start:
    di
    ld b, a
    ld sp, $E000
    ld hl, $FF80
    ld c, $7F
    xor a
.h  ld [hli], a
    dec c
    jr nz, .h
    ld a, b
    cp $11
    jr nz, .notcgb
    ld a, 1
    ldh [hIsCGB], a
.notcgb
    call LCDOff
    ld hl, $C000
    ld bc, $1EA0
    call MemClear
    ld hl, DMARoutine
    ld de, hOAMDMA
    ld bc, DMARoutineEnd - DMARoutine
    call MemCopy
    call SoundInit
    ldh a, [hIsCGB]
    or a
    jp z, DMGScreen
    ld a, 1
    ld [$2000], a
    xor a
    ld [$4000], a
    ldh a, [rKEY1]
    bit 7, a
    jr nz, .fast
    ld a, $30
    ldh [rP1], a
    ld a, 1
    ldh [rKEY1], a
    stop
.fast
    call LoadGfx
    xor a
    ldh [rIF], a
    ld a, 1
    ldh [rIE], a
    ld a, 7
    ldh [rWX], a
    ld a, 1
    ld [wMusTimer], a
    ld [wMusicOn], a
    jp TitleScreen

DMARoutine:
    ld a, HIGH(wOAM)
    ldh [rDMA], a
    ld a, 40
.w  dec a
    jr nz, .w
    ret
DMARoutineEnd:

; ---------------------------------------------------------------- utils
MemClear:
    xor a
MemFill:                    ; A value, HL dest, BC count
    ld d, a
.l  ld a, d
    ld [hli], a
    dec bc
    ld a, b
    or c
    jr nz, .l
    ret

MemCopy:                    ; HL src, DE dest, BC count
.l  ld a, [hli]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .l
    ret

LCDOff:
    ldh a, [rLCDC]
    bit 7, a
    ret z
.w  ldh a, [rLY]
    cp 144
    jr c, .w
    ldh a, [rLCDC]
    res 7, a
    ldh [rLCDC], a
    ret

WaitVBlank:
.loop
    di
    ldh a, [hVBlankFlag]
    or a
    jr nz, .done
    ei
    halt
    jr .loop
.done
    xor a
    ldh [hVBlankFlag], a
    ei
    ret

ReadJoypad:
    ld a, $20
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F
    swap a
    ld b, a
    ld a, $10
    ldh [rP1], a
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    ldh a, [rP1]
    cpl
    and $0F
    or b
    ld b, a
    ld a, $30
    ldh [rP1], a
    ldh a, [hJoyHeld]
    cpl
    and b
    ldh [hJoyPressed], a
    ld c, a
    ld a, b
    ldh [hJoyHeld], a
    and $F0
    jr z, .none
    ld a, c
    and $F0
    jr z, .held
    ldh [hJoyRepeat], a
    ld a, 11
    ldh [hRepTimer], a
    ret
.held
    ldh a, [hRepTimer]
    dec a
    ldh [hRepTimer], a
    jr nz, .none
    ld a, 4
    ldh [hRepTimer], a
    ld a, b
    and $F0
    ldh [hJoyRepeat], a
    ret
.none
    xor a
    ldh [hJoyRepeat], a
    ret

Rand:                       ; -> A. clobbers HL
    ld hl, wRng
    ld a, [hli]
    ld h, [hl]
    ld l, a
    ld a, h
    rra
    ld a, l
    rra
    xor h
    ld h, a
    ld a, l
    rra
    ld a, h
    rra
    xor l
    ld l, a
    xor h
    ld h, a
    ld a, l
    ld [wRng], a
    ld a, h
    ld [wRng + 1], a
    ret

; HL = VRAM map address, B = tile, C = attr. Preserves BC, DE, HL.
PutTile:
    di
.w  ldh a, [rSTAT]
    and 2
    jr nz, .w
    ld [hl], b
    ld a, 1
    ldh [rVBK], a
    ld [hl], c
    xor a
    ldh [rVBK], a
    ei
    ret

; A = bank-0 tile, HL = dest. Advances HL. Preserves DE.
PutIcon:
    push de
    ld b, a
    ld e, a
    ld d, HIGH(TileAttr)
    ld a, [de]
    ld c, a
    pop de
    call PutTile
    inc hl
    ret

; A = glyph, HL = dest. Advances HL. Preserves DE.
PutChar:
    ld b, a
    ldh a, [hTextAttr]
    ld c, a
    call PutTile
    inc hl
    ret

; DE = string, HL = dest. Returns HL after last char.
PrintStr:
    push hl
.loop
    ld a, [de]
    inc de
    cp $FF
    jr z, .done
    cp $FE
    jr nz, .ch
    pop hl
    ld bc, 32
    add hl, bc
    push hl
    jr .loop
.ch
    call PutChar
    jr .loop
.done
    pop bc
    ret

; fill with spaces until column A
PadTo:
    ld d, a
.l  ld a, l
    and 31
    cp d
    ret nc
    ld b, 0
    ld c, TA_WHITE
    call PutTile
    inc hl
    jr .l

; DE = value, B = width (1..5), HL = dest. Right aligned.
PrintNum:
    push bc
    push hl
    ld h, d
    ld l, e
    ld de, wDigits
    ld bc, -10000
    call .digit
    ld bc, -1000
    call .digit
    ld bc, -100
    call .digit
    ld bc, -10
    call .digit
    ld a, l
    ld [de], a
    pop hl
    pop bc
    ld a, 5
    sub b
    add LOW(wDigits)
    ld e, a
    ld a, HIGH(wDigits)
    adc 0
    ld d, a
    ld c, 0
.pl
    ld a, [de]
    inc de
    or a
    jr nz, .nz
    ld a, c
    or a
    jr nz, .zero
    ld a, b
    cp 1
    jr z, .zero
    xor a
    jr .put
.zero
    ld a, GLY_0
    jr .put
.nz
    ld c, 1
    add GLY_0
.put
    push bc
    call PutChar
    pop bc
    dec b
    jr nz, .pl
    ret
.digit
    ld a, $FF
.dl inc a
    add hl, bc
    jr c, .dl
    push af
    ld a, l
    sub c
    ld l, a
    ld a, h
    sbc b
    ld h, a
    pop af
    ld [de], a
    inc de
    ret

; A = 0..99, HL = dest, zero padded
PrintDec2Z:
    ld e, 0
.t  cp 10
    jr c, .o
    sub 10
    inc e
    jr .t
.o  push af
    ld a, e
    add GLY_0
    call PutChar
    pop af
    add GLY_0
    jp PutChar

; A = row -> HL = WIN + row*32
WinRow:
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, h
    add HIGH(WIN)
    ld h, a
    ret

ClearWin:
    ld hl, WIN
    ld d, 18
.row
    ld e, 20
.col
    ld b, 0
    ld c, TA_WHITE
    call PutTile
    inc hl
    dec e
    jr nz, .col
    ld bc, 12
    add hl, bc
    dec d
    jr nz, .row
    ret

FillMap:                    ; HL start, B tile, C attr, 1024 cells
    ld de, 1024
.l  call PutTile
    inc hl
    dec de
    ld a, d
    or e
    jr nz, .l
    ret

HideSprites:
    ld hl, wOAM
    ld b, 160
    xor a
.l  ld [hli], a
    dec b
    jr nz, .l
    ret

LoadGfx:
    xor a
    ldh [rVBK], a
    ld hl, TilesData
    ld de, $8000
    ld bc, TilesDataEnd - TilesData
    call MemCopy
    ld a, 1
    ldh [rVBK], a
    ld hl, FontData
    ld de, $8000
    ld bc, FontDataEnd - FontData
    call MemCopy
    xor a
    ldh [rVBK], a
    ld a, $80
    ldh [rBCPS], a
    ld hl, BGPalData
    ld b, 64
.b  ld a, [hli]
    ldh [rBCPD], a
    dec b
    jr nz, .b
    ld a, $80
    ldh [rOCPS], a
    ld hl, OBJPalData
    ld b, 32
.o  ld a, [hli]
    ldh [rOCPD], a
    dec b
    jr nz, .o
    ret

; ---------------------------------------------------------------- interrupt
VBlankISR:
    push af
    push bc
    push de
    push hl
    ldh a, [rVBK]
    push af
    xor a
    ldh [rVBK], a
    ldh a, [hSCX]
    ldh [rSCX], a
    ldh a, [hSCY]
    ldh [rSCY], a
    call hOAMDMA
    ldh a, [hFrame]
    inc a
    ldh [hFrame], a
    rra
    jr c, .noBelt
    and 3
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, BeltAnim
    add hl, de
    ld de, $8000 + T_BELT * 16
    ld b, 64
.cp ld a, [hli]
    ld [de], a
    inc de
    dec b
    jr nz, .cp
.noBelt
    ldh a, [hFrame]
    and 7
    jr nz, .noPal
    ldh a, [hFrame]
    rra
    and $0C
    add LOW(FirePal)
    ld l, a
    ld a, HIGH(FirePal)
    adc 0
    ld h, a
    ld a, $80 | (5 * 8 + 4)
    ldh [rBCPS], a
    ld b, 4
.pl ld a, [hli]
    ldh [rBCPD], a
    dec b
    jr nz, .pl
.noPal
    call MusicTick
    ld a, 1
    ldh [hVBlankFlag], a
    pop af
    ldh [rVBK], a
    pop hl
    pop de
    pop bc
    pop af
    reti

; ---------------------------------------------------------------- sound
SoundInit:
    ld a, $80
    ldh [rNR52], a
    ld a, $77
    ldh [rNR50], a
    ld a, $FF
    ldh [rNR51], a
    xor a
    ldh [rNR30], a
    ld hl, WaveData
    ld c, $30
    ld b, 16
.l  ld a, [hli]
    ldh [c], a
    inc c
    dec b
    jr nz, .l
    ret

WaveData:
    db $01,$23,$45,$67,$89,$AB,$CD,$EF,$FE,$DC,$BA,$98,$76,$54,$32,$10

SfxPlace:
    push hl
    ld hl, .d
    jr SfxCh1
.d  db $00, $80, $F1, $83, $87
SfxRemove:
    push hl
    ld hl, .d
    jr SfxCh1
.d  db $1C, $80, $F1, $59, $87
SfxTick:
    push hl
    ld hl, .d
    jr SfxCh1
.d  db $00, $40, $71, $9D, $87
SfxError:
    push hl
    ld hl, .d
    jr SfxCh1
.d  db $00, $00, $F2, $58, $83
SfxRumble:
    ld a, $3F
    ldh [rNR41], a
    ld a, $F7
    ldh [rNR41 + 1], a
    ld a, $6D
    ldh [rNR41 + 2], a
    ld a, $80
    ldh [rNR41 + 3], a
    ret
SfxCh1:
    push bc
    di
    xor a
    ld [wJingPtr], a
    ld [wJingPtr + 1], a
    ld c, LOW(rNR10)
    ld b, 5
.l  ld a, [hli]
    ldh [c], a
    inc c
    dec b
    jr nz, .l
    ei
    pop bc
    pop hl
    ret

SfxJingle:
    push hl
    ld hl, JingleWin
    jr SetJingle
SfxNotify:
    push hl
    ld hl, JingleNote
SetJingle:
    di
    ld a, l
    ld [wJingPtr], a
    ld a, h
    ld [wJingPtr + 1], a
    xor a
    ld [wJingTimer], a
    ei
    pop hl
    ret

JingleWin:  db N_C6, 5, N_E6, 5, N_G6, 5, N_C7, 14, $FF
JingleNote: db N_G5, 5, N_C6, 8, $FF

; A = note -> BC = freq
NoteLookup:
    add a
    add LOW(NoteFreq)
    ld l, a
    ld a, HIGH(NoteFreq)
    adc 0
    ld h, a
    ld a, [hli]
    ld c, a
    ld b, [hl]
    ret

MusicTick:
    ; jingle on channel 1
    ld hl, wJingPtr
    ld a, [hli]
    ld h, [hl]
    ld l, a
    or h
    jr z, .music
    ld a, [wJingTimer]
    or a
    jr z, .jnext
    dec a
    ld [wJingTimer], a
    jr .music
.jnext
    ld a, [hli]
    cp $FF
    jr z, .jend
    push hl
    call NoteLookup
    xor a
    ldh [rNR10], a
    ld a, $80
    ldh [rNR10 + 1], a
    ld a, $F3
    ldh [rNR10 + 2], a
    ld a, c
    ldh [rNR10 + 3], a
    ld a, b
    or $80
    ldh [rNR10 + 4], a
    pop hl
    ld a, [hli]
    ld [wJingTimer], a
    ld a, l
    ld [wJingPtr], a
    ld a, h
    ld [wJingPtr + 1], a
    jr .music
.jend
    xor a
    ld [wJingPtr], a
    ld [wJingPtr + 1], a
.music
    ld a, [wMusicOn]
    or a
    ret z
    ld hl, wMusTimer
    dec [hl]
    ret nz
    ld [hl], TEMPO
    ld a, [wMusOrd]
    add a
    add a
    add LOW(MusOrder)
    ld l, a
    ld a, HIGH(MusOrder)
    adc 0
    ld h, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    push hl
    ld a, [wMusStep]
    add e
    ld e, a
    jr nc, .m1
    inc d
.m1 ld a, [de]
    or a
    jr z, .mdone
    dec a
    jr z, .moff
    inc a
    call NoteLookup
    ld a, $80
    ldh [rNR21], a
    ld a, $92
    ldh [rNR22], a
    ld a, c
    ldh [rNR23], a
    ld a, b
    or $80
    ldh [rNR24], a
    jr .mdone
.moff
    ld a, $08
    ldh [rNR22], a
    ld a, $80
    ldh [rNR24], a
.mdone
    pop hl
    ld a, [hli]
    ld e, a
    ld d, [hl]
    ld a, [wMusStep]
    add e
    ld e, a
    jr nc, .b1
    inc d
.b1 ld a, [de]
    or a
    jr z, .bdone
    dec a
    jr z, .boff
    inc a
    call NoteLookup
    ld a, $80
    ldh [rNR30], a
    ld a, $40
    ldh [rNR32], a
    ld a, c
    ldh [rNR33], a
    ld a, b
    or $80
    ldh [rNR34], a
    jr .bdone
.boff
    xor a
    ldh [rNR32], a
.bdone
    ld hl, wMusStep
    inc [hl]
    ld a, [hl]
    cp 64
    ret c
    ld [hl], 0
    ld hl, wMusOrd
    inc [hl]
    ld a, [hl]
    cp MUS_ORDER_LEN
    ret c
    ld [hl], 0
    ret

ToggleMusic:
    ld a, [wMusicOn]
    xor 1
    ld [wMusicOn], a
    ret nz
    ld a, $08
    ldh [rNR22], a
    ld a, $80
    ldh [rNR24], a
    xor a
    ldh [rNR32], a
    ret

; ---------------------------------------------------------------- DMG lock-out
DMGScreen:
    ld hl, FontData
    ld de, $8000
    ld bc, FontDataEnd - FontData
    call MemCopy
    ld hl, BGM
    ld bc, 1024
    call MemClear
    ld hl, BGM + 5 * 32 + 1
    ld de, Str_Dmg
    push hl
.l  ld a, [de]
    inc de
    cp $FF
    jr z, .done
    cp $FE
    jr nz, .c
    pop hl
    ld bc, 32
    add hl, bc
    push hl
    jr .l
.c  ld [hli], a
    jr .l
.done
    pop hl
    ld a, %11100100
    ldh [rBGP], a
    xor a
    ldh [rSCX], a
    ldh [rSCY], a
    ld a, $91
    ldh [rLCDC], a
.hang
    jr .hang

; ---------------------------------------------------------------- title
TitleScreen:
    call LCDOff
    ld sp, $E000
    xor a
    ldh [hSCX], a
    ldh [hSCY], a
    ldh [rSCX], a
    ldh [rSCY], a
    call HideSprites
    ld hl, BGM
    ld b, T_BLANK
    ld c, 3
    call FillMap
    ld hl, BGM + 3 * 32 + 5
    ld a, T_LOGO
    ld d, 2
.lr ld e, LOGO_W
.lc push af
    call PutIcon
    pop af
    inc a
    dec e
    jr nz, .lc
    ld bc, 32 - LOGO_W
    add hl, bc
    dec d
    jr nz, .lr
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ld hl, BGM + 6 * 32 + 4
    ld de, Str_Title1
    call PrintStr
    ld a, TA_CYAN
    ldh [hTextAttr], a
    ld hl, BGM + 8 * 32 + 4
    ld de, Str_TitleSub
    call PrintStr
    ld hl, BGM + 10 * 32
    ld e, 20
.br ld a, T_BELT + 1
    call PutIcon
    dec e
    jr nz, .br
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ld hl, BGM + 13 * 32 + 7
    ld de, Str_TitleNew
    call PrintStr
    xor a
    ld [wMenuSel], a
    ld [wMenuCount], a
    call HasSave
    jr nz, .nosave
    ld hl, BGM + 15 * 32 + 7
    ld de, Str_TitleCont
    call PrintStr
    ld a, 1
    ld [wMenuSel], a
    ld [wMenuCount], a
.nosave
    call .cursor
    ld a, $D3
    ldh [rLCDC], a
.loop
    call WaitVBlank
    call ReadJoypad
    ldh a, [hFrame]
    and 7
    jr nz, .noanim
    ld a, [wTitlePos]
    inc a
    cp 20
    jr c, .p
    xor a
.p  ld [wTitlePos], a
    xor a
    ld d, T_ITEMB + (IT_GEAR - 1) * 4 + 1
    call .item
    ld a, 7
    ld d, T_ITEMB + (IT_COPPER - 1) * 4 + 1
    call .item
    ld a, 14
    ld d, T_ITEMB + (IT_CIRCUIT - 1) * 4 + 1
    call .item
.noanim
    ldh a, [hJoyPressed]
    ld b, a
    and PAD_UP | PAD_DOWN | PAD_SELECT
    jr z, .nomove
    ld a, [wMenuCount]
    or a
    jr z, .nomove
    ld a, [wMenuSel]
    xor 1
    ld [wMenuSel], a
    call SfxTick
    call .cursor
.nomove
    ld a, b
    and PAD_A | PAD_START
    jr z, .loop
    call SfxPlace
    ldh a, [hFrame]
    ld [wRng], a
    ldh a, [rDIV]
    or 1
    ld [wRng + 1], a
    ld a, [wMenuSel]
    or a
    jp nz, LoadGame
    jp NewGame

.cursor
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld a, [wMenuSel]
    or a
    ld d, GLY_CURSOR
    ld e, 0
    jr z, .c1
    ld d, 0
    ld e, GLY_CURSOR
.c1 ld hl, BGM + 13 * 32 + 5
    ld a, d
    call PutChar
    ld hl, BGM + 15 * 32 + 5
    ld a, e
    call PutChar
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ret

.item                       ; A = offset, D = tile
    ld hl, wTitlePos
    add [hl]
    cp 20
    jr c, .ok
    sub 20
.ok ld e, a
    add LOW(BGM + 10 * 32)
    ld l, a
    ld h, HIGH(BGM + 10 * 32)
    ld a, d
    call PutIcon
    ld a, e
    or a
    jr nz, .e1
    ld a, 20
.e1 dec a
    add LOW(BGM + 10 * 32)
    ld l, a
    ld h, HIGH(BGM + 10 * 32)
    ld a, T_BELT + 1
    jp PutIcon

; ---------------------------------------------------------------- save / load
SaveMagic: db "GL01"

HasSave:                    ; Z if valid save
    ld a, $0A
    ld [$0000], a
    ld hl, $A000
    ld de, SaveMagic
    ld b, 4
.l  ld a, [de]
    cp [hl]
    jr nz, .x
    inc de
    inc hl
    dec b
    jr nz, .l
.x  push af
    xor a
    ld [$0000], a
    pop af
    ret

SaveGame:
    ld a, $0A
    ld [$0000], a
    ld hl, wSaveVars
    ld de, $A004
    ld bc, wSaveVarsEnd - wSaveVars
    call MemCopy
    ld hl, wMapTerr
    ld de, $A100
    ld bc, $1000
    call MemCopy
    ld hl, wMapBufA
    ld de, $B100
    ld bc, $0800
    call MemCopy
    ld hl, SaveMagic
    ld de, $A000
    ld bc, 4
    call MemCopy
    xor a
    ld [$0000], a
    ret

LoadGame:
    call LCDOff
    ld a, $0A
    ld [$0000], a
    ld hl, $A004
    ld de, wSaveVars
    ld bc, wSaveVarsEnd - wSaveVars
    call MemCopy
    ld hl, $A100
    ld de, wMapTerr
    ld bc, $1000
    call MemCopy
    ld hl, $B100
    ld de, wMapBufA
    ld bc, $0800
    call MemCopy
    xor a
    ld [$0000], a
    jp EnterGame

; ---------------------------------------------------------------- new game
NewGame:
    call LCDOff
    ld hl, wMapTerr
    ld bc, $1000
    call MemClear
    ld hl, wMapBufA
    ld bc, $0800
    call MemClear
    ld a, [wRng]
    ld e, a
    ld a, [wRng + 1]
    ld d, a
    push de
    ld a, [wMusicOn]
    push af
    ld hl, wSaveVars
    ld bc, wSaveVarsEnd - wSaveVars
    call MemClear
    pop af
    ld [wMusicOn], a
    pop de
    ld a, e
    ld [wRng], a
    ld a, d
    ld [wRng + 1], a
    call GenMap
    ; hub
    ld hl, wMapType + 15 * 32 + 15
    ld a, BT_HUB << 2
    ld [hli], a
    ld [hl], a
    ld hl, wMapType + 16 * 32 + 15
    ld [hli], a
    ld [hl], a
    ld a, 1
    ld [wMapData + 15 * 32 + 16], a
    inc a
    ld [wMapData + 16 * 32 + 15], a
    inc a
    ld [wMapData + 16 * 32 + 16], a
    ; starting stock
    ld a, 40
    ld [wStock + IT_IRON * 2], a
    ld a, 12
    ld [wStock + IT_STONE * 2], a
    ld a, BT_BELT
    ld [wTool], a
    ld a, 1
    ld [wDir], a
    ld [wPowOK], a
    ld a, 15
    ld [wCurX], a
    ld a, 18
    ld [wCurY], a
    ld a, LOW(wMapType)
    ld [wSimIdx], a
    ld a, HIGH(wMapType)
    ld [wSimIdx + 1], a
    jp EnterGame

GenMap:
    ld hl, wMapTerr
    ld b, 0
.y  ld c, 0
.x  ld a, b
    or a
    jr z, .water
    cp 31
    jr z, .water
    ld a, c
    or a
    jr z, .water
    cp 31
    jr z, .water
    push hl
    call Rand
    pop hl
    and 31
    jr z, .flower
    cp 3
    jr c, .g2
    jr z, .tree
    xor a
    jr .set
.water
    ld a, TR_WATER
    jr .set
.flower
    ld a, TR_FLOWER
    jr .set
.g2 ld a, TR_GRASS2
    jr .set
.tree
    ld a, TR_TREE
.set
    ld [hli], a
    inc c
    ld a, c
    cp 32
    jr nz, .x
    inc b
    ld a, b
    cp 32
    jr nz, .y
    ; clear the hub zone
    ld hl, wMapTerr + 12 * 32 + 12
    ld b, 8
.zr ld c, 8
    xor a
.zc ld [hli], a
    dec c
    jr nz, .zc
    ld de, 24
    add hl, de
    dec b
    jr nz, .zr
    ; ponds
    ld b, 3
.pond
    push bc
.retry
    call Rand
    and 31
    cp 3
    jr c, .retry
    cp 29
    jr nc, .retry
    ld d, a
    call Rand
    and 31
    cp 3
    jr c, .retry
    cp 29
    jr nc, .retry
    ld e, a
    ld b, TR_WATER
    ld c, 14
    call Blob
    pop bc
    dec b
    jr nz, .pond
    ; ore patches
    ld hl, PatchTab
.patch
    ld a, [hli]
    or a
    ret z
    ld b, a
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld c, a
    push hl
    call Rand
    and 3
    dec a
    add d
    ld d, a
    call Rand
    and 3
    dec a
    add e
    ld e, a
    call Blob
    pop hl
    jr .patch

PatchTab:
    db TR_IRON,   8, 13, 30
    db TR_STONE, 22, 10, 22
    db TR_COPPER, 9, 22, 28
    db TR_COAL,  23, 21, 26
    db TR_IRON,   4,  4, 30
    db TR_COPPER,26,  4, 30
    db TR_COAL,   5, 26, 30
    db TR_STONE, 26, 26, 26
    db TR_IRON,  16,  5, 26
    db TR_COPPER,16, 26, 26
    db TR_IRON,  27, 15, 28
    db TR_COAL,   4, 15, 24
    db 0

; random-walk blob. D = x, E = y, B = terrain, C = steps
Blob:
    ld a, d
    ldh [hBX], a
    ldh [hCX0], a
    ld a, e
    ldh [hBY], a
    ldh [hCY0], a
.step
    ; skip hub zone 12..19
    ldh a, [hBX]
    cp 12
    jr c, .put
    cp 20
    jr nc, .put
    ldh a, [hBY]
    cp 12
    jr c, .put
    cp 20
    jr c, .move
.put
    ldh a, [hBY]
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ldh a, [hBX]
    or l
    ld l, a
    ld a, h
    add HIGH(wMapTerr)
    ld h, a
    ld [hl], b
.move
    call Rand
    and 3
    jr z, .n
    dec a
    jr z, .e
    dec a
    jr z, .s
    ldh a, [hBX]
    dec a
    ldh [hBX], a
    jr .clamp
.n  ldh a, [hBY]
    dec a
    ldh [hBY], a
    jr .clamp
.e  ldh a, [hBX]
    inc a
    ldh [hBX], a
    jr .clamp
.s  ldh a, [hBY]
    inc a
    ldh [hBY], a
.clamp
    ; too far from the centre or out of bounds -> back to centre
    ldh a, [hCX0]
    ld d, a
    ldh a, [hBX]
    cp 2
    jr c, .reset
    cp 30
    jr nc, .reset
    sub d
    add 2
    cp 5
    jr nc, .reset
    ldh a, [hCY0]
    ld d, a
    ldh a, [hBY]
    cp 2
    jr c, .reset
    cp 30
    jr nc, .reset
    sub d
    add 2
    cp 5
    jr c, .next
.reset
    ldh a, [hCX0]
    ldh [hBX], a
    ldh a, [hCY0]
    ldh [hBY], a
.next
    dec c
    jp nz, .step
    ret

; ---------------------------------------------------------------- game entry / loop
EnterGame:
    call LCDOff
    ld sp, $E000
    ld hl, wMapType
.l  call DrawCell
    inc hl
    ld a, h
    cp HIGH(wMapType) + 4
    jr nz, .l
    call ClearWin
    xor a
    ldh [hMenuOpen], a
    ld [wMsgTimer], a
    ld [wNotify], a
    ld a, 7
    ldh [hHudDirty], a
    call UpdateHud
    ld b, 80
.c  push bc
    call UpdateCamera
    pop bc
    dec b
    jr nz, .c
    ldh a, [hSCX]
    ldh [rSCX], a
    ldh a, [hSCY]
    ldh [rSCY], a
    call UpdateSprites
    ld a, 128
    ldh [rWY], a
    ld a, $F3
    ldh [rLCDC], a

GameLoop:
    call NextFrame
    call HandleInput
    call UpdateCamera
    call UpdateSprites
    call UpdateHud
    jr GameLoop

NextFrame:
    call WaitVBlank
    call ReadJoypad
    call SimSlice
    ; play time
    ld hl, wPlayFrames
    inc [hl]
    ld a, [hl]
    cp 60
    ret c
    ld [hl], 0
    inc hl
    inc [hl]
    ld a, [hl]
    cp 60
    ret c
    ld [hl], 0
    inc hl
    inc [hl]
    ld a, [hl]
    cp 60
    ret c
    ld [hl], 0
    inc hl
    ld a, [hl]
    cp 99
    ret nc
    inc [hl]
    ret

; HL = &wMapType[cursor]
CursorPtr:
    ld a, [wCurY]
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld a, [wCurX]
    or l
    ld l, a
    ld a, h
    add HIGH(wMapType)
    ld h, a
    ret

HandleInput:
    ldh a, [hJoyPressed]
    bit 3, a
    jp nz, MainMenu
    bit 2, a
    jr z, .noSel
    ld a, [wDir]
    inc a
    and 3
    ld [wDir], a
    ldh a, [hHudDirty]
    or 1
    ldh [hHudDirty], a
    call SfxTick
.noSel
    ldh a, [hJoyRepeat]
    and $F0
    jp z, .noMove
    ld c, a
    call CursorPtr
    ld a, l
    ldh [hPrevLo], a
    ld a, h
    ldh [hPrevHi], a
    bit 6, c
    jr z, .notUp
    ld a, [wCurY]
    cp 2
    jr c, .noMove
    dec a
    ld [wCurY], a
    xor a
    jr .moved
.notUp
    bit 7, c
    jr z, .notDown
    ld a, [wCurY]
    cp 30
    jr nc, .noMove
    inc a
    ld [wCurY], a
    ld a, 2
    jr .moved
.notDown
    bit 5, c
    jr z, .right
    ld a, [wCurX]
    cp 2
    jr c, .noMove
    dec a
    ld [wCurX], a
    ld a, 3
    jr .moved
.right
    ld a, [wCurX]
    cp 30
    jr nc, .noMove
    inc a
    ld [wCurX], a
    ld a, 1
.moved
    ldh [hMoveDir], a
    ldh a, [hHudDirty]
    or 2
    ldh [hHudDirty], a
    ldh a, [hJoyHeld]
    bit 0, a
    jr z, .noDragA
    call DragPlace
    jr .noMove
.noDragA
    bit 1, a
    jr z, .noMove
    ld a, 1
    ldh [hQuiet], a
    call RemoveAt
.noMove
    ldh a, [hJoyPressed]
    bit 0, a
    jr z, .noA
    xor a
    ldh [hQuiet], a
    call PlaceAt
.noA
    ldh a, [hJoyPressed]
    bit 1, a
    ret z
    xor a
    ldh [hQuiet], a
    jp RemoveAt

DragPlace:
    ld a, [wTool]
    cp BT_BELT
    jr nz, .plain
    ldh a, [hPrevLo]
    ld l, a
    ldh a, [hPrevHi]
    ld h, a
    ld a, [hl]
    srl a
    srl a
    cp BT_BELT
    jr nz, .np
    ldh a, [hMoveDir]
    or BT_BELT << 2
    ld [hl], a
    call DrawCell
.np ldh a, [hMoveDir]
    ld [wDir], a
    ldh a, [hHudDirty]
    or 1
    ldh [hHudDirty], a
.plain
    ld a, 1
    ldh [hQuiet], a
    ; fallthrough

PlaceAt:
    call CursorPtr
    ld a, [hl]
    or a
    jr z, .empty
    ld b, a
    ldh a, [hQuiet]
    or a
    ret nz
    ld a, b
    srl a
    srl a
    cp BT_ASM
    jp z, RecipeMenu
    cp BT_BELT
    jr nz, .err
    ld a, [wTool]
    cp BT_BELT
    jr nz, .err
    ld a, [wDir]
    or BT_BELT << 2
    ld [hl], a
    call DrawCell
    jp SfxTick
.errQ
    ldh a, [hQuiet]
    or a
    ret nz
.err
    ld de, Str_MsgNoPlace
    jp ErrMsg
.empty
    push hl
    hop -4
    ld a, [hl]
    pop hl
    ld c, a                 ; C = terrain
    cp TR_TREE
    jr z, .errQ
    cp TR_WATER
    jr z, .errQ
    ld a, [wTool]
    ld b, a                 ; B = tool
    cp BT_MINER
    jr z, .needOre
    cp BT_DRILL
    jr nz, .terrOK
.needOre
    ld a, c
    cp TR_IRON
    jr nc, .terrOK
    ldh a, [hQuiet]
    or a
    ret nz
    ld de, Str_MsgNeedOre
    jp ErrMsg
.terrOK
    push hl
    push bc
    ld a, b
    call CanAfford
    pop bc
    pop hl
    jr nc, .pay
    ldh a, [hQuiet]
    or a
    ret nz
    ld de, Str_MsgNoMat
    jp ErrMsg
.pay
    push hl
    push bc
    ld a, b
    call PayCost
    pop bc
    pop hl
    ld a, b
    add a
    add a
    ld e, a
    ld a, b
    cp BT_GEN
    jr z, .nodir
    cp BT_CROSS
    jr z, .nodir
    ld a, [wDir]
    or e
    ld e, a
.nodir
    ld [hl], e
    push hl
    hop 4
    ld d, 0
    ld a, b
    cp BT_MINER
    jr z, .ore
    cp BT_DRILL
    jr nz, .noore
.ore
    ld a, c
    sub 4
    ld d, a
.noore
    ld [hl], d
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], 0
    pop hl
    call DrawCell
    call SfxPlace
    ldh a, [hHudDirty]
    or 2
    ldh [hHudDirty], a
    ld a, b
    cp BT_ASM
    ret nz
    ldh a, [hQuiet]
    or a
    ret nz
    jp RecipeMenu

ErrMsg:
    call ShowMsg
    jp SfxError

RemoveAt:
    call CursorPtr
    ld a, [hl]
    or a
    ret z
    srl a
    srl a
    ld b, a
    cp BT_HUB
    jr nz, .ok
    ldh a, [hQuiet]
    or a
    ret nz
    ld de, Str_MsgNoRemove
    jp ErrMsg
.ok
    push hl
    ld a, b
    cp BT_BELT
    jr nz, .nb
    hop 4
    ld a, [hl]
    and $1F
    jr z, .nb
    ld d, a
    ld e, 1
    call StockAdd
.nb
    ld a, b
    call RefundCost
    pop hl
    ld [hl], 0
    push hl
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], 0
    pop hl
    call DrawCell
    call SfxRemove
    ldh a, [hHudDirty]
    or 2
    ldh [hHudDirty], a
    ret

; ---------------------------------------------------------------- stock / costs
StockPtr:                   ; A = item -> HL
    add a
    add LOW(wStock)
    ld l, a
    ld a, HIGH(wStock)
    adc 0
    ld h, a
    ret

StockAdd:                   ; D = item, E = amount. Preserves BC, DE
    ld a, d
    call StockPtr
    ld a, [hl]
    add e
    ld [hli], a
    ld a, [hl]
    adc 0
    ld [hld], a
    ld a, [hli]
    sub LOW(10000)
    ld a, [hl]
    sbc HIGH(10000)
    ret c
    ld a, HIGH(9999)
    ld [hld], a
    ld a, LOW(9999)
    ld [hl], a
    ret

StockSub:                   ; D = item, E = amount
    ld a, d
    call StockPtr
    ld a, [hl]
    sub e
    ld [hli], a
    ld a, [hl]
    sbc 0
    ld [hl], a
    ret

CostPtr:                    ; A = building type -> HL
    dec a
    add a
    add a
    add LOW(BuildCost)
    ld l, a
    ld a, HIGH(BuildCost)
    adc 0
    ld h, a
    ret

CanAfford:                  ; A = type. Carry set if not affordable
    call CostPtr
    call .one
    ret c
.one
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    ld a, d
    or a
    ret z
    push hl
    call StockPtr
    ld a, [hli]
    sub e
    ld a, [hl]
    sbc 0
    pop hl
    ret

PayCost:
    call CostPtr
    call .one
.one
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    ld a, d
    or a
    ret z
    push hl
    call StockSub
    pop hl
    ret

RefundCost:
    call CostPtr
    call .one
.one
    ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    ld a, d
    or a
    ret z
    push hl
    call StockAdd
    pop hl
    ret

BuildCost:
    db IT_IRON, 1, 0, 0             ; belt
    db IT_IRON, 4, 0, 0             ; miner
    db IT_STONE, 4, 0, 0            ; furnace
    db IT_IRON, 6, IT_COPPER, 4     ; assembler
    db IT_IRON, 6, IT_BRICK, 4      ; generator
    db IT_IRON, 2, IT_GEAR, 2       ; splitter
    db IT_IRON, 2, IT_GEAR, 2       ; crossing
    db IT_STEEL, 4, IT_CIRCUIT, 2   ; drill
    db IT_STEEL, 4, IT_BRICK, 6     ; electric furnace

BuildUnlock:                ; goals needed
    db 0, 0, 0, 1, 1, 2, 2, 5, 5

; recipe: inA, qtyA, inB, qtyB, out, outQty, time, pad
RecipeTab:
    db IT_IRON, 2, 0, 0, IT_GEAR, 1, 6, 0
    db IT_COPPER, 1, 0, 0, IT_WIRE, 2, 4, 0
    db IT_IRON, 1, IT_WIRE, 3, IT_CIRCUIT, 1, 12, 0
    db IT_IRON, 2, IT_COAL, 1, IT_STEEL, 1, 12, 0
    db IT_GEAR, 2, IT_STEEL, 1, IT_ENGINE, 1, 20, 0
    db IT_STEEL, 1, IT_BRICK, 2, IT_FRAME, 1, 16, 0
    db IT_CIRCUIT, 2, IT_WIRE, 2, IT_BRAIN, 1, 24, 0
    db IT_ENGINE, 1, IT_BRAIN, 1, IT_ROCKET, 1, 32, 0

RecipeUnlock:
    db 1, 2, 3, 4, 6, 6, 7, 8

RecipePtr:                  ; A = recipe id (1..) -> HL
    dec a
    add a
    add a
    add a
    add LOW(RecipeTab)
    ld l, a
    ld a, HIGH(RecipeTab)
    adc 0
    ld h, a
    ret

MachBase:
    db 0, T_BELT, T_MINER, T_FURN, T_ASM, T_GEN, T_SPLIT, T_CROSS, T_DRILL, T_EFURN, T_HUB

BuildNames:
    dw Str_BN1, Str_BN2, Str_BN3, Str_BN4, Str_BN5, Str_BN6, Str_BN7, Str_BN8, Str_BN9, Str_BN10
ItemNames:
    dw Str_IN1, Str_IN2, Str_IN3, Str_IN4, Str_IN5, Str_IN6, Str_IN7, Str_IN8
    dw Str_IN9, Str_IN10, Str_IN11, Str_IN12, Str_IN13, Str_IN14, Str_IN15

BuildNamePtr:               ; A = type -> DE. Preserves HL
    push hl
    dec a
    add a
    add LOW(BuildNames)
    ld l, a
    ld a, HIGH(BuildNames)
    adc 0
    ld h, a
    ld a, [hli]
    ld d, [hl]
    ld e, a
    pop hl
    ret

ItemNamePtr:                ; A = item -> DE. Preserves HL
    push hl
    dec a
    add a
    add LOW(ItemNames)
    ld l, a
    ld a, HIGH(ItemNames)
    adc 0
    ld h, a
    ld a, [hli]
    ld d, [hl]
    ld e, a
    pop hl
    ret

; ---------------------------------------------------------------- cell drawing
; HL = cell (type array) -> A = tile. Preserves HL, BC
CellTile:
    ld a, [hl]
    or a
    jr z, .terr
    ld e, a
    and 3
    ld d, a                 ; D = dir
    ld a, e
    srl a
    srl a
    cp BT_BELT
    jr nz, .notBelt
    push hl
    hop 4
    ld a, [hl]
    pop hl
    and $1F
    jr z, .emptyBelt
    dec a
    add a
    add a
    add d
    add T_ITEMB
    ret
.emptyBelt
    ld a, d
    add T_BELT
    ret
.notBelt
    cp BT_HUB
    jr nz, .mach
    push hl
    hop 8
    ld a, [hl]
    pop hl
    add T_HUB
    ret
.mach
    push hl
    add LOW(MachBase)
    ld l, a
    ld a, HIGH(MachBase)
    adc 0
    ld h, a
    ld e, [hl]
    pop hl
    push hl
    hop 16
    ld a, [hl]
    pop hl
    and $80
    jr z, .na
    ld a, 4
.na add d
    add e
    ret
.terr
    push hl
    hop -4
    ld a, [hl]
    pop hl
    add T_TERR
    ret

; HL = cell. Preserves HL, BC, DE
DrawCell:
    push hl
    push bc
    push de
    call CellTile
    ld b, a
    ld e, a
    ld d, HIGH(TileAttr)
    ld a, [de]
    ld c, a
    ld a, h
    sub HIGH(wMapType) - HIGH(BGM)
    ld h, a
    call PutTile
    pop de
    pop bc
    pop hl
    ret

; HL = cell, A = 0 / $80. Updates the "active" look of a machine
SetActive:
    ld e, a
    ld d, h
    hop 16
    ld a, [hl]
    and $80
    cp e
    jr z, .same
    ld a, [hl]
    xor $80
    ld [hl], a
    ld h, d
    jp DrawCell
.same
    ld h, d
    ret

; ---------------------------------------------------------------- simulation
SimSlice:
    ld a, [wSimIdx]
    ld l, a
    ld a, [wSimIdx + 1]
    ld h, a
    ld b, SIM_SLICE
    ld a, [wSimDir]
    or a
    jr nz, .back
.fwd
    ld a, [hl]
    or a
    jr z, .fnext
    push bc
    push hl
    call SimCell
    pop hl
    pop bc
.fnext
    inc hl
    ld a, h
    cp HIGH(wMapType) + 4
    jr nz, .fcont
    call EndPass
    ld hl, wMapType + 1023
    jr .store
.fcont
    dec b
    jr nz, .fwd
.store
    ld a, l
    ld [wSimIdx], a
    ld a, h
    ld [wSimIdx + 1], a
    ret
.back
    ld a, [hl]
    or a
    jr z, .bnext
    push bc
    push hl
    call SimCell
    pop hl
    pop bc
.bnext
    dec hl
    ld a, h
    cp HIGH(wMapType) - 1
    jr nz, .bcont
    call EndPass
    ld hl, wMapType
    jr .store
.bcont
    dec b
    jr nz, .back
    jr .store

EndPass:
    ld hl, wSimDir
    ld a, [hl]
    xor 1
    ld [hl], a
    ld hl, wParity
    ld a, [hl]
    xor $80
    ld [hl], a
    ld hl, wPowSupAcc
    ld a, [hli]
    ld e, a
    ld d, [hl]
    xor a
    ld [hld], a
    ld [hl], a
    ld hl, wPowDemAcc
    ld a, [hli]
    ld c, a
    ld b, [hl]
    xor a
    ld [hld], a
    ld [hl], a
    ld hl, wPowSupply
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, c
    ld [hli], a
    ld [hl], b
    ldh a, [hHudDirty]
    or 6
    ldh [hHudDirty], a
    ld a, b
    or c
    jr z, .ok0
    ld a, e
    sub c
    ld a, d
    sbc b
    jr nc, .ok0
    ; short on power: machines run on a fraction of the passes.
    ; a small trickle (demand/8 + 1) always remains so a blackout can recover.
    push bc
    srl b
    rr c
    srl b
    rr c
    srl b
    rr c
    inc bc
    ld a, e
    add c
    ld e, a
    ld a, d
    adc b
    ld d, a
    pop bc
    ld hl, wPowFrac
    ld a, [hl]
    add e
    ld [hli], a
    ld a, [hl]
    adc d
    ld [hld], a
    ld a, [hli]
    sub c
    ld e, a
    ld a, [hl]
    sbc b
    jr c, .no
    ld [hld], a
    ld [hl], e
    ld a, 1
    jr .set
.no xor a
    jr .set
.ok0
    xor a
    ld [wPowFrac], a
    ld [wPowFrac + 1], a
    inc a
.set
    ld [wPowOK], a
    call GoalCheck
    jr c, .notReady
    ld a, [wGoalNote]
    or a
    ret nz
    inc a
    ld [wGoalNote], a
    ld [wNotify], a
    ret
.notReady
    xor a
    ld [wGoalNote], a
    ret

AddDemand:                  ; A = amount. Preserves BC, DE, HL
    push hl
    ld hl, wPowDemAcc
    jr AddAcc
AddSupply:
    push hl
    ld hl, wPowSupAcc
AddAcc:
    add [hl]
    ld [hli], a
    jr nc, .x
    inc [hl]
.x  pop hl
    ret

; HL = cell, C = direction -> HL = neighbour cell
NeighborHL:
    ld a, c
    and 3
    jr z, .n
    dec a
    jr z, .e
    dec a
    jr z, .s
    dec hl
    ret
.e  inc hl
    ret
.n  ld a, l
    sub 32
    ld l, a
    ret nc
    dec h
    ret
.s  ld a, l
    add 32
    ld l, a
    ret nc
    inc h
    ret

; HL = cell, A = type byte
SimCell:
    ld c, a
    srl a
    srl a
    dec a
    add a
    add LOW(SimJump)
    ld e, a
    ld a, HIGH(SimJump)
    adc 0
    ld d, a
    ld a, [de]
    ld b, a
    inc de
    ld a, [de]
    ld d, a
    ld e, b
    push de
    ret                     ; jump to handler: HL = cell, C = type|dir

SimJump:
    dw SimBelt, SimMiner, SimFurn, SimAsm, SimGen, SimSplit, SimCross, SimDrill, SimEFurn, SimNone

SimNone:
    ret

SimBelt:
    push hl
    hop 4
    ld a, [hl]
    ld b, a
    and $1F
    jr z, .done
    ld e, a
    ld a, [wParity]
    xor b
    and $80
    jr z, .done
    ld a, [wParity]
    or e
    ld [hl], a
    pop hl
    push hl
    ld b, e
    call NeighborHL
    call TryInsert
    jr nc, .done
    pop hl
    push hl
    hop 4
    ld [hl], 0
    pop hl
    jp DrawCell
.done
    pop hl
    ret

SimSplit:
    push hl
    hop 4
    ld a, [hl]
    ld b, a
    and $1F
    jr z, .done
    ld e, a
    ld a, [wParity]
    xor b
    and $80
    jr z, .done
    ld a, [wParity]
    or e
    ld [hl], a
    ld b, e                 ; B = item
    hop 4
    ld a, [hl]
    ldh [hSplitIdx], a
    ld a, 3
    ldh [hSplitCnt], a
    ld a, c
    and 3
    ldh [hSplitDir], a
.try
    ldh a, [hSplitIdx]
    cp 2
    jr nz, .o
    inc a
.o  ld c, a
    ldh a, [hSplitDir]
    add c
    and 3
    ld c, a
    pop hl
    push hl
    call NeighborHL
    call TryInsert
    jr c, .ok
    ldh a, [hSplitIdx]
    inc a
    cp 3
    jr c, .s
    xor a
.s  ldh [hSplitIdx], a
    ldh a, [hSplitCnt]
    dec a
    ldh [hSplitCnt], a
    jr nz, .try
    jr .done
.ok
    ldh a, [hSplitIdx]
    inc a
    cp 3
    jr c, .s2
    xor a
.s2 ld e, a
    pop hl
    push hl
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], e
.done
    pop hl
    ret

SimCross:
    push hl
    hop 4
    ld a, [hl]
    ld b, a
    and $1F
    jr z, .v
    ld e, a
    ld a, [wParity]
    xor b
    and $80
    jr z, .v
    ld a, b
    and $40
    ld d, a
    ld a, [wParity]
    or e
    or d
    ld [hl], a
    ld c, 1
    bit 6, b
    jr z, .h1
    ld c, 3
.h1 ld b, e
    pop hl
    push hl
    call NeighborHL
    call TryInsert
    jr nc, .v
    pop hl
    push hl
    hop 4
    ld [hl], 0
.v  pop hl
    push hl
    hop 8
    ld a, [hl]
    ld b, a
    and $1F
    jr z, .done
    ld e, a
    ld a, [wParity]
    xor b
    and $80
    jr z, .done
    ld a, b
    and $40
    ld d, a
    ld a, [wParity]
    or e
    or d
    ld [hl], a
    ld c, 2
    bit 6, b
    jr z, .v1
    ld c, 0
.v1 ld b, e
    pop hl
    push hl
    call NeighborHL
    call TryInsert
    jr nc, .done
    pop hl
    push hl
    hop 8
    ld [hl], 0
.done
    pop hl
    ret

; HL = cell, C = type|dir, B = item. Tries to push one pending output. Preserves HL, C
MachOut:
    push hl
    push bc
    hop 16
    ld a, [hl]
    and $0F
    jr z, .none
    pop bc
    pop hl
    push hl
    push bc
    call NeighborHL
    ld a, c
    and 3
    ld c, a
    call TryInsert
    jr nc, .none
    pop bc
    pop hl
    push hl
    push bc
    hop 16
    dec [hl]
.none
    pop bc
    pop hl
    ret

SimMiner:
    ld a, MINER_TIME
    jr MinerCommon
SimDrill:
    ld a, DRILL_POWER
    call AddDemand
    ld a, [wPowOK]
    or a
    jr z, MinerCommon       ; A = 0 -> stalled
    ld a, DRILL_TIME
MinerCommon:
    ldh [hPeriod], a
    push hl
    hop 4
    ld b, [hl]
    pop hl
    call MachOut
    ldh a, [hPeriod]
    or a
    jr z, .idle
    push hl
    hop 16
    ld a, [hl]
    and $0F
    cp 2
    jr nc, .full
    hop -8
    ld a, [hl]
    or a
    jr nz, .dec
    ldh a, [hPeriod]
.dec
    dec a
    ld [hl], a
    jr nz, .act
    hop 8
    inc [hl]
.act
    pop hl
    ld a, $80
    jp SetActive
.full
    pop hl
.idle
    xor a
    jp SetActive

SimFurn:
    ld a, FURN_TIME
    jr FurnCommon
SimEFurn:
    ld a, EFURN_POWER
    call AddDemand
    ld a, [wPowOK]
    or a
    jr z, FurnCommon
    ld a, EFURN_TIME
FurnCommon:
    ldh [hPeriod], a
    push hl
    hop 4
    ld a, [hl]
    pop hl
    or a
    jr z, .idle
    ld b, IT_IRON
    cp IT_IRONORE
    jr z, .o
    ld b, IT_COPPER
    cp IT_COPORE
    jr z, .o
    ld b, IT_BRICK
.o  call MachOut
    ldh a, [hPeriod]
    or a
    jr z, .idle
    push hl
    hop 8
    ld a, [hl]
    or a
    jr z, .start
    dec [hl]
    jr nz, .run
    hop 8
    inc [hl]
    pop hl
    push hl
    hop 8
.start
    hop 8
    ld a, [hl]
    and $0F
    cp 4
    jr nc, .stop
    ld e, a
    hop -4
    ld a, [hl]
    or a
    jr z, .empty
    dec [hl]
    hop -4
    ldh a, [hPeriod]
    ld [hl], a
.run
    pop hl
    ld a, $80
    jp SetActive
.empty
    ld a, e
    or a
    jr nz, .stop
    hop -8
    ld [hl], 0
.stop
    pop hl
.idle
    xor a
    jp SetActive

SimAsm:
    ld a, ASM_POWER
    call AddDemand
    push hl
    hop 4
    ld a, [hl]
    pop hl
    or a
    jp z, .idle
    push hl
    call RecipePtr
    ld a, l
    ldh [hRecLo], a
    ld a, h
    ldh [hRecHi], a
    ld de, 4
    add hl, de
    ld b, [hl]
    pop hl
    call MachOut
    ld a, [wPowOK]
    or a
    jr z, .idle
    push hl
    hop 8
    ld a, [hl]
    or a
    jr z, .start
    dec [hl]
    jr nz, .run
    hop 8
    call .rec
    inc de
    inc de
    inc de
    inc de
    inc de
    ld a, [de]
    add [hl]
    ld [hl], a
    pop hl
    push hl
    hop 8
.start
    hop 8
    ld a, [hl]
    and $0F
    cp 4
    jr nc, .stop
    hop -4
    call .rec
    inc de
    ld a, [de]
    ld b, a
    inc de
    inc de
    ld a, [de]
    swap a
    ld e, a
    ld a, [hl]
    and $0F
    cp b
    jr c, .stop
    ld a, [hl]
    and $F0
    cp e
    jr c, .stop
    ld a, [hl]
    sub b
    sub e
    ld [hl], a
    hop -4
    call .rec
    ld a, e
    add 6
    ld e, a
    jr nc, .nc
    inc d
.nc ld a, [de]
    ld [hl], a
.run
    pop hl
    ld a, $80
    jp SetActive
.stop
    pop hl
.idle
    xor a
    jp SetActive
.rec
    ldh a, [hRecLo]
    ld e, a
    ldh a, [hRecHi]
    ld d, a
    ret

SimGen:
    push hl
    hop 8
    ld a, [hl]
    or a
    jr nz, .burn
    ld a, [wPowDemand]
    ld e, a
    ld a, [wPowDemand + 1]
    or e
    jr z, .off
    hop 4
    ld a, [hl]
    or a
    jr z, .off
    dec [hl]
    hop -4
    ld [hl], GEN_BURN + 1
.burn
    dec [hl]
    ld a, GEN_POWER
    call AddSupply
    pop hl
    ld a, $80
    jp SetActive
.off
    pop hl
    xor a
    jp SetActive

; HL = target cell, B = item, C = heading. Carry set if accepted. Preserves BC
TryInsert:
    ld a, [hl]
    or a
    ret z
    ld e, a
    srl a
    srl a
    cp BT_BELT
    jr z, .belt
    cp BT_HUB
    jr z, .hub
    cp BT_FURN
    jr z, .furn
    cp BT_EFURN
    jr z, .furn
    cp BT_ASM
    jp z, .asm
    cp BT_SPLIT
    jr z, .split
    cp BT_CROSS
    jp z, .cross
    cp BT_GEN
    jp z, .gen
.fail
    or a
    ret
.belt
    ld a, e
    xor c
    and 3
    cp 2
    jr z, .fail
    ld d, h
    hop 4
    ld a, [hl]
    and $1F
    jr nz, .failH
    ld a, [wParity]
    or b
    ld [hl], a
    ld h, d
    call DrawCell
    scf
    ret
.split
    ld a, e
    xor c
    and 3
    cp 2
    jr z, .fail
    ld d, h
    hop 4
    ld a, [hl]
    and $1F
    jr nz, .failH
    ld a, [wParity]
    or b
    ld [hl], a
    ld h, d
    scf
    ret
.failH
    ld h, d
    or a
    ret
.hub
    ld d, b
    ld e, 1
    call StockAdd
    scf
    ret
.furn
    ld a, b
    cp IT_IRONORE
    jr z, .fok
    cp IT_COPORE
    jr z, .fok
    cp IT_STONE
    jr nz, .fail
.fok
    ld d, h
    hop 4
    ld a, [hl]
    or a
    jr z, .fnew
    cp b
    jr nz, .failH
    hop 8
    ld a, [hl]
    cp 4
    jr nc, .failH
    inc [hl]
    ld h, d
    scf
    ret
.fnew
    ld [hl], b
    hop 8
    ld [hl], 1
    ld h, d
    scf
    ret
.asm
    push hl
    hop 4
    ld a, [hl]
    or a
    jr z, .asmFail
    call RecipePtr
    ld a, [hl]
    cp b
    jr z, .asmA
    inc hl
    inc hl
    ld a, [hl]
    cp b
    jr nz, .asmFail
    pop hl
    ld d, h
    hop 12
    ld a, [hl]
    and $F0
    cp $60
    jr nc, .failH
    ld a, [hl]
    add $10
    ld [hl], a
    ld h, d
    scf
    ret
.asmA
    pop hl
    ld d, h
    hop 12
    ld a, [hl]
    and $0F
    cp 6
    jr nc, .failH
    inc [hl]
    ld h, d
    scf
    ret
.asmFail
    pop hl
    or a
    ret
.gen
    ld a, b
    cp IT_COAL
    jp nz, .fail
    ld d, h
    hop 12
    ld a, [hl]
    cp 8
    jr nc, .failH2
    inc [hl]
    ld h, d
    scf
    ret
.cross
    ld d, h
    bit 0, c
    jr z, .crossV
    hop 4
    ld a, [hl]
    and $1F
    jr nz, .failH2
    ld a, [wParity]
    or b
    bit 1, c
    jr z, .cE
    or $40
.cE ld [hl], a
    ld h, d
    scf
    ret
.crossV
    hop 8
    ld a, [hl]
    and $1F
    jr nz, .failH2
    ld a, [wParity]
    or b
    bit 1, c
    jr nz, .cS
    or $40
.cS ld [hl], a
    ld h, d
    scf
    ret
.failH2
    ld h, d
    or a
    ret

; ---------------------------------------------------------------- goals
GoalPtr:                    ; -> HL = record of current goal
    ld a, [wGoal]
    ld l, a
    ld h, 0
    add hl, hl
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, GoalTab
    add hl, de
    ret

GoalCheck:                  ; carry set if NOT deliverable
    ld a, [wGoal]
    cp NUM_GOALS
    ccf
    ret c
    call GoalPtr
    ld b, 3
.l  ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld c, a
    ld a, d
    or a
    jr z, .next
    push hl
    call StockPtr
    ld a, [hli]
    sub e
    ld a, [hl]
    sbc c
    pop hl
    ret c
.next
    dec b
    jr nz, .l
    or a
    ret

GoalConsume:
    call GoalPtr
    ld b, 3
.l  ld a, [hli]
    ld d, a
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld c, a
    ld a, d
    or a
    jr z, .next
    push hl
    call StockPtr
    ld a, [hl]
    sub e
    ld [hli], a
    ld a, [hl]
    sbc c
    ld [hl], a
    pop hl
.next
    dec b
    jr nz, .l
    ret

; ---------------------------------------------------------------- camera / sprites
UpdateCamera:
    ld a, [wCurX]
    add a
    add a
    add a
    sub 76
    jr nc, .x1
    xor a
.x1 cp 97
    jr c, .x2
    ld a, 96
.x2 ld b, a
    ld a, [wCamX]
    call Ease
    ld [wCamX], a
    ldh [hSCX], a
    ld a, [wCurY]
    add a
    add a
    add a
    sub 60
    jr nc, .y1
    xor a
.y1 cp 129
    jr c, .y2
    ld a, 128
.y2 ld b, a
    ld a, [wCamY]
    call Ease
    ld [wCamY], a
    ldh [hSCY], a
    ret

Ease:                       ; A = current, B = target -> A
    cp b
    ret z
    jr c, .up
    sub b
    cp 16
    jr c, .d2
    ld c, 4
    jr .dd
.d2 cp 2
    jr c, .d1
    ld c, 2
    jr .dd
.d1 ld c, 1
.dd add b
    sub c
    ret
.up ld c, a
    ld a, b
    sub c
    cp 16
    jr c, .u2
    ld a, 4
    jr .uu
.u2 cp 2
    jr c, .u1
    ld a, 2
    jr .uu
.u1 ld a, 1
.uu add c
    ret

UpdateSprites:
    ld hl, wOAM
    ld a, [wCamX]
    ld b, a
    ld a, [wCurX]
    add a
    add a
    add a
    sub b
    add 8
    ld d, a                 ; D = X
    ld a, [wCamY]
    ld b, a
    ld a, [wCurY]
    add a
    add a
    add a
    sub b
    add 16
    ld e, a                 ; E = Y
    ldh a, [hFrame]
    and $10
    swap a
    ld c, a                 ; palette 0/1
    ld a, e
    dec a
    ld [hli], a
    ld a, d
    dec a
    ld [hli], a
    ld a, T_CURSOR
    ld [hli], a
    ld a, c
    ld [hli], a
    ld a, e
    dec a
    ld [hli], a
    ld a, d
    inc a
    ld [hli], a
    ld a, T_CURSOR
    ld [hli], a
    ld a, c
    or $20
    ld [hli], a
    ld a, e
    inc a
    ld [hli], a
    ld a, d
    dec a
    ld [hli], a
    ld a, T_CURSOR
    ld [hli], a
    ld a, c
    or $40
    ld [hli], a
    ld a, e
    inc a
    ld [hli], a
    ld a, d
    inc a
    ld [hli], a
    ld a, T_CURSOR
    ld [hli], a
    ld a, c
    or $60
    ld [hli], a
    ; direction arrow
    ld a, [wTool]
    cp BT_GEN
    jr z, .noArrow
    cp BT_CROSS
    jr z, .noArrow
    ldh a, [hFrame]
    and 8
    jr z, .noArrow
    ld a, [wDir]
    add a
    add a
    add LOW(ArrowTab)
    ld c, a
    ld a, HIGH(ArrowTab)
    adc 0
    ld b, a
    ld a, [bc]
    add e
    ld [hli], a
    inc bc
    ld a, [bc]
    add d
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    inc bc
    ld a, [bc]
    ld [hli], a
    ret
.noArrow
    xor a
    ld [hli], a
    ld [hli], a
    ret

ArrowTab:                   ; dy, dx, tile, attr
    db -8, 0, T_ARROW_U, 0
    db 0, 8, T_ARROW_R, 0
    db 8, 0, T_ARROW_U, $40
    db 0, -8, T_ARROW_R, $20

; ---------------------------------------------------------------- HUD
UpdateHud:
    ld a, [wMsgTimer]
    or a
    jr z, .nomsg
    dec a
    ld [wMsgTimer], a
    jr nz, .nomsg
    ldh a, [hHudDirty]
    or 2
    ldh [hHudDirty], a
.nomsg
    ld a, [wNotify]
    or a
    jr z, .nonote
    xor a
    ld [wNotify], a
    ld de, Str_MsgGoalReady
    call ShowMsg
    call SfxNotify
.nonote
    ldh a, [hHudDirty]
    bit 0, a
    call nz, DrawHudTool
    ldh a, [hHudDirty]
    bit 1, a
    call nz, DrawHudInfo
    ldh a, [hHudDirty]
    bit 2, a
    call nz, DrawHudPower
    xor a
    ldh [hHudDirty], a
    ret

ShowMsg:                    ; DE = string
    ldh a, [hMenuOpen]
    or a
    ret nz
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld hl, WIN + 32
    call PrintStr
    ld a, 20
    call PadTo
    ld a, 120
    ld [wMsgTimer], a
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ret

; A = building type -> A = display tile (uses current direction where relevant)
ToolTile:
    ld e, a
    add LOW(MachBase)
    ld l, a
    ld a, HIGH(MachBase)
    adc 0
    ld h, a
    ld a, e
    ld e, [hl]
    cp BT_GEN
    jr z, .nd
    cp BT_CROSS
    jr z, .nd
    ld a, [wDir]
    add e
    ret
.nd ld a, e
    ret

DrawHudTool:
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ld a, [wTool]
    call ToolTile
    ld hl, WIN
    call PutIcon
    xor a
    call PutChar
    ld a, [wTool]
    call BuildNamePtr
    call PrintStr
    ld a, 10
    call PadTo
    ; fallthrough

DrawHudPower:
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ld hl, WIN + 10
    ld a, GLY_DEN
    call PutChar
    ld a, [wPowDemand]
    ld e, a
    ld a, [wPowDemand + 1]
    ld d, a
    ld b, 3
    call PrintNum
    ld a, GLY_SLASH
    call PutChar
    ld a, [wPowSupply]
    ld e, a
    ld a, [wPowSupply + 1]
    ld d, a
    ld b, 3
    call PrintNum
    ld a, [wPowOK]
    or a
    ld a, 0
    jr nz, .p
    ld a, GLY_EXCL
.p  call PutChar
    xor a
    jp PutChar

DrawHudInfo:
    ld a, [wMsgTimer]
    or a
    ret nz
    ld a, TA_WHITE
    ldh [hTextAttr], a
    call CursorPtr
    ld a, l
    ldh [hInfoLo], a
    ld a, h
    ldh [hInfoHi], a
    ld a, [hl]
    or a
    jp z, .terr
    srl a
    srl a
    ld [wTmpItem], a
    call BuildNamePtr
    ld hl, WIN + 32
    call PrintStr
    ld a, [wTmpItem]
    cp BT_ASM
    jr z, .asm
    cp BT_MINER
    jr z, .ore
    cp BT_DRILL
    jr z, .ore
    cp BT_FURN
    jr z, .furn
    cp BT_EFURN
    jr z, .furn
    cp BT_GEN
    jp nz, .pad
    ld d, IT_COAL
    jr .buf
.furn
    ld a, 4
    call InfoByte
    or a
    jp z, .pad
    ld d, a
.buf                        ; D = item held in buffer A
    inc hl
    ld a, d
    add T_ICON - 1
    call PutIcon
    ld a, 12
    call InfoByte
    and $0F
    add GLY_0
    call PutChar
    jp .pad
.ore
    ld a, GLY_COLON
    call PutChar
    ld a, 4
    call InfoByte
    call ItemNamePtr
    call PrintStr
    jp .pad
.asm
    ld a, GLY_COLON
    call PutChar
    ld a, 4
    call InfoByte
    or a
    jr nz, .rec
    ld de, Str_NoRecipe
    call PrintStr
    jr .pad
.rec
    ld [wTmpItem], a
    push hl
    call RecipePtr
    ld de, 4
    add hl, de
    ld a, [hl]
    pop hl
    call ItemNamePtr
    call PrintStr
    inc hl
    push hl
    ld a, [wTmpItem]
    call RecipePtr
    ld a, [hli]
    ld d, a
    inc hl
    ld e, [hl]
    pop hl
    push de
    ld a, d
    add T_ICON - 1
    call PutIcon
    ld a, 12
    call InfoByte
    and $0F
    add GLY_0
    call PutChar
    pop de
    ld a, e
    or a
    jr z, .pad
    add T_ICON - 1
    call PutIcon
    ld a, 12
    call InfoByte
    swap a
    and $0F
    add GLY_0
    call PutChar
    jr .pad
.terr
    hop -4
    ld a, [hl]
    ld hl, WIN + 32
    cp TR_TREE
    jr c, .pad
    jr nz, .t1
    ld de, Str_TerrTree
    jr .tp
.t1 cp TR_WATER
    jr nz, .t2
    ld de, Str_TerrWater
    jr .tp
.t2 sub 4
    call ItemNamePtr
.tp call PrintStr
.pad
    ld a, 20
    jp PadTo

; A = array offset from the type array -> A = byte of the inspected cell. Preserves HL, DE
InfoByte:
    push hl
    ld b, a
    ldh a, [hInfoLo]
    ld l, a
    ldh a, [hInfoHi]
    add b
    ld h, a
    ld a, [hl]
    pop hl
    ret

; ---------------------------------------------------------------- window helpers
OpenWin:
    ld a, 1
    ldh [hMenuOpen], a
    call HideSprites
WinOffClear:
    ldh a, [rLCDC]
    res 5, a
    ldh [rLCDC], a
    jp ClearWin

ShowWin:
    xor a
    ldh [rWY], a
    ldh a, [rLCDC]
    set 5, a
    ldh [rLCDC], a
    ret

CloseWin:
    ldh a, [rLCDC]
    res 5, a
    ldh [rLCDC], a
    xor a
    ldh [hMenuOpen], a
    ldh [hJoyPressed], a
    ldh [hJoyRepeat], a
    call ClearWin
    ld a, 7
    ldh [hHudDirty], a
    call UpdateHud
    ld a, 128
    ldh [rWY], a
    ldh a, [rLCDC]
    set 5, a
    ldh [rLCDC], a
    ret

MenuCursorPos:
    ld a, [wMenuTop]
    ld hl, wMenuSel
    add [hl]
    jp WinRow

MenuCursorDraw:
    call MenuCursorPos
    ld b, GLY_CURSOR
    ld c, TA_YELLOW
    jp PutTile

MenuMove:
    ldh a, [hJoyRepeat]
    and PAD_UP | PAD_DOWN
    ret z
    push af
    call MenuCursorPos
    ld b, 0
    ld c, TA_WHITE
    call PutTile
    pop af
    bit 6, a
    jr z, .down
    ld a, [wMenuSel]
    or a
    jr nz, .d1
    ld a, [wMenuCount]
.d1 dec a
    jr .set
.down
    ld a, [wMenuSel]
    inc a
    ld hl, wMenuCount
    cp [hl]
    jr c, .set
    xor a
.set
    ld [wMenuSel], a
    call MenuCursorDraw
    jp SfxTick

PrintHint:                  ; DE = string, bottom row
    ld a, TA_CYAN
    ldh [hTextAttr], a
    ld hl, WIN + 17 * 32 + 1
    call PrintStr
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ret

PrintTitle:                 ; DE = string, top row
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld hl, WIN + 1
    call PrintStr
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ret

; ---------------------------------------------------------------- main menu
MainMenu:
    call SfxTick
    call OpenWin
    xor a
    ld [wMenuSel], a
    call BuildMenuList
    ld hl, wMenuList
    ld b, 0
.find
    ld a, [wMenuCount]
    cp b
    jr z, .redraw
    ld a, [wTool]
    cp [hl]
    jr z, .found
    inc hl
    inc b
    jr .find
.found
    ld a, b
    ld [wMenuSel], a
.redraw
    call BuildMenuList
    call DrawMainMenu
    call ShowWin
.loop
    call NextFrame
    ldh a, [hJoyPressed]
    and PAD_B | PAD_START
    jr nz, .close
    call MenuMove
    ldh a, [hJoyPressed]
    bit 0, a
    jr z, .loop
    ld a, [wMenuSel]
    ld e, a
    ld d, 0
    ld hl, wMenuList
    add hl, de
    ld a, [hl]
    cp $80
    jr nc, .special
    ld [wTool], a
    call SfxTick
.close
    jp CloseWin
.special
    sub $80
    jr z, .goal
    dec a
    jr z, .stock
    dec a
    jr z, .save
    dec a
    jr z, .bgm
    call HelpScreen
    jr .back
.goal
    call GoalScreen
    jr .back
.stock
    call StockScreen
.back
    call WinOffClear
    jr .redraw
.save
    call SaveGame
    call CloseWin
    ld de, Str_MsgSaved
    call ShowMsg
    jp SfxPlace
.bgm
    call ToggleMusic
    call SfxTick
    jr .back

BuildMenuList:
    ld hl, wMenuList
    ld c, 0
    ld b, 1
.l  push hl
    ld a, b
    dec a
    add LOW(BuildUnlock)
    ld l, a
    ld a, HIGH(BuildUnlock)
    adc 0
    ld h, a
    ld a, [wGoal]
    cp [hl]
    pop hl
    jr c, .skip
    ld [hl], b
    inc hl
    inc c
.skip
    inc b
    ld a, b
    cp NUM_BUILD + 1
    jr nz, .l
    ld b, 5
    ld a, $80
.s  ld [hli], a
    inc a
    inc c
    dec b
    jr nz, .s
    ld a, c
    ld [wMenuCount], a
    ld hl, wMenuSel
    ld a, [hl]
    cp c
    ret c
    ld [hl], 0
    ret

SpecialNames:
    dw Str_MenuGoal, Str_MenuStock, Str_MenuSave, Str_MenuBgmOn, Str_MenuHelp

DrawMainMenu:
    ld de, Str_MenuTitle
    call PrintTitle
    ld a, 2
    ld [wMenuTop], a
    xor a
    ld [wTmpK], a
.l  ld a, [wTmpK]
    ld hl, wMenuCount
    cp [hl]
    jp z, .done
    ld e, a
    ld d, 0
    ld hl, wMenuList
    add hl, de
    ld a, [hl]
    ld [wTmpItem], a
    ld a, [wTmpK]
    add 2
    call WinRow
    inc hl
    ld a, [wTmpItem]
    cp $80
    jr nc, .sp
    push hl
    add LOW(MachBase)
    ld l, a
    ld a, HIGH(MachBase)
    adc 0
    ld h, a
    ld a, [hl]
    pop hl
    call PutIcon
    inc hl
    ld a, [wTmpItem]
    call BuildNamePtr
    call PrintStr
    ld a, [wTmpK]
    add 2
    call WinRow
    ld bc, 11
    add hl, bc
    push hl
    ld a, [wTmpItem]
    call CostPtr
    ld d, h
    ld e, l
    pop hl
    call .cost
    inc hl
    call .cost
    jr .next
.sp inc hl
    inc hl
    sub $80
    push hl
    add a
    add LOW(SpecialNames)
    ld l, a
    ld a, HIGH(SpecialNames)
    adc 0
    ld h, a
    ld a, [hli]
    ld d, [hl]
    ld e, a
    pop hl
    ld a, [wTmpItem]
    cp $83
    jr nz, .spp
    ld a, [wMusicOn]
    or a
    jr nz, .spp
    ld de, Str_MenuBgmOff
.spp
    call PrintStr
.next
    ld hl, wTmpK
    inc [hl]
    jp .l
.done
    ld de, Str_Hint
    call PrintHint
    jp MenuCursorDraw
.cost                       ; DE -> (item, qty), HL = dest
    ld a, [de]
    inc de
    or a
    jr z, .c0
    push de
    add T_ICON - 1
    call PutIcon
    pop de
    ld a, [de]
    inc de
    push de
    ld e, a
    ld d, 0
    ld b, 2
    call PrintNum
    pop de
    ret
.c0 inc de
    ret

; ---------------------------------------------------------------- recipe menu
RecipeMenu:
    call SfxTick
    call OpenWin
    ld hl, wMenuList
    ld c, 0
    ld b, 1
.l  push hl
    ld a, b
    dec a
    add LOW(RecipeUnlock)
    ld l, a
    ld a, HIGH(RecipeUnlock)
    adc 0
    ld h, a
    ld a, [wGoal]
    cp [hl]
    pop hl
    jr c, .skip
    ld [hl], b
    inc hl
    inc c
.skip
    inc b
    ld a, b
    cp NUM_RECIPES + 1
    jr nz, .l
    ld a, c
    ld [wMenuCount], a
    ; preselect current recipe
    call CursorPtr
    hop 4
    ld d, [hl]
    xor a
    ld [wMenuSel], a
    ld hl, wMenuList
    ld b, 0
.find
    ld a, b
    cp c
    jr z, .draw
    ld a, [hli]
    cp d
    jr z, .found
    inc b
    jr .find
.found
    ld a, b
    ld [wMenuSel], a
.draw
    ld de, Str_RecipeTitle
    call PrintTitle
    ld a, 2
    ld [wMenuTop], a
    xor a
    ld [wTmpK], a
.dl ld a, [wTmpK]
    ld hl, wMenuCount
    cp [hl]
    jr z, .drawn
    ld e, a
    ld d, 0
    ld hl, wMenuList
    add hl, de
    ld a, [hl]
    call RecipePtr
    ld d, h
    ld e, l                 ; DE = recipe
    ld a, [wTmpK]
    add 2
    call WinRow
    inc hl
    push de
    inc de
    inc de
    inc de
    inc de
    ld a, [de]
    ld [wTmpItem], a
    add T_ICON - 1
    call PutIcon
    inc hl
    ld a, [wTmpItem]
    call ItemNamePtr
    call PrintStr
    ld a, [wTmpK]
    add 2
    call WinRow
    ld bc, 10
    add hl, bc
    pop de
    ld a, GLY_LARROW
    call PutChar
    call .ing
    inc hl
    call .ing
    inc hl
    ; output quantity
    inc de
    ld a, [de]
    cp 2
    jr c, .dn
    push af
    ld a, GLY_BATSU
    call PutChar
    pop af
    add GLY_0
    call PutChar
.dn ld hl, wTmpK
    inc [hl]
    jr .dl
.drawn
    ld de, Str_Hint
    call PrintHint
    call MenuCursorDraw
    call ShowWin
.loop
    call NextFrame
    ldh a, [hJoyPressed]
    bit 1, a
    jr nz, .close
    call MenuMove
    ldh a, [hJoyPressed]
    bit 0, a
    jr z, .loop
    ld a, [wMenuSel]
    ld e, a
    ld d, 0
    ld hl, wMenuList
    add hl, de
    ld b, [hl]
    call CursorPtr
    hop 4
    ld a, [hl]
    cp b
    jr z, .same
    ld [hl], b
    hop 4
    ld [hl], 0
    hop 4
    ld [hl], 0
    hop 4
    ld a, [hl]
    and $80
    ld [hl], a
.same
    call SfxPlace
.close
    jp CloseWin
.ing                        ; DE -> (item, qty); prints icon + digit
    ld a, [de]
    inc de
    or a
    jr z, .i0
    push de
    add T_ICON - 1
    call PutIcon
    pop de
    ld a, [de]
    inc de
    add GLY_0
    jp PutChar
.i0 inc de
    inc hl
    inc hl
    ret

; ---------------------------------------------------------------- goal screen
PrintTime:                  ; HL = dest
    ld de, Str_PlayTime
    call PrintStr
    inc hl
    ld a, [wPlayHour]
    ld e, a
    ld d, 0
    ld b, 2
    call PrintNum
    ld a, GLY_COLON
    call PutChar
    ld a, [wPlayMin]
    call PrintDec2Z
    ld a, GLY_COLON
    call PutChar
    ld a, [wPlaySec]
    jp PrintDec2Z

GoalScreen:
.redraw
    call WinOffClear
    ld a, [wGoal]
    cp NUM_GOALS
    jr c, .active
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld hl, WIN + 3 * 32 + 1
    ld de, Str_AllDone
    call PrintStr
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ld hl, WIN + 8 * 32 + 1
    call PrintTime
    ld de, Str_HintBack
    call PrintHint
    call ShowWin
.dl call NextFrame
    ldh a, [hFrame]
    and 63
    jr nz, .dn
    ld hl, WIN + 8 * 32 + 1
    call PrintTime
.dn ldh a, [hJoyPressed]
    and PAD_A | PAD_B
    jr z, .dl
    ret
.active
    call GoalDrawStatic
    call GoalDrawDyn
    ld de, Str_HintBack
    call PrintHint
    call ShowWin
.loop
    call NextFrame
    ldh a, [hFrame]
    and 31
    call z, GoalDrawDyn
    ldh a, [hJoyPressed]
    bit 1, a
    ret nz
    bit 0, a
    jr z, .loop
    call GoalCheck
    jr c, .cant
    call GoalConsume
    call SfxJingle
    call WinOffClear
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld hl, WIN + 2 * 32 + 3
    ld de, Str_Cleared
    call PrintStr
    ld hl, WIN + 5 * 32 + 1
    ld de, Str_Reward
    call PrintStr
    ld a, TA_WHITE
    ldh [hTextAttr], a
    call GoalPtr
    ld de, 11
    add hl, de
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ld hl, WIN + 7 * 32 + 2
    call PrintStr
    ld de, Str_Next
    call PrintHint
    call ShowWin
    ld hl, wGoal
    inc [hl]
    xor a
    ld [wGoalNote], a
    call SaveGame
.w  call NextFrame
    ldh a, [hJoyPressed]
    bit 0, a
    jr z, .w
    ld a, [wGoal]
    cp NUM_GOALS
    jp nz, .redraw
    call EndingScreen
    jp .redraw
.cant
    call SfxError
    jr .loop

GoalReq:                    ; loads requirement wTmpK -> wTmpItem / wTmpQty. Z if empty
    call GoalPtr
    ld a, [wTmpK]
    ld e, a
    add a
    add e
    ld e, a
    ld d, 0
    add hl, de
    ld a, [hli]
    ld [wTmpItem], a
    ld a, [hli]
    ld [wTmpQty], a
    ld a, [hl]
    ld [wTmpQty + 1], a
    ld a, [wTmpItem]
    or a
    ret

GoalDrawStatic:
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld hl, WIN + 1
    ld de, Str_GoalHead
    call PrintStr
    inc hl
    ld a, [wGoal]
    inc a
    ld e, a
    ld d, 0
    ld b, 2
    call PrintNum
    ld de, Str_GoalOf
    call PrintStr
    ld hl, WIN + 9 * 32 + 1
    ld de, Str_Reward
    call PrintStr
    ld a, TA_WHITE
    ldh [hTextAttr], a
    call GoalPtr
    ld de, 9
    add hl, de
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld d, a
    push hl
    ld hl, WIN + 2 * 32 + 1
    call PrintStr
    pop hl
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ld hl, WIN + 10 * 32 + 2
    call PrintStr
    xor a
    ld [wTmpK], a
.l  call GoalReq
    jr z, .next
    ld a, [wTmpK]
    add 4
    call WinRow
    inc hl
    ld a, [wTmpItem]
    add T_ICON - 1
    call PutIcon
    inc hl
    ld a, [wTmpItem]
    call ItemNamePtr
    call PrintStr
    ld a, [wTmpK]
    add 4
    call WinRow
    ld de, 14
    add hl, de
    ld a, GLY_SLASH
    call PutChar
    ld a, [wTmpQty]
    ld e, a
    ld a, [wTmpQty + 1]
    ld d, a
    ld b, 3
    call PrintNum
.next
    ld hl, wTmpK
    inc [hl]
    ld a, [hl]
    cp 3
    jr nz, .l
    ret

GoalDrawDyn:
    ld a, TA_WHITE
    ldh [hTextAttr], a
    xor a
    ld [wTmpK], a
.l  call GoalReq
    jr z, .next
    ld a, [wTmpK]
    add 4
    call WinRow
    ld de, 10
    add hl, de
    push hl
    ld a, [wTmpItem]
    call StockPtr
    ld a, [hli]
    ld d, [hl]
    ld e, a
    pop hl
    push de
    ld b, 4
    call PrintNum
    pop de
    ; mark
    ld a, [wTmpQty]
    ld c, a
    ld a, [wTmpQty + 1]
    ld b, a
    ld a, e
    sub c
    ld a, d
    sbc b
    ld a, GLY_MARU
    jr nc, .m
    ld a, GLY_BATSU
.m  push af
    ld a, [wTmpK]
    add 4
    call WinRow
    ld de, 19
    add hl, de
    pop af
    call PutChar
.next
    ld hl, wTmpK
    inc [hl]
    ld a, [hl]
    cp 3
    jr nz, .l
    call GoalCheck
    jr c, .wait
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld de, Str_GoalDeliver
    jr .act
.wait
    ld de, Str_GoalWait
.act
    ld hl, WIN + 15 * 32 + 1
    call PrintStr
    ld a, 20
    call PadTo
    ld a, TA_WHITE
    ldh [hTextAttr], a
    ret

EndingScreen:
    ; ---- launch animation over the map
    ldh a, [rLCDC]
    res 5, a
    ldh [rLCDC], a
    call HideSprites
    ld a, 16
    ld [wCurX], a
    ld [wCurY], a
    ld b, 50
.settle
    push bc
    call NextFrame
    call UpdateCamera
    pop bc
    dec b
    jr nz, .settle
    ; rocket position (OAM coords) from the hub position
    ld a, [wCamY]
    ld b, a
    ld a, 15 * 8 + 16
    sub b
    ldh [hBY], a
    xor a
    ldh [hBX], a            ; y fraction
    ldh [hCX0], a           ; velocity lo
    ldh [hCY0], a           ; velocity hi
    ld a, 70
    ld [wTmpK], a           ; countdown frames
    call SfxRumble
.fly
    call NextFrame
    call UpdateCamera
    ld a, [wTmpK]
    or a
    jr z, .ascend
    dec a
    ld [wTmpK], a
    call z, SfxRumble
    ; shake
    ldh a, [hFrame]
    rra
    and 1
    ld b, a
    ldh a, [hSCX]
    add b
    ldh [hSCX], a
    jr .draw
.ascend
    ldh a, [hCX0]
    add 5
    ldh [hCX0], a
    ld c, a
    ldh a, [hCY0]
    adc 0
    ldh [hCY0], a
    ld b, a                 ; BC = velocity
    ldh a, [hBX]
    sub c
    ldh [hBX], a
    ldh a, [hBY]
    sbc b
    ldh [hBY], a
    jr c, .gone
    cp 2
    jr c, .gone
.draw
    ld a, [wCamX]
    ld b, a
    ld a, 15 * 8 + 8
    sub b
    ld d, a                 ; D = X
    ldh a, [hBY]
    ld e, a                 ; E = Y
    ld hl, wOAM
    ld c, T_ROCKET
    call .spr
    ld a, d
    add 8
    ld d, a
    call .spr
    ld a, d
    sub 8
    ld d, a
    ld a, e
    add 8
    ld e, a
    call .spr
    ld a, d
    add 8
    ld d, a
    call .spr
    ; flame
    ld a, e
    add 8
    ld [hli], a
    ld a, d
    sub 4
    ld [hli], a
    ldh a, [hFrame]
    rra
    rra
    and 1
    add T_FLAME
    ld [hli], a
    ld a, 3
    ld [hli], a
    jr .fly
.spr
    ld a, e
    ld [hli], a
    ld a, d
    ld [hli], a
    ld a, c
    ld [hli], a
    inc c
    ld a, 2
    ld [hli], a
    ret
.gone
    call HideSprites
    ld b, 40
.after
    push bc
    call NextFrame
    pop bc
    dec b
    jr nz, .after
    ; ---- message
    call WinOffClear
    ld a, TA_YELLOW
    ldh [hTextAttr], a
    ld hl, WIN + 32 + 2
    ld de, Str_End
    call PrintStr
    ld a, TA_CYAN
    ldh [hTextAttr], a
    ld hl, WIN + 11 * 32 + 2
    call PrintTime
    ld de, Str_Next
    call PrintHint
    call ShowWin
    call SfxJingle
    ld b, 60
.d  push bc
    call NextFrame
    pop bc
    dec b
    jr nz, .d
.w  call NextFrame
    ldh a, [hJoyPressed]
    bit 0, a
    jr z, .w
    ret

; ---------------------------------------------------------------- stock screen
StockScreen:
    call WinOffClear
    ld de, Str_StockTitle
    call PrintTitle
    ld a, 1
    ld [wTmpK], a
.l  ld a, [wTmpK]
    inc a
    call WinRow
    inc hl
    ld a, [wTmpK]
    add T_ICON - 1
    call PutIcon
    inc hl
    ld a, [wTmpK]
    call ItemNamePtr
    call PrintStr
    ld hl, wTmpK
    inc [hl]
    ld a, [hl]
    cp NUM_ITEMS + 1
    jr nz, .l
    call .nums
    ld de, Str_HintBack
    call PrintHint
    call ShowWin
.loop
    call NextFrame
    ldh a, [hFrame]
    and 31
    call z, .nums
    ldh a, [hJoyPressed]
    and PAD_A | PAD_B
    jr z, .loop
    ret
.nums
    ld a, 1
    ld [wTmpK], a
.n  ld a, [wTmpK]
    inc a
    call WinRow
    ld de, 14
    add hl, de
    push hl
    ld a, [wTmpK]
    call StockPtr
    ld a, [hli]
    ld d, [hl]
    ld e, a
    pop hl
    ld b, 4
    call PrintNum
    ld hl, wTmpK
    inc [hl]
    ld a, [hl]
    cp NUM_ITEMS + 1
    jr nz, .n
    ret

; ---------------------------------------------------------------- help
HelpPages:
    dw Str_Help1, Str_Help2, Str_Help3, Str_Help4

HelpScreen:
    xor a
    ld [wTmpK], a
.page
    call WinOffClear
    ld a, [wTmpK]
    add a
    add LOW(HelpPages)
    ld l, a
    ld a, HIGH(HelpPages)
    adc 0
    ld h, a
    ld a, [hli]
    ld d, [hl]
    ld e, a
    ld hl, WIN + 1
    call PrintStr
    ld de, Str_HintHelp
    call PrintHint
    call ShowWin
.loop
    call NextFrame
    ldh a, [hJoyPressed]
    bit 1, a
    ret nz
    bit 0, a
    jr z, .loop
    call SfxTick
    ld hl, wTmpK
    inc [hl]
    ld a, [hl]
    cp 4
    jr nz, .page
    ret

; =====================================================================
SECTION "TileAttr", ROM0, ALIGN[8]
TileAttr:
    INCBIN "build/tileattr.bin"

SECTION "Data", ROMX, BANK[1]
INCLUDE "build/strings.inc"
INCLUDE "build/pal.inc"
INCLUDE "build/music.inc"
BeltAnim:
    INCBIN "build/beltanim.bin"
TilesData:
    INCBIN "build/tiles.bin"
TilesDataEnd:
FontData:
    INCBIN "build/font.bin"
FontDataEnd:
