-- Mapote CPU

displayMode(OVERLAY)
displayMode(FULLSCREEN)
supportedOrientations(LANDSCAPE_ANY)

-- Use this function to perform your initial setup
function setup()
    print("Welcome to Mapote CPU")
    
    cpu = CPU()
    
    -- Fib
    cpu.codeLines[1] = Instruction(CPU.USI,0,0,7,0)
    cpu.codeLines[2] = Instruction(CPU.ADD,0,0,3,1)
    cpu.codeLines[3] = Instruction(CPU.SUB,0,7,6,1)
    cpu.codeLines[4] = Instruction(CPU.ADD,6,0,7,0)
    cpu.codeLines[5] = Instruction(CPU.BEQ,0,7,0,12)
    cpu.codeLines[6] = Instruction(CPU.ADD,3,0,1,0)
    cpu.codeLines[7] = Instruction(CPU.ADD,1,0,4,0)
    cpu.codeLines[8] = Instruction(CPU.ADD,2,0,1,0)
    cpu.codeLines[9] = Instruction(CPU.ADD,4,0,2,0)
    cpu.codeLines[10] = Instruction(CPU.ADD,1,2,3,0)
    cpu.codeLines[11] = Instruction(CPU.BGT,0,7,0,3)
    cpu.codeLines[12] = Instruction(CPU.USO,3,0,0,0)
    cpu.codeLines[13] = Instruction(CPU.HALT,0,0,0,0)
    
    FPS()
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)

    -- This sets the line thickness
    strokeWidth(5)

    -- Do your drawing here
    fc = (fc or 0) + 1
    if fc % 6 == 0 then
        cpu:execute()
    end
    
    cpu:draw()
end

function touched(touch)
    cpu:touched(touch)
end

