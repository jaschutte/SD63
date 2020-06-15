
local mod = {}

local threads = require("loaders.threading")
local floor, min, max = math.floor, math.min, math.max
mod.Frames = {}
mod.FramesOnZ = {}
mod.Messages = {}
mod.DrawHoverTile = false
mod.DrawTileSelection = false

local function clamp(x,y,z) --limit x between y and z
    return (x > y and x or y) < z and (x > y and x or y) or z
end

local function sign(x,f) --get the sign of an number. Option to replace 0 with f
    return x == 0 and (f or 0) or x < 0 and -1 or 1
end

local function insertFrame(fr)
    local placed = false
    local temp = {}
    if #mod.FramesOnZ == 0 then
        placed = true
        temp[1] = fr
    else
        for id,frame in ipairs(mod.FramesOnZ) do
            if placed then
                temp[id+1] = frame
            else
                if frame.Layer == "Menu" then
                    if fr.Layer == "Menu" then
                        if fr.Z < frame.Z then
                            placed = true
                            temp[id] = fr
                            temp[id+1] = frame
                        end
                    end
                elseif fr.Layer == "Menu" then
                    placed = true
                    temp[id] = fr
                else
                    if fr.Z < frame.Z then
                        placed = true
                        temp[id] = fr
                        temp[id+1] = frame
                    end
                end
            end
        end
        if not placed then
            placed = true
            temp[#mod.FramesOnZ+1] = fr
        end
    end
    for id,frame in pairs(temp) do
        mod.FramesOnZ[id] = frame
    end
end

local function removeFrame(fr)
    local found = false
    for id,frame in ipairs(mod.FramesOnZ) do
        if found then
            mod.FramesOnZ[id-1] = frame
            mod.FramesOnZ[id] = nil
        end
        if id == fr.Id then
            mod.FramesOnZ[id] = nil
            found = true
        end
    end
end

function mod.DefaultOnEnter(self)
    threads:StartThread(threads:NewThread(function(self)
        self:SetColours(.7,.7,.7)
        for i = 0,1,.1 do
            self.ScaleX = Lerp(1,1.1,i)
            self.ScaleY = Lerp(1,1.1,i)
            threads:Wait(0.01)
        end
    end,self))
end
function mod.DefaultOnLeave(self)
    threads:StartThread(threads:NewThread(function(self)
        self:SetColours(1,1,1)
        for i = 0,1,.1 do
            self.ScaleX = Lerp(1.1,1,i)
            self.ScaleY = Lerp(1.1,1,i)
            threads:Wait(0.01)
        end
    end,self))
end

function mod:MassDelete(delete) --only loops FramesOnZ once for the entire list of deletion. Should be used if more than 3 objects need to be deleted
    local rev = {}
    for _,frame in pairs(delete) do
        mod.Frames[frame.Id] = nil
        rev[frame.Id] = true
    end
    local sub = 0
    for key,frame in pairs(mod.FramesOnZ) do
        if rev[frame.Id] then
            mod.FramesOnZ[key] = nil
            sub = sub + 1
        elseif sub ~= 0 then
            mod.FramesOnZ[key-sub] = frame
            mod.FramesOnZ[key] = nil
        end
    end
    return nil
end

function mod:NewFrame(x,y,w,h,z,layer)
    local obj = {}
    obj.X = x or 0
    obj.Y = y or 0
    obj.W = w or 0
    obj.H = h or 0
    obj.Z = z or 0
    obj.Layer = layer or "b"
    obj.R = 0
    obj.AnchorX = 0.5
    obj.AnchorY = 0.5
    obj.ScaleX = 1; -- ONLY SCALES WHEN DRAWN, DOES NOT SCALE COLLISION
    obj.ScaleY = 1; -- ONLY SCALES WHEN DRAWN, DOES NOT SCALE COLLISION
    obj.Colour = {
        R = 1;
        G = 1;
        B = 1;
        A = 1;
    }
    obj.BackgroundColour = {
        R = 1;
        G = 1;
        B = 1;
        A = 1;
    }
    obj.ImageData = {
        Image = nil;
        W = 0;
        H = 0;
        ScaleX = 0;
        ScaleY = 0;
    }
    obj.Clips = {
        AnchorX = 0.5;
        AnchorY = 0.5;
        X = 0;
        Y = 0;
        W = 0;
        H = 0;
    }
    obj.Id = GetId()
    obj.FitImageInsideWH = false
    obj.Collision = {
        OnClick = nil; --when the user presses the frame
        OnUp = nil; --when the mouse is up
        OnScroll = nil; --when the user scroll above the frame
        DetectHover = false; --want to check for hover?
        OnEnter = mod.DefaultOnEnter; --when mouse enters frame
        OnLeave = mod.DefaultOnLeave; --when mouse exits frame
        IsBeingHovered = false; --boolean to check if mouse is being hovered above frame
        IsDown = false;
    }
    obj.Visible = false
    obj.ApplyZoom = true
    obj.ScreenPosition = false --if false it will use CameraPosition
    function obj:SetColours(r,g,b,a,forBackground)
        if forBackground then
            obj.BackgroundColour.R = r or obj.BackgroundColour.R
            obj.BackgroundColour.G = g or obj.BackgroundColour.G
            obj.BackgroundColour.B = b or obj.BackgroundColour.B
            obj.BackgroundColour.A = a or obj.BackgroundColour.A
        else
            obj.Colour.R = r or obj.Colour.R
            obj.Colour.G = g or obj.Colour.G
            obj.Colour.B = b or obj.Colour.B
            obj.Colour.A = a or obj.Colour.A
        end
        return obj
    end
    function obj:CheckCollision(mx,my)
        local x,y, w,h = obj:ToScreenPixels()
        return mx > x and mx < x+w and my > y and my < y+h
    end
    function obj:SetImage(img)
        obj.ImageData.Image = img
        obj.ImageData.W, obj.ImageData.H = img:getDimensions()
        obj.ImageData.ScaleX, obj.ImageData.ScaleY = obj.W/obj.ImageData.W, obj.H/obj.ImageData.H
    end
    function obj:Resize(w,h)
        w = w or obj.W
        h = h or obj.H
        obj.W, obj.H = w, h
        if obj.ImageData.Image then
            obj.ImageData.ScaleX, obj.ImageData.ScaleY = obj.W/obj.ImageData.W, obj.H/obj.ImageData.H
        end
    end
    function obj:ChangeZ(z,layer)
        obj.Z = z or obj.Z
        obj.Layer = layer or obj.Layer
        removeFrame(obj)
        insertFrame(obj)
    end
    function obj:Move(x,y)
        x = x or obj.X
        y = y or obj.Y
        obj.X, obj.Y = x, y
    end
    function obj:TileToItem(x,y)
        obj:Move(floor(x*32),floor(y*32))
    end
    function obj:Destroy()
        removeFrame(obj)
        mod.Frames[obj.Id] = nil
        return nil
    end
    function obj:ToScreenPixels(ignoreAnchors,applyScale)
        local x, y = obj.X, obj.Y
        local w, h = obj.W, obj.H
        if applyScale then
            w, h = w*obj.ScaleX, h*obj.ScaleY
        end
        if obj.ApplyZoom then
            --w, h = w*CameraPosition.Z, h*CameraPosition.Z
            if not ignoreAnchors then
                x, y = x*CameraPosition.Z-w*obj.AnchorX, y*CameraPosition.Z-h*obj.AnchorY
            else
                x, y = x*CameraPosition.Z, y*CameraPosition.Z
            end
        elseif not ignoreAnchors then
            x, y = x-w*obj.AnchorX, y-h*obj.AnchorY
        end
        if not obj.ScreenPosition then
            x, y = x+CameraPosition.X, y+CameraPosition.Y
        end
        return floor(x),floor(y), floor(w),floor(h)
    end
    function obj:Draw()
        if obj.Visible then
            love.graphics.setColor(obj.Colour.R,obj.Colour.G,obj.Colour.B,obj.Colour.A)
            local x,y, w,h = obj:ToScreenPixels(true)
            if obj.Clips.W ~= 0 and obj.Clips.H ~= 0 then --clips ignore zoom
                local x, y = obj.Clips.X-obj.Clips.W*obj.Clips.AnchorX, obj.Clips.Y-obj.Clips.H*obj.Clips.AnchorY
                if not obj.ScreenPosition then
                    x, y = x - CameraPosition.X, y - CameraPosition.Y
                end
                love.graphics.setScissor(x,y,obj.Clips.W,obj.Clips.H)
            end
            if obj.ImageData.Image then
                local sx = obj.ApplyZoom and obj.ScaleX*CameraPosition.Z or obj.ScaleX
                local sy = obj.ApplyZoom and obj.ScaleY*CameraPosition.Z or obj.ScaleY
                if obj.KeepBackground then
                    love.graphics.setColor(obj.BackgroundColour.R,obj.BackgroundColour.G,obj.BackgroundColour.B,obj.BackgroundColour.A)
                    local x,y,w,h = obj:ToScreenPixels(false,true)
                    love.graphics.rectangle("fill",x,y,w,h)
                    love.graphics.setColor(obj.Colour.R,obj.Colour.G,obj.Colour.B,obj.Colour.A)
                end
                if obj.FitImageInsideWH then
                    love.graphics.draw(
                        obj.ImageData.Image, x,y,obj.R,
                        sx*obj.ImageData.ScaleX, sy*obj.ImageData.ScaleY,
                        w*obj.AnchorX/obj.ImageData.ScaleX, h*obj.AnchorY/obj.ImageData.ScaleY
                    )
                else
                    love.graphics.draw(
                        obj.ImageData.Image, x,y,obj.R,
                        sx,sy,
                        w*obj.AnchorX/obj.ImageData.ScaleX, h*obj.AnchorY/obj.ImageData.ScaleY
                    )
                end
            else
                local x,y,w,h = obj:ToScreenPixels(false,true)
                love.graphics.rectangle("fill",x,y,w,h)
            end
            love.graphics.setScissor()
        end
    end
    mod.Frames[obj.Id] = obj
    insertFrame(obj)
    return obj
end

function mod:ScreenToWorld(x, y)
    return CameraPosition.X - x / CameraPosition.Z, CameraPosition.Y - y / CameraPosition.Z
end

function mod:TileToScreen(x,y) --convert tile units to screen units
    return floor(CameraPosition.X+x*CameraPosition.Z*32), floor(CameraPosition.Y+y*CameraPosition.Z*32)
end

function mod:ScreenToTile(x,y) --convert screen units to tile units
    return floor((x-CameraPosition.X)/CameraPosition.Z/32), floor((y-CameraPosition.Y)/CameraPosition.Z/32)
end

function mod:IsTilePositionValid(x,y,id,rev) --check if position is valid. If true it returns the tile id
    if id then
        if rev then
            return LD.Level.Tiles[x] and LD.Level.Tiles[x][y]  and LD.Level.Tiles[x][y] ~= id and LD.Level.Tiles[x][y] or false
        else
            return LD.Level.Tiles[x] and LD.Level.Tiles[x][y]  and LD.Level.Tiles[x][y] == id and id or false
        end
    else
        return LD.Level.Tiles[x] and LD.Level.Tiles[x][y] or false
    end
end

--messages

function mod:AddMessage(message,lifespan) --add a little message to the bottem of the screen
    local obj = {}
    obj.Id = GetId()
    obj.Text = message
    obj.Lifespan = lifespan
    obj.RunOutAt = os.clock()+lifespan
    obj.Y = 0
    obj.State = "alive" --alive = shown, fade = slowely fading away, dead = object has passed it's lifespan
    obj.Colour = {
        R = 1;
        G = 1;
        B = 1;
        A = 1;
    }
    function obj:Move(newY) --move message & move other messages as well
        obj.Y = newY
        for _,msg in pairs(mod.Messages) do
            if msg.Id ~= obj.Id then
                if msg.Y == obj.Y then
                    msg:Move(msg.Y+20)
                    return
                end
            end
        end
    end
    function obj:Update(newmsg,span) --update the text and timer
        obj.Text = newmsg and newmsg or obj.Text
        obj.Lifespan = span and span or obj.Lifespan
        obj.RunOutAt = os.clock()+obj.Lifespan
        obj:Move(24)
    end
    function obj:Kill(noFade) --forcefully end the object
        obj.State = noFade and "dead" or "fade"
    end
    function obj:SetColours(r,g,b)
        obj.Colour.R = r or obj.BackgroundColour.R
        obj.Colour.G = g or obj.BackgroundColour.G
        obj.Colour.B = b or obj.BackgroundColour.B
    end
    obj:Move(24) --update movement
    mod.Messages[obj.Id] = obj
    return obj
end

function mod:DrawTiles()
    local lvl, textures = LD.Level, Textures.TileTextures
    local tx, ty = mod:ScreenToTile(0,0)
    local bx, by = mod:ScreenToTile(WindowX,WindowY)
    tx, ty = max(1,tx), max(1,ty)
    bx, by = min(lvl.Size.X,bx), min(lvl.Size.Y,by)
    local dx, dy = mod:TileToScreen(tx,ty)
    local dw, dh = mod:TileToScreen(bx+1,by+1)
    dw, dh = dw-dx, dh-dy
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill",dx,dy,dw,dh)
    love.graphics.setColor(1,1,1)
    for x = tx,bx do
        for y = ty,by do
            local px, py = mod:TileToScreen(x,y)
            love.graphics.draw(
                textures[lvl.Tiles[x][y]],
                floor(px), floor(py), 0,
                CameraPosition.Z, CameraPosition.Z
            )
        end
    end
end

function mod:DrawHovers()
    if mod.DrawHoverTile then
        local x, y = mod:ScreenToTile(ToolSettings.MouseX,ToolSettings.MouseY)
        if mod:IsTilePositionValid(x,y) then
            x, y = mod:TileToScreen(x,y)
            if ToolSettings.EraserMode then
                love.graphics.setColor(1,0,0,.5)
                love.graphics.rectangle("fill",x,y,32 * CameraPosition.Z,32 * CameraPosition.Z)
            else
                love.graphics.setColor(1,1,1,.5)
                if type(ToolSettings.SelectedTile) == "string" then
                    love.graphics.draw(Textures.TileTextures[ToolSettings.SelectedTile], x, y, 0, CameraPosition.Z, CameraPosition.Z)
                elseif type(ToolSettings.SelectedTile) == "table" then --tilepack support
                    for x,yList in ipairs(ToolSettings.SelectedTile) do
                        if type(yList) == "table" then
                            for y,id in ipairs(yList) do
                                local mx, my = mod:ScreenToTile(ToolSettings.MouseX,ToolSettings.MouseY)
                                if mod:IsTilePositionValid(mx + x - 1, my + y - 1) then
                                    mx, my = mod:TileToScreen(mx + x - 1, my + y - 1)
                                    love.graphics.draw(Textures.TileTextures[id], mx, my, 0, CameraPosition.Z, CameraPosition.Z)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if mod.DrawTileRangeBackground then
        love.graphics.setColor(1,1,1,.5)
        for x = ToolSettings.TileRange.StartX,ToolSettings.TileRange.EndX, sign(ToolSettings.TileRange.EndX-ToolSettings.TileRange.StartX,1) do
            for y = ToolSettings.TileRange.StartY,ToolSettings.TileRange.EndY, sign(ToolSettings.TileRange.EndY-ToolSettings.TileRange.StartY,1) do
                local t = mod:IsTilePositionValid(x,y)
                if t and mod:IsTilePositionValid(x+ToolSettings.Translation.X, y+ToolSettings.Translation.Y) then
                    local x, y = mod:TileToScreen(x+ToolSettings.Translation.X, y+ToolSettings.Translation.Y)
                    love.graphics.draw(Textures.TileTextures[t],x,y,0,CameraPosition.Z, CameraPosition.Z)
                end
            end
        end
        local sx, sy = mod:TileToScreen(
            clamp(ToolSettings.TileRange.StartX+ToolSettings.Translation.X,1,LD.Level.Size.X),
            clamp(ToolSettings.TileRange.StartY+ToolSettings.Translation.Y,1,LD.Level.Size.Y)
        )
        local ex, ey = mod:TileToScreen(
            clamp(ToolSettings.TileRange.EndX+ToolSettings.Translation.X,1,LD.Level.Size.X),
            clamp(ToolSettings.TileRange.EndY+ToolSettings.Translation.Y,1,LD.Level.Size.Y)
        )
        local dx, dy = ex-sx, ey-sy
        if dx < 0 then
            sx = sx + 32*CameraPosition.Z
            dx = dx - 32*CameraPosition.Z
        else
            dx = dx + 32*CameraPosition.Z
        end
        if dy < 0 then
            sy = sy + 32*CameraPosition.Z
            dy = dy - 32*CameraPosition.Z
        else
            dy = dy + 32*CameraPosition.Z
        end
        love.graphics.setColor(0,1,1,.5)
        love.graphics.rectangle("fill",sx,sy,dx,dy)
    end
end

function mod:UpdateMessages(dt) --update the messages so their state updates
    local now = os.clock()
    for _,message in pairs(mod.Messages) do
        if message.State == "alive" and now > message.RunOutAt then
            message.State = "fade"
        end
        if message.State == "fade" then
            message.Colour.A = message.Colour.A - 0.5*dt
        end
        if message.Colour.A < 0 then
            message.State = "dead"
        end
    end
end

function mod:DrawMessages()
    for _,message in pairs(mod.Messages) do
        if message.State == "dead" then
            mod.Messages[message.Id] = nil
        else
            love.graphics.setColor(message.Colour.R,message.Colour.G,message.Colour.B,message.Colour.A)
            love.graphics.print(message.Text,10,WindowY-message.Y)
        end
    end
end

return mod
