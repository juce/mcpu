-- Mapote CPU

displayMode(OVERLAY)
displayMode(FULLSCREEN)
supportedOrientations(LANDSCAPE_ANY)

-- Use this function to perform your initial setup
function setup()
    print("Welcome to Mapote CPU")
    
    cpu = CPU()
    cpu.codeLines[0] = Instruction(CPU.MOV,0,0,1,78)
    cpu.codeLines[1] = Instruction(CPU.ADD,0,0,2,200)
    cpu.codeLines[2] = Instruction(CPU.ADD,1,2,3,0)
    cpu.codeLines[3] = Instruction(CPU.SUB,3,2,4,0)
    
    --cpu.codeLines[4] = Instruction(CPU.MOV,0,0,5,1)
    cpu.codeLines[4] = Instruction(CPU.SUB,0,1,2,1)
    cpu.codeLines[5] = Instruction(CPU.MOV,2,0,1,0)
    cpu.codeLines[6] = Instruction(CPU.CMP,1,0,0,0)
    cpu.codeLines[7] = Instruction(CPU.BGT,0,0,0,4)
    
    --cpu:reg("r1"):write(78)
    --cpu:reg("r2"):write(200)
    
    --cpu:reg("r5"):write(1)
    --cpu:reg("r6"):write(0)
   
    --[[
    parameter.watch("cpu.stopped") 
    parameter.watch('cpu:regValues("r1,r2,r3,r4")') 
    parameter.watch('cpu:regValues("r1,r5,r6")')
    parameter.watch("cpu.ip:read()")
    --]]
    
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

