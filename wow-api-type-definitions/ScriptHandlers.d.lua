---@meta

-- TODO can we make the handler functions typesafe?
-- https://wowpedia.fandom.com/wiki/Widget_script_handlers?oldid=159825

---@alias OnScriptButton
--- | "OnChar"
--- | "OnClick"
--- | "OnDoubleClick"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptCheckButton
--- | "OnChar"
--- | "OnClick"
--- | "OnDoubleClick"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptColorSelect
--- | "OnChar"
--- | "OnColorSelect"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptDressUpModel
--- | "OnAnimFinished"
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnUpdateModel"

---@alias OnScriptEditBox
--- | "OnChar"
--- | "OnCursorChanged"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEditFocusGained"
--- | "OnEditFocusLost"
--- | "OnEnter"
--- | "OnEnterPressed"
--- | "OnEscapePressed"
--- | "OnEvent"
--- | "OnHide"
--- | "OnInputLanguageChanged"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnSpacePressed"
--- | "OnTabPressed"
--- | "OnTextChanged"
--- | "OnTextSet"
--- | "OnUpdate"

---@alias OnScriptFrame
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptGameTooltip
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnTooltipAddMoney"
--- | "OnTooltipCleared"
--- | "OnTooltipSetDefaultAnchor"
--- | "OnUpdate"
--- | "OnTooltipSetSpell"

---@alias OnScriptLootButton
--- | "OnChar"
--- | "OnClick"
--- | "OnDoubleClick"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptMessageFrame
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptMinimap
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptModel
--- | "OnAnimFinished"
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnUpdateModel"

---@alias OnScriptPlayerModel
--- | "OnAnimFinished"
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnUpdateModel"

---@alias OnScriptScrollFrame
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnHorizontalScroll"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnScrollRangeChanged"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnVerticalScroll"

---@alias OnScriptScrollingMessageFrame
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnHyperlinkClick"
--- | "OnHyperlinkEnter"
--- | "OnHyperlinkLeave"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMessageScrollChanged"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptSimpleHTML
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnHyperlinkClick"
--- | "OnHyperlinkEnter"
--- | "OnHyperlinkLeave"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"

---@alias OnScriptSlider
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnValueChanged"

---@alias OnScriptStatusBar
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnValueChanged"

---@alias OnScriptTabardModel
--- | "OnAnimFinished"
--- | "OnChar"
--- | "OnDragStart"
--- | "OnDragStop"
--- | "OnEnter"
--- | "OnEvent"
--- | "OnHide"
--- | "OnKeyDown"
--- | "OnKeyUp"
--- | "OnLeave"
--- | "OnLoad"
--- | "OnMouseDown"
--- | "OnMouseUp"
--- | "OnMouseWheel"
--- | "OnReceiveDrag"
--- | "OnShow"
--- | "OnSizeChanged"
--- | "OnUpdate"
--- | "OnUpdateModel"

--- Set the function to use for a handler on this frame.
---@param scriptType OnScriptButton
---@param handler nil|function nil to remove current handler.
---@return nil
function Button:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptCheckButton
---@param handler nil|function nil to remove current handler.
---@return nil
function CheckButton:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptColorSelect
---@param handler nil|function nil to remove current handler.
---@return nil
function ColorSelect:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptDressUpModel
---@param handler nil|function nil to remove current handler.
---@return nil
function DressUpModel:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptEditBox
---@param handler nil|function nil to remove current handler.
---@return nil
function EditBox:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptEditBox
---@param handler nil|function nil to remove current handler.
---@return nil
function EditBox:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptFrame
---@param handler nil|function nil to remove current handler.
---@return nil
function Frame:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptGameTooltip
---@param handler nil|function nil to remove current handler.
---@return nil
function GameTooltip:SetScript(scriptType, handler) end

------
---@param scriptType OnScriptGameTooltip
---@param handler nil|function nil to remove current handler.
---@return nil
function GameTooltip:HookScript(scriptType, handler) end

---
---@param scriptType OnScriptLootButton
---@param handler nil|function nil to remove current handler.
---@return nil
function LootButton:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptMessageFrame
---@param handler nil|function nil to remove current handler.
---@return nil
function MessageFrame:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptMinimap
---@param handler nil|function nil to remove current handler.
---@return nil
function Minimap:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptModel
---@param handler nil|function nil to remove current handler.
---@return nil
function Model:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptPlayerModel
---@param handler nil|function nil to remove current handler.
---@return nil
function PlayerModel:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptScrollFrame
---@param handler nil|function nil to remove current handler.
---@return nil
function ScrollFrame:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptScrollingMessageFrame
---@param handler nil|function nil to remove current handler.
---@return nil
function ScrollingMessageFrame:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptSimpleHTML
---@param handler nil|function nil to remove current handler.
---@return nil
function SimpleHTML:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptSlider
---@param handler nil|function nil to remove current handler.
---@return nil
function Slider:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptStatusBar
---@param handler nil|function nil to remove current handler.
---@return nil
function StatusBar:SetScript(scriptType, handler) end

---
---@param scriptType OnScriptTabardModel
---@param handler nil|function nil to remove current handler.
---@return nil
function TabardModel:SetScript(scriptType, handler) end

-- Mega-union to avoid writing overloads for get/has
---@alias OnScriptMegaUnion
--- | OnScriptButton
--- | OnScriptCheckButton
--- | OnScriptColorSelect
--- | OnScriptDressUpModel
--- | OnScriptEditBox
--- | OnScriptFrame
--- | OnScriptGameTooltip
--- | OnScriptLootButton
--- | OnScriptMessageFrame
--- | OnScriptMinimap
--- | OnScriptModel
--- | OnScriptPlayerModel
--- | OnScriptScrollFrame
--- | OnScriptScrollingMessageFrame
--- | OnScriptSimpleHTML
--- | OnScriptSlider
--- | OnScriptStatusBar
--- | OnScriptTabardModel
