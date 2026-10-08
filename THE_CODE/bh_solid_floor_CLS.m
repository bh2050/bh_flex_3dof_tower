classdef bh_solid_floor_CLS
    properties
        WIDTH       (1,1) double {mustBePositive} = 1 % (m)
        DEPTH       (1,1) double {mustBePositive} = 1 % (m)
        THICKNESS   (1,1) double {mustBePositive} = 1 % (m)
        MASS        (1,1) double {mustBePositive} = 1 % (m)
    end
%_#########################################################################
methods
function obj = bh_solid_floor_CLS(Width, Depth, Thickness, Mass)
    obj.WIDTH     = Width;
    obj.DEPTH     = Depth; 
    obj.THICKNESS = Thickness;
    obj.MASS      = Mass;
end
%--------------------------------------------------------------------------
function Lxyz = get_Lxyz(OBJ)

         Lxyz = [OBJ.WIDTH, OBJ.DEPTH, OBJ.THICKNESS];
end
%--------------------------------------------------------------------------
end % methods
%_#########################################################################
end % classdef