local prefix = "talents/"
for id = 1, TalentTree:GetLatestTalentID() do
    require(prefix .. "talent_" .. id)
end
require(prefix .. "talents_phantom_ranger")