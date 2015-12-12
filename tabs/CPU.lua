
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
    self.flags = Flags("flags")
    self.ip = Register("ip")
    self.input = Register("inp")
    self.output = Register("out")
    
    self.codeLines = {}
    for i=0,31 do
        self.codeLines[i] = Instruction(0, 0, 0, 0, 0)
    end
    
    Button.dark = Colors.Gray1
    Button.light = Colors.Gray3
    
    self.codeViewButton = Button("binary", WIDTH/2+130, 200, 100, 60)
    self.codeViewButton.clicked = function(b)
        self.showAssembler = not self.showAssembler
        b.label = (self.showAssembler) and "asm" or "binary"
    end
    
    self.ipResetButton = Button("reset ip", WIDTH/2+240, 200, 120, 60)
    self.ipResetButton.clicked = function(b)
        self.ip:write(0)
    end
    
    self.runButton = Button("run", WIDTH/2+130, 130, 80, 60)
    self.runButton.clicked = function(b)
        self.flags:setRunning(1)
        self.flags:setStepping(0)
    end
    
    self.stopButton = Button("stop", WIDTH/2+220, 130, 80, 60)
    self.stopButton.clicked = function(b)
        self.flags:setRunning(0)
    end
    
    self.stepButton = Button("step", WIDTH/2+310, 130, 80, 60)
    self.stepButton.clicked = function(b)
        self.flags:setRunning(1)
        self.flags:setStepping(1)
    end
    
    self.clearCode = Button("clear code", WIDTH/2+130, 60, 140, 60)
    self.clearCode.clicked = function(b)
        for i=0,31 do
            self.codeLinesImage = nil
            self.codeLinesAsm = nil
            local c = self.codeLines[i]
            Bits.write(0, c.opcode)
            Bits.write(0, c.in1)
            Bits.write(0, c.in2)
            Bits.write(0, c.out) 
            Bits.write(0, c.imm)
        end
    end
    
    self.resetAll = Button("reset all", WIDTH/2+280, 60, 120, 60)
    self.resetAll.clicked = function(b)
        for i,r in ipairs(self.regMap) do
            r:write(0)
        end
        self.input:write(0)
        self.output:write(0)
        self.flags:write(0)
        self.ip:write(0)
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
    if not self.flags:isRunning() then
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
    if self.flags:isStepping() then
        self.flags:setRunning(0)
    end
    return true
end

function CPU:next()
    self.ip:write(self.ip:read() + 1)
end

function CPU:halt(line)
    self.flags:setRunning(0)
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

function CPU:bge(line)
    if self.flags.bits[Flags.names.Equal] == 1 or self.flags.bits[Flags.names.Greater] == 1 then
        self.ip = Bits.read(line.imm)
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

function CPU:b(line)
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
        r:draw(WIDTH/2+130, HEIGHT-i*30)
    end
    self.flags:draw(WIDTH/2+130, HEIGHT-10*30)
    self.ip:draw(WIDTH/2+130, HEIGHT-11*30)
    self.input:draw(WIDTH/2+130, HEIGHT-13*30)
    self.output:draw(WIDTH/2+130, HEIGHT-14*30)
    
    -- code lines
    if self.showAssembler then
        self:disasm_view()
    else
        self:codeLines_view()
    end
    
    self.codeViewButton:draw()
    self.ipResetButton:draw()
    self.runButton:draw()
    self.stopButton:draw()
    self.stepButton:draw()
    self.resetAll:draw()
    self.clearCode:draw()
end

function CPU:codeLines_view()
    -- highlight active line
    local i = self.ip:read()
    fill(Colors.Highlight)
    noStroke()
    rect(30, HEIGHT-25-i*20, 40+20*25, 20)
    
    -- draw code lines
    if self.codeLinesImage then
        sprite(self.codeLinesImage, 5*WIDTH/16, HEIGHT/2)
    else
        self.codeLinesImage = image(5*WIDTH/8, HEIGHT)
        setContext(self.codeLinesImage)
        for i=0,31 do
            local cline = self.codeLines[i]
            cline:draw(i, 70, HEIGHT-25-i*20)
        end
        setContext()
    end

end

function CPU:disasm_view()
    -- highlight active line
    local i = self.ip:read()
    fill(Colors.Highlight)
    noStroke()
    rect(30, HEIGHT-25-i*20, 40+20*25, 20)
    
    -- disasm view
    fill(Colors.Gray1)
    if self.codeLinesAsm then
        sprite(self.codeLinesAsm, WIDTH/4, HEIGHT/2)
    else
        self.codeLinesAsm = image(WIDTH/2, HEIGHT)
        setContext(self.codeLinesAsm)
        pushStyle()
        for i=0,31 do
            local opcode = Bits.read(self.codeLines[i].opcode)
            local opname = self.instMap[opcode + 1]
            local inst = Instruction.disasm(self.codeLines[i], opname)
            local txt = string.format("%2d:  %s", i, inst)
            textMode(CORNER)
            text(txt, 40, HEIGHT-25-i*20)
            if opname == "halt" then
                break
            end
        end
        popStyle()
        setContext()
    end
end

local function toggleBit(bits, i)
    bits[i] = (bits[i] + 1) % 2
    sound(SOUND_PICKUP, 26938)
end

function CPU:touched(touch)
    -- Codea does not automatically call this method
    self.codeViewButton:touched(touch)
    self.ipResetButton:touched(touch)
    self.runButton:touched(touch)
    self.stopButton:touched(touch)
    self.stepButton:touched(touch)
    self.resetAll:touched(touch)
    self.clearCode:touched(touch)
    
    -- check for coding touches
    if touch.state == ENDED then
        clx = clx or 70
        cly = cly or HEIGHT-25-31*20
        clr = clr or clx + WIDTH/8*5
        clt = clt or cly + HEIGHT
        local x, y = touch.x, touch.y
        if (clx <= x and x <= clr and cly <= y and y <= clt) then
            self.codeLinesImage = nil
            self.codeLinesAsm = nil
            local i = math.max(0, 31-(y-cly)//20)
            local j = math.min(31, (x-clx)//20)
            if j <= 3 then
                toggleBit(self.codeLines[i].opcode, j+1)
            elseif j >= 5 and j <= 7 then
                toggleBit(self.codeLines[i].in1, j-4)
            elseif j >= 9 and j <= 11 then
                toggleBit(self.codeLines[i].in2, j-8)
            elseif j >= 13 and j <= 15 then
                toggleBit(self.codeLines[i].out, j-12)
            elseif j >= 17 and j <= 24 then
                toggleBit(self.codeLines[i].imm, j-16)
            end
        end
    end
end
