
_G.WindowX, _G.WindowY = love.window.getMode()
love.window.setTitle("Super Designer 63")
love.window.setMode(WindowX,WindowY,{resizable = true, minwidth=500, minheight=375, vsync = true})
love.graphics.setBackgroundColor(0,0,.5)

_G.CameraPosition = {X = 0, Y = 0, Z = 1} --Z is camera zoom; z<1 = zoomout; x>1 = zoomin
_G.Catagories = {
    ItemCatagories = {};
    TileCatagories = {};
}
_G.Textures = {
    MenuTextures = {};
    ItemSkins = {};
    TileTextures = {};
    ItemTextures = {};
    HUDTextures = {};
    RawTextures = {
        Cursors = {};
        Items = {};
    };
}
_G.ClickAfterEvents = {}
_G.ClickBeforeEvents = {}
_G.GetId = setmetatable({id = 0}, {__call = function(tab) tab.id = tab.id + 1 return tab.id end})
_G.Lerp = function(x,y,t)
    return (1-t)*x + t*y
end
_G.PrintTable = function(...)
    for _,t in pairs({...}) do
        local s = ""
        for k,v in pairs(t) do s = s..tostring(k)..": "..tostring(v).."\t" end
        if s ~= "" then
            print(s)
        end
    end
end
_G.ToolSettings = {
    BlockInput = false;
    CurrentDisplay = false;
    UIBlockingMouse = false;
    EraserMode = false;
    ItemTool = "move";
    TileTool = "normal";
    RememberTileTool = "normal";
    ShiftDown = false;
    CtrlDown = false;
    SelectedTile = "2K";
    SelectedItem = 1;
    TileCatagory = 100;
    ItemCatagory = 0;
    MouseX = 0;
    MouseY = 0;
    ItemGrid = {
        X = 16;
        Y = 16;
    };
    MouseDown = false;
    Translation = {
        BeginX = 0;
        BeginY = 0;
        X = 0;
        Y = 0;
        Enabled = false;
    };
    TileRange = {
        StartX = 0;
        StartY = 0;
        EndX = 0;
        EndY = 0;
        Stage = 1; --1 = select start, 2 = select end, 3 = finish
    };
    ItemRange = {
        StartX = 0;
        StartY = 0;
        EndX = 0;
        EndY = 0;
        Stage = 1;
    };
}
_G.LD = {
    Level = {
        Size = {X = 0, Y = 0};
        Tiles = {};
        Items = {};
    };
    Settings = {
        CameraSpeed = 1;
        ScrollSpeed = 15;
        Mods = {};
        ToolHolder = {
            SizeX = 200;
            SizeY = WindowY;
            X = WindowX-210;
            Y = 0;
        }
    };
}
_G.Colours = { --was planning to make a metatable out of this so it automaticly returns the 3 values. Then decided it wasn't worth the effort. Oh well~
    Standard = {
        BoolYes = {0, .5, 0};
        BoolNo = {.5, 0, 0};
        HintColour = {0, 0, 0, .5};
        HintTextColour = {.8, .8, .8};
    };
    WindowUI = {
        TopBar = {.2, .2, .2};
        MainBg = {.3, .3, .3};
        Text = {0, 0, 0};
        Tab = {.25, .25, .25};
        ReadOnly = {0, 0, 0, 0};
        NormalField = {.35, .35, .35};
        TrippleOptionField1 = {.45, .45, .45};
        TrippleOptionField2 = {.6, .2, 0};
        TrippleOptionField3 = {0, .3, .6};
        DoubleOptionField1 = {.6, 0, 0};
        DoubleOptionField2 = {0, .3, .6};
        HeaderTextColour = {.8, .8, .8};
        SubTextColour = {.7, .7, .7};
        NormalTextColour = {1, 1, 1};
    }
}
_G.Fonts = {
    FontIncrement = 2;
    FontMin = 10;
    FontMax = 50;
    FontNames = {
        "Inconsolata-Bold";
        "Inconsolata-Black";
        "Inconsolata-ExtraLight";
        "Inconsolata-Light";
        "Inconsolata-Medium";
        "Inconsolata-Regular";
        "Inconsolata-SemiBold";
    };
    FontObjs = {};
    Fallback = love.graphics.newFont(12);
}

local graphics = require("loaders.graphics")
local menu = require("loaders.menu")
local threads = require("loaders.threading")
local tools = require("loaders.toolhandler")
local items = require("loaders.items")
local decoding = require("loaders.decode")
local windows = require("loaders.window")
local DIR = tostring(io.popen("CD"):read())

function love.load()
    local texts = {
        "Nice day outside isn't it?", "h", "Created by Trump himself.", "Pew! Pew! Boom!",
        "Boop", "Nyeheheh", "So cool", "Do you know the way?\nI'm lost..\nplease...",
        "This is an level designer, WHAT ON EARTH IS IT LOADING!?", "Have you read my book yet?",
        "Ngl, sm63 is pretty cool, I wish there was an level designer for it though...",
        "Did you know?\nJe ne parle pas français.\nJE PARLE BAGUETTE!", "There's wayyy to many of these texts...",
        "Hello!", "Kabieeeeem", "sans undertale xD xD xD XDDDDD SO FUNNY", "Sponsored by Temmie Flakes!",
        "What if... I doubled the 63 in sm63 and then added 1. Maybe there's a game named like that.",
        "Mario & Mario: Mario's inside story.", "Building a space station."
    }
    math.randomseed(os.time())
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, WindowX, WindowY)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Loading textures...\n"..texts[math.random(1, #texts)], 10, 10)
    --load textures
    local dir = "textures/menuTexturesDark"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.MenuTextures[texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    local dir = "textures/HUD"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.HUDTextures[texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    --tile textures
    local dir = "textures/tiles"
    Textures.TileTextures["0"] = love.graphics.newImage("textures/airTile.png")
    for _,folder in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local subDir = dir.."/"..folder
        Catagories.TileCatagories[tonumber(folder)] = {}
        for _,texture in ipairs(love.filesystem.getDirectoryItems(subDir)) do
            local group = tonumber(folder)
            if string.sub(texture,1,1) == "m" then
                local id = tonumber(texture:sub(2,-5))
                Textures.TileTextures[texture:sub(1,-5)] = love.graphics.newImage(subDir.."/"..texture)
                Catagories.TileCatagories[group][id] = texture:sub(1,-5)
            else
                local num = tonumber(texture:sub(1,-5))
                local id = string.char(math.floor((group+num)/75)+49)..string.char((group+num)-math.floor((group+num)/75)*75+49)
                Textures.TileTextures[id] = love.graphics.newImage(subDir.."/"..texture)
                Catagories.TileCatagories[group][num] = id
            end
        end
    end
    --item textures
    local dir = "textures/items"
    for _,folder in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local subDir = dir.."/"..folder
        Catagories.ItemCatagories[tonumber(folder)] = {}
        for _,texture in ipairs(love.filesystem.getDirectoryItems(subDir)) do
            local group = tonumber(folder)
            local num = tonumber(texture:sub(1,-5))
            Textures.ItemTextures[group + num] = love.graphics.newImage(subDir.."/"..texture)
            Textures.RawTextures.Items[group + num] = love.image.newImageData(subDir.."/"..texture)
            Catagories.ItemCatagories[group][num] = group + num
        end
    end
    --cursor icons
    local dir = "textures/cursorIcons"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        local x, y = 0, 0
        if texture == "bucket.png" or texture == "bucketRemove.png" then
            x, y = 5, 25
        elseif texture == "pencil.png" then
            x, y = 4, 27
        end
        Textures.RawTextures.Cursors[texture:sub(1,-5)] = love.mouse.newCursor(love.image.newImageData(dir.."/"..texture),x,y)
    end
    --themes
    local dir = "textures/themes/tiles"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.MenuTextures["THEME/TILES/"..texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    local dir = "textures/themes/items"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.MenuTextures["THEME/ITEMS/"..texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    --skins
    local dir = "textures/skins"
    for _,item in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.ItemSkins[item] = {}
        for _,skinNum in pairs(love.filesystem.getDirectoryItems(dir.."/"..item)) do
            Textures.ItemSkins[item][skinNum:sub(1,-5)] = love.graphics.newImage(dir.."/"..item.."/"..skinNum)
        end
    end
    --load font
    for _,name in pairs(Fonts.FontNames) do
        local sub = name:gsub("-","")
        Fonts.FontObjs[sub] = {}
        for i = Fonts.FontMin, Fonts.FontMax, Fonts.FontIncrement do
            Fonts.FontObjs[sub][i] = love.graphics.newFont("fonts/"..name..".ttf", i)
        end
    end
    love.keyboard.setKeyRepeat(true)
    --setup default Level
    for x = 1,50 do
        LD.Level.Tiles[x] = {}
        for y = 1,30 do
            LD.Level.Tiles[x][y] = "0"
        end
    end
    LD.Level.Size = {X = 50, Y = 30}
    menu:InitMenu()
    --[[for i = 1,2000 do --a fun little test
        items:New(math.random(1, 40), math.random(1, 1028), math.random(1, 1028))
    end--]]
end

function love.resize(sx,sy)
    local dx, dy = sx-WindowX, sy-WindowY
    WindowX, WindowY = sx, sy
    LD.Settings.ToolHolder.SizeY = LD.Settings.ToolHolder.SizeY+dy
    LD.Settings.ToolHolder.X = LD.Settings.ToolHolder.X+dx
    --update menu
    menu.OnResize()
end

function love.mousereleased(mx,my,b)
    ToolSettings.MouseDown = false
    tools:MouseUp(b)
    windows:MouseUp(b)
    --OnUp event
    for i = #graphics.FramesOnZ,1,-1 do
        local frame = graphics.FramesOnZ[i]
        if frame then
            if frame.Visible and frame.Collision.IsDown and frame.Collision.OnUp then
                frame.Collision.IsDown = false
                frame.Collision.OnUp(mx, my, b)
            end
        end
    end
end

local clickIgnoreList = {List = {}, Last = nil}
function love.mousepressed(mx,my,b)
    --afterclick
    for _,event in pairs(ClickBeforeEvents) do
        event(mx,my,b)
    end
    --update toolsettings
    ToolSettings.MouseDown = true
    tools:MouseDown(b)
    --OnClick events
    local _hitSomething
    for i = #graphics.FramesOnZ,1,-1 do
        local frame = graphics.FramesOnZ[i]
        if frame then
            if frame.Visible and frame.Collision.OnClick then
                if frame:CheckCollision(mx, my, true) then
                    if not frame.SecondPressWillSelectUnder then
                        frame.Collision.IsDown = true
                        frame.Collision.OnClick(mx,my,b)
                        _hitSomething = true
                        break
                    elseif not clickIgnoreList.List[frame.Id] then
                        clickIgnoreList.List[frame.Id] = true
                        frame.Collision.IsDown = true
                        frame.Collision.OnClick(mx,my,b)
                        _hitSomething = true
                        break
                    else
                        clickIgnoreList.Last = frame
                    end
                end
            end
        else
            print("Warning: Id "..i.." is nil!")
        end
    end
    if not _hitSomething then
        clickIgnoreList.List = {}
        if clickIgnoreList.Last then
            clickIgnoreList.Last.Collision.IsDown = true
            clickIgnoreList.Last.Collision.OnClick(mx,my,b)
            clickIgnoreList.Last = nil
        end
    end
    --afterclick
    for _,event in pairs(ClickAfterEvents) do
        event(mx,my,b)
    end
end

function love.wheelmoved(_,delta)
    local mx, my = love.mouse.getPosition()
    for _,frame in ipairs(graphics.FramesOnZ) do
        if frame.Visible and frame.Collision.OnScroll then
            local x,y, w,h = frame:ToScreenPixels()
            if mx > x and mx < x+w and my > y and my < y+h then
                frame.Collision.OnScroll(delta)
                break
            end
        end
    end
end

function love.mousemoved(mx,my)
    ToolSettings.MouseX, ToolSettings.MouseY = mx, my
    windows:OnMove(mx, my) --update the window libaray
    --frame collision detection
    local oldFrames = {}
    local block = false
    for id,frame in pairs(graphics.Frames) do
        if frame.Visible and frame.Collision.DetectHover and frame.Collision.IsBeingHovered then
            frame.Collision.IsBeingHovered = false
            oldFrames[id] = frame
        end
    end
    for i = #graphics.FramesOnZ,1,-1 do
        local frame = graphics.FramesOnZ[i]
        if frame then
            if frame.Visible and frame.Collision.DetectHover then
                if frame:CheckCollision(mx,my) then
                    frame.Collision.IsBeingHovered = true
                    if not oldFrames[frame.Id] then
                        if frame.Collision.OnEnter then
                            frame.Collision.OnEnter(frame,mx,my)
                        end
                        block = true --check if ui is blocking tile grid
                    end
                    break
                end
            end
        else
            print("Warning: Id "..i.." is nil!")
        end
    end
    for _,frame in pairs(oldFrames) do
        if not frame.Collision.IsBeingHovered then
            if frame.Collision.OnLeave then
                frame.Collision.OnLeave(frame,mx,my)
            end
            ToolSettings.UIBlockingMouse = false
        end
    end
    ToolSettings.UIBlockingMouse = block or ToolSettings.UIBlockingMouse
    --
end

function love.textinput(key)
    graphics:OnText(key)
    if not ToolSettings.BlockInput then --(again) don't move when busy editing text
        if key == "-" then
            CameraPosition.Z = math.max(CameraPosition.Z - .2,.4)
        elseif key == "=" then
            CameraPosition.Z = math.min(CameraPosition.Z + .2,2)
        end
    end
end

function love.keypressed(key)
    if key == "lshift" then
        ToolSettings.ShiftDown = true
    end
    if key == "lctrl" then
        ToolSettings.CtrlDown = true
    end
    graphics:OnKeyPress(key) --update the textboxes
    if not ToolSettings.BlockInput then --if a textbox is being editing, ignore the signal
        tools:OnKeyPress(key) --update the tools library
    end
end

function love.keyreleased(key)
    if key == "lshift" then
        ToolSettings.ShiftDown = false
    end
    if key == "lctrl" then
        ToolSettings.CtrlDown = false
    end
    tools:OnKeyRelease(key) --update the tools library
end

local fr = graphics:NewFrame(0, 0, 20, 20)
local test = graphics:NewScrollbar(200, 300, 100, 200)
test:SetColours(.2, .2, .2)
test:Attach(fr, 0, 0)
test:Move()
test.Visible = true

local _FRAMES_UNTIL_RECACL = 0
function love.update(dt)
    --test:Move(ToolSettings.MouseX - 10, ToolSettings.MouseY - 10)
    --camera
    local cX, cY = CameraPosition.X, CameraPosition.Y
    local ch = 500*dt*LD.Settings.CameraSpeed
    if not ToolSettings.BlockInput then --don't move if the textbox is being edited
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            CameraPosition.Y = CameraPosition.Y + ch
        end
        if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
            CameraPosition.Y = CameraPosition.Y - ch
        end
        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            CameraPosition.X = CameraPosition.X + ch
        end
        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            CameraPosition.X = CameraPosition.X - ch
        end
    end
    --update frames if camera moved
    _FRAMES_UNTIL_RECACL = _FRAMES_UNTIL_RECACL + 1
    if _FRAMES_UNTIL_RECACL >= graphics._RECALC_ON_SCRN_EVERY then
        _FRAMES_UNTIL_RECACL = 0--]]
        if CameraPosition.X ~= cX or CameraPosition.y ~= cY then
            local tX, tY = graphics:ScreenToWorld(0, 0)
            local bX, bY = graphics:ScreenToWorld(WindowX, WindowY)
            for _,frame in ipairs(graphics.FramesOnZ) do
                if not frame.OnScreen then
                    if frame.ScreenPosition then
                        frame.OnScreen = true
                    elseif frame.Layer == "Menu" then
                        frame.OnScreen = true
                    end
                end
                if not frame.ScreenPosition and frame.Layer ~= "Menu" then
                    frame.OnScreen = frame.X+frame.W*frame.AnchorX >= tX and frame.X-frame.W*frame.AnchorX <= bX and frame.Y+frame.H*frame.AnchorY >= tY and frame.Y-frame.H*frame.AnchorY <= bY
                end
            end
        end
    end
    --update modules
    items:Update()
    tools:Update()
    graphics:UpdateMessages(dt)
    threads:OnFrame()
end

function love.draw()
    graphics:DrawTiles()
    graphics:DrawHovers()
    for _,frame in ipairs(graphics.FramesOnZ) do
        if frame.OnScreen and frame.Visible then
            frame:Draw()
        end
    end
    love.graphics.setFont(Fonts.Fallback)
    graphics:DrawMessages()
    --display framerate
    love.graphics.setColor(1,1,1)
    love.graphics.print("FPS: "..love.timer.getFPS(),5,WindowY-20)
end
