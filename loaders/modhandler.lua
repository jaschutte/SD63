
local graphics = require("loaders.graphics")
local windows = require("loaders.window")
local socketUrl = require("socket.url")

local mod = {}

function mod:CreateMod(url, values)
    for _, mod in pairs(LD.Settings.Mods) do
        if mod.Url == url then
            return --if user tries to add multiple of the same mod, do nothing
        end
    end
    LD.Settings.Mods[#LD.Settings.Mods+1] = {
        Url = url;
        Values = values
    }
    --[[
        Value = {
            Key = string or nil
            Value = string/number/(table must be another value table) or nil
        }
    ]]
end

local function arrayToString(tab) --recursive function to convert table to string using the mod format
    local str = ""
    for _, pair in ipairs(tab) do
        if type(pair.Value) == "string" or type(pair.Value) == "number" then
            if pair.Key then
                str = str.."<"..pair.Key..":"..pair.Value..">" --if value was a number, it would converted anyway
            else
                str = str.."<"..pair.Value..">"
            end
        elseif type(pair.Value) == "table" then
            if pair.Key then
                str = str.."<"..pair.Key..">"..arrayToString(pair.Value) --if value was a number, it would converted anyway
            else
                str = str..arrayToString(pair.Value)
            end
        elseif pair.Value == nil and pair.Key then --if nil but there is a key then:
            str = str.."<"..pair.Key..">"
        end --if it's not any of these, discard it (functions, userdata)
    end
    return str
end

function mod:ToString(mod, urlescape) --only works with 1 mod at a time
    local modStr = "<img src=\""..mod.Url.."\">"
    modStr = modStr..arrayToString(mod.Values)
    return urlescape and socketUrl.escape(modStr) or modStr
end

function mod:ToTable(modStr, urlunescape) --only works with 1 mod at a time
    modStr = urlunescape and socketUrl.unescape(modStr) or modStr
    local mod = {Values = {}}
    modStr:gsub("%b<>", function(chars)
        chars = chars:sub(2):sub(1, -2)
        local endKey = chars:find(":") or #chars
        local key = chars:sub(1, endKey - (endKey ~= #chars and 1 or 0))
        local val = chars:sub(endKey - #chars)
        if key == "img src=\"https" or key == "img src=\"http" then
            mod.Url = (key == "img src=\"http" and "http:" or "https:")..val:sub(1, -2)
        else
            mod.Values[#mod.Values+1] = {
                Key = key;
                Value = endKey ~= #chars and val or nil;
            }
        end
    end)
    print("Mod Url:\n",mod.Url,"\nValues:")
    for i,v in ipairs(mod.Values) do
        print(i)
        print("\tKey:", v.Key)
        if v.Value then
            print("\tValue:", v.Value)
        end
    end
end

local encoded = mod:ToString({
    Url = "https://raw.githubusercontent.com/Runouw-Modders/SM63-Mods/master/public/somemodidk.swf";
    Values = {
        {
            Key = "windspeed";
            Value = 60;
        };
        {
            Key = "speed";
            Value = {
                {
                    Key = "X";
                    Value = 5;
                };
                {
                    Key = "Y";
                    Value = 20;
                };
            };
        };
        {
            Key = "gravity";
            Value = 9.81;
        }
    }
}, true)

print(encoded)

mod:ToTable(encoded, true)

function mod:OpenEditor(id)
    local window = windows:NewWindow(ToolSettings.MouseX - 230, ToolSettings.MouseY - 150, 300, 200)
    window:SetScaling(true)
    window:SetTitle("Value Editor")
    local main = graphics:NewScrollbar(0, 16, 300, 186)
    main.WindowParent = window
    main:SetColours(0, 0, 0, 0)
    window.OnResize = function(w, h)
        main:Resize(w, h - 16)
    end
    window:Attach(main, 0, 16)
    local t = graphics:NewFrame(0, 0, 20, 20)
    main:Attach(t, 20, 180)
end

return mod
