pos = vector.new(gps.locate(5))
--y is normal to the floor
-- x and z are 2 d place parallel to ground
--if theres a block in front of the turtle break it, even if other shit falls in front
function digXZ()
    while turtle.detect() do
        turtle.dig()
    end
end

--updates the global position variable to current location
function updatePos()
    pos = vector.new(gps.locate(5))
end

--dig down if theres a block
function digYdown()
    while turtle.detectDown() do
        turtle.digDown()
    end
end

--move down after digging down
function moveYdown()
    digYdown()
    turtle.down()
end

-- dig up while theres a block there
function digYup()
    while turtle.detectUp() do
        turtle.digUp()
    end
end

-- move up after diggin up
function moveYup()
    digYup()
    turtle.up()
end

-- go forward after digging forward
function moveForward()
    digXZ()
    turtle.forward()
end

--face the desired x direction in the least amount of turns
function orientX(final_location)
    pos = vector.new(gps.locate())
    local diffx = final_location.x - pos.x
    if orientation == 1 and diffx > 0 then
        turtle.turnRight()
        orientation = 2;
    elseif orientation == 3 and diffx > 0 then 
        turtle.turnLeft()
        orientation = 2;
    elseif orientation == 1 and diffx < 0 then 
        turtle.turnLeft()
        orientation = 4;
    elseif orientation == 3 and diffx < 0 then
        turtle.turnRight()
        orientation = 4;
    elseif orientation == 2  and diffx < 0 then 
        turtle.turnRight()
        turtle.turnRight()
        orientation = 4;
    elseif orientation == 4 and diffx > 0 then
        turtle.turnRight()
        turtle.turnRight()
        orientation = 2;
    end
end

--face the desired z direction in the least amount of turns
function orientZ(final_location)
    pos = vector.new(gps.locate());
    local diffz = final_location.z - pos.z;
    if orientation == 2 and diffz < 0 then
        turtle.turnLeft();
        orientation = 1;
    elseif orientation == 3 and diffz < 0 then
        turtle.turnRight()
        turtle.turnRight()
        orientation = 1;
    elseif orientation == 4 and diffz < 0 then 
        turtle.turnRight();
        orientation = 1;
    elseif orientation == 2 and diffz > 0 then 
        turtle.turnRight()
        orientation = 3;
    elseif orientation == 4 and diffz > 0 then
        turtle.turnLeft()
        orientation = 3;
    elseif orientation == 1 and diffz > 0 then 
        turtle.turnRight()
        turtle.turnRight()
        orientation = 3;
    end
end

--which direction are you facing? Cardinal coordinates once the bot has intialized this orientation, it shouldnt need to ever do it again
--N = 1 (+z)
--E = 2 (+x)
--S = 3 (-z)
--W = 4 (-x)
function get_orientation()
    local mypos = vector.new(gps.locate(5));
    moveForward()
    local new_pos = vector.new(gps.locate(5));
    local xmove = new_pos.x - mypos.x;
    local zmove = new_pos.z - mypos.z;
    if xmove > 0 then
        orientation = 2;
    elseif xmove < 0 then
        orientation = 4;
    end
    if zmove > 0 then
        orientation = 3;
    elseif zmove < 0 then
        orientation = 1;
    end
    return orientation
end

-- move to the target location( y first, then x, and then z)( down and then within the XZ plane)
-- The bot will move forward in the XZ place first is order to orient itself, then move to the point in space based on its start rotation
function moveTo(final_location)
    updatePos() --use for minecraft
    get_orientation()
    local diffx = final_location.x - pos.x
    local diffy = final_location.y - pos.y
    local diffz = final_location.z - pos.z
    while diffy ~= 0 do
        if diffy > 0 then
            moveYup();
            updatePos()
            diffy = final_location.y - pos.y
        end
        if diffy < 0 then
            updatePos()
            diffy = final_location.y - pos.y
        end
    end

    --We move in the x direction first so we need to orient ourselves in the correct direction
    if diffx ~= 0 then
        orientX(final_location)
    end

    --while we aren't at our desired location we need to move forward, x first then z
    while diffx ~= 0 do
        moveForward()
        updatePos()
        diffx = final_location.x -pos.x
    end

    --orient in proper z direction
    if diffz ~= 0 then
        orientZ(final_location)
    end

    while diffz ~= 0 do
        moveForward()
        updatePos()
        diffz = final_location.z - pos.z
    end
    return pos
end

--quarry excavating algorithm
--should be called once you are at desired dig location
function dig_quarry(depth, width , height)
    --N = 1 (+z)
    --E = 2 (+x)
    --S = 3 (-z)
    --W = 4 (-x)
    while orientation ~=1 do
        turtle.turnRight()
        orientation = (orientation % 4) + 1;
    end

    local firstmove = true
    local slice_completed
    local startpos = vector.new(gps.locate(5))
    local mypos
    for i = 0, depth do
        moveYdown()
        mypos = vector.new(gps.locate(5))
        slice_completed = false
        while not slice_completed do
            if i%2 == 0 then
                if mypos.z == startpos.z then
                    if firstmove then
                        mypos = moveTo(vector.new(mypos.x, mypos.y, height+startpos.z))
                        firstmove = false
                    else
                        mypos = moveTo(vector.new(mypos.x+1, mypos.y, height+startpos.z))
                    end
                elseif mypos.z == height+startpos.z then
                    mypos = moveTo(vector.new(mypos.x+1, mypos.y, startpos.z))
                end
                if mypos.x == width then
                    slice_completed = true
                end
            else
                if mypos.z == startpos.z then
                    mypos = moveTo(vector.new(mypos.x-1, mypos.y, height+startpos.z))
                elseif mypos.z == height+startpos.z then
                    if firstmove then
                        mypos = moveTo(vector.new(width+startpos.x, mypos.y, startpos.z))
                        firstmove = false
                    else
                        mypos = moveTo(vector.new(mypos.x-1, mypos.y, startpos.z))
                    end
                end
                if mypos.x == startpos.x then
                    slice_completed = true
                end
            end
        end
        firstmove = true
    end
end

moveTo(vector.new(-355, 71, -320))
dig_quarry(3,5,5)
moveTo(vector.new(-355, 71, -320))