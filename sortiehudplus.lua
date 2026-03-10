-- SortieHUDPlus v22
-- Clean grid HUD with gold objective completion and green sector completion

_addon.name = 'SortieHUDPlus'
_addon.author = 'Madroxx'
_addon.version = '22.0'
_addon.commands = {'sh','shud'}

texts = require('texts')
config = require('config')

defaults = {pos={x=150,y=350},font='Consolas',size=11}
settings = config.load(defaults)

display = texts.new({
 pos=settings.pos,
 text={font=settings.font,size=settings.size},
 bg={visible=true,alpha=190,red=28,green=22,blue=58},
 stroke={width=2}
})
display:show()

hud_mode="ground"
detail_sector="A"

completed={}
grid={}

sectors={'A','B','C','D','E','F','G','H'}

for _,s in ipairs(sectors) do
 grid[s]={
  chest={false,false,false,false,false},
  casket={false,false},
  coffer=false
 }
end

fragments={E=false,F=false,G=false,H=false}

gallimaufry_current=0
gallimaufry_earned=0

item_types={'Metal','Plate','Shard','Key'}
temp_items={}

for _,t in ipairs(item_types) do
 temp_items[t]={}
 for _,s in ipairs(sectors) do
  temp_items[t][s]=false
 end
end

objectives = {

A = {
"Chest #A1: Open any unlocked Gate #A.",
"Chest #A2: Cast magic next to Device #A.",
"Chest #A3: Vanquish 3 Abject foes with magic.",
"Chest #A4: Vanquish 3 more Abject foes with magic.",
"Chest #A5: Interact with Bitzer #A while naked.",
"Casket #A1: Vanquish 5 Abject foes.",
"Casket #A2: /heal between gate and leeches.",
"Coffer #A: Vanquish Abject Obdella."
},

B = {
"Chest #B1: Open any unlocked Gate #B.",
"Chest #B2: Cast magic next to Device #B.",
"Chest #B3: Vanquish 3 Abject foes with magic.",
"Chest #B4: Vanquish 3 more Abject foes with magic.",
"Chest #B5: Interact with Bitzer #B while naked.",
"Casket #B1: Vanquish 5 Abject foes.",
"Casket #B2: /heal near the Device.",
"Coffer #B: Vanquish Abject Twitherym."
},

C = {
"Chest #C1: Open any unlocked Gate #C.",
"Chest #C2: Cast magic next to Device #C.",
"Chest #C3: Vanquish 3 Abject foes with magic.",
"Chest #C4: Vanquish 3 more Abject foes with magic.",
"Chest #C5: Interact with Bitzer #C while naked.",
"Casket #C1: Vanquish 5 Abject foes.",
"Casket #C2: /heal near the Device.",
"Coffer #C: Vanquish Abject Dhalmel."
},

D = {
"Chest #D1: Open any unlocked Gate #D.",
"Chest #D2: Cast magic next to Device #D.",
"Chest #D3: Vanquish 3 Abject foes with magic.",
"Chest #D4: Vanquish 3 more Abject foes with magic.",
"Chest #D5: Interact with Bitzer #D while naked.",
"Casket #D1: Vanquish 5 Abject foes.",
"Casket #D2: /heal near the Device.",
"Coffer #D: Vanquish Abject Bhuta."
},

E = {
"Chest #E1: Open any unlocked Gate #E.",
"Chest #E2: Cast magic next to Device #E.",
"Chest #E3: Vanquish 3 Abject foes with magic.",
"Chest #E4: Vanquish 3 more Abject foes with magic."
},

F = {
"Chest #F1: Open any unlocked Gate #F.",
"Chest #F2: Cast magic next to Device #F.",
"Chest #F3: Vanquish 3 Abject foes with magic.",
"Chest #F4: Vanquish 3 more Abject foes with magic."
},

G = {
"Chest #G1: Open any unlocked Gate #G.",
"Chest #G2: Cast magic next to Device #G.",
"Chest #G3: Vanquish 3 Abject foes with magic.",
"Chest #G4: Vanquish 3 more Abject foes with magic."
},

H = {
"Chest #H1: Open any unlocked Gate #H.",
"Chest #H2: Cast magic next to Device #H.",
"Chest #H3: Vanquish 3 Abject foes with magic.",
"Chest #H4: Vanquish 3 more Abject foes with magic."
}

}

function box(val)
 if val then
  return "\\cs(255,215,0)[X]\\cr"
 else
  return "[ ]"
 end
end

function aminon_status()
 for _,f in pairs(fragments) do
  if not f then return "Aminon: LOCKED" end
 end
 return "Aminon: OPEN"
end

function render_fragments()
 local t="Fragments: "
 for _,f in ipairs({'E','F','G','H'}) do
  if fragments[f] then
   t=t.."["..f.."]"
  else
   t=t.." "..f.." "
  end
 end
 return t
end

function mark_objective(key)

 completed[key]=true

 local s=key:sub(1,1)
 local num=tonumber(key:sub(2))

 if num<=5 then
  grid[s].chest[num]=true
 elseif num<=7 then
  grid[s].casket[num-5]=true
 else
  grid[s].coffer=true
 end
end

function undo_objective(key)

 completed[key]=nil

 local s=key:sub(1,1)
 local num=tonumber(key:sub(2))

 if num<=5 then
  grid[s].chest[num]=false
 elseif num<=7 then
  grid[s].casket[num-5]=false
 else
  grid[s].coffer=false
 end
end

function render_row_ground(sec)

 local g=grid[sec]

 local completed=true

 for i=1,5 do
  if not g.chest[i] then completed=false end
 end

 for i=1,2 do
  if not g.casket[i] then completed=false end
 end

 if not g.coffer then completed=false end

 local color=""
 local reset=""

 if completed then
  color="\\cs(120,255,120)"
  reset="\\cr"
 end

 local t=color..sec.."  "

 for i=1,5 do
  t=t..box(g.chest[i])
 end

 t=t.." "

 for i=1,2 do
  t=t..box(g.casket[i])
 end

 t=t.." "..box(g.coffer)..reset

 return t
end

function render_row_basement(sec)

 local g=grid[sec]

 local completed=true

 for i=1,4 do
  if not g.chest[i] then completed=false end
 end

 local color=""
 local reset=""

 if completed then
  color="\\cs(120,255,120)"
  reset="\\cr"
 end

 local t=color..sec.."  "

 for i=1,4 do
  t=t..box(g.chest[i])
 end

 t=t..reset

 return t
end

function render_ground()

 local t="Sortie HUD (Ground)\n"
 t=t.."────────────\n\n"

 t=t.."     1  2  3  4  5  6  7  8\n"

 t=t..render_row_ground("A").."\n"
 t=t..render_row_ground("B").."\n"
 t=t..render_row_ground("C").."\n"
 t=t..render_row_ground("D").."\n"

 t=t.."\n────────────\n"
 t=t..render_fragments().."\n"
 t=t..aminon_status().."\n"
 t=t.."Gallimaufry: "..gallimaufry_current.." (+"..gallimaufry_earned..")\n"

 return t
end

function render_basement()

 local t="Sortie HUD (Basement)\n"
 t=t.."────────────\n\n"

 t=t.."     1  2  3  4\n"

 t=t..render_row_basement("E").."\n"
 t=t..render_row_basement("F").."\n"
 t=t..render_row_basement("G").."\n"
 t=t..render_row_basement("H").."\n"

 t=t.."\n────────────\n"
 t=t..render_fragments().."\n"
 t=t..aminon_status().."\n"
 t=t.."Gallimaufry: "..gallimaufry_current.." (+"..gallimaufry_earned..")\n"

 return t
end

function render_temp()

 local t="Temporary Items\n"
 t=t.."────────────\n\n"

 t=t.."     "
 for _,s in ipairs(sectors) do
  t=t..s.." "
 end
 t=t.."\n"

 for _,row in ipairs(item_types) do
  if row=="Key" then
   t=t.."Key  "
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

function objective_progress(sec)

 local done=0
 local total=#objectives[sec]

 for i=1,total do
  if completed[sec..i] then
   done=done+1
  end
 end

 return done,total
end

function render_detail(sec)

 local done,total=objective_progress(sec)

 local t=sec.." Objectives ("..done.." / "..total.." Complete)\n"
 t=t.."────────────\n\n"

 for i,obj in ipairs(objectives[sec]) do

  local key=sec..i

  if not completed[key] then
   t=t..sec..i..": "..obj.."\n\n"
  end

 end

 if done==total then
  t=t.."All objectives complete.\n"
 end

 return t
end

function update()

 if hud_mode=="ground" then
  display:text(render_ground())

 elseif hud_mode=="basement" then
  display:text(render_basement())

 elseif hud_mode=="temp" then
  display:text(render_temp())

 elseif hud_mode=="detail" then
  display:text(render_detail(detail_sector))
 end

end

windower.register_event('incoming text',function(text)

 if not text then return end

 local gain=text:match("received (%d+) gallimaufry")

 if gain then
  gain=tonumber(gain)
  gallimaufry_current=gallimaufry_current+gain
  gallimaufry_earned=gallimaufry_earned+gain
 end

 if text:find("A chest appears") then
  mark_objective("A1")
 end

 if text:find("A casket appears") then
  mark_objective("A6")
 end

 if text:find("A coffer appears") then
  mark_objective("A8")
 end

end)

windower.register_event("addon command",function(cmd,arg)

 if not cmd then return end

 cmd=cmd:lower()

 if cmd=="ground" then
  hud_mode="ground"

 elseif cmd=="basement" then
  hud_mode="basement"

 elseif cmd=="temp" then
  hud_mode="temp"

 elseif cmd=="obj" and arg then
  detail_sector=arg:upper()
  hud_mode="detail"

 elseif cmd=="done" and arg then
  mark_objective(arg:upper())

 elseif cmd=="undo" and arg then
  undo_objective(arg:upper())

 end

end)

windower.register_event("prerender",update)