
local wxLua = require("wx")
local mod = {}

local function mathclamp(x,min,max)
    return math.max(min,math.min(x,max))
end
local green = wxLua.wxColour(0,127,0)
local blue = wxLua.wxColour(0,0,154)
local grey = wxLua.wxColour(80,80,80)
local darkGrey = wxLua.wxColour(60,60,60)
local pureGreen = wxLua.wxColour(0,255,0)
local pureRed = wxLua.wxColour(255,0,0)
local white = wxLua.wxColour(220,220,220)
local dark = wxLua.wxColour(40,40,40)

mod.Visible = false

function mod:init()
    self.X = 0
    self.Y = 0
    self.Width = 415
    self.Height = 300
    self.ItemId = nil
    self.ItemImage = nil
    self.Dialog = wxLua.wxDialog(wxLua.NULL,wxLua.wxID_ANY,"Item Properties",wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height),wxLua.wxDEFAULT_DIALOG_STYLE)--,wxLua.wxCLOSE_BOX)
    self.MainLayer = wxLua.wxPanel(self.Dialog,wxLua.wxID_ANY,wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height))
    self.Dialog:SetBackgroundColour(dark)
    self.Image = wxLua.wxStaticBitmap(self.Dialog,wxLua.wxID_ANY,wxLua.wxBitmap("textures/tiles/cave/3.png"),wxLua.wxPoint(0,0),wxLua.wxSize(32,32))
    self.wxFont = wxLua.wxFont(8,wxLua.wxFONTFAMILY_DEFAULT,wxLua.wxFONTSTYLE_NORMAL,wxLua.wxFONTWEIGHT_NORMAL)
    --[[self.Test:SetCellEditor(0,1,wxLua.wxGridCellFloatEditor(0,2)) --number
    self.Test:SetCellRenderer(0,1,wxLua.wxGridCellFloatRenderer(0,2))
    self.Test:SetCellEditor(1,1,wxLua.wxGridCellBoolEditor()) --boolean
    self.Test:SetCellRenderer(1,1,wxLua.wxGridCellBoolRenderer())
    self.Test:SetCellEditor(2,1,wxLua.wxGridCellChoiceEditor({"a","b","c"}))--choice
    self.Dialog:Show(true)--]]
end

function mod:Populate(item)
    self.ItemImage = {ImageFileFromItemID.Regular[item.iID],item.Image:getWidth(),item.Image:getHeight()}
    if item.iID == "9" then
        item.SaveParams[14] = math.floor(mathclamp(item.SaveParams[14],1,31))
        self.ItemImage[1] = ImageFileFromItemID.Skins["9"][item.SaveParams[14]]
    elseif item.iID == "71" then
        item.SaveParams[9] = math.floor(mathclamp(item.SaveParams[9],1,9))
        self.ItemImage[1] = ImageFileFromItemID.Skins["71"][item.SaveParams[9]]
    elseif item.iID == "7" then
        item.SaveParams[13] = math.floor(mathclamp(item.SaveParams[13],1,3))
        self.ItemImage[1] = ImageFileFromItemID.Skins["7+8"][item.SaveParams[13]]
    elseif item.iID == "8" then
        item.SaveParams[8] = math.floor(mathclamp(item.SaveParams[8],1,3))
        self.ItemImage[1] = ImageFileFromItemID.Skins["7+8"][item.SaveParams[8]]
    elseif item.iID == "39" then
        item.SaveParams[6] = math.floor(mathclamp(item.SaveParams[6],1,6))
        self.ItemImage[1] = ImageFileFromItemID.Skins["39"][item.SaveParams[6]]
    end
    local params, desc = item.SaveParams, item.SaveDescription
    if self.ItemId ~= item.Id then
        if self.Grid then
            self.Grid:Destroy()
            self.Grid = nil
        end
        self.ItemId = item.Id
        self.Height = math.ceil(#params/2)*18+88
        self.Grid = wxLua.wxGrid(self.MainLayer,1,wxLua.wxPoint(0,0),wxLua.wxSize(self.Width,self.Height))
        self.Grid:SetDefaultCellTextColour(white)
        self.Grid:SetDefaultCellBackgroundColour(dark)
        self.Grid:SetGridLineColour(darkGrey)
        self.Grid:SetColLabelSize(0)
        self.Grid:SetRowLabelSize(0)
        self.Grid:SetDefaultColSize(130)
        self.Grid:EnableDragGridSize(false)
        self.Grid:SetDefaultCellOverflow(false)
        self.Grid:CreateGrid(math.ceil(#params/2),4)
        self.Grid:SetColSize(1,70)
        self.Grid:SetColSize(3,70)
        self.Grid:SetDefaultCellFont(self.wxFont)
        for i,v in ipairs(params) do
            if desc[i] == "DISABLE ITEM" then
                self.Grid:SetReadOnly(0,0)
                self.Grid:SetCellValue(0,0,"DISABLE ITEM")
                self.Grid:SetCellEditor(0,1,wxLua.wxGridCellBoolEditor())
                self.Grid:SetCellRenderer(0,1,wxLua.wxGridCellBoolRenderer())
                self.Grid:SetCellBackgroundColour(0,1,tostring(v) == "1" and pureGreen or pureRed)
            else
                local dsk = "num"
                if desc[i] == "SPRITEID" or desc[i] == "UNKNOWN" then
                    self.Grid:SetReadOnly(math.floor(i/2),i%2*2+1)
                    dsk = false
                elseif desc[i] == "DIRECTION" or desc[i] == "ROTATION_DIRECTION" then
                    self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellChoiceEditor({"Left","Right"}))
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,blue)
                    dsk = false
                elseif desc[i] == "XDIRECTION" then
                    self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellChoiceEditor({"none","Left","Right"}))
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,green)
                    dsk = false
                elseif desc[i] == "TOUCHNGO" or desc[i] == "MIRROR" or desc[i] == "DISABLE ITEM" or desc[i] == "CHASE" or desc[i] == "DISABLED" or desc[i] == "START OFF" then
                    self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellBoolEditor())
                    self.Grid:SetCellRenderer(math.floor(i/2),i%2*2+1,wxLua.wxGridCellBoolRenderer())
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,tostring(v) == "1" and pureGreen or pureRed)
                    dsk = false
                elseif desc[i] == "YDIRECTION" then
                    self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellChoiceEditor({"none","Up","Down"}))
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,green)
                    dsk = false
                elseif desc[i] == "TEXT" then
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,grey)
                    dsk = "txt"
                elseif desc[i] == "ANGLE" then
                    self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellFloatEditor(0,2))
                    self.Grid:SetCellRenderer(math.floor(i/2),i%2*2+1,wxLua.wxGridCellFloatRenderer(0,2))
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,grey)
                    dsk = "rnum"
                elseif desc[i] == "Z LAYER" then
                    self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellChoiceEditor({"r","f","b"}))
                    self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,green)
                    dsk = false
                end
                self.Grid:SetReadOnly(math.floor(i/2),i%2*2)
                self.Grid:SetCellValue(math.floor(i/2),i%2*2,desc[i])
                self.Grid:SetCellValue(math.floor(i/2),i%2*2+1,tostring(v))
                if dsk then
                    if dsk == "txt" then
                        self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,grey)
                    else
                        self.Grid:SetCellEditor(math.floor(i/2),i%2*2+1,wxLua.wxGridCellFloatEditor(0,2)) --number
                        self.Grid:SetCellRenderer(math.floor(i/2),i%2*2+1,wxLua.wxGridCellFloatRenderer(0,2))
                        self.Grid:SetCellBackgroundColour(math.floor(i/2),i%2*2+1,grey)
                    end
                end
            end
        end
        self.Dialog:Connect(1,wxLua.wxEVT_GRID_CELL_CHANGE,function(ev)
            local row, col = ev:GetRow(), ev:GetCol()
            local id = row*2+math.ceil(col/2)-1
            id = id == 0 and #params or id
            local it = items[self.ItemId]
            undoModule:ItemChanges({"propchange",it.Id,it.X,it.Y,{unpack(it.SaveParams)}})
            items[self.ItemId].SaveParams[id] = #mod.Grid:GetCellValue(row,col) == 0 and 0 or tostring(tonumber(mod.Grid:GetCellValue(row,col))) == mod.Grid:GetCellValue(row,col) and tonumber(mod.Grid:GetCellValue(row,col)) or mod.Grid:GetCellValue(row,col)
            if item.iID == "9" then
                item.SaveParams[14] = math.floor(mathclamp(item.SaveParams[14],1,31))
                self.ItemImage[1] = ImageFileFromItemID.Skins["9"][item.SaveParams[14]]
                if id == 14 then
                    self.Grid:SetCellValue(row,col,tostring(item.SaveParams[14]))
                end
            elseif item.iID == "71" then
                item.SaveParams[9] = math.floor(mathclamp(item.SaveParams[9],1,9))
                self.ItemImage[1] = ImageFileFromItemID.Skins["71"][item.SaveParams[9]]
                if id == 9 then
                    self.Grid:SetCellValue(row,col,tostring(item.SaveParams[9]))
                end
            elseif item.iID == "7" then
                item.SaveParams[13] = math.floor(mathclamp(item.SaveParams[13],1,3))
                self.ItemImage[1] = ImageFileFromItemID.Skins["7+8"][item.SaveParams[13]]
                if id == 133 then
                    self.Grid:SetCellValue(row,col,tostring(item.SaveParams[13]))
                end
            elseif item.iID == "8" then
                item.SaveParams[8] = math.floor(mathclamp(item.SaveParams[8],1,3))
                self.ItemImage[1] = ImageFileFromItemID.Skins["7+8"][item.SaveParams[8]]
                if id == 8 then
                    self.Grid:SetCellValue(row,col,tostring(item.SaveParams[8]))
                end
            elseif item.iID == "39" then
                item.SaveParams[6] = math.floor(mathclamp(item.SaveParams[6],1,6))
                self.ItemImage[1] = ImageFileFromItemID.Skins["39"][item.SaveParams[6]]
                if id == 6 then
                    self.Grid:SetCellValue(row,col,tostring(item.SaveParams[6]))
                end
            end
            self.Image:SetBitmap(wxLua.wxBitmap(self.ItemImage[1]))
            self.Image:SetSize(32,32)
            items[self.ItemId]:PropChanged()
            if self.Grid:GetCellBackgroundColour(row,col):GetAsString() == pureGreen:GetAsString() then
                self.Grid:SetCellBackgroundColour(row,col,pureRed)
            elseif self.Grid:GetCellBackgroundColour(row,col):GetAsString() == pureRed:GetAsString() then
                self.Grid:SetCellBackgroundColour(row,col,pureGreen)
            end
        end)
        local x,y = wxLua.wxGetMousePosition():GetXY()
        self.Dialog:Move(wxLua.wxPoint(x+20,y+20))
        self.Dialog:SetSize(self.Width,self.Height+18)
        self.MainLayer:SetSize(self.Width,self.Height)
        self.Image:SetBitmap(wxLua.wxBitmap(self.ItemImage[1]))
        self.Image:SetSize(64,64)
        self.Image:Move(self.Width-67,self.Height-67)
    end
    local x,y = wxLua.wxGetMousePosition():GetXY()
    self.Dialog:Move(wxLua.wxPoint(x+20,y+20))
    self.Dialog:Show(true)
    self.Dialog:SetFocus()
end

local rotateRight = love.graphics.newImage("textures/RotateToRight.png")
local rotateLeft = love.graphics.newImage("textures/RotateToLeft.png")

return mod
