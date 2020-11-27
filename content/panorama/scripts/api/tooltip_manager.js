"use strict";

var TooltipManager = {};

TooltipManager.GetItemStatIcon = function(stat) {
    switch (stat) {
        case "HEALTH":
            return "file://{images}/custom_game/hud/stats/health.png";
        case "HEALTH_PERCENT":
            return "file://{images}/custom_game/hud/stats/health.png";
        case "HEALING_RECEIVED":
            return "file://{images}/custom_game/hud/stats/healing_received.png";
        case "COOLDOWN_REDUCTION":
            return "file://{images}/custom_game/hud/stats/mana.png";
        case "STATUS_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/status_resistance.png";
        case "CAST_SPEED":
            return "file://{images}/custom_game/hud/stats/cast_speed.png";
        case "CAST_SPEED_PERCENT":
            return "file://{images}/custom_game/hud/stats/cast_speed.png";
        case "THREAT":
            return "file://{images}/custom_game/hud/stats/threat.png";
        case "MANA":
            return "file://{images}/custom_game/hud/stats/mana.png";
        case "MANA_PERCENT":
            return "file://{images}/custom_game/hud/stats/mana.png";
        case "DAMAGE_REDUCTION":
            return "file://{images}/custom_game/hud/stats/damage_reduction.png";
        case "ATTACK_RANGE":
            return "file://{images}/custom_game/hud/stats/attack_range.png";
        case "ATTACK_RANGE_PERCENT":
            return "file://{images}/custom_game/hud/stats/attack_range.png";
        case "SPELL_DAMAGE":
            return "file://{images}/custom_game/hud/stats/spell_damage.png";
        case "HEALING_CAUSED":
            return "file://{images}/custom_game/hud/stats/healing_caused.png";
        case "ARMOR":
            return "file://{images}/custom_game/hud/stats/armor.png";
        case "ARMOR_PERCENT":
            return "file://{images}/custom_game/hud/stats/armor.png";
        case "HEALTH_REGENERATION":
            return "file://{images}/custom_game/hud/stats/health_regeneration.png";
        case "HEALTH_REGENERATION_PERCENT":
            return "file://{images}/custom_game/hud/stats/health_regeneration.png";
        case "BASE_ATTACK_TIME":
            return "file://{images}/custom_game/hud/stats/bat.png";
        case "BASE_ATTACK_TIME_PERCENT":
            return "file://{images}/custom_game/hud/stats/bat.png";
        case "BASE_ATTACK_TIME_VALUE":
            return "file://{images}/custom_game/hud/stats/bat.png";
        case "CRITICAL_STRIKE_DAMAGE":
            return "file://{images}/custom_game/hud/stats/critical_damage.png";
        case "EXPERIENCE":
            return "file://{images}/custom_game/hud/stats/exp.png";
        case "CRITICAL_STRIKE_CHANCE":
            return "file://{images}/custom_game/hud/stats/critical_chance.png";
        case "STATUS_AMPLIFICATION":
            return "file://{images}/custom_game/hud/stats/status_amplification.png";
        case "ATTACK_SPEED":
            return "file://{images}/custom_game/hud/stats/attack_speed.png";
        case "ATTACK_SPEED_PERCENT":
            return "file://{images}/custom_game/hud/stats/attack_speed.png";
        case "ATTACK_DAMAGE":
            return "file://{images}/custom_game/hud/stats/attack_damage.png";
        case "ATTACK_DAMAGE_PERCENT":
            return "file://{images}/custom_game/hud/stats/attack_damage.png";
        case "MOVE_SPEED":
            return "file://{images}/custom_game/hud/stats/move_speed.png";
        case "MOVE_SPEED_PERCENT":
            return "file://{images}/custom_game/hud/stats/move_speed.png";
        case "MANA_REGENERATION":
            return "file://{images}/custom_game/hud/stats/mana_regeneration.png";
        case "MANA_REGENERATION_PERCENT":
            return "file://{images}/custom_game/hud/stats/mana_regeneration.png";
        case "HOLY_DAMAGE":
            return "file://{images}/custom_game/hud/stats/holy_element.png";
        case "HOLY_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/holy_element.png";
        case "VOID_DAMAGE":
            return "file://{images}/custom_game/hud/stats/void_element.png";
        case "VOID_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/void_element.png";
        case "NATURE_DAMAGE":
            return "file://{images}/custom_game/hud/stats/nature_element.png";
        case "NATURE_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/nature_element.png";
        case "INFERNO_DAMAGE":
            return "file://{images}/custom_game/hud/stats/inferno_element.png";
        case "INFERNO_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/inferno_element.png";
        case "EARTH_DAMAGE":
            return "file://{images}/custom_game/hud/stats/earth_element.png";
        case "EARTH_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/earth_element.png";
        case "FIRE_DAMAGE":
            return "file://{images}/custom_game/hud/stats/fire_element.png";
        case "FIRE_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/fire_element.png";
        case "FROST_DAMAGE":
            return "file://{images}/custom_game/hud/stats/frost_element.png";
        case "FROST_RESISTANCE":
            return "file://{images}/custom_game/hud/stats/frost_element.png";
        case "STRENGTH":
            return "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex";
        case "STRENGTH_PERCENT":
            return "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_strength_psd.vtex";
        case "AGILITY":
            return "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex";
        case "AGILITY_PERCENT":
            return "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_agility_psd.vtex";
        case "INTELLECT":
            return "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex";
        case "INTELLECT_PERCENT":
            return "s2r://panorama/images/primary_attribute_icons/primary_attribute_icon_intelligence_psd.vtex";
        default:
            return "none";
    }
};

TooltipManager.FindAndReplaceStatIconsMarkers = function(label) {
    var result = label;
    var re = /\%.*?\%/ig;
    var match;
    while ((match = re.exec(result)) != null) {
        result = result.replace(match[0], "<img class='ItemStatIcon' src='" + TooltipManager.GetItemStatIcon(match[0].replace("%", "").replace("%", "")) + "'>");
    }
    return result;
};

// Added from tooltip_talent.js ._.

// Added from tooltip_item.js ._.

(function() {
    GameUI.CustomUIConfig().TooltipManager = TooltipManager;
})();