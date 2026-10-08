%==========================================================================
% ATTENTION:
%==========================================================================

classdef CLS_modal_POLE

properties (SetAccess=protected)
  pole       (1,1) double
  real_part (1,1) double
  imag_part (1,1) double
  mag_val   (1,1) double
end

properties (Hidden)
   TOL (1,1) double = 1e-8
end
%_#########################################################################
methods
function OBJ = CLS_modal_POLE(pole_list)
    
     if(0==nargin)
         return
     end
    
     assert(isvector(pole_list), "###_ERROR:  you must supply a VECTOR of poles");

     for kk=1:length(pole_list)   
         OBJ(kk,1).pole          = pole_list(kk);
         OBJ(kk,1).real_part     = real( pole_list(kk)  );
         OBJ(kk,1).imag_part     = imag( pole_list(kk)  );    
         OBJ(kk,1).mag_val       = abs( pole_list(kk)   );     
     end
end
%--------------------------------------------------------------------------
function tf_res = is_zero(OBJ)
    tf_res = LOC_is_small( abs([OBJ.pole]), [OBJ.TOL] );
end
%--------------------------------------------------------------------------
function tf_res = is_real(OBJ)
    tf_is_small_real = LOC_is_small( abs([OBJ.real_part]), [OBJ.TOL] );
    tf_is_small_imag = LOC_is_small( abs([OBJ.imag_part]), [OBJ.TOL] );
    
    tf_res           =  ~tf_is_small_real & tf_is_small_imag;
end
%--------------------------------------------------------------------------
function tf_res = is_imag(OBJ)
    tf_is_small_real = LOC_is_small( abs([OBJ.real_part]), [OBJ.TOL] );
    tf_is_small_imag = LOC_is_small( abs([OBJ.imag_part]), [OBJ.TOL] );
    
    tf_res           =  ~tf_is_small_imag & tf_is_small_real;
end
%--------------------------------------------------------------------------
function tf_res = is_stable(OBJ)    
    tf_res =  [OBJ.real_part] <= 0;
    tf_res = tf_res(:);
end
%--------------------------------------------------------------------------
function tf_res = is_modal(OBJ)

     tf_res = ~is_zero(OBJ)   & ...
               is_stable(OBJ) & ... 
              ~is_real(OBJ);
end
%--------------------------------------------------------------------------
function [wn_col, damp_col, tf_is_modal] = get_wn_and_drat(OBJ)

    wn_col      = NaN(size(OBJ));
    damp_col    = NaN(size(OBJ));
    tf_is_modal = is_modal(OBJ);

    for kk=1:length(OBJ)
       if(tf_is_modal(kk)==false)
           continue
       end

       this_obj = OBJ(kk);

       if( is_imag(this_obj) )
           wn_col(kk)   = this_obj.imag_part;
           damp_col(kk) = 0;
           continue
       end

       % OK: if we made it to here we have a nice underdamped POLE
       wn_col(kk)   = this_obj.mag_val;

       damp_col(kk) = -1 * this_obj.real_part / wn_col(kk);

    end % for kk
end
%--------------------------------------------------------------------------
function out_TAB = tabulate(OBJ)

    [wn_col, damp_col, tf_is_modal] = get_wn_and_drat(OBJ);

    out_TAB = table;
    
    out_TAB.Count     = [1:length(OBJ)]';
    out_TAB.the_pole  = [OBJ.pole].';
    out_TAB.wn        = wn_col;
    out_TAB.damp_rat  = damp_col;
    out_TAB.is_modal  = tf_is_modal;
    out_TAB.is_stable = is_stable(OBJ);
    out_TAB.is_zero   = is_zero(OBJ);
    out_TAB.is_real   = is_real(OBJ);  
end
%------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
end % methods
%_#########################################################################

end % classdef
%_#########################################################################
% SUBFUNCTIONS only beyond this point
%_#########################################################################
function tf_col = LOC_is_small(value_list, TOL_list)

   assert( isreal(value_list), "###_ERROR:  value list MUST be real !" );

   tf_col = abs(value_list) < TOL_list;

   tf_col = tf_col(:);
end
