
--[[
    01 02 03 04 05
    06 07 08 09 10
    11 12 xx 13 14
    15 16 17 18 19
    20 21 22 23 24
]]

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
    for group,tiles in pairs(mod.MultiTiles) do
        mod.DeepLoop(tiles,function(og,key,val,extrakey)
            og[key] = string.char(math.floor((group+val)/75)+49)..string.char((group+val)-math.floor((group+val)/75)*75+49)
            mod.Override[og[key]] = extrakey..key
        end,"",true)
    end
end

mod.Override = {}
mod.MultiTiles = {
    [100] = {
        [46] = {
            TopTile = 1;
            BottemTile = 37;
            SlabTileTop = 2;
            SlabTileBottem = 3;
            LeftEdge = 15;
            RightEdge = 16;
            TopToSlab = {
                Left = 23;
                Right = 24;
                LeftRandom = 25;
                RightRandom = 26;
            };
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
                BottemLeftBase = 45;
                BottemLeftRandom = 45;
                BottemRightBase = 44;
                BottemRightRandom = 44;
            };
            SmoothCorners = {
                TopLeft = {
                    TL = 27;
                    TR = 25;
                    BL = 29;
                    BR = 35;
                };
                TopRight = {
                    TL = 26;
                    TR = 36;
                    BL = 28;
                    BR = 30;
                };
                BottemLeft = {
                    TL = 39;
                    TR = 41;
                    BL = 0;
                    BR = 39;
                };
                BottemRight = {
                    TL = 40;
                    TR = 38;
                    BL = 38;
                    BR = 0;
                };
            };
            EdgeCorner = {
                Left = 17;
                Right = 18;
                SlabLeftTop = 19;
                SlabRightTop = 20;
                SlabLeftBottem = 21;
                SlabRightBottem = 22;
            }
        };
    }
}

return mod
