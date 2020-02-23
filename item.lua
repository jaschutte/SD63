
local function mathclamp(x,min,max)
    return math.max(min,math.min(x,max))
end

local mod = {}

function mod:setValues(item)
    local saveparams = {}
    local desc = {"SPRITEID","XPOS","YPOS"}
    saveparams[1] = item.iID
    saveparams[2] = item.X-64
    saveparams[3] = item.Y-64
    if item.iID == "1" then
        saveparams[4] = 0
        saveparams[5] = 0
        saveparams[6] = "Right"
        desc = {"SPRITEID","XPOS","YPOS","XSPEED","YSPEED","DIRECTION"}
    elseif item.iID == "7" then
        saveparams[4] = 3
        saveparams[5] = 0
        saveparams[6] = 30
        saveparams[7] = 0
        saveparams[8] = 0
        saveparams[9] = 0
        saveparams[10] = "Right"
        saveparams[11] = "none"
        saveparams[12] = 0.5
        saveparams[13] = 1
        saveparams[14] = 0
        saveparams[15] = 25
        desc = {"SPRITEID","XPOS","YPOS","XSPEED","YSPEED","XLENGTH","YLENGTH","XOFFSET","YOFFSET","XDIRECTION","YDIRECTION","ACCELERATION","SIZE","TOUCHNGO","COUNT"}
    elseif item.iID == "8" then
        saveparams[4] = 2
        saveparams[5] = 2
        saveparams[6] = 50
        saveparams[7] = 0
        saveparams[8] = 1
        desc = {"SPRITEID","XPOS","YPOS","SPEED","PLATFORMCOUNT","RADIUS","OFFSET","SIZE"}
    elseif item.iID == "9" then
        saveparams[4] = 0
        saveparams[5] = 0
        saveparams[6] = 0
        saveparams[7] = 0
        saveparams[8] = 0
        saveparams[9] = 0
        saveparams[10] = "Right"
        saveparams[11] = "none"
        saveparams[12] = 0.5
        saveparams[13] = 80
        saveparams[14] = 1
        saveparams[15] = "Left"
        saveparams[16] = 3
        saveparams[17] = 72
        saveparams[18] = 1
        desc = {"SPRITEID","XPOS","YPOS","XSPEED","YSPEED","XLENGTH","YLENGTH","XOFFSET","YOFFSET","XDIRECTION","YDIRECTION","ACCELERATION","SIZE","BLOCK_TYPE","ROTATION_DIRECTION","ROTATION_SPEED","WAIT_TIME","UNKNOWN"}
    elseif item.iID == "18" or item.iID == "19" then
        saveparams[4] = 2
        saveparams[5] = 0
        desc = {"SPRITEID","XPOS","YPOS","SPEED","ANGLE"}
    elseif tonumber(item.iID) >= 28 and tonumber(item.iID) <= 36 or item.iID == "41" or item.iID == "42" then
        saveparams[4] = 1
        saveparams[5] = 0
        desc = {"SPRITEID","XPOS","YPOS","MIRROR","ANGLE"}
    elseif item.iID == "37" then
        saveparams[4] = 15
        saveparams[5] = 0
        desc = {"SPRITEID","XPOS","YPOS","SPEED","ANGLE"}
    elseif item.iID == "38" then
        saveparams[2] = saveparams[2] - 64
        saveparams[3] = saveparams[3] - 48
        saveparams[4] = 0
        saveparams[5] = 128
        saveparams[6] = 96
        desc = {"SPRITEID","XPOS","YPOS","ANGLE","LENGTH","DEPTH"}
    elseif item.iID == "39" then
        saveparams[4] = item.X-64
        saveparams[5] = item.Y-64
        saveparams[6] = 1
        desc = {"SPRITEID","XPOS","YPOS","TARGETX","TARGETY","FRAME"}
    elseif item.iID == "40" then
        saveparams[4] = item.X-64
        saveparams[5] = item.Y-64
        desc = {"SPRITEID","XPOS","YPOS","TARGETX","TARGETY"}
    elseif item.iID == "44" then
        saveparams[4] = 0
        saveparams[5] = 12
        saveparams[6] = 16
        saveparams[7] = 7
        saveparams[8] = 1
        saveparams[9] = .1
        saveparams[10] = 3
        saveparams[11] = 30
        saveparams[12] = 1
        desc = {"SPRITEID","XPOS","YPOS","OFFSET","WAITTIME","GROUNDWAITTIME","FALLSPEED","FALLACCEL","RISEACCEL","RISESPEED","RANGE","CHASE"}
    elseif item.iID == "45" then
        saveparams[4] = 0
        saveparams[5] = 100
        saveparams[6] = 100
        saveparams[7] = 64
        saveparams[8] = 92
        saveparams[9] = 0
        saveparams[10] = 0
        saveparams[11] = 0
        desc = {"SPRITEID","XPOS","YPOS","ANGLE","XSCALE","YSCALE","ONWAIT","OFFWAIT","DISABLED","OFFSET","STARTOFF"}
    elseif tonumber(item.iID) >= 51 and tonumber(item.iID) <= 70 or item.iID == "72" then
        saveparams[4] = 1
        desc = {"SPRITEID","XPOS","YPOS","MIRROR"}
    elseif item.iID == "71" then
        saveparams[4] = "Both"
        saveparams[5] = 0
        saveparams[6] = 3
        saveparams[7] = 100
        saveparams[8] = 0
        saveparams[9] = 1
        saveparams[10] = 0
        desc = {"SPRITEID","XPOS","YPOS","DIRECTION","ANGLE","SPEED","WAIT","OFFSET","COLOR","CHASE"}
    elseif item.iID == "73" then
        saveparams[4] = "This is a sign... Placed using SuperDesigner63!"
        desc = {"SPRITEID","XPOS","YPOS","TEXT"}
    elseif item.iID == "74" then
        saveparams[4] = 20
        desc = {"SPRITEID","XPOS","YPOS","DURATION"}
    elseif tonumber(item.iID) >= 78 and tonumber(item.iID) <= 81 then
        saveparams[4] = 30
        desc = {"SPRITEID","XPOS","YPOS","DURATION"}
    elseif tonumber(item.iID) >= 100 then
        saveparams[4] = 1
        saveparams[5] = 0
        desc = {"SPRITEID","XPOS","YPOS","MIRROR","ANGLE"}
    end
    saveparams[#saveparams+1] = item.iID == "1" and 100 or #itemsOnZ["r"]
    desc[#desc+1] = "Z INDEX"
    saveparams[#saveparams+1] = "r"
    desc[#desc+1] = "Z LAYER"
    saveparams[#saveparams+1] = 0
    desc[#desc+1] = "DISABLE ITEM"
    return saveparams, desc
end

mod.Animations = {}
function mod.Animations.Get7(saveparams,item)
    local self = {}
    self.X = 0
    self.Y = 0
    self.CurrentX = saveparams[4] + saveparams[8]
    self.CurrentY = saveparams[5] + saveparams[9]
    self.DirectionX = saveparams[10]
    self.DirectionY = saveparams[11]
    self.CurrentSpeedY = 0
    self.CurrentSpeedX = 0
    self.Image = item.Image
    self.ScaleX = item.ScaleX
    self.ScaleY = item.ScaleY
    self.Width = item.Width/2
    self.Height = item.Height/2
    self.OffsetX = item.X
    self.OffsetY = item.Y
    self.Rotate = 0
    function self.Frame()
        self.CurrentX = self.CurrentX + 1
        if self.CurrentX >= saveparams[6] then
            self.CurrentX = 0
            self.DirectionX = self.DirectionX == "Right" and "Left" or "Right"
        end
        self.CurrentSpeedX = self.DirectionX == "Right" and self.CurrentSpeedX + saveparams[12] or self.CurrentSpeedX - saveparams[12]
        self.CurrentY = self.CurrentY + 1
        if self.CurrentY >= saveparams[7] then
            self.CurrentY = 0
            self.DirectionY = self.DirectionY == "Up" and "Down" or "Up"
        end
        self.CurrentSpeedY = self.DirectionY == "Up" and self.CurrentSpeedY + saveparams[12] or self.CurrentSpeedY - saveparams[12]
        self.CurrentSpeedX = mathclamp(self.CurrentSpeedX,-saveparams[4],saveparams[4])
        self.CurrentSpeedY = mathclamp(self.CurrentSpeedY,-saveparams[5],saveparams[5])
        self.X = self.X + self.CurrentSpeedX
        self.Y = self.Y + self.CurrentSpeedY
    end
    return self
end
function mod.Animations.Get8(saveparams,item,rot)
    local self = {}
    self.X = 0
    self.Y = 0
    self.Image = itemSkins["7+8"][item.SaveParams[8]]
    self.ScaleX = item.ScaleX
    self.ScaleY = item.ScaleY
    self.Width = self.Image:getWidth()/2
    self.Height = self.Image:getHeight()/2
    self.OffsetX = item.X
    self.OffsetY = item.Y
    self.Rotate = 0
    self.Angle = rot
    function self.Frame()
        self.Angle = self.Angle + math.rad(saveparams[4])
        self.X = -math.sin(self.Angle) * saveparams[6]
        self.Y = math.cos(self.Angle) * saveparams[6]
    end
    return self
end
function mod.Animations.Get9(saveparams,item)
    local self = {}
    self.X = 0
    self.Y = 0
    self.CurrentX = saveparams[4] + saveparams[8]
    self.CurrentY = saveparams[5] + saveparams[9]
    self.DirectionX = saveparams[10]
    self.DirectionY = saveparams[11]
    self.CurrentSpeedY = 0
    self.CurrentSpeedX = 0
    self.Image = item.Image
    self.ScaleX = item.ScaleX
    self.ScaleY = item.ScaleY
    self.Width = item.Width/2
    self.Height = item.Height/2
    self.OffsetX = item.X
    self.OffsetY = item.Y
    self.Rotate = 0
    self.Counter = 0
    self.SpinCounter = 0
    function self.Frame()
        self.Counter = self.Counter + 1
        if self.Counter > saveparams[17] then
            self.SpinCounter = self.SpinCounter + 1
            if self.SpinCounter * saveparams[16] <= 90 then
                self.Rotate = saveparams[15] == "Left" and self.Rotate - math.rad(saveparams[16]) or self.Rotate + math.rad(saveparams[16])
            else
                self.Counter = 0
                self.SpinCounter = 0
            end
        end
        self.CurrentX = self.CurrentX + 1
        if self.CurrentX >= saveparams[6] then
            self.CurrentX = 0
            self.DirectionX = self.DirectionX == "Right" and "Left" or "Right"
        end
        self.CurrentSpeedX = self.DirectionX == "Right" and self.CurrentSpeedX + saveparams[12] or self.CurrentSpeedX - saveparams[12]
        self.CurrentY = self.CurrentY + 1
        if self.CurrentY >= saveparams[7] then
            self.CurrentY = 0
            self.DirectionY = self.DirectionY == "Up" and "Down" or "Up"
        end
        self.CurrentSpeedY = self.DirectionY == "Up" and self.CurrentSpeedY + saveparams[12] or self.CurrentSpeedY - saveparams[12]
        self.CurrentSpeedX = mathclamp(self.CurrentSpeedX,-saveparams[4],saveparams[4])
        self.CurrentSpeedY = mathclamp(self.CurrentSpeedY,-saveparams[5],saveparams[5])
        self.X = self.X + self.CurrentSpeedX
        self.Y = self.Y + self.CurrentSpeedY
    end
    return self
end
function mod.Animations.Get18(saveparams,item)
    local self = {}
    self.X = 0
    self.Y = 0
    self.Image = item.Image
    self.ScaleX = item.ScaleX
    self.ScaleY = item.ScaleY
    self.Width = item.Width/2
    self.Height = item.Height/2
    self.OffsetX = item.X
    self.OffsetY = item.Y
    self.Rotate = math.rad(saveparams[5])
    function self.Frame()
        self.Rotate = self.Rotate + math.rad(saveparams[4])
    end
    return self
end

return mod
