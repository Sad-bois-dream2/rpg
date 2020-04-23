function IsUniversalTalent(id)
	if(id >= 25 and id <= 33) then
		return true
	end
	if(id >= 1 and id <= 18) then
		return true
	end
	return false
end

local latestTalendtId = 51
local latestBranchId = 6
talenttree_system = {}
talenttree_system.supported_heroes = { 
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_axe",
    "npc_dota_hero_crystal_maiden",
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_enchantress",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_mars",
    "npc_dota_hero_venomancer",
    "npc_dota_hero_silencer",
    "npc_dota_hero_invoker",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_abyssal_underlord"
}
print("\t\t<Panel style=\"visibility: collapse;\">")
for i = 1, #talenttree_system.supported_heroes do
  for j=1, latestTalendtId do
    if(IsUniversalTalent(j)) then
      print("\t\t\t<Image src=\"file://{images}/custom_game/hud/talenttree/talent_"..j..".png\" />")
    else
      print("\t\t\t<Image src=\"file://{images}/custom_game/hud/talenttree/"..talenttree_system.supported_heroes[i].."/talent_"..j..".png\" />")
    end
  end
  for j=1, latestBranchId do
    print("\t\t\t<Image src=\"file://{images}/custom_game/hud/talenttree/"..talenttree_system.supported_heroes[i].."/talentbranch_"..j..".png\" />")
  end
end
print("\t\t</Panel>")