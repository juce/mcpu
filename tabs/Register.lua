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
    strokeWidth(3)
    stroke(147, 136, 136, 255)
    fill(219, 223, 18, 255)
    text(self.name, x - 20, y + 10)
    for i,b in ipairs(self.bits) do
        if b == 1 then
            fill(84, 255, 0, 255)
        else
            noFill()
        end
        rect(x + (i-1)*26, y, 26, 26)
    end
    fill(0, 126, 255, 255)
    text(tostring(self:read()), x + 8*26 + 20, y + 10)
end

function Register:touched(touch)
    -- Codea does not automatically call this method
end
