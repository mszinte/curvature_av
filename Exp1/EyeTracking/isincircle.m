function inside = isincircle(x,y,rect)
% ----------------------------------------------------------------------
% inside = isincircle(x,y,rect)
% ----------------------------------------------------------------------
% Goal of the function :
% Tests if point [x y] is inside one of the
% circles enveloped by rectangles defined in
% rect [x1 y1 x2 y2]. inside returns the rect,
% which [x,y] is in.
% ----------------------------------------------------------------------
% Function created by Martin Rolfs
%          adapted by Martin SZINTE (martin.szinte@gmail.com)
% ----------------------------------------------------------------------


inside = 0;
for r = 1:size(rect,1)
    cxm = mean(rect(r,[1 3]));  % x center of circle
    cym = mean(rect(r,[2 4]));  % y center of circle
    dx  = rect(r,3)-rect(r,1);  % x diameter
    dy  = rect(r,4)-rect(r,2);  % y diameter
    rad = abs(min([dx dy])/2);
    if sqrt((x-cxm)^2+(y-cym)^2)<rad
        inside = r;
    end
end
