_addon.name = 'SortieHUDPlus'
_addon.author = 'Madroxx'
_addon.version = '1.0.0'
_addon.commands = {'sh','shud'}

texts = require('texts')
config = require('config')
res = require('resources')
packets = require('packets')

defaults = {pos={x=150,y=350},font='Consolas',size=11}
settings = config.load(defaults)

display = texts.new({
    pos=settings.pos,
    text={font=settings.font,size=settings.size},
    bg={visible=true,alpha=190,red=28,green=22,blue=58},
    stroke={width=2}
})

display:show()

hud_mode = "ground"
detail_sector = "A"

completed = {}
seen_chests = {}

sectors = {'A','B','C','D','E','F','G','H'}

fragments = {E=false,F=false,G=false,H=false}

gallimaufry_current = 0
gallimaufry_earned = 0
gallimaufry_baseline = nil

item_types = {'Metal','Plate','Sheet','Key'}
temp_items = {}

for _,t in ipairs(item_types) do
    temp_items[t] = {}
    for _,s in ipairs(sectors) do
        temp_items[t][s] = false
    end
end

scan_interval = 2
last_scan = 0

-- ===============================
-- OBJECTIVE TABLE (unchanged)
-- ===============================

objectives = {

A = {
"Open any unlocked Gate #A. Ground Floor: (D-4), (F-2), (H-2)",
"Cast magic next to Diaphanous Device #A. Any magic works, including summoning a trust.",
"Vanquish 3 Abject foes using single-target magic for the killing blow.",
"Vanquish 3 more Abject foes using single-target magic for the killing blow.",
"Interact with Diaphanous Bitzer #A while naked.",
"Vanquish 5 Abject foes (excluding Abject Obdella).",
"/heal between Gate #A1 and the Abject Leeches.",
"Vanquish Abject Obdella."
},

B = {
"Open Gates #B1 through #B6 in order.",
"/hurray with Diaphanous Device #B.",
"Perform a Weapon Skill on 5 Biune foes before defeating them.",
"Perform a Weapon Skill on 5 more Biune foes before defeating them.",
"Interact with Diaphanous Bitzer #B after traveling from the entrance on foot.",
"Vanquish 3 Biune foes within 30 seconds of gaining enmity.",
"Open any Locked Gate #B. Ground Floor: (J-8), (K-8), (M-8)",
"Vanquish Biune Porxie after meeting the objective for B6."
},

C = {
"Open Gate #C1 or #C2 before defeating any enemies in Sector C.",
"Pull a Cachaemic foe to Diaphanous Device #C and defeat it there.",
"Perform a Magic Burst on 3 Cachaemic foes before defeating them.",
"Perform a Magic Burst on 3 more Cachaemic foes before defeating them.",
"Vanquish at least one Cachaemic foe, materialize them at Device #C, then interact with Bitzer #C.",
"Vanquish 3 Cachaemic foes within 15 seconds of gaining enmity.",
"Vanquish all Cachaemic foes.",
"Vanquish Cachaemic Bhoot within 5 minutes of spawn."
},

D = {
"Open Gates #D1 and #D2 within two minutes of each other.",
"Drop your Obsidian Wing at Diaphanous Device #D.",
"Perform a 4-step Skillchain on 3 Demisang foes before defeating them.",
"Perform a 4-step Skillchain on 3 more Demisang foes before defeating them.",
"Vanquish all Demisang foes, then interact with Bitzer #D.",
"Vanquish 6 Demisang foes of different jobs.",
"Defeat Demisang foes in job order: WAR MNK WHM BLM RDM THF.",
"Vanquish Demisang Deleterious then any 3 Demisang foes."
},

E = {
"Vanquish Esurient Botulus with majority damage from Weapon Skills performed from behind.",
"Vanquish 12 Esurient foes in the Bitzer room.",
"Vanquish 15 Esurient Flan.",
"Vanquish the 6 mini-Naakuals that spawn 5 minutes after entering Sector E."
},

F = {
"Vanquish Fetid Ixion while its horn is broken.",
"Interact with the Bitzer wearing or lockstyling 5/5 Empyrean armor pieces.",
"Vanquish all Fetid Veela.",
"Vanquish the 6 mini-Naakuals triggered by re-entering Sector F."
},

G = {
"Vanquish Gyvewrapped Naraka.",
"Stand still targeting the Bitzer within 6 yalms for 30 seconds.",
"Vanquish 19 Gyvewrapped Dullahan.",
"Vanquish the 6 mini-Naakuals after clearing the split room in order."
},

H = {
"Vanquish Haughty Tulittia after dealing indirect AoE damage (~50%).",
"Leave and re-enter Sector H.",
"Defeat all Haughty Paladin enemies.",
"Vanquish the 6 mini-Naakuals after defeating 8 Haughty enemies of different jobs."
}

}

-- ===============================
-- UTILITY
-- ===============================

function box(v)
    if v then
        return "\\cs(255,215,0)[X]\\cr"
    else
        return "[ ]"
    end
end

function row_complete(sec)
    local total = #objectives[sec]
    for i=1,total do
        if not completed[sec..i] then
            return false
        end
    end
    return true
end

-- ===============================
-- CHEST DETECTION (PACKET)
-- ===============================
function render_fragments()
    local t = "Fragments: "
    for _,f in ipairs({'E','F','G','H'}) do
        if fragments[f] then
            t = t.."["..f.."]"
        else
            t = t.." "..f.." "
        end
    end
    return t
end

function aminon_status()
    for _,f in pairs(fragments) do
        if not f then
            return "Aminon: LOCKED"
        end
    end
    return "Aminon: OPEN"
end

function render_ground()

    local t = "Sortie HUD (Ground)\n"
    t = t.."────────────\n\n"
    t = t.."    1  2  3  4  5  6  7  8\n"

    for _,s in ipairs({'A','B','C','D'}) do

        local color=""
        local reset=""

        if row_complete(s) then
            color="\\cs(120,255,120)"
            reset="\\cr"
        end

        t=t..color..s.."  "

        for i=1,8 do
            t=t..box(completed[s..i])
        end

        t=t..reset.."\n"
    end

    t=t.."\n────────────\n"
    t=t..render_fragments().."\n"
    t=t..aminon_status().."\n"
    t=t.."Gallimaufry: "..gallimaufry_current.." (+"..gallimaufry_earned..")\n"

    return t
end

function render_basement()

    local t="Sortie HUD (Basement)\n"
    t=t.."────────────\n\n"
    t=t.."    1  2  3  4\n"

    for _,s in ipairs({'E','F','G','H'}) do

        local color=""
        local reset=""

        if row_complete(s) then
            color="\\cs(120,255,120)"
            reset="\\cr"
        end

        t=t..color..s.."  "

        for i=1,4 do
            t=t..box(completed[s..i])
        end

        t=t..reset.."\n"
    end

    t=t.."\n────────────\n"
    t=t..render_fragments().."\n"
    t=t..aminon_status().."\n"
    t=t.."Gallimaufry: "..gallimaufry_current.." (+"..gallimaufry_earned..")\n"

    return t
end

function render_temp()

    local t="Temporary Items\n"
    t=t.."────────────\n\n"

    t=t.."      "
    for _,s in ipairs(sectors) do
        t=t..s.." "
    end
    t=t.."\n"

    for _,row in ipairs(item_types) do

        if row=="Key" then
            t=t.."Key   "
        elseif row=="Sheet" then
            t=t.."Sheet "
        else
            t=t..row.." "
        end

        for _,s in ipairs(sectors) do
            if temp_items[row][s] then
                t=t.."X "
            else
                t=t..". "
            end
        end

        t=t.."\n"
    end

    return t
end

function render_detail(sec)

    local total=#objectives[sec]
    local done=0

    for i=1,total do
        if completed[sec..i] then
            done=done+1
        end
    end

    local t=sec.." Objectives ("..done.." / "..total.." Complete)\n"
    t=t.."────────────\n\n"

    local shown=0

    for i,obj in ipairs(objectives[sec]) do
        if not completed[sec..i] then
            t=t..sec..i..": "..obj.."\n\n"
            shown=shown+1
        end
    end

    if shown==0 then
        t=t.."All objectives complete.\n"
    end

    return t
end
windower.register_event('incoming chunk', function(id,data)

    if id ~= 0x0E then return end

    local p = packets.parse('incoming', data)
    if not p or not p.Name then return end

    local sector, num = p.Name:match("#([A-H])(%d)")

    if sector and num then

        local key = sector..num

        if not seen_chests[key] then
            seen_chests[key] = true
            completed[key] = true
        end

    end

end)

-- ===============================
-- FALLBACK MOB SCAN
-- ===============================

function scan_objective_chests()

    local mobs = windower.ffxi.get_mob_array()
    if not mobs then return end

    for _,mob in pairs(mobs) do

        if mob and mob.name then

            local name = mob.name

            local sec,num = name:match("Chest #([A-H])(%d)")
            if sec and num then
                local key = sec..num
                if not seen_chests[key] then
                    seen_chests[key] = true
                    completed[key] = true
                end
            end

            local sec,num = name:match("Casket #([A-H])(%d)")
            if sec and num then
                local offset = tonumber(num) + 5
                local key = sec..offset
                if not seen_chests[key] then
                    seen_chests[key] = true
                    completed[key] = true
                end
            end

            local sec = name:match("Coffer #([A-H])")
            if sec then
                local key = sec.."8"
                if not seen_chests[key] then
                    seen_chests[key] = true
                    completed[key] = true
                end
            end

        end
    end
end

-- ===============================
-- TEMP ITEM SCAN (unchanged)
-- ===============================

function scan_temp_items()

    local items = windower.ffxi.get_items()
    if not items or not items.temporary then return end

    for _,t in ipairs(item_types) do
        for _,s in ipairs(sectors) do
            temp_items[t][s] = false
        end
    end

    local temp = items.temporary

    for i=1,(temp.max or 0) do

        local entry = temp[i]

        if entry and entry.id ~= 0 then

            local item = res.items[entry.id]
            local name = item and item.en

            if name then
                local kind, sector = name:match("Ra'Kaznar%s+(%a+)%s+#([A-H])")

                if kind and sector and temp_items[kind] then
                    temp_items[kind][sector] = true
                end
            end
        end
    end
end

function scan_fragments()

    local items = windower.ffxi.get_items()
    if not items then return end

    local bags = {
        items.inventory,
        items.wardrobe,
        items.wardrobe2,
        items.wardrobe3,
        items.wardrobe4
    }

    for _,bag in ipairs(bags) do

        if bag then

            for i=1,(bag.max or 0) do

                local entry = bag[i]

                if entry and entry.id and entry.id ~= 0 then

                    local item = res.items[entry.id]
                    local name = item and item.en

                    if name then

                        local frag = name:match("Ra'Kaznar Fragment ([EFGH])")

                        if frag then
                            fragments[frag] = true
                        end

                    end

                end
            end

        end

    end

end
-- ===============================
-- PERIODIC SCAN
-- ===============================

function periodic_scan()

    local now = os.clock()

    if now - last_scan < scan_interval then return end
    last_scan = now

    scan_temp_items()
    scan_objective_chests()
    scan_fragments()

end

-- ===============================
-- CHAT DETECTION (UNCHANGED)
-- ===============================

windower.register_event('incoming text', function(text)

    if not text then return end

    local gain,total = text:match("received%s+(%d+)%s+gallimaufry%s+for%s+a%s+total%s+of%s+(%d+)")

    if gain and total then
        gain = tonumber(gain)
        total = tonumber(total)

        gallimaufry_current = total

        if not gallimaufry_baseline then
            gallimaufry_baseline = total - gain
        end

        gallimaufry_earned = gallimaufry_current - gallimaufry_baseline
        return
    end

    local gain_only = text:match("received%s+(%d+)%s+gallimaufry")

    if gain_only then
        gain_only = tonumber(gain_only)

        gallimaufry_current = gallimaufry_current + gain_only

        if not gallimaufry_baseline then
            gallimaufry_baseline = gallimaufry_current - gain_only
        end

        gallimaufry_earned = gallimaufry_current - gallimaufry_baseline
        return
    end

    local sec,done = text:match("^([A-H]) treasure coffer status report:%s*(%d+)%/(%d+)")

    if sec and done then
        sync_sector_progress(sec, tonumber(done))
        return
    end

end)

-- ===============================
-- COMMANDS
-- ===============================

windower.register_event("addon command", function(cmd,arg)

    if not cmd then return end
    cmd = cmd:lower()

    if cmd == "ground" then
        hud_mode = "ground"

    elseif cmd == "basement" then
        hud_mode = "basement"

    elseif cmd == "temp" then
        hud_mode = "temp"

    elseif cmd == "obj" and arg then
        local sec = arg:upper()
        if objectives[sec] then
            detail_sector = sec
            hud_mode = "detail"
        end

    elseif cmd == "done" and arg then
        completed[arg:upper()] = true

    elseif cmd == "undo" and arg then
        completed[arg:upper()] = nil
    end

end)

-- ===============================
-- RENDER LOOP
-- ===============================

windower.register_event("prerender", function()

    periodic_scan()

    if hud_mode == "ground" then
        display:text(render_ground())
    elseif hud_mode == "basement" then
        display:text(render_basement())
    elseif hud_mode == "temp" then
        display:text(render_temp())
    elseif hud_mode == "detail" then
        display:text(render_detail(detail_sector))
    end

end)
