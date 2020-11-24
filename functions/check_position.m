function [this_position] = check_position(cellW, cellH, position, subpl)

if(subpl == 1 | subpl == 3)
    left = 0;
else
    left = 1;
end

if(subpl < 3)
    bottom = 1;
else 
    bottom = 0;
end

% Left coord
this_position(1) = position(1) + (left * cellW);

% Bottom coord
this_position(2) = position(2) + (bottom * cellH);

% Width and height
this_position(3) = cellW;
this_position(4) = 0.9 * cellH;
