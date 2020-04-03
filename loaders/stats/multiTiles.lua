
local mod = {}

function mod.DeepLoop(t,f,extra,igFirst)
    for key,value in pairs(t) do
        if type(value) == "table" then
            mod.DeepLoop(value,f,igFirst and "" or extra..key)
        else
            f(t,key,value,extra)
        end
    end
end

function mod:Init()
    local real = {}
    for group,tiles in pairs(mod.MultiTiles) do
        mod.DeepLoop(tiles,function(og,key,val,extrakey)
            og[key] = string.char(math.floor((group+val)/75)+49)..string.char((group+val)-math.floor((group+val)/75)*75+49)
            if real[og[key]] then
                real[og[key]][extrakey..key] = true
            else
                real[og[key]] = {[extrakey..key] = true}
            end
        end,"",true)
    end
    mod.Override = setmetatable({},{
        __index = function(_,key)
            return real[key] and real[key] or {}
        end
    })
end

mod.Override = {}
mod.MultiTiles = {
    [100] = {
        [46] = {
            TopTile = 1;
            BottemTile = 37;
            SlabTileTop = 2;
            SlabTileBottem = 4;
            LeftEdge = 15;
            RightEdge = 16;
            GroundTiles = {
                Base = 3;
                Random1 = 5;
                Random2 = 6;
            };
            Corners = {
                TopLeftBase = 7;
                TopLeftRandom = 9;
                TopRightBase = 8;
                TopRightRandom = 10;
                SlabTopLeftBase = 11;
                SlabTopLeftRandom = 13;
                SlabTopRightBase = 12;
                SlabTopRightRandom = 14;
                BottemRightBase = 45;
                BottemLeftBase = 44;
            };
            SmoothCorners = {
                TopRight = {
                    Base = {
                        TL = 31;
                        TR = 25;
                        BL = 33;
                        BR = 35;
                    };
                    Random = {
                        TL = 27;
                        TR = 23;
                        BL = 29;
                        BR = 35;
                    }
                };
                TopLeft = {
                    Base = {
                        TL = 26;
                        TR = 32;
                        BL = 36;
                        BR = 34;
                    };
                    Random = {
                        TL = 24;
                        TR = 28;
                        BL = 36;
                        BR = 30;
                    }
                };
                BottemLeft = {
                    Small = 38;
                    Big = 40;
                };
                BottemRight = {
                    Small = 39;
                    Big = 41;
                };
            };
            EdgeCorner = {
                Left = 18;
                Right = 17;
                SlabLeftTop = 20;
                SlabRightTop = 19;
                SlabLeftBottem = 22;
                SlabRightBottem = 21;
                BottemLeft = 42;
                BottemRight = 43;
            }
        };
    }
}

return mod
