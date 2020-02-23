
local coroutine, os = coroutine, os
local mod = {}
mod.Threads = {}

function mod:NewThread(f,...)
    assert(type(f) == "function","Given argument wasn't a function.")
    local id = GetId()
    mod.Threads[id] = {coroutine.create(f),{...},false,true,-1}
    return id
end

function mod:SetArguments(id,...)
    assert(type(id) == "number","Given argument wasn't a number id.")
    assert(mod.Threads[id] ~= nil,"Given id does not exist.")
    mod.Threads[id][2] = {...}
    return true
end

function mod:StartThread(id)
    assert(type(id) == "number","Given argument wasn't a number id.")
    assert(mod.Threads[id] ~= nil,"Given id does not exist.")
    mod.Threads[id][3] = true
    return true
end

function mod:DisableThread(id)
    assert(type(id) == "number","Given argument wasn't a number id.")
    assert(mod.Threads[id] ~= nil,"Given id does not exist.")
    mod.Threads[id][3] = false
    return true
end

function mod:RemoveThread(id)
    assert(type(id) == "number","Given argument wasn't a number id.")
    assert(mod.Threads[id] ~= nil,"Given id does not exist.")
    mod.Threads[id] = nil
    return true
end
function mod:MakeThreadWait(id,sec)
    assert(type(id) == "number","Given argument wasn't a number id.")
    assert(mod.Threads[id] ~= nil,"Given id does not exist.")
    assert(type(sec) == "number","Given argument for 'seconds' wasn't a number.")
    mod.Threads[id][5] = os.clock()+sec
    mod:DisableThread(id)
    return true
end

function mod:CancelWait(id)
    assert(type(id) == "number","Given argument wasn't a number id.")
    assert(mod.Threads[id] ~= nil,"Given id does not exist.")
    mod.Threads[id][5] = -1
    mod:StartThread(id)
    return true
end

function mod:Wait(duration)
    local goal = os.clock()+duration
    repeat
        coroutine.yield()
    until os.clock() > goal
    return true
end

function mod:OnFrame()
    local now = os.clock()
    for id,cor in pairs(mod.Threads) do
        if coroutine.status(cor[1]) == "dead" and cor[4] then
            mod:RemoveThread(id)
        elseif cor[3] then
            coroutine.resume(cor[1],unpack(cor[2]))
        elseif cor[5] ~= -1 then
            if now > cor[5] then
                cor[5] = -1
                mod:StartThread(id)
            end
        end
    end
end

return mod
