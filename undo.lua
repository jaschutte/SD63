
local windowModule = require("window")
local mod = {}

function mod:Initialize() --this must be called atleast once
    self.ChangeLog = {}
    self.RedoLog = {}
    self.Stage = 0
end

function mod:ItemChanges(item)
    for i = self.Stage+1,#self.ChangeLog do
        self.ChangeLog[i] = nil
    end
    if item[1] == "add" then
        if items[item[2]].iID == "1" then
            item[1] = "propchange"
        end
    end
    self.ChangeLog[#self.ChangeLog+1] = {"item",item} --{delete/add/propchange,oldid/id,x,y,prop}
    self.Stage = #self.ChangeLog
end

function mod:TileChanges(changes)
    for i = self.Stage+1,#self.ChangeLog do
        self.ChangeLog[i] = nil
    end
    self.ChangeLog[#self.ChangeLog+1] = {"tile",changes} --{x,y,id}
    self.Stage = #self.ChangeLog
end

mod.Capture = {}
mod.Recording = {}
function mod:Snapshot()
    self.Capture = {}
    for x,yList in pairs(tiles) do
        self.Capture[x] = {}
        for y,id in pairs(yList) do
            self.Capture[x][y] = id
        end
    end
end

function mod:CommitChange(pos)
    if self.Recording[pos[1]] then
        self.Recording[pos[1]][pos[2]] = true
    else
        self.Recording[pos[1]] = {[pos[2]] = true}
    end
end

function mod:CommitSnapshot()
    local t = {}
    for x,yList in pairs(self.Recording) do
        for y in pairs(yList) do
            if self.Capture[x] and self.Capture[x][y] then
                t[#t+1] = {x,y,self.Capture[x][y]}
            end
        end
    end
    if #t ~= 0 then
        self:TileChanges(t)
    end
    self.Recording = {}
    self.Capture = {}
end

function mod:Undo()
    if self.Stage ~= 0 then
        local current = self.ChangeLog[self.Stage]
        if current[1] == "tile" then
            local old = {}
            for k,v in pairs(current[2]) do
                if tiles[v[1]] and tiles[v[1]][v[2]] then
                    old[k] = {v[1],v[2],tiles[v[1]][v[2]]}
                    tiles[v[1]][v[2]] = v[3]
                end
            end
            self.ChangeLog[self.Stage] = {"tile",old}
        elseif current[1] == "item" then --delete/add/propchange
            if current[2][1] == "delete" then
                local item = item:new(current[2][3],current[2][4],current[2][2])
                self:ReplaceId(current[2][6],item.Id)
                item.SaveParams = current[2][5]
                item:PropChanged()
                if windowModule.Grid then
                    windowModule:Populate(item)
                end
                self.ChangeLog[self.Stage] = {"item",{"add",item.Id,item.X,item.Y,item.SaveParams}}
            elseif current[2][1] == "add" then
                local item = items[current[2][2]]
                self.ChangeLog[self.Stage] = {"item",{"delete",item.iID,item.X,item.Y,item.SaveParams,item.Id}}
                item:Destroy(true)
            elseif current[2][1] == "propchange" then
                local item = items[current[2][2]]
                local t = {"item",{"propchange",item.Id,item.X,item.Y,{unpack(item.SaveParams)}}}
                item.SaveParams = current[2][5]
                item:PropChanged()
                if windowModule.Grid then
                    windowModule:Populate(item)
                end
                self.ChangeLog[self.Stage] = t
            end
        end
        self.Stage = self.Stage - 1
    end
end

function mod:ReplaceId(oldId,newId)
    for key,stat in pairs(self.ChangeLog) do
        if stat[1] and stat[2] and stat[2][1] and stat[2][2] and stat[1] == "item" and (stat[2][1] == "add" or stat[2][1] == "propchange") then
            if stat[2][2] == oldId then
                self.ChangeLog[key][2][2] = newId
            end
        end
    end
end

function mod:Redo()
    if self.Stage ~= #self.ChangeLog then
        self.Stage = self.Stage + 1
        local current = self.ChangeLog[self.Stage]
        if current[1] == "tile" then
            local old = {}
            for k,v in pairs(current[2]) do
                if tiles[v[1]] and tiles[v[1]][v[2]] then
                    old[k] = {v[1],v[2],tiles[v[1]][v[2]]}
                    tiles[v[1]][v[2]] = v[3]
                end
            end
            self.ChangeLog[self.Stage] = {"tile",old}
        elseif current[1] == "item" then
            if current[2][1] == "delete" then
                local item = item:new(current[2][3],current[2][4],current[2][2])
                self:ReplaceId(current[2][6],item.Id)
                item.SaveParams = current[2][5]
                item:PropChanged()
                if windowModule.Grid then
                    windowModule:Populate(item)
                end
                self.ChangeLog[self.Stage] = {"item",{"add",item.Id,item.X,item.Y,item.SaveParams}}
            elseif current[2][1] == "add" then
                local item = items[current[2][2]]
                self.ChangeLog[self.Stage] = {"item",{"delete",item.iID,item.X,item.Y,item.SaveParams,item.Id}}
                item:Destroy(true)
            elseif current[2][1] == "propchange" then
                local item = items[current[2][2]]
                local t = {"item",{"propchange",item.Id,item.X,item.Y,{unpack(item.SaveParams)}}}
                item.SaveParams = current[2][5]
                item:PropChanged()
                if windowModule.Grid then
                    windowModule:Populate(item)
                end
                self.ChangeLog[self.Stage] = t
            end
        end
    end
end

return mod
