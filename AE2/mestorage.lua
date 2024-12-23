--- Credit: Srendi - https://github.com/SirEndii

mon = peripheral.find("monitor")
me = peripheral.find("meBridge")

local label = "ME Storage"

data = {
  totalItemStorage = 0,
  usedItemStorage = 0,
  totalFluidStorage = 0,
  usedFluidStorage = 0,
  cells = 0,
}

os.loadAPI("mnt/AE2/api/bars.lua")

function init()
    mon.clear()
    width, height = mon.getSize()
    mon.setCursorPos((width/2)-(#label/2), 1)
    mon.setTextScale(1)
    mon.write(label)
    mon.setCursorPos(1, 1)

    drawBox(2, width - 1, 3, 15, "Items", colors.gray, colors.lightGray)
    drawBox(2, width - 1, 17, height - 1, "Fluids", colors.gray, colors.lightGray)

    data.totalItemStorage = me.getTotalItemStorage()
    data.usedItemStorage = me.getUsedItemStorage()
    data.totalFluidStorage = me.getTotalFluidStorage()
    data.usedFluidStorage = me.getUsedFluidStorage()
    data.cells = #me.listCells()
    drawBars()
end

function drawBox(xMin, xMax, yMin, yMax, title, bcolor, tcolor)
    mon.setBackgroundColor(bcolor)
    for xPos = xMin, xMax, 1 do
        mon.setCursorPos(xPos, yMin)
        mon.write(" ")
    end
    for yPos = yMin, yMax, 1 do
        mon.setCursorPos(xMin, yPos)
        mon.write(" ")
        mon.setCursorPos(xMax, yPos)
        mon.write(" ")

    end
    for xPos = xMin, xMax, 1 do
        mon.setCursorPos(xPos, yMax)
        mon.write(" ")
    end
    mon.setCursorPos(xMin+2, yMin)
    mon.setBackgroundColor(colors.black)
    mon.setTextColor(tcolor)
    mon.write(" ")
    mon.write(title)
    mon.write(" ")
    mon.setTextColor(colors.white)
end

function drawBars()
    bars.add("items", "hor", data.totalItemStorage, data.usedItemStorage, 5, 5, width-8, 4, colors.red, colors.green)
    bars.add("fluids", "hor", data.totalFluidStorage, data.usedFluidStorage, 5, 19, width-8, 4, colors.red, colors.green)
    bars.construct(mon)
    bars.screen()
end

function clear(xMin,xMax, yMin, yMax)
    mon.setBackgroundColor(colors.black)
    for xPos = xMin, xMax, 1 do
        for yPos = yMin, yMax, 1 do
            mon.setCursorPos(xPos, yPos)
            mon.write(" ")
        end
    end
end

function itemUsage()
  return data.usedItemStorage * 100 / data.totalItemStorage
end

function fluidUsage()
  return data.usedFluidStorage * 100 / data.totalFluidStorage
end

function comma_value(n) -- credit http://richard.warburton.it
    local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function roundToDecimal(num, decimalPlaces)
    local mult = 10^(decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function update()
  clear(3, width-3, height-5, height-2)

  bars.set("items", "cur", data.usedItemStorage)
  bars.set("items", "max", data.totalItemStorage)

  bars.set("fluids", "cur", data.usedFluidStorage)
  bars.set("fluids", "max", data.totalFluidStorage)

  bars.screen()

  -- Item storage stats
  mon.setCursorPos(5, 7)
  mon.write("Used: ".. roundToDecimal(itemUsage(), 2) .."%")
  mon.setCursorPos(5, 9)
  mon.write("Cells: " .. data.cells)
  mon.setCursorPos(5, 11)
  mon.write("Bytes (Used/Total): ")
  mon.setCursorPos(25, 11)
  mon.write(comma_value(data.usedItemStorage) .." / ".. comma_value(data.totalItemStorage))

  -- Fluid storage stats
  mon.setCursorPos(5, 21)
  mon.write("Used: ".. roundToDecimal(fluidUsage(), 2) .."%")
  mon.setCursorPos(5, 23)
  mon.write("Bytes (Used/Total): ")
  mon.setCursorPos(25, 23)
  mon.write(comma_value(data.usedFluidStorage) .." / ".. comma_value(data.totalFluidStorage))
end

init()

while true do
    data.totalItemStorage = me.getTotalItemStorage()
    data.usedItemStorage = me.getUsedItemStorage()
    data.totalFluidStorage = me.getTotalFluidStorage()
    data.usedFluidStorage = me.getUsedFluidStorage()
    data.cells = #me.listCells()
    update()
    sleep(0.5)
end
