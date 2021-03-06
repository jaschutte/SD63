
local graphics = require("loaders.graphics")
local windows = require("loaders.window")
local decode = require("loaders.decode")
local menuTextures = Textures.MenuTextures
local mod = {}
mod.Icons = {}
mod.TileTools = {}
mod.ItemTools = {}
mod.HUD = {}
mod.TileButton = nil
mod.ItemButton = nil

local function sign(x,f)
    return x == 0 and (f or 0) or x < 0 and -1 or 1
end

function mod:GenerateHUD(x,y,tile)
    graphics:MassDelete(mod.HUD)
    ToolSettings.TileRange.X, ToolSettings.TileRange.Y = 0, 0
    x, y = graphics:ScreenToWorld(x, y)
    if ToolSettings.TileRange.EndX < ToolSettings.TileRange.StartX then
        x = x - 220
    end
    if ToolSettings.TileRange.EndY < ToolSettings.TileRange.StartY then
        y = y - 82
    end
    x, y = x + 40, y + 40
    mod.HUD.Background = graphics:NewFrame(x,y,172,36,3,"Menu")
    mod.HUD.Background.AnchorX, mod.HUD.Background.AnchorY = 0, 0
    mod.HUD.Background:SetColours(.11,.11,.11)
    mod.HUD.Background.Collision.DetectHover = true
    mod.HUD.Background.Collision.OnEnter = nil
    mod.HUD.Background.Collision.OnLeave = nil
    mod.HUD.Background.ScreenPosition = false
    mod.HUD.Background.Visible = true
    mod.HUD.Close = graphics:NewFrame(x+18,y+18,32,32,4,"Menu")
    mod.HUD.Close:SetImage(Textures.HUDTextures.genericClose)
    mod.HUD.Close.Collision.DetectHover = true
    mod.HUD.Close.ScreenPosition = false
    mod.HUD.Close.Visible = true
    mod.HUD.Move = graphics:NewFrame(x+52,y+18,32,32,4,"Menu") --make this a button instead of a dragging icon
    mod.HUD.Move:SetImage(Textures.HUDTextures.genericMove)
    mod.HUD.Move.Collision.DetectHover = true
    mod.HUD.Move.ScreenPosition = false
    mod.HUD.Move.Visible = true
    mod.HUD.Fill = graphics:NewFrame(x+86,y+18,32,32,4,"Menu")
    mod.HUD.Fill:SetImage(Textures.HUDTextures.genericFill)
    mod.HUD.Fill.Collision.DetectHover = true
    mod.HUD.Fill.ScreenPosition = false
    mod.HUD.Fill.Visible = true
    mod.HUD.Save = graphics:NewFrame(x+120,y+18,32,32,4,"Menu")
    mod.HUD.Save:SetImage(Textures.HUDTextures.genericSave)
    mod.HUD.Save.Collision.DetectHover = true
    mod.HUD.Save.ScreenPosition = false
    mod.HUD.Save.Visible = true
    mod.HUD.Delete = graphics:NewFrame(x+154,y+18,32,32,4,"Menu")
    mod.HUD.Delete:SetImage(Textures.HUDTextures.genericDelete)
    mod.HUD.Delete.Collision.DetectHover = true
    mod.HUD.Delete.ScreenPosition = false
    mod.HUD.Delete.Visible = true
    mod.HUD.Close.Collision.OnClick = function()
        if tile then
            mod.TileTools.Area.Collision.OnClick()
            ToolSettings.UIBlockingMouse = false
        end
    end
    mod.HUD.Move.Collision.OnClick = function()
        ToolSettings.Translation.BeginX, ToolSettings.Translation.BeginY = graphics:ScreenToTile(ToolSettings.MouseX,ToolSettings.MouseY)
        ToolSettings.Translation.X, ToolSettings.Translation.Y = 0, 0
        ToolSettings.Translation.Enabled = true
    end
    mod.HUD.Fill.Collision.OnClick = function()
        if tile then
            for x = ToolSettings.TileRange.StartX, ToolSettings.TileRange.EndX, sign(ToolSettings.TileRange.EndX-ToolSettings.TileRange.StartX,1) do
                for y = ToolSettings.TileRange.StartY, ToolSettings.TileRange.EndY, sign(ToolSettings.TileRange.EndY-ToolSettings.TileRange.StartY,1) do
                    _G:SetTile(x,y,ToolSettings.SelectedTile)
                end
            end
        end
    end
    mod.HUD.Save.Collision.OnClick = function()
        decode:SaveTiles()
    end
    mod.HUD.Delete.Collision.OnClick = function()
        if tile then
            for x = ToolSettings.TileRange.StartX, ToolSettings.TileRange.EndX, sign(ToolSettings.TileRange.EndX-ToolSettings.TileRange.StartX,1) do
                for y = ToolSettings.TileRange.StartY, ToolSettings.TileRange.EndY, sign(ToolSettings.TileRange.EndY-ToolSettings.TileRange.StartY,1) do
                    _G:SetTile(x, y, "0")
                end
            end
            mod.TileTools.Area.Collision.OnClick()
            ToolSettings.UIBlockingMouse = false
        end
    end
end

function mod:MoveIcons(dx,dy)
    for _,icon in pairs(mod.Icons) do
        icon:Move(icon.X+dx,icon.Y+dy)
    end
end

function mod:GenerateTools(tileTools)
    graphics:MassDelete(mod.TileTools)
    graphics:MassDelete(mod.ItemTools)
    mod.TileTools = {}
    mod.ItemTools = {}
    if tileTools then
        mod.TileTools = {}
        --I can't put these infront of the if statement. Why not? I have no clue
        mod.TileTools.MoveUp = graphics:NewFrame(
            LD.Settings.ToolHolder.X+18,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-114,
            16,16,
            2,"Menu"
        )
        mod.TileTools.MoveUp:SetImage(Textures.MenuTextures.moveUp)
        mod.TileTools.MoveUp.ApplyZoom = false
        mod.TileTools.MoveUp.ScreenPosition = true
        mod.TileTools.MoveUp.Collision.DetectHover = true
        mod.TileTools.MoveUp.Collision.OnClick = function()
            mod:MoveIcons(0,-64)
        end
        mod.TileTools.MoveUp.Visible = true
        mod.TileTools.MoveDown = graphics:NewFrame(
            LD.Settings.ToolHolder.X+18,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-98,
            16,16,
            2,"Menu"
        )
        mod.TileTools.MoveDown:SetImage(Textures.MenuTextures.moveDown)
        mod.TileTools.MoveDown.ApplyZoom = false
        mod.TileTools.MoveDown.ScreenPosition = true
        mod.TileTools.MoveDown.Collision.DetectHover = true
        mod.TileTools.MoveDown.Collision.OnClick = function()
            mod:MoveIcons(0,64)
        end
        mod.TileTools.MoveDown.Visible = true
        --tile only
        mod.TileTools.Pencil = graphics:NewFrame(
            LD.Settings.ToolHolder.X+44,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-106,
            32,32,
            2,"Menu"
        )
        mod.TileTools.Pencil:SetImage(Textures.MenuTextures.toolPencil)
        mod.TileTools.Pencil.ApplyZoom = false
        mod.TileTools.Pencil.ScreenPosition = true
        mod.TileTools.Pencil.Collision.DetectHover = true
        mod.TileTools.Pencil.Collision.OnClick = function()
            love.mouse.setCursor(Textures.RawTextures.Cursors.pencil)
            ToolSettings.EraserMode = false
            graphics.DrawHoverTile = true
            graphics.DrawTileRangeBackground = false
            ToolSettings.TileTool = "normal"
            graphics:MassDelete(mod.HUD)
        end
        mod.TileTools.Pencil.Visible = true
        mod.TileTools.Eraser = graphics:NewFrame(
            LD.Settings.ToolHolder.X+78,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-106,
            32,32,
            2,"Menu"
        )
        mod.TileTools.Eraser:SetImage(Textures.MenuTextures.toolEraser)
        mod.TileTools.Eraser.ApplyZoom = false
        mod.TileTools.Eraser.ScreenPosition = true
        mod.TileTools.Eraser.Collision.DetectHover = true
        mod.TileTools.Eraser.Collision.OnClick = function()
            ToolSettings.EraserMode = true
            if ToolSettings.TileTool ~= "fill" then
                graphics.DrawHoverTile = true
                graphics.DrawTileRangeBackground = false
                graphics:MassDelete(mod.HUD)
                love.mouse.setCursor(Textures.RawTextures.Cursors.pencil)
                ToolSettings.TileTool = "normal"
            else
                love.mouse.setCursor(Textures.RawTextures.Cursors.bucketRemove)
            end
        end
        mod.TileTools.Eraser.Visible = true
        mod.TileTools.Area = graphics:NewFrame(
            LD.Settings.ToolHolder.X+112,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-106,
            32,32,
            2,"Menu"
        )
        mod.TileTools.Area:SetImage(Textures.MenuTextures.toolArea)
        mod.TileTools.Area.ApplyZoom = false
        mod.TileTools.Area.ScreenPosition = true
        mod.TileTools.Area.Collision.DetectHover = true
        mod.TileTools.Area.Collision.OnClick = function()
            love.mouse.setCursor()
            graphics:MassDelete(mod.HUD)
            graphics.DrawHoverTile = false
            graphics.DrawTileRangeBackground = true
            ToolSettings.TileRange.Stage = 1
            ToolSettings.TileTool = "area"
        end
        mod.TileTools.Area.Visible = true
        mod.TileTools.Fill = graphics:NewFrame(
            LD.Settings.ToolHolder.X+146,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-106,
            32,32,
            2,"Menu"
        )
        mod.TileTools.Fill:SetImage(Textures.MenuTextures.toolBucketFill)
        mod.TileTools.Fill.ApplyZoom = false
        mod.TileTools.Fill.ScreenPosition = true
        mod.TileTools.Fill.Collision.DetectHover = true
        mod.TileTools.Fill.Collision.OnClick = function()
            love.mouse.setCursor(Textures.RawTextures.Cursors.bucket)
            graphics.DrawHoverTile = false
            graphics.DrawTileRangeBackground = false
            ToolSettings.TileTool = "fill"
            graphics:MassDelete(mod.HUD)
        end
        mod.TileTools.Fill.Visible = true
        mod.TileTools.ChangeCatagory = graphics:NewFrame(LD.Settings.ToolHolder.X+LD.Settings.ToolHolder.SizeX/2,2,144,54,2,"Menu")
        mod.TileTools.ChangeCatagory.ApplyZoom = false
        mod.TileTools.ChangeCatagory.ScreenPosition = true
        mod.TileTools.ChangeCatagory.AnchorY = 0
        mod.TileTools.ChangeCatagory:SetImage(Textures.MenuTextures["THEME/TILES/"..ToolSettings.TileCatagory])
        mod.TileTools.ChangeCatagory.Collision.DetectHover = true
        mod.TileTools.ChangeCatagory.Collision.OnClick = function()
            local frames = {}
            local mainFrame = graphics:NewFrame(WindowX/2,WindowY/2,298,118,99,"Menu")
            mainFrame.ApplyZoom = false
            mainFrame.ScreenPosition = true
            mainFrame:SetColours(.15,.15,.15)
            mainFrame.Visible = true
            mainFrame.Collision.DetectHover = true
            mainFrame.Collision.OnEnter = function() end
            mainFrame.Collision.OnLeave = function() end
            frames[#frames+1] = mainFrame
            for cat = 100,650,50 do --generate theme buttons
                local button = graphics:NewFrame(mainFrame.X-111+(cat/50-2)%4*74,WindowY/2-42.5+math.floor((cat/50-2)/4)*29,72,27,100,"Menu")
                button.ApplyZoom = false
                button.ScreenPosition = true
                button.AnchorX = 0.5
                button.AnchorY = 0.5
                button.FitImageInsideWH = true
                button:SetImage(Textures.MenuTextures["THEME/TILES/"..cat])
                button.Collision.DetectHover = true
                button.Collision.OnClick = function()
                    ToolSettings.TileCatagory = cat
                    mod:GenerateIcons(true)
                    mod:GenerateTools(true)
                    graphics:MassDelete(frames)
                    ClickBeforeEvents.ThemeAfterPress = nil
                end
                button.Visible = true
                frames[#frames+1] = button
            end
            --generate saved tiles 1 button
            local button = graphics:NewFrame(mainFrame.X-111,WindowY/2+44.5,72,27,100,"Menu")
            button.ApplyZoom = false
            button.ScreenPosition = true
            button.AnchorX = 0.5
            button.AnchorY = 0.5
            button.FitImageInsideWH = true
            button:SetImage(Textures.MenuTextures["THEME/TILES/Saved1"])
            button.Collision.DetectHover = true
            button.Collision.OnClick = function()
                ToolSettings.TileCatagory = "Saved1"
                mod:GenerateIcons(true)
                mod:GenerateTools(true)
                graphics:MassDelete(frames)
                ClickBeforeEvents.ThemeAfterPress = nil
            end
            button.Visible = true
            frames[#frames+1] = button

            ClickBeforeEvents.ThemeAfterPress = function(mx,my,b)
                if not mainFrame:CheckCollision(mx,my) then
                    graphics:MassDelete(frames)
                    ClickBeforeEvents.ThemeAfterPress = nil
                end
            end
        end
        mod.TileTools.ChangeCatagory.Visible = true
    else
        mod.ItemTools.MoveUp = graphics:NewFrame(
            LD.Settings.ToolHolder.X+18,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-114,
            16,16,
            2,"Menu"
        )
        mod.ItemTools.MoveUp:SetImage(Textures.MenuTextures.moveUp)
        mod.ItemTools.MoveUp.ApplyZoom = false
        mod.ItemTools.MoveUp.ScreenPosition = true
        mod.ItemTools.MoveUp.Collision.DetectHover = true
        mod.ItemTools.MoveUp.Collision.OnClick = function()
            mod:MoveIcons(0,-64)
        end
        mod.ItemTools.MoveUp.Visible = true
        mod.ItemTools.MoveDown = graphics:NewFrame(
            LD.Settings.ToolHolder.X+18,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-98,
            16,16,
            2,"Menu"
        )
        mod.ItemTools.MoveDown:SetImage(Textures.MenuTextures.moveDown)
        mod.ItemTools.MoveDown.ApplyZoom = false
        mod.ItemTools.MoveDown.ScreenPosition = true
        mod.ItemTools.MoveDown.Collision.DetectHover = true
        mod.ItemTools.MoveDown.Collision.OnClick = function()
            mod:MoveIcons(0,64)
        end
        mod.ItemTools.MoveDown.Visible = true
        --tiles only
        mod.ItemTools.Move = graphics:NewFrame(
            LD.Settings.ToolHolder.X+44,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-106,
            32,32,
            2,"Menu"
        )
        mod.ItemTools.Move:SetImage(Textures.HUDTextures.genericMove)
        mod.ItemTools.Move.ApplyZoom = false
        mod.ItemTools.Move.ScreenPosition = true
        mod.ItemTools.Move.Collision.DetectHover = true
        mod.ItemTools.Move.Collision.OnClick = function()
            ToolSettings.EraserMode = false
            ToolSettings.RememberTileTool = ToolSettings.ItemTool
            ToolSettings.ItemTool = "move"
        end
        mod.ItemTools.Move.Visible = true
        mod.ItemTools.Eraser = graphics:NewFrame(
            LD.Settings.ToolHolder.X+78,LD.Settings.ToolHolder.Y+LD.Settings.ToolHolder.SizeY-106,
            32,32,
            2,"Menu"
        )
        mod.ItemTools.Eraser:SetImage(Textures.MenuTextures.toolEraser)
        mod.ItemTools.Eraser.ApplyZoom = false
        mod.ItemTools.Eraser.ScreenPosition = true
        mod.ItemTools.Eraser.Collision.DetectHover = true
        mod.ItemTools.Eraser.Collision.OnClick = function()
            ToolSettings.EraserMode = true
        end
        --the change catagory button for items
        mod.ItemTools.ChangeCatagory = graphics:NewFrame(LD.Settings.ToolHolder.X+LD.Settings.ToolHolder.SizeX/2,2,144,54,2,"Menu")
        mod.ItemTools.ChangeCatagory.ApplyZoom = false
        mod.ItemTools.ChangeCatagory.ScreenPosition = true
        mod.ItemTools.ChangeCatagory.AnchorY = 0
        mod.ItemTools.ChangeCatagory:SetImage(Textures.MenuTextures["THEME/ITEMS/"..ToolSettings.ItemCatagory])
        mod.ItemTools.ChangeCatagory.Collision.DetectHover = true
        mod.ItemTools.ChangeCatagory.Collision.OnClick = function()
            local window = windows:NewWindow(WindowX/2 - 75, WindowY/2 - 30, 150, 77)
            for i = 0, 100, 50 do
                local catagory = graphics:NewFrame(0, 0, 72, 27)
                catagory.AnchorX, catagory.AnchorY = 0, 0
                catagory:SetImage(Textures.MenuTextures["THEME/ITEMS/"..i])
                catagory.FitImageInsideWH = true
                catagory.Collision.DetectHover = true
                catagory.Collision.OnClick = function()
                    ToolSettings.ItemCatagory = i
                    mod.ItemTools.ChangeCatagory:SetImage(Textures.MenuTextures["THEME/ITEMS/"..i])
                    mod:GenerateIcons()
                    window:Close()
                end
                window:Attach(catagory, i <= 50 and i/50 * 74 + 2 or 2, i == 100 and 48 or 18)
            end
            local catagory = graphics:NewFrame(0, 0, 72, 27)
            catagory.AnchorX, catagory.AnchorY = 0, 0
            catagory:SetImage(Textures.MenuTextures["THEME/ITEMS/saved #2"])
            catagory.FitImageInsideWH = true
            catagory.Collision.DetectHover = true
            window:Attach(catagory, 76, 48)
            window:SetTitle("Select A Catagory")
        end
        mod.ItemTools.ChangeCatagory.Visible = true
        mod.ItemTools.Eraser.Visible = true
    end
end

function mod:GenerateIcons(tileIcons)
    graphics:MassDelete(mod.Icons)
    mod.Icons = {}
    if tileIcons then
        local cat = Catagories.TileCatagories[ToolSettings.TileCatagory]
        if cat then --if catagory exists, draw the button/icon thingies
            local offset = LD.Settings.ToolHolder.X+(LD.Settings.ToolHolder.SizeX-2)%34/2
            local xMax = math.floor(LD.Settings.ToolHolder.SizeX/34)
            for i,id in ipairs(cat) do
                local icon = graphics:NewFrame(offset+34*((i-1)%xMax)+18,LD.Settings.ToolHolder.Y+76+34*math.floor((i-1)/xMax),32,32,2,"Menu")
                icon:SetImage(Textures.TileTextures[id])
                icon:SetColours(.3,.3,.3,1,true)
                icon.Collision.DetectHover = true
                icon.FitImageInsideWH = true
                icon.KeepBackground = true
                icon.ScreenPosition = true
                icon.ApplyZoom = false
                icon.KeepImageScale = true
                icon.Clips = {
                    AnchorX = 0;
                    AnchorY = 0;
                    X = offset;
                    Y = LD.Settings.ToolHolder.Y+58;
                    W = math.floor(LD.Settings.ToolHolder.SizeX/34)*34+2;
                    H = LD.Settings.ToolHolder.SizeY-190;
                }
                icon.Collision.OnClick = function()
                    if ToolSettings.TileTool == "fill" then
                        love.mouse.setCursor(Textures.RawTextures.Cursors.bucket)
                    end
                    ToolSettings.EraserMode = false
                    ToolSettings.SelectedTile = id
                end
                icon.Visible = true
                mod.Icons[i] = icon
            end
        elseif ToolSettings.TileCatagory == "Saved1" then
            local cat = decode:ReadSavedTiles() --get the saved tiles
            if not cat then
                graphics:AddMessage("Failed to load saves tiles, no tiles could be collected.", 1)
                return
            end
            local offset = LD.Settings.ToolHolder.X+(LD.Settings.ToolHolder.SizeX-2)%68/2
            local xMax = math.floor(LD.Settings.ToolHolder.SizeX/68)
            for i,collection in ipairs(cat) do
                local icon = graphics:NewFrame(offset+68*((i-1)%xMax)+18,LD.Settings.ToolHolder.Y+76+34*math.floor((i-1)/xMax),32,32,2,"Menu")
                icon:SetImage(Textures.TileTextures[collection.Show])
                icon:SetColours(.3,.3,.3,1,true)
                icon.Collision.DetectHover = true
                icon.FitImageInsideWH = true
                icon.KeepBackground = true
                icon.ScreenPosition = true
                icon.ApplyZoom = false
                icon.Clips = {
                    AnchorX = 0;
                    AnchorY = 0;
                    X = offset;
                    Y = LD.Settings.ToolHolder.Y+58;
                    W = math.floor(LD.Settings.ToolHolder.SizeX/34)*34+2;
                    H = LD.Settings.ToolHolder.SizeY-190;
                }
                icon.Collision.OnClick = function()
                    if ToolSettings.TileTool == "fill" then
                        love.mouse.setCursor(Textures.RawTextures.Cursors.bucket)
                    end
                    ToolSettings.EraserMode = false
                    ToolSettings.SelectedTile = collection.Struct
                end
                icon.Visible = true
                mod.Icons[i] = icon

                --delete tile button
                icon = graphics:NewFrame(offset+68*((i-1)%xMax)+52,LD.Settings.ToolHolder.Y+76+34*math.floor((i-1)/xMax),32,32,2,"Menu")
                icon:SetImage(Textures.HUDTextures.genericClose)
                icon:SetColours(.3,.3,.3,1,true)
                icon.Collision.DetectHover = true
                icon.FitImageInsideWH = true
                icon.KeepBackground = true
                icon.ScreenPosition = true
                icon.ApplyZoom = false
                icon.KeepImageScale = true
                icon.Clips = {
                    AnchorX = 0;
                    AnchorY = 0;
                    X = offset;
                    Y = LD.Settings.ToolHolder.Y+58;
                    W = math.floor(LD.Settings.ToolHolder.SizeX/34)*34+2;
                    H = LD.Settings.ToolHolder.SizeY-190;
                }
                icon.Collision.OnClick = function()
                    --delete logic
                    decode:DeleteTiles(collection.Id)
                    mod:GenerateIcons(true)
                end
                icon.Visible = true
                mod.Icons[#cat+i] = icon
            end
        end
    else
        local cat = Catagories.ItemCatagories[ToolSettings.ItemCatagory] --get the catagory
        if cat then
            local offset = LD.Settings.ToolHolder.X+(LD.Settings.ToolHolder.SizeX-2)%34/2
            local xMax = math.floor(LD.Settings.ToolHolder.SizeX/34)
            for i,id in ipairs(cat) do --ipairs to keep looping consistent
                local icon = graphics:NewFrame(offset+34*((i-1)%xMax)+18,LD.Settings.ToolHolder.Y+76+34*math.floor((i-1)/xMax),32,32,2,"Menu")
                icon:SetImage(Textures.ItemTextures[id])
                icon:SetColours(.3,.3,.3,1,true)
                icon.Collision.DetectHover = true
                icon.FitImageInsideWH = true
                icon.KeepBackground = true
                icon.ScreenPosition = true
                icon.ApplyZoom = false
                icon.KeepImageScale = true
                icon.Clips = {
                    AnchorX = 0;
                    AnchorY = 0;
                    X = offset;
                    Y = LD.Settings.ToolHolder.Y+58;
                    W = math.floor(LD.Settings.ToolHolder.SizeX/34)*34+2;
                    H = LD.Settings.ToolHolder.SizeY-190;
                }
                icon.Collision.OnClick = function()
                    ToolSettings.EraserMode = false
                    ToolSettings.SelectedItem = id
                    if not ToolSettings.CtrlDown then
                        ToolSettings.ItemTool = "normal"
                    end
                end
                icon.Visible = true
                mod.Icons[i] = icon
            end
        end
    end
end

function mod:InitMenu()
    --top buttons
    local menuButton = graphics:NewFrame(48,32,64,32,0,"Menu")
    menuButton:SetImage(menuTextures.menuButton)
    menuButton.ApplyZoom = false
    menuButton.ScreenPosition = true
    menuButton.Collision.DetectHover = true
    menuButton.Visible = true
    local tilesButton = graphics:NewFrame(112,32,64,32,0,"Menu")
    tilesButton:SetImage(menuTextures.tilesButton)
    tilesButton.ApplyZoom = false
    tilesButton.ScreenPosition = true
    tilesButton.Collision.DetectHover = true
    tilesButton.Visible = true
    local itemsButton = graphics:NewFrame(176,32,64,32,0,"Menu")
    itemsButton:SetImage(menuTextures.itemsButton)
    itemsButton.ApplyZoom = false
    itemsButton.ScreenPosition = true
    itemsButton.Collision.DetectHover = true
    itemsButton.Visible = true
    local cameraButton = graphics:NewFrame(240,32,64,32,0,"Menu")
    cameraButton:SetImage(menuTextures.cameraButton)
    cameraButton.ApplyZoom = false
    cameraButton.ScreenPosition = true
    cameraButton.Collision.DetectHover = true
    cameraButton.Visible = true
    --button inside of menu
    local menuButtons = {}
    menuButtons.CourseButton = graphics:NewFrame(48,64,64,32,0,"Menu")
    menuButtons.CourseButton:SetImage(menuTextures.courseButton)
    menuButtons.CourseButton.ApplyZoom = false
    menuButtons.CourseButton.ScreenPosition = true
    menuButtons.CourseButton.Collision.DetectHover = true
    menuButtons.CourseButton.Visible = true
    menuButtons.ResizeButton = graphics:NewFrame(48,96,64,32,0,"Menu")
    menuButtons.ResizeButton:SetImage(menuTextures.resizeButton)
    menuButtons.ResizeButton.ApplyZoom = false
    menuButtons.ResizeButton.ScreenPosition = true
    menuButtons.ResizeButton.Collision.DetectHover = true
    menuButtons.ResizeButton.Visible = true
    menuButtons.SaveButton = graphics:NewFrame(48,128,64,32,0,"Menu")
    menuButtons.SaveButton:SetImage(menuTextures.saveButton)
    menuButtons.SaveButton.ApplyZoom = false
    menuButtons.SaveButton.ScreenPosition = true
    menuButtons.SaveButton.Collision.DetectHover = true
    menuButtons.SaveButton.Visible = true
    menuButtons.LoadButton = graphics:NewFrame(48,160,64,32,0,"Menu")
    menuButtons.LoadButton:SetImage(menuTextures.loadButton)
    menuButtons.LoadButton.ApplyZoom = false
    menuButtons.LoadButton.ScreenPosition = true
    menuButtons.LoadButton.Collision.DetectHover = true
    menuButtons.LoadButton.Visible = true
    menuButtons.TestButton = graphics:NewFrame(48,192,64,32,0,"Menu")
    menuButtons.TestButton:SetImage(menuTextures.testButton)
    menuButtons.TestButton.ApplyZoom = false
    menuButtons.TestButton.ScreenPosition = true
    menuButtons.TestButton.Collision.DetectHover = true
    menuButtons.TestButton.Visible = true
    menuButtons.ResetButton = graphics:NewFrame(48,224,64,32,0,"Menu")
    menuButtons.ResetButton:SetImage(menuTextures.resetButton)
    menuButtons.ResetButton.ApplyZoom = false
    menuButtons.ResetButton.ScreenPosition = true
    menuButtons.ResetButton.Collision.DetectHover = true
    menuButtons.ResetButton.Visible = true
    menuButtons.ModButton = graphics:NewFrame(48,256,64,32,0,"Menu")
    menuButtons.ModButton:SetImage(menuTextures.modsButton)
    menuButtons.ModButton.ApplyZoom = false
    menuButtons.ModButton.ScreenPosition = true
    menuButtons.ModButton.Collision.DetectHover = true
    menuButtons.ModButton.Visible = true
    menuButtons.SettingsButton = graphics:NewFrame(48,288,64,32,0,"Menu")
    menuButtons.SettingsButton:SetImage(menuTextures.settingsButton)
    menuButtons.SettingsButton.ApplyZoom = false
    menuButtons.SettingsButton.ScreenPosition = true
    menuButtons.SettingsButton.Collision.DetectHover = true
    menuButtons.SettingsButton.Visible = true
    --tile & items holders
    local toolHolder = graphics:NewFrame(
        LD.Settings.ToolHolder.X,LD.Settings.ToolHolder.Y,
        LD.Settings.ToolHolder.SizeX,LD.Settings.ToolHolder.SizeY,
        0,"Menu"
    )
    toolHolder:SetColours(0.15625,0.15625,0.15625)
    toolHolder.AnchorX = 0
    toolHolder.AnchorY = 0
    toolHolder.ScreenPosition = true
    toolHolder.Collision.DetectHover = true
    toolHolder.Collision.OnEnter = function() end
    toolHolder.Collision.OnLeave = function() end
    toolHolder.ApplyZoom = false
    local iconHolder = graphics:NewFrame(
        LD.Settings.ToolHolder.X+(LD.Settings.ToolHolder.SizeX-2)%34/2,LD.Settings.ToolHolder.Y+58,
        math.floor(LD.Settings.ToolHolder.SizeX/34)*34+2,LD.Settings.ToolHolder.SizeY-190,
        1,"Menu"
    )
    iconHolder:SetColours(0.234375,0.234375,0.234375)
    iconHolder.AnchorX = 0
    iconHolder.AnchorY = 0
    iconHolder.ScreenPosition = true
    iconHolder.ApplyZoom = false
    --functionality
    menuButton.Collision.OnClick = function()
        for _,button in pairs(menuButtons) do
            button.Visible = not button.Visible
        end
    end
    --functionality/icons
    local function removeTiles()
        graphics:MassDelete(mod.Icons)
        graphics:MassDelete(mod.TileTools)
        graphics:MassDelete(mod.HUD)
        love.mouse.setCursor()
        toolHolder.Visible = false
        iconHolder.Visible = false
        graphics.DrawHoverTile = false
        graphics.DrawTileRangeBackground = false
        graphics.DrawTileSelection = false
        --print("hmhm?")
        ToolSettings.TileRange.Stage = 1
        ToolSettings.CurrentDisplay = false
    end

    local function removeItems()
        graphics:MassDelete(mod.Icons)
        graphics:MassDelete(mod.TileTools)
        graphics:MassDelete(mod.ItemTools)
        love.mouse.setCursor()
        toolHolder.Visible = false
        iconHolder.Visible = false
        ToolSettings.CurrentDisplay = false
    end

    itemsButton.Collision.OnClick = function()
        if ToolSettings.CurrentDisplay then
            if ToolSettings.CurrentDisplay == "Items" then
                removeItems()
            else
                removeTiles()
                mod:GenerateIcons(false)
                mod:GenerateTools(false)
                toolHolder.Visible = true
                iconHolder.Visible = true
                ToolSettings.CurrentDisplay = "Items"
            end
        else
            mod:GenerateIcons(false)
            mod:GenerateTools(false)
            toolHolder.Visible = true
            iconHolder.Visible = true
            ToolSettings.CurrentDisplay = "Items"
        end
    end

    tilesButton.Collision.OnClick = function()
        if ToolSettings.CurrentDisplay then
            if ToolSettings.CurrentDisplay == "Tiles" then
                removeTiles()
            else
                removeItems()
                mod:GenerateIcons(true)
                mod:GenerateTools(true)
                toolHolder.Visible = true
                iconHolder.Visible = true
                if ToolSettings.SelectedTile == "0" or not Textures.TileTextures[ToolSettings.SelectedTile] then
                    ToolSettings.SelectedTile = "2K"
                end
                if ToolSettings.TileTool == "normal" then
                    mod.TileTools.Pencil.Collision.OnClick()
                elseif ToolSettings.TileTool == "area" then
                    mod.TileTools.Area.Collision.OnClick()
                elseif ToolSettings.TileTool == "fill" then
                    mod.TileTools.Fill.Collision.OnClick()
                end
                ToolSettings.CurrentDisplay = "Tiles"
            end
        else
            mod:GenerateIcons(true)
            mod:GenerateTools(true)
            toolHolder.Visible = true
            iconHolder.Visible = true
            if ToolSettings.SelectedTile == "0" or not Textures.TileTextures[ToolSettings.SelectedTile] then
                ToolSettings.SelectedTile = "2K"
            end
            if ToolSettings.TileTool == "normal" then
                mod.TileTools.Pencil.Collision.OnClick()
            elseif ToolSettings.TileTool == "area" then
                mod.TileTools.Area.Collision.OnClick()
            elseif ToolSettings.TileTool == "fill" then
                mod.TileTools.Fill.Collision.OnClick()
            end
            ToolSettings.CurrentDisplay = "Tiles"
        end
    end

    iconHolder.Collision.OnScroll = function(delta)
        mod:MoveIcons(0,delta*10*LD.Settings.ScrollSpeed)
    end
    --resize
    mod.OnResize = function()
        toolHolder:Move(LD.Settings.ToolHolder.X,LD.Settings.ToolHolder.Y)
        toolHolder:Resize(LD.Settings.ToolHolder.SizeX,LD.Settings.ToolHolder.SizeY)
        iconHolder:Move(LD.Settings.ToolHolder.X+(LD.Settings.ToolHolder.SizeX-2)%34/2,LD.Settings.ToolHolder.Y+58)
        iconHolder:Resize(math.floor(LD.Settings.ToolHolder.SizeX/34)*34+2,LD.Settings.ToolHolder.SizeY-190)
        if ToolSettings.CurrentDisplay then
            mod:GenerateIcons(ToolSettings.CurrentDisplay == "Tiles")
            mod:GenerateTools(ToolSettings.CurrentDisplay == "Tiles")
        end
    end
    mod.TileButton = tilesButton
    mod.ItemButton = itemsButton
end

return mod
