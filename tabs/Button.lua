Button = class()
Button.light = Colors.Gray3
Button.dark = Colors.Gray1

function Button:init(label, x, y, w, h, fillColor, strokeColor)
    self.label = label
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.fillColor = fillColor or Colors.Transparent
    self.strokeColor = strokeColor or Colors.Gray1
    self._strokeColor = self.strokeColor
    self._fillColor = self.fillColor
end

function Button:draw()
    pushStyle()
    strokeWidth(1.5)
    fill(self.fillColor)
    stroke(self.strokeColor)
    rectMode(CORNER)
    rect(self.x, self.y, self.w, self.h)
    textMode(CENTER)
    font("HelveticaNeue-CondensedBlack")
    fill(self.pressed and Button.light or Button.dark)
    fontSize(30)
    text(self.label, self.x+self.w/2, self.y+self.h/2)
    popStyle()
end

function Button:touched(touch)
    local x, y, w, h = self.x, self.y, self.w, self.h
    local clicked = false

    if (x <= touch.x and touch.x <= x+w) then
        if (y <= touch.y and touch.y <= y+h) then
            if touch.state == BEGAN then
                self.pressed = true
                local black = color(0, 0, 0, 255)
                self.fillColor, self.strokeColor = self.strokeColor, self.fillColor
                sound(DATA, "ZgJANwAiQHM6QEBAAAAAADQfND7Cvvs+fwBAf0BAQEA8QEBA")
            elseif touch.state == ENDED and self.pressed then
                clicked = true
            end
        end
    end
    
    if self.pressed and touch.state == ENDED then
        -- reset state
        self.pressed = false
        self.strokeColor = self._strokeColor
        self.fillColor = self._fillColor
    end
    
    if clicked then
        self:clicked()
    end
end

function Button:clicked()
    -- redefine this in subclasses
end