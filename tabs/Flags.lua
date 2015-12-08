Flags = class(Register)
Flags.names = { Overflow = 1, Zero = 2, Less = 3, Equal = 4, Greater = 5 }
Flags.abbr = {"O","Z","L","E","G"}

function Flags:init()
    Register.init(self, "flags")
end

function Flags:setOverflow()
    self.bits[Flags.names.Overflow] = 1
end

function Flags:draw(x, y)
    -- Codea does not automatically call this method
    Register.draw(self, x, y)
    for i,b in ipairs(self.bits) do
        local n = self.abbr[i]
        if n then
            if b == 1 then
                fill(Colors.Gray3)
            else
                fill(Colors.Gray1)
            end
            text(n, x + (i-1)*26 + 13, y + 13)
        end
    end
end

function Flags:touched(touch)
    -- Codea does not automatically call this method
end
