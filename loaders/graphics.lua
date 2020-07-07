
local mod = {}

local threads = require("loaders.threading")
local floor, min, max = math.floor, math.min, math.max
mod.Frames = {}
mod.FramesOnZ = {}
mod.Messages = {}
mod.EditableTexts = {}
mod.DrawHoverTile = false
mod.DrawTileSelection = false
mod.TotalFrames = 0
mod._RECALC_ON_SCRN_EVERY = 20
--mod.ItemSpriteBatch = love.graphics.newSpriteBatch() --group all items in here maybe?

--[[
    Add a scrollbar class;
    properties:
        ScrollW = W;
        ScrollH = H;
        ScrollUpDown = true;
        ScrollLeftRight = false;
    functions:
        :Influence(frame) --the influenced frame moves with the scrollbar
]]

local function polyPoint(px, py, verts) --modified version from the one available on the love2d forums
    local next, collision = 3, false
    assert(#verts%2 == 0, "Not a valid polygon!")
    for current = 1, #verts, 2 do --loop every second entry
        next = current + 2
        if next >= #verts then
            next = 1
        end
        local vcx, vcy = verts[current], verts[current + 1] --get the coords
        local vnx, vny = verts[next], verts[next + 1]
        if (((vcy >= py and vny < py) or (vcy < py and vny >= py)) and
            (px < (vnx-vcx)*(py-vcy) / (vny-vcy)+vcx)) then
            collision = not collision
        end
    end
    return collision
end

local function rotate(x, y, ox, oy, a) --rotate a point around an origin
    local sA, cA = math.sin(a), math.cos(a)
    local oX, oY = x - ox, y - oy
    local rX, rY = oX * cA - oY * sA, oX * sA + oY * cA
    return rX + ox, rY + oy
end

local function clamp(x,y,z) --limit x between y and z
    return (x > y and x or y) < z and (x > y and x or y) or z
end

local function sign(x,f) --get the sign of an number. Option to replace 0 with f
    return x == 0 and (f or 0) or x < 0 and -1 or 1
end

local function drawFunc(obj) --fixed it yeya
    if obj.Visible then
        love.graphics.setColor(obj.Colour.R,obj.Colour.G,obj.Colour.B,obj.Colour.A)
        if obj.Clips.W ~= 0 and obj.Clips.H ~= 0 then
            love.graphics.setScissor( --set the clips
                obj.Clips.X - obj.Clips.W * obj.Clips.AnchorX,
                obj.Clips.Y - obj.Clips.H * obj.Clips.AnchorY,
                obj.Clips.W,
                obj.Clips.H
            )
        end
        local x, y, w, h = obj:ToScreenPixels() --uses anchoring by default
        if obj.ImageData.Image then
            local sX, sY = obj.ApplyZoom and CameraPosition.Z or 1, obj.ApplyZoom and CameraPosition.Z or 1
            if obj.KeepBackground then
                love.graphics.setColor(obj.BackgroundColour.R,obj.BackgroundColour.G,obj.BackgroundColour.B,obj.BackgroundColour.A)
                love.graphics.rectangle("fill", x, y, w * sX, h * sY)
                love.graphics.setColor(obj.Colour.R,obj.Colour.G,obj.Colour.B,obj.Colour.A)
            end
            if obj.FitImageInsideWH then
                sX, sY = sX * obj.ImageData.ScaleX, sY * obj.ImageData.ScaleY
                if obj.KeepImageScale then
                    if obj.ImageData.W > obj.ImageData.H then
                        sY = sY * obj.ImageData.H / obj.ImageData.W
                    else
                        sX = sX * obj.ImageData.W / obj.ImageData.H
                    end
                end
            end
            if obj.Mirror then
                sX = sX * -1
            end
            x, y = obj:ToScreenPixels(true)
            love.graphics.draw(obj.ImageData.Image, x, y, obj.R, sX, sY, obj.AnchorX * obj.ImageData.W, obj.AnchorY * obj.ImageData.H)
        else
            love.graphics.rectangle("fill", x, y, w, h)
        end
        love.graphics.setScissor()
    end
end

local function insertFrame(fr) --inserts a frame carefully, doesn't ruin layering
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
                if fr.Layer == "Menu" then
                    if frame.Layer == "Menu" then
                        if fr.Z < frame.Z then
                            placed = true
                            temp[id] = fr
                            temp[id+1] = frame
                        else
                            temp[id] = frame
                        end
                    else
                        temp[id] = frame
                    end
                else
                    if frame.Layer == "Menu" then
                        temp[id] = frame
                    else
                        if fr.Z < frame.Z then
                            placed = true
                            temp[id] = fr
                            temp[id+1] = frame
                        else
                            temp[id] = frame
                        end
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
    mod.TotalFrames = #mod.FramesOnZ
end

local function removeFrame(fr) --removes a frame carefully, so it doesn't messup layering
    local found = false
    for id,frame in ipairs(mod.FramesOnZ) do
        if found then
            mod.FramesOnZ[id-1] = frame
            mod.FramesOnZ[id] = nil
        end
        if frame.Id == fr.Id then
            mod.FramesOnZ[id] = nil
            found = true
        end
    end
    mod.TotalFrames = #mod.FramesOnZ
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
        for _,func in pairs(frame.AponDeletion) do --invoke the deletion method
            func(frame)
        end
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
    mod.TotalFrames = #mod.FramesOnZ
end

function mod:KeepNonAlpha(rawText) --returns a new image with only the opaque pixels in white
    if not rawText then
        print("Oi we aint going to send empty images around okay? It's just a waste of space..")
        return
    end
    local texture = rawText:clone()
    texture:mapPixel(function(x, y, r, g, b, a)
        if a == 0 then
            return 0, 0, 0, 0
        else
            return 1, 1, 1, 1
        end
    end)
    return texture
end

function mod:SaveCheckPixel(rawText, px, py) --savely checks what colour the pixel is on the texture
    local c, r, g, b, a = pcall(function()
        return rawText:getPixel(px, py)
    end)
    if c then --if the getPixel was performed succesfully do this:
        return r, g, b, a
    end
end

function mod:NewFrame(x,y,w,h,z,layer,ax,ay)
    local obj = {}
    obj.X = x or 0
    obj.Y = y or 0
    obj.W = w or 0
    obj.H = h or 0
    obj.Z = z or 0
    obj.Layer = layer or "r"
    obj.Mirror = false
    obj.R = 0
    obj.AnchorX = ax or 0.5
    obj.AnchorY = ay or 0.5
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
    obj.KeepImageScale = false
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
    obj.SecondPressWillSelectUnder = false
    obj.OnScreen = true
    obj.ApplyZoom = true
    obj.ScreenPosition = false --if false it will use CameraPosition
    obj.AponDeletion = {} --invokes when this frame is being deleted, USE GETID() AS A KEY!!
    obj.CollisionTexture = nil
    function obj:SetCollisionTexture(rawText) --must be fed a raw texture inorder to work properly
        self.CollisionTexture = rawText and mod:KeepNonAlpha(rawText) or nil --this is unused.
    end
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
    function obj:CheckCollision(mx,my, accurateCollision)
        local x,y, w,h = obj:ToScreenPixels()
        if accurateCollision then --if raw check bounds alone will do
            local cX, cY = x + w/2, y + h/2
            local corners = {}
            corners[1], corners[2] = rotate(x, y, cX, cY, self.R)
            corners[3], corners[4] = rotate(x + w, y, cX, cY, self.R)
            corners[5], corners[6] = rotate(x + w, y + h, cX, cY, self.R)
            corners[7], corners[8] = rotate(x, y + h, cX, cY, self.R)
            return polyPoint(mx, my, corners)
        else
            return mx > x and mx < x+w and my > y and my < y+h
        end
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
    function obj:ChangeZ(z, layer)
        obj.Z = z or obj.Z
        obj.Layer = layer or obj.Layer
        removeFrame(obj)
        insertFrame(obj)
    end
    function obj:Move(x,y)
        x = x or obj.X
        y = y or obj.Y
        obj.X, obj.Y = x, y
        if not obj.ScreenPosition and obj.Layer ~= "Menu" then
            local tX, tY = mod:ScreenToWorld(0, 0)
            local bX, bY = mod:ScreenToWorld(WindowX, WindowY)
            obj.OnScreen = obj.X+obj.W*obj.AnchorX >= tX and obj.X-obj.W*obj.AnchorX <= bX and obj.Y+obj.H*obj.AnchorY >= tY and obj.Y-obj.H*obj.AnchorY <= bY
        end
    end
    function obj:TileToItem(x,y)
        obj:Move(floor(x*32),floor(y*32))
    end
    function obj:Destroy()
        for _,func in pairs(obj.AponDeletion) do --invoke the deletion method
            func(obj)
        end
        removeFrame(obj)
        mod.Frames[obj.Id] = nil
        return nil
    end
    function obj:ToScreenPixels(ignoreAnchors, applyScale)
        local x, y = obj.X, obj.Y
        local w, h = obj.W, obj.H
        if obj.ApplyZoom then
            x, y = x * CameraPosition.Z, y * CameraPosition.Z
            w, h = w * CameraPosition.Z, h * CameraPosition.Z
        end
        if not obj.ScreenPosition then
            x, y = x+CameraPosition.X, y+CameraPosition.Y
        end
        if not ignoreAnchors then
            x, y = x-w*obj.AnchorX, y-h*obj.AnchorY
        end
        return floor(x),floor(y), floor(w),floor(h)
    end
    function obj:Draw()
        drawFunc(obj)
    end
    mod.Frames[obj.Id] = obj
    insertFrame(obj)
    return obj
end

function mod:NewText(x,y,w,h,z,layer,ax,ay)
    local obj = self:NewFrame(x,y,w,h,z,layer,ax,ay)
    obj.Text = "Hello, World!"
    obj.FontColour = {R = 0, G = 0, B = 0, A = 1}
    obj.Font = Fonts.FontObjs.InconsolataMedium[14]
    obj.ScreenPosition = true --Textfields can't be accesable in worldspace, mainly due to clips
    obj.ApplyZoom = false
    obj.SizePerCharacter = {W = obj.Font:getWidth(" "), H = obj.Font:getHeight(" ")}
    obj.TextOffsetX = 0
    obj.TextOffsetY = 0
    obj.Hint = {
        Enabled = false;
        Obj = nil;
    }
    obj._Lines = {}
    obj.TextSelection = {
        Start = 0;
        End = 0;
        R = 0;
        G = 1;
        B = 1;
        A = 0.5;
        _Draw = {};
    }
    function obj:SetHint(enabled, hint)
        self.Hint.Enabled = enabled or self.Hint.Enabled
        hint = hint or ""
        if self.Hint.Enabled then --yes I'm creating a textlabel in a textlabel
            hint = hint.." " --add a space so it looks prettier
            self.Hint.Obj = mod:NewText(
                0, 0,
                self.Font:getWidth(hint), self.Font:getHeight(hint),
                self.Z + 9999, "Menu"
            )
            self.Hint.Obj.Text = hint
            self.Hint.Obj:SetColours(unpack(Colours.Standard.HintColour))
            self.Hint.Obj.FontColour = {
                R = Colours.Standard.HintTextColour[1] or 0;
                G = Colours.Standard.HintTextColour[2] or 0;
                B = Colours.Standard.HintTextColour[3] or 0;
                A = Colours.Standard.HintTextColour[4] or 1;
            }
            self.Hint.Obj.ScreenPosition = true
            self.Hint.Obj.ApplyZoom = false
            self.Collision.DetectHover = true
            self.Collision.OnEnter = function()
                if self.Hint.ThreadId then --if there's still an active thread remove it
                    threads:RemoveThread(self.Hint.ThreadId)
                    self.Hint.ThreadId = nil
                end
                self.Hint.ThreadId = threads:NewThread(function(self) --create a new thread
                    while true do
                        local x, y = ToolSettings.MouseX, ToolSettings.MouseY
                        threads:Wait(.5)
                        if x == ToolSettings.MouseX and y == ToolSettings.MouseY then
                            if self and self.Hint and self.Hint.Obj then
                                if self:CheckCollision(ToolSettings.MouseX, ToolSettings.MouseY) then
                                    self.Hint.Obj:Move(ToolSettings.MouseX, ToolSettings.MouseY - self.Hint.Obj.H)
                                    self.Hint.Obj.Visible = true
                                end
                            end
                        elseif self.Hint.Obj.Visible then --if mouse moved, make the hint invisible
                            self.Hint.Obj.Visible = false
                        end
                    end
                end, self)
                threads:StartThread(self.Hint.ThreadId) --don't forget to start the thread lol
            end
            self.Collision.OnLeave = function()
                if self and self.Hint and self.Hint.Obj then --if the object still exists
                    if self.Hint.ThreadId then --if there's still an thread active, REMOVE IT
                        threads:RemoveThread(self.Hint.ThreadId)
                        self.Hint.ThreadId = nil
                    end
                    self.Hint.Obj.Visible = false
                end
            end
            self.AponDeletion[GetId()] = function()
                if self and self.Hint and self.Hint.Obj then
                    self.Hint.Obj:Destroy()
                end
            end
        end
    end
    function obj:SetSelection(s, e) --if the text changes this must be changed as well, THIS ISN'T AUTOMATIC!
        --broken, fix this later, not now
    end
    function obj:TextToPosition(cPos, mode) --modes: a = absolute, objpos + textpos | c = character, returns the character in this line | r = relative (default), textpos
        local sub = self.Text:sub(1, cPos)
        local breaks = sub:reverse():find("\n")
        local x = breaks and breaks - 1 or #sub --I really don't want to use :reverse() but I suppose it's required (tried starting search at -1)
        local y = #sub:gsub("[^%c\n]", "")
        if mode == "a" then
            return self.X + x * self.SizePerCharacter.W, self.Y + y * self.SizePerCharacter.H
        elseif mode == "c" then
            return x, y
        else
            return x * self.SizePerCharacter.W, y * self.SizePerCharacter.H
        end
    end
    function obj:GetTextByPosition(x, y) --requires TEXTPOS (relative) position
        for i = 1,#self.Text do
            local gx, gy = self:TextToPosition(i)
            if x == gx and gy == y then
                return self:sub(i, i), i
            end
        end
    end
    function obj:SetFont(name, size)
        if Fonts.FontObjs[name] then
            size = clamp(size - size%Fonts.FontIncrement, Fonts.FontMin, Fonts.FontMax)
            obj.Font = Fonts.FontObjs[name][size]
            obj.SizePerCharacter.W, obj.SizePerCharacter.H = obj.Font:getWidth(" "), obj.Font:getHeight(" ")
        else
            print("Sorry, but we don't allow blackmarket fonts here. Come back once you got the legal stuff!")
        end
    end
    obj.AfterDraw = nil --this will be run after normal draw has been called (still within the scissors though)
    function obj:Insert(pos, str)
        local from = self.Text:sub(1, pos)
        local to = self.Text:sub(pos + 1)
        self.Text = from..str..to
    end
    function obj:Draw() --override the draw command
        drawFunc(self)
        love.graphics.setFont(self.Font)
        love.graphics.setScissor(self.X, self.Y, self.W, self.H)
        love.graphics.setColor(self.FontColour.R, self.FontColour.B, self.FontColour.G, self.FontColour.A)
        love.graphics.print(self.Text, self.X + self.SizePerCharacter.W * self.TextOffsetX, self.Y + self.SizePerCharacter.H * self.TextOffsetY)
        love.graphics.setColor(self.TextSelection.R, self.TextSelection.B, self.TextSelection.G, self.TextSelection.A)
        for _,draw in pairs(self.TextSelection._Draw) do --for the textselection
            love.graphics.rectangle("fill", self.X + draw[1], self.Y + draw[2], draw[3], draw[4])
        end
        if self.AfterDraw then self.AfterDraw() end
        love.graphics.setScissor()
    end
    obj.AnchorX, obj.AnchorY = 0, 0
    obj:Move(x, y)
    obj:Resize(w, h)
    local meta = setmetatable({},{
        __index = function(_, key)
            return obj[key]
        end;
        __newindex = function(_, key, val)
            obj[key] = val
            local _line = {"", 0, 0}
            if key == "Text" then --auto update the lines if text is modified
                obj._Lines = {}
                for c in obj.Text:gmatch(".") do --collect all of the lines
                    _line[2] = _line[2] + 1
                    if c == "\n" then
                        obj._Lines[#obj._Lines+1] = {Start = _line[3], Str = _line[1]}
                        _line[1] = ""
                        _line[3] = _line[2]
                    else
                        _line[1] = _line[1]..c
                    end
                end
                obj._Lines[#obj._Lines+1] = {Start = _line[3], Str = _line[1]}
            end
        end
    })
    return meta
end

function mod:NewEditableText(x,y,w,h,z,layer,ax,ay)
    local obj = self:NewText(x,y,w,h,z,layer,ax,ay)
    obj.AnchorX, obj.AnchorY = 0, 0
    obj.IsFocussed = false
    obj.Cursor = 1
    obj.OnCompletion = nil --this will be fired when the editing of this text got completed (arguments: (bool): returnPressed)
    obj.Text = ""
    obj.Settings = {
        MultiLine = false;
        MaxLines = -1; --has no effect is multiline is disabled, -1 means no limit
        NumberOnly = false;
        RoundNumber = -1; --has no effect is numneronly is disabled, -1 means no rounding, if enabled multiline gets disabled
        ReadOnly = false; --this disabled the editing, making it static
        Bounds = {
            Enabled = false;
            Min = 0;
            Max = 360;
        };
    }
    obj.Collision.OnClick = function()
        if not obj.Settings.ReadOnly then
            obj.IsFocussed = os.clock() + 0.5
            ToolSettings.BlockInput = obj
        end
    end
    obj.Collision.DetectHover = true
    obj.Collision.OnEnter = nil
    obj.Collision.OnLeave = function()
        if obj.IsFocussed then
            obj.IsFocussed = false
            ToolSettings.BlockInput = false
            if obj.Settings.NumberOnly then
                local last = obj.Text:sub(-1, -1)
                if last == "." or last == "-" then
                    obj.Text = obj.Text.."0"
                end
                local n = tonumber(obj.Text) or 0
                if obj.Settings.RoundNumber >= 0 then
                    n = math.floor(n*(10^obj.Settings.RoundNumber)+.5)/(10^obj.Settings.RoundNumber) --rounding with customizable decimals
                end
                if obj.Settings.Bounds.Enabled then
                    n = clamp(n, obj.Settings.Bounds.Min, obj.Settings.Bounds.Max)
                end
                obj.Text = tostring(n)
            end
            if obj.OnCompletion then
                obj.OnCompletion()
            end
        end
    end
    obj.AfterDraw = function()
        if obj.IsFocussed then --add the mouse cursor when editing text
            if obj.IsFocussed > 0 then --if positive draw
                local x, y = obj:TextToPosition(obj.Cursor, "a")
                love.graphics.setColor(obj.FontColour.R, obj.FontColour.B, obj.FontColour.G, obj.FontColour.A)
                love.graphics.line(x, y, x, y + obj.SizePerCharacter.H)
            end
            if obj.IsFocussed > 0 and os.clock() >= obj.IsFocussed then --set the clock to negative
                obj.IsFocussed = -os.clock() - 0.5
            end
            if obj.IsFocussed <= 0 and -os.clock() <= obj.IsFocussed then --set the clock to positive
                obj.IsFocussed = os.clock() + 0.5
            end
        end
    end
    obj.AponDeletion[obj.Id] = function() --add this so it also gets removed from EditableTexts
        mod.EditableTexts[obj.Id] = nil
    end
    self.EditableTexts[obj.Id] = obj
    return obj
end

function mod:WorldToScreen(x, y)
    return (CameraPosition.X + x)*CameraPosition.Z, (CameraPosition.Y + y)*CameraPosition.Z
end

function mod:ScreenToWorld(x, y)
    return (-CameraPosition.X + x) / CameraPosition.Z, (-CameraPosition.Y + y) / CameraPosition.Z
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
    love.graphics.setColor(0,0,.8)
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

function mod:OnKeyPress(key)
    key = love.keyboard.getScancodeFromKey(key) --make it listen to universal signals
    local textbox = ToolSettings.BlockInput

    if textbox then
        if key == "left" then --a switch command would be usefull now..
            textbox.Cursor = math.max(0, textbox.Cursor - 1)
        elseif key == "right" then
            textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
        elseif key == "down" then --there are better methods of doing up and down but this works fine so I don't see the need
            local offset
            for _,line in ipairs(textbox._Lines) do --loop through the lines from top to bottom
                if offset then
                    textbox.Cursor = math.min(line.Start + #line.Str, line.Start + offset)
                    break
                elseif textbox.Cursor >= line.Start and textbox.Cursor <= line.Start + #line.Str then
                    offset = textbox.Cursor - line.Start
                end
            end
        elseif key == "up" then
            local offset
            for y = #textbox._Lines, 0, -1 do --loop through the lines from bottom to top
                local line = textbox._Lines[y]
                if line then
                    if offset then
                        textbox.Cursor = math.min(line.Start + #line.Str, line.Start + offset)
                        break
                    elseif textbox.Cursor >= line.Start and textbox.Cursor <= line.Start + #line.Str then
                        offset = textbox.Cursor - line.Start --get the offset
                    end
                end
            end
        elseif key == "delete" then
            local from = textbox.Text:sub(1, textbox.Cursor)
            local to = textbox.Text:sub(textbox.Cursor + 2)
            textbox.Text = from..to
        elseif key == "backspace" then
            local from = textbox.Text:sub(1, math.max(0, textbox.Cursor - 1))
            local to = textbox.Text:sub(textbox.Cursor + 1)
            textbox.Text = from..to
            textbox.Cursor = math.max(0, textbox.Cursor - 1)
        elseif key == "tab" then
            local from = textbox.Text:sub(1, math.max(0, textbox.Cursor))
            local to = textbox.Text:sub(textbox.Cursor + 1)
            textbox.Text = from.."    "..to --not adding \t because that just breaks everything lul
            textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 4)
        elseif key == "return" then
            if textbox.Settings.MultiLine then
                local from = textbox.Text:sub(1, textbox.Cursor)
                local to = textbox.Text:sub(textbox.Cursor + 1)
                if textbox.Settings.MaxLines ~= -1 then --if it exceeds max lines, do nothing
                    local _, lines = textbox.Text:gsub("\n", "\n")
                    lines = lines + 1
                    if lines < textbox.Settings.MaxLines then
                        textbox.Text = from.."\n"..to
                        textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
                    end
                else
                    textbox.Text = from.."\n"..to
                    textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
                end
            else
                if textbox.Settings.NumberOnly then
                    local last = textbox.Text:sub(-1, -1)
                    if last == "." or last == "-" then
                        textbox.Text = textbox.Text.."0"
                    end
                    local n = tonumber(textbox.Text) or 0
                    if textbox.Settings.RoundNumber >= 0 then
                        n = math.floor(n*(10^textbox.Settings.RoundNumber)+.5)/(10^textbox.Settings.RoundNumber) --rounding with customizable decimals
                    end
                    if textbox.Settings.Bounds.Enabled then
                        n = clamp(n, textbox.Settings.Bounds.Min, textbox.Settings.Bounds.Max)
                    end
                    textbox.Text = tostring(n)
                end
                textbox.IsFocussed = false
                ToolSettings.BlockInput = false
                if textbox.OnCompletion then
                    textbox.OnCompletion(true)
                end
            end
        end
    end
end

function mod:OnText(key) --luckily this doesn't fire when OnKeyPress fires, so it won't cause trouble
    local textbox = ToolSettings.BlockInput
    if textbox then
        local from = textbox.Text:sub(1, textbox.Cursor)
        local to = textbox.Text:sub(textbox.Cursor + 1)
        if textbox.Settings.NumberOnly then
            local n = tonumber(key)
            if n then --check if it's a number
                textbox.Text = from..key..to
                textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
            elseif key == "." then --or a dot
                textbox.Text = from:gsub("%.", "")..key..to:gsub("%.", "") --remove all old dots and insert a new one here
                textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
            elseif key == "-" then --or a minus
                local hasMinus = textbox.Text:find("-")
                if hasMinus then
                    local new, found = textbox.Text:gsub("-", "")
                    textbox.Text = new
                    textbox.Cursor = math.max(0, textbox.Cursor - found)
                else
                    textbox.Text = "-"..textbox.Text
                    textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
                end
            end
        else
            textbox.Text = from..key..to
            textbox.Cursor = math.min(#textbox.Text, textbox.Cursor + 1)
        end
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
