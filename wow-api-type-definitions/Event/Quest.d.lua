---@meta

---@alias EventQuestUnit
--- | "UNIT_QUEST_LOG_CHANGED"

---@alias EventQuest
--- | EventQuestUnit
---
--- This event fires when an escort quest is started by another player. A dialog appears asking if the player also wants to start the quest.
--- arg1 string NPC name?
--- arg2 string Quest name?
--- | "QUEST_ACCEPT_CONFIRM"
---
--- Fired when the player hits the "Continue" button in the quest-information page, before the "Complete Quest" button.
--- In other words, it fires when you are given the option to complete a quest, but before you actually complete the quest.
--- | "QUEST_COMPLETE"
---
--- Fired when the player is given a more detailed view of his quest.
--- | "QUEST_DETAIL"
---
--- Fired whenever the quest frame changes (Detail to Progress to Reward, etc.) or is closed.
--- | "QUEST_FINISHED"
---
--- Fired when a quest is offered
--- | "QUEST_GREETING"
---
--- Fired when the quest items are updated
--- | "QUEST_ITEM_UPDATE"
---
--- This event is fired very often. This includes, but is not limited to:
--- - viewing a quest for the first time in a session in the Quest Log
--- - (once for each quest?) every time the player changes zones across an instance boundry
--- - every time the player picks up a non-grey item
--- - every time the player performs a quest activity, such as killing a mob for a quest
--- | "QUEST_LOG_UPDATE"
---
--- Fired when a player is viewing the status of their quest.
--- | "QUEST_PROGRESS"
---
--- Fired just before a quest goal was completed. At this point the game client's quest data is not yet updated, but will be after a subsequent QUEST_LOG_UPDATE event.
--- TODO Incomplete - does 1.12 have arg1?
--- arg1 unknown questIndex (not watch index)
--- | "QUEST_WATCH_UPDATE"
