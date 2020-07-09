
--[[
    A small library to assign tags to.. anything
    I wanted this so I can assign tags to frames without constantly having to create new
    tables for them inside of the module itself.

    I'm going to put this out there for myself:
    DO. NOT. FORGET. TO. UNASSIGN. TAGS. APON. DELETION.
    Or you will create a memory leak, and we don't want that do we?
        Atleast I think it will
        It's better to be sure.
]]

local mod = {}
mod.Tags = {}

function mod:AddTag(instance, tag, val) --add a tag to an instance, optional value
    if not self.Tags[tag] then
        self.Tags[tag] = {}
    end
    self.Tags[tag][instance] = val or true --if no value was given, just give it true
end

function mod:HasTag(instance, tag) --check if an instance has a tag, if the tag has a value, return that
    return self.Tags[tag] and self.Tags[tag][instance] or false
end

function mod:MapTag(tag, func) --applies a function to each member of a tag
    --the arguments given to the function are the instances and the values, it can return the new values, if nil it stays the same
    if self.Tags[tag] then
        for inst, value in pairs(self.Tags[tag]) do
            local new = func(inst, value)
            if new and self.Tags[tag] and self.Tags[tag][inst] then
                self.Tags[tag][inst] = new
            end
        end
    end
end

function mod:RemoveTag(instance, tag) --remove the tag from an instance
    if self.Tags[tag] then
        self.Tags[tag][instance] = nil
    else
        print("WARNING: Untagging an instance from an non existant tag. Tag: "..tag.." Instance: "..instance)
    end
end

return mod
