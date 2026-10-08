classdef earth_vis_CLS
       
    properties
        tile_A_norm_RGB  (1,3) {mustBeNonnegative} = [0.7373,1,0.7882] % [1,1,1]
        tile_B_norm_RGB  (1,3) {mustBeNonnegative} = [1,1,0.498] %[0,0,0]
        tile_L           (1,1) {mustBeNonnegative} = 0.1     % (m) TILE square side length
        tile_H           (1,1) {mustBeNonnegative} = 1/1000  % (m) TILE thickness (Z-direction)
        z_offset_rel_to_ref (1,1) = -0.05 % (m)
    end

    properties (Constant)
        NUM_TILES_XY     (1,2) {mustBeNonnegative} = [12,12]
    end

    properties (Dependent)
        tile_Lxyz
        World_origin_of_SW_corner
    end

    methods
        function OBJ = earth_vis_CLS()
        end
        %------------------------------------------------
        function val = get.tile_Lxyz(OBJ)
                 val = [OBJ.tile_L, OBJ.tile_L, OBJ.tile_H];
        end
        %------------------------------------------------ 
        function val = get.World_origin_of_SW_corner(OBJ)
            Nx = OBJ.NUM_TILES_XY(1);
            Ny = OBJ.NUM_TILES_XY(2);

            val = [ -(Nx/2 - 0.5)*OBJ.tile_L, ...
                    -(Ny/2 - 0.5)*OBJ.tile_L, ...
                     OBJ.z_offset_rel_to_ref]; 
        end

    end
end
