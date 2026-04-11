function buttonclick()
    sounds:playSound("ui.button.click", player:getPos(), 0.3, 1, false)
end
function toggleclick()
    sounds:playSound("ui.button.click", player:getPos(), 0.3, 1, false)
end
function pageclick()
    sounds:playSound("item.book.page_turn", player:getPos(), 2.5, 1, false)
end
function importclick()
    sounds:playSound("block.enchantment_table.use", player:getPos(), 1.5, 1, false)
end
function readfileclick()
    sounds:playSound("item.axe.strip", player:getPos(), 0.8, 1, false)
end
function errorclick()
    sounds:playSound("entity.item.break", player:getPos(), 0.6, 1, false)
end
function failclick()
    sounds:playSound("item.shield.block", player:getPos(), 0.6, 1, false)
end