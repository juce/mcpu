Instruction = class()

function Instruction:init(opcode, in1, in2, out, imm)
    self.opcode = {0, 0, 0, 0}
    self.in1 = {0, 0, 0}
    self.in2 = {0, 0, 0}
    self.out = {0, 0, 0}
    self.imm = {0, 0, 0, 0, 0, 0, 0, 0}
    
    Bits.write(opcode, self.opcode)
    Bits.write(in1, self.in1)
    Bits.write(in2, self.in2)
    Bits.write(out, self.out)
    Bits.write(imm, self.imm)
end

function Instruction:disasm(opname)
    local in1 = Bits.read(self.in1)
    local in2 = Bits.read(self.in2)
    local out = Bits.read(self.out)
    return string.format("%s %s,%s,%s,%s",
        opname,
        in1 == 0 and "0" or "r" .. in1,
        in2 == 0 and "0" or "r" .. in2,
        out == 0 and "0" or "r" .. out,
        Bits.read(self.imm)
    )
end

function Instruction:draw(addr, x, y, strokeColor)
    -- Codea does not automatically call this method
    strokeWidth(2)
    fill(Colors.Yellow)
    text(addr, x - 20, y + 10)
    stroke(strokeColor or Colors.Gray1)
    -- opcode
    for i,b in ipairs(self.opcode) do
        fill(b==1 and Colors.Green or Colors.Transparent)
        rect(x + 20*(i-1), y, 19, 19)
    end
    -- in1
    for i,b in ipairs(self.in1) do
        fill(b==1 and Colors.Green or Colors.Transparent)
        rect(x + 20*5 + 20*(i-1), y, 19, 19)
    end
    -- in2
    for i,b in ipairs(self.in2) do
        fill(b==1 and Colors.Green or Colors.Transparent)
        rect(x + 20*9 + 20*(i-1), y, 19, 19)
    end
    -- out
    for i,b in ipairs(self.out) do
        fill(b==1 and Colors.Green or Colors.Transparent)
        rect(x + 20*13 + 20*(i-1), y, 19, 19)
    end
    -- imm
    for i,b in ipairs(self.imm) do
        fill(b==1 and Colors.Green or Colors.Transparent)
        rect(x + 20*17 + 20*(i-1), y, 19, 19)
    end
end

function Instruction:touched(touch)
    -- Codea does not automatically call this method
end
