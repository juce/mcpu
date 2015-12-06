Instruction = class()

function Instruction:init(opcode, in1, in2, out, imm)
    setmetatable(self, mt)
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

function Instruction:draw()
    -- Codea does not automatically call this method
end

function Instruction:touched(touch)
    -- Codea does not automatically call this method
end
