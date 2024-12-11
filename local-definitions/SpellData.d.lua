---@meta

---@class SpellData
---@field castTime number The time to cast this spell.
---@field cooldown number The cooldown for this spell.
---@field delayTime number The actual smallest time between casts.
---@field spellPowerType number The power type it uses.
---@field spellPowerCost number The amount of power it uses.
SpellData = {
}

---@class SpellDamageData: SpellData
---@field spellTreeID SpellTreeID The spell tree of this spell.
---@field coefficient number The total damage dealt.
---@field spellPower number The spell power of this spell.
---@field spellPowerDamage number The damage provided by spell power.
---@field baseDPS number The DPS of the spell, without spell power.
---@field empoweredDPS number The DPS of the spell, with spell power.
SpellDamageData = {
}

---@class SpellFlatDamageData: SpellDamageData
---@field damage number The flat damage dealt by this spell.
---@field empoweredDamage number The total empowered damage dealt.
SpellFlatDamageData = {

}

---@class SpellDamageRangeData: SpellDamageData
---@field low number A low end of the damage.
---@field empoweredLow number A low end of the empowered damage.
---@field high number The high end of the damage.
---@field empoweredHigh number A high end of the empowered damage.
---@field avg number The average damage.
---@field empoweredAvg number The average empowered damage.
SpellDamageRangeData = {
}

---@class SpellDamageOverTimeData: SpellDamageData
---@field damage number The total damage dealt.
---@field empoweredDamage number The total empowered damage dealt.
---@field damagePerTick number The damage dealt per tick.
---@field empoweredDamagePerTick number The empowered damage dealt per tick.
---@field duration number The total duration of the effect.
---@field ticks number The total number of ticks.
SpellDamageOverTimeData = {

}

---@class SpellMixin
---@field flat nil|SpellFlatDamageData
---@field dot nil|SpellDamageOverTimeData
---@field range nil|SpellDamageRangeData
SpellMixin = {
}
