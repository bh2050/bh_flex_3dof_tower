classdef bh_flex_column_CLS
    properties
        WIDTH_x          (1,1) double  {mustBePositive} = 1 % (m)
        DEPTH_y          (1,1) double  {mustBePositive} = 1 % (m)
        LENGTH_z         (1,1) double  {mustBePositive} = 1 % (m)
        density          (1,1) double  {mustBePositive} = 1 % material denisty (kg/m^3)        
        E_GPa_Young      (1,1) double  {mustBePositive} = 1 % GPa 
        v_Poisson        (1,1) double  {mustBePositive} = 1 % (-)   
        %------------------------------------------------------
        % DAMPING - RAYLEIGH
        damp_M_coeff = 0;      % (1/sec)
        damp_K_coeff = 0.001;  % (sec)
        %------------------------------------------------------
        % DAMPING - Damping ratio
        damp_ratio = 0;      % (-)
        %------------------------------------------------------
        % DISCRETIZATION
        num_eles = 1; %1;
        %------------------------------------------------------
        % ROM
        num_ret_modes = 5;
        %------------------------------------------------------
        BC_case (1,1) string {mustBeMember(BC_case, ["FIXED_FIXED_WITH_SWAY","CANTILEVER"])} = "FIXED_FIXED_WITH_SWAY"
    end
    %----------------------------------------------------------
    properties (Dependent)
       mass
       vol
       Ix
       Iy
       Kx
       area
    end
%_#########################################################################
methods
function obj = bh_flex_column_CLS( W,D,L, density, E_Gpa, v_Poi_rat)
    obj.WIDTH_x    = W;
    obj.DEPTH_y   = D; 
    obj.LENGTH_z   = L;
    obj.density     = density;
    obj.E_GPa_Young = E_Gpa;  
    obj.v_Poisson   = v_Poi_rat;
end
%--------------------------------------------------------------------------
function m = get.mass(obj)
         m = obj.density * obj.WIDTH_x * obj.DEPTH_y * obj.LENGTH_z;
end
%--------------------------------------------------------------------------
function area = get.area(obj)
         area = obj.WIDTH_x * obj.DEPTH_y;
end
%--------------------------------------------------------------------------
function v = get.vol(obj)
         v = obj.WIDTH_x * obj.DEPTH_y * obj.LENGTH_z;
end
%--------------------------------------------------------------------------
function Ix = get.Ix(obj)
         [Ix, ~] = bh_calc_I_for_RECT(obj.WIDTH_x, obj.DEPTH_y);  
end
%--------------------------------------------------------------------------
function Iy = get.Iy(obj)
         [~, Iy] = bh_calc_I_for_RECT(obj.WIDTH_x, obj.DEPTH_y);  
end
%--------------------------------------------------------------------------
function Kx = get.Kx(obj)
         % stiffness in the X-DIRECTION

         E = obj.E_GPa_Young * 1e9;  % (Pa)
         I = obj.Iy;
         L = obj.LENGTH_z;

         switch(obj.BC_case)
             case "FIXED_FIXED_WITH_SWAY"
                   % assume FIXED-FIXED boundary with SIDEWAYS SWAY permitted at tip
                   % REFS:
                   %  1.) https://engcourses-uofa.ca/books/advanced-dynamics-and-vibrations/review-of-single-and-multi-degree-of-freedom-mdof-systems/equivalent-spring-constants/
                   Kx = 12 * E * I / (L^3);
             case "CANTILEVER"
                   % stiffness at tip
                   % REFS:
                   %  1.) https://en.wikipedia.org/wiki/Euler%E2%80%93Bernoulli_beam_theory
                   %  2.) https://engcourses-uofa.ca/books/advanced-dynamics-and-vibrations/review-of-single-and-multi-degree-of-freedom-mdof-systems/equivalent-spring-constants/
                   Kx = 3 * E * I / (L^3);
             otherwise
                 error("###_ERROR:  UNknown boundary condition");
         end
end
%--------------------------------------------------------------------------

end % methods
%_#########################################################################
end % classdef