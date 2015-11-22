function B = TransformCoordinates(O,Y,A)
%this function takes vector A in one cartesian coordinate system
%and transforms it into another vector B in a coordinate system defined by the
%two vectors - one to the new origin O and one to a point on the y axis Y

%apply translation
Y = Y - O;
A = A - O;
O = O - O;
%calculate angle of rotation
theta = -(pi - asin((Y(1) - O(1)) / norm(Y-O)));
%create rotation matrix
R = [cos(theta), sin(theta) ; -sin(theta), cos(theta)];
%apply rotation
B = R*A;
end