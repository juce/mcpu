CPU = class()
CPU.HALT = 0
CPU.ADD = 1
CPU.SUB = 2
CPU.MOV = 3
CPU.LOAD = 4
CPU.STOR = 5
CPU.BLE = 6
CPU.BLT = 7
CPU.BGE = 8
CPU.BGT = 9
CPU.B = 10
CPU.CMP = 11
CPU.RSHFT = 12

function CPU:init() 
    self.instMap = {
        "halt", "add", "sub", "mov", 
        "load", "stor", "ble", "blt",
        "bge", "bgt", "b", "cmp",
        "rshft",
    }  
    self.regMap = {
        Register("r0"),
        Register("r1"),
        Register("r2"),
        Register("r3"),
        Register("r4"),
        Register("r5"),
        Register("r6"),
        Register("r7"),
    }
    self.stopped = false
    self.flags = Flags("flags")
    self.ip = Register("ip")
    self.input = Register("inp")
    self.output = Register("out")
    
    self.codeLines = {}
    for i=0,31 do
        self.codeLines[i] = Instruction(0, 0, 0, 0, 0)
    end
end

function CPU:reg(name)
    local id = string.match(name, "r([0-7])")
    if not id then
        error("FATAL: unknown register: " .. name)
    end
    return self.regMap[tonumber(id)+1]
end

function CPU:regValues(s)
    local res = {}
    for v in string.gmatch(s,"r[0-7]") do
        res[#res + 1] = tostring(self:reg(v):read())
    end
    return table.concat(res,",")
end

function CPU:execute()
    if self.stopped then
        return false
    end
    local line = self.codeLines[self.ip:read()]
    if not line then
        error("FATAL: instruction pointer out of range")
    end
    local inst = self.instMap[Bits.read(line.opcode) + 1]
    if not inst then
        error("FATAL: invalid instruction at address: " .. self.ip)
    end
    CPU[inst](self, line)
    return true
end

function CPU:next()
    self.ip:write(self.ip:read() + 1)
end

function CPU:halt(line)
    self.stopped = true
end

function CPU:add(line)
    local in1 = self.regMap[Bits.read(line.in1) + 1]
    local in2 = self.regMap[Bits.read(line.in2) + 1]
    local out = self.regMap[Bits.read(line.out) + 1]
    local overflow = out:write((in1:read() | Bits.read(line.imm)) + in2:read())
    if overflow then
        self.flags:setOverflow()
    end
    self:next()
end

function CPU:sub(line)
    local in1 = self.regMap[Bits.read(line.in1) + 1]
    local in2 = self.regMap[Bits.read(line.in2) + 1]
    local out = self.regMap[Bits.read(line.out) + 1]
    local overflow = out:write(in2:read() - (in1:read() | Bits.read(line.imm)))
    if overflow then
        self.flags:setOverflow()
    end
    self:next()
end

function CPU:mov(line)
    local in1 = self.regMap[Bits.read(line.in1) + 1]
    local out = self.regMap[Bits.read(line.out) + 1]
    out:write(in1:read() | Bits.read(line.imm))
    self:next()
end

function CPU:load(line)
    local out = self.regMap[Bits.read(line.out) + 1]
    out:write(self.input:read())
    self:next()
end

function CPU:stor(line)
    local in1 = self.regMap[Bits.read(line.in1) + 1]
    self.output:write(in1:read())
    self:next()
end

function CPU:ble(line)
    if self.flags.bits[Flags.names.Equal] == 1 or self.flags.bits[Flags.names.Less] == 1 then
        self.ip = Bits.read(line.imm)
    else
        self:next()
    end
end

function CPU:blt(line)
    if self.flags.bits[Flags.names.Less] == 1 then
        self.ip:write(Bits.read(line.imm))
    else
        self:next()
    end
end

function CPU:bgt(line)
    if self.flags.bits[Flags.names.Greater] == 1 then
        self.ip:write(Bits.read(line.imm))
    else
        self:next()
    end
end

function CPU.b(line)
    self.ip:write(Bits.read(line.imm))
end

function CPU:cmp(line)
    local in1 = self.regMap[Bits.read(line.in1) + 1]
    local in2 = self.regMap[Bits.read(line.in2) + 1]
    local diff = in1:read() - in2:read()
    self.flags.bits[Flags.names.Equal] = diff==0 and 1 or 0
    self.flags.bits[Flags.names.Less] = diff<0 and 1 or 0
    self.flags.bits[Flags.names.Greater] = diff>0 and 1 or 0
    self:next()
end

function CPU:rshft(line)
    local out = self.regMap[Bits.read(line.out) + 1]
    for i=1,7 do
        out.bits[i+1] = out.bits[i]
    end
    self:next()
end

function CPU:draw()
    -- Codea does not automatically call this method
    for i,r in ipairs(self.regMap) do
        r:draw(WIDTH/2+30, HEIGHT-i*30)
    end
    self.flags:draw(WIDTH/2+30, HEIGHT-10*30)
    self.ip:draw(WIDTH/2+30, HEIGHT-11*30)
    
    fill(63, 112, 175, 255)
    if not txt then
        local lines = {}
        for i=0,31 do
            local opcode = Bits.read(self.codeLines[i].opcode)
            local opname = self.instMap[opcode + 1]
            local inst = Instruction.disasm(self.codeLines[i], opname)
            lines[#lines + 1] = string.format("%2d: %s", i, inst)
            if opname == "halt" then
                break
            end
        end
        txt = table.concat(lines, "\n")
        tw,th = textSize(txt)
    else
        text(txt, 40 + tw/2, HEIGHT - 10 - th/2)
    end
end

function CPU:touched(touch)
    -- Codea does not automatically call this method
end
