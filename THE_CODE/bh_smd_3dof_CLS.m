classdef bh_smd_3dof_CLS
    properties
        m1  (1,1) double {mustBePositive} = 1 % (kg)
        m2  (1,1) double {mustBePositive} = 1 % (kg)
        m3  (1,1) double {mustBePositive} = 1 % (kg)
        %-----------------------------------------------------
        kg  (1,1) double {mustBePositive} = 1 % (N/m)
        k1  (1,1) double {mustBePositive} = 1 % (N/m)
        k2  (1,1) double {mustBePositive} = 1 % (N/m)
        %-----------------------------------------------------
        cg  (1,1) double {mustBeNonnegative}  = 0 % value >= 0
        c1  (1,1) double {mustBeNonnegative}  = 0 % value >= 0
        c2  (1,1) double {mustBeNonnegative}  = 0 % value >= 0
        %-----------------------------------------------------
        M   (3,3) double
        C   (3,3) double
        K   (3,3) double    
    end
%_#########################################################################
methods
function obj = bh_smd_3dof_CLS()
end
%--------------------------------------------------------------------------
function obj = scale_damping(obj, GAIN)

    obj.cg = obj.cg * GAIN;
    obj.c1 = obj.c1 * GAIN;
    obj.c2 = obj.c2 * GAIN;
    
    obj.C  = obj.C * GAIN;
end
%--------------------------------------------------------------------------

end % methods
%_#########################################################################
end % classdef