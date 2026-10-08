classdef bh_brick_CLS
    properties
        % Geometry properties
        Length     (1,1) {isnumeric, mustBePositive} =   50/100;  % (m)
        Height     (1,1) {isnumeric, mustBePositive} =   1/100;   % (m)
        Thickness  (1,1) {isnumeric, mustBePositive} =   2/100;   % (m)
        LHT_body_axes (1,1) string {mustBeMember(LHT_body_axes,["XYZ", "YZX"])} = "YZX"'

        % Inertial properties
        Mass        (1,1) {isnumeric, mustBePositive} =   3;       % (kg)

        % Material
        E_Gpa       (1,1) {isnumeric, mustBePositive} =   200;  % (Gpa)
        Poisson_rat (1,1) {isnumeric, mustBePositive} =   0.33;  % (-)
    end

    properties (Dependent=true)
      vec_XYZ
      density  % (kg/m^3)
    end
    %----------------------------------------
    methods
        function obj = bh_brick_CLS()
        end
    %----------------------------------------
        function val = get.vec_XYZ(OBJ)
           % say we have a Body fixed frame attached to the Brick
           % What are the X,Y,Z dimensions of the brick ?
           % - these dimensions should consist of the 
           %    LENGTH, HEIGHT and THICKNESS of the Brick

            switch OBJ.LHT_body_axes
                case "YZX"
                 val =  [ OBJ.Thickness,  OBJ.Length, OBJ.Height ];
                case "XYZ"
                    val =  [ OBJ.Length, OBJ.Height, OBJ.Thickness];
                otherwise
                    error("###_ERROR:  UNknown Body fixed frame convention");
            end

        end
    %----------------------------------------
    function dens = get.density(OBJ)
           VOLUME = prod(OBJ.vec_XYZ);
           dens   = OBJ.Mass /  VOLUME;  % (kg/m^3)
        end
    %----------------------------------------
    
    end % methods
end     % classdef