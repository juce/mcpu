Register = class()

function Register:init(name)
    -- you can accept and set parameters here
    self.name = name
    self.bits = {0, 0, 0, 0, 0, 0, 0, 0}
end

function Register:read()
    return Bits.read(self.bits)
end

function Register:write(v)
    return Bits.write(v, self.bits)
end

function Register:draw(x, y)
    -- Codea does not automatically call this method
    strokeWidth(2)
    stroke(Colors.Gray1)
    fill(Colors.Yellow)
    text(self.name, x - 20, y + 10)
    for i,b in ipairs(self.bits) do
        if b == 1 then
            fill(Colors.Green)
        else
            noFill()
        end
        rect(x + (i-1)*26, y, 25, 25)
    end
    fill(Colors.Blue)
    text(tostring(self:read()), x + 8*26 + 20, y + 10)
end

function Register:touched(touch, xl, yb)
    -- Codea does not automatically call this method
    if touch.state ~= ENDED then
        return
    end
    local x, y = touch.x, touch.y
    local xr, yt = xl + 8*26, yb + 26
    if (xl <= x and x <= xr and yb <= y and y <= yt) then
        local i = (x - xl)//26 + 1
        self.bits[i] = (self.bits[i] + 1) % 2
    end
end
