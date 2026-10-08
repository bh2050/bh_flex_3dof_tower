classdef CLS_sdyn_frf
%CLS_sdyn_frf a Structural dynamics second order section representation of
%         a Frequency Response Function (FRF):
%
%
%     FRF = sum(i=1:N) (   R_i      +     R_i*      )  +   E   +   F
%                      ( --------        ---------  )             ---
%                      (  s - L_i         s - L_i*  )             s^2              
%
% where:
%        R_i    =  a complex residue(or shape factor) for MODE_i
%        L_i    = -zeta_i.wn_i + J.wn_i.sqrt(1 - zeta_i^2)
%        wn_i   =  UNdamped modal frequency (rad/s) for MODE_i
%        zeta_i =  damping ratio  for MODE_i
%==========================================================================
% TYPICAL_USAGE: 
% 
% A_WORKING_EXAMPLE_TEST_SCRIPT:
%
%     >> bh_test_harness_for_CE_algorithm
%--------------------------------------------------------------------------
% USAGE #1:
%  >> OBJ = CLS_sdyn_frf( the_damping_zeta, the_wn_rads, the_R, the_E, the_F)
%
%  >> frf = OBJ.frf;
%  >> OBJ.plot_db
%--------------------------------------------------------------------------
% USAGE #2:
%  >> OBJ = CLS_sdyn_frf( the_damping_zeta, the_wn_rads, the_R, the_E, the_F)
%
%  >> OBJ.s_w_fhz_col = 10:0.1:250;  % <---sets freq band of interest
%  >> frf = OBJ.frf;
%  >> OBJ.plot_db
%==========================================================================
% Bradley Horton :    bradley.horton@mathworks.com.au
%==========================================================================
properties(SetAccess = public, GetAccess = public)
   s_w_fhz_col        = 0;
   ID_label           = 'sdt_foo';
   display_plot_title = true;
end

properties(SetAccess = private, GetAccess = public)
   E = 0;
   F = 0;
   Num_modes = 0;
   R_col = [];
   P_col = [];

   zeta_col = [];
   wn_col   = [];
end

methods
   function obj = CLS_sdyn_frf(the_damping_zeta, the_wn_rads, the_R, the_E, the_F)
     obj.zeta_col  = the_damping_zeta(:); 
     obj.wn_col    = the_wn_rads(:); 
     obj.R_col     = the_R(:); 
     obj.E         = the_E; 
     obj.F         = the_F;  
     obj.Num_modes = length(the_wn_rads);
     obj.P_col     =  -obj.zeta_col .* obj.wn_col + ...
                       1i*obj.wn_col.*sqrt(1 - obj.zeta_col.^2);
                   
     % set a default frequency band of interest
     the_min_freq_wn     = min(the_wn_rads);
     the_max_freq_wn     = max(the_wn_rads);
     
     wn_band_of_interest = linspace(0.8*the_min_freq_wn, 1.2*the_max_freq_wn, 200)';
     
     obj.s_w_fhz_col     = wn_band_of_interest(:)/(2*pi);
   end
   %------------------------------------------------------------------   
   function out = frf(obj, opts_T)
       arguments
           obj
           opts_T.fhz_list (:,1) double = [];  % a list of frequencies(Hz) to evaluate the FRF at
       end
       
       if( isempty(opts_T.fhz_list) ) 
          % use defaults
          w_rad_col = 2*pi*obj.s_w_fhz_col;
          THE_S     = 1i*w_rad_col;
       else
          w_rad_col = 2*pi*opts_T.fhz_list;
          THE_S     = 1i*w_rad_col;
       end
 
        out       = calc_frf(obj,THE_S);
   end
   %------------------------------------------------------------------   
   function out = db(obj, varargin)
     % ALLOWED_USAGE:
     %  >> OBJ.db()
     %  >> OBJ.db(some_frf)  % used by 3D dB plotting
                     
     if(0==length(varargin))
              out = 20*log10(  abs(obj.frf())  );
     else
          some_frf = varargin{1};
          out      = 20*log10(  abs(some_frf)  );
          
     end
   end
   %-------------------------------------------------------------------
   function out = real(obj)
     out =  real( obj.frf() ); 
   end 
   %-------------------------------------------------------------------                      
   function out = imag(obj)
     out =  imag( obj.frf() ); 
   end           
   %-------------------------------------------------------------------   
   function out = fhz(obj)
     out =  obj.s_w_fhz_col; 
   end              
   %-------------------------------------------------------------------         
   function out = mag(obj)
     out = abs( obj.frf() ); 
   end
   %-------------------------------------------------------------------
   function out = phase(obj, varargin)
     %  returns the phase angles, in radians, for each element of 
     %  complex array Z. The angles lie between +/- PI
     %
     % ALLOWED_USAGE:
     %                 A.phase
     %                 A.phase('DEGS')
     %                 A.phase('RADS')
     % out = phase( obj.frf() );
     THE_FRF = obj.frf();
     out     = atan2( imag(THE_FRF), real(THE_FRF) );
     
     if(length(varargin)==1)
         units_str = upper(varargin{1}); 
         switch(units_str)
             case {'-DEGS', '-DEGREES', 'DEGS', 'DEGREES'}
                  out = out *180/pi;
             case {'-RADS', '-RADIANS', 'RADS', 'RADIANS'}
                  out = out;
             otherwise
                 error('###_ERROR: unknown units specified for PHASE');
         end
     end
   end
   %-------------------------------------------------------------------
   function varargout = plot_db(obj, varargin)
       % ALLOWED USAGE:
       %   A.plot_db
       %   A.plot_db(h_ax)
       %   A.plot_db(h_ax, '-r')
       %   A.plot_db(h_ax, '-r', false)


       %   h_ax = A.plot 
                 % Check INPUT arguments

       tf_annotate = true;          
       switch(length(varargin))
           case 0
                   h_f         = figure('Name', 'CLS_sdyn_frf');
                   h_ax        = axes('Tag', obj.ID_label);
                   LSPEC       = '-b';
           case 1
                   h_ax        = varargin{1};
                   hold(h_ax, 'on');
                   LSPEC       = '-r';
           case 2
                   h_ax        = varargin{1};
                   hold(h_ax, 'on');
                   LSPEC       = varargin{2}; 
           case 3
                   h_ax        = varargin{1};
                   hold(h_ax, 'on');
                   LSPEC       = varargin{2}; 
                   tf_annotate = varargin{3};
           otherwise
               error('###_UNKNOWN arg list to PLOT_DB !');
       end


       h_L = plot(h_ax, obj.s_w_fhz_col, obj.db(), LSPEC);

       if(tf_annotate)
           xlabel(h_ax,'[Hz]', 'FontWeight', 'Bold');
           ylabel(h_ax,'[dB]', 'FontWeight', 'Bold');
           grid(h_ax,'on'); axis(h_ax,'tight');
           if(obj.display_plot_title)
               title(h_ax,['SD Frequency Response Function for: <',obj.ID_label,'>'],...
                   'FontWeight', 'Bold', 'Interpreter', 'none');
           end
       end

       drawnow

       if(nargout >= 1)
           varargout{1} = h_ax;
       end
        if(nargout >= 2)
           varargout{2} = h_L;
       end

   end  
   %-------------------------------------------------------------------
      function varargout = plot_phase(obj, h_ax, LSPEC, opts_T)
         arguments
            obj (1,1)
            h_ax (1,1) = []
            LSPEC (1,:) char = '-r'
            opts_T.UNITS (1,:) char {mustBeMember(opts_T.UNITS,{'DEGS','RADS'})} = 'DEGS';
         end
         
         if (isempty(h_ax) )
            h_f        = figure();
            h_ax       = axes('Tag', obj.ID_label);
         end
  
       h_L = plot(h_ax, obj.s_w_fhz_col, obj.phase(opts_T.UNITS), LSPEC);

       xlabel(h_ax,'[Hz]',   'FontWeight', 'Bold');
          tmp_list = ['[',opts_T.UNITS,']'];
       ylabel(h_ax,tmp_list, 'FontWeight', 'Bold'); 
       grid(h_ax,'on');
       axis(h_ax,'tight');
       if(obj.display_plot_title)
           title(h_ax,['Frequency Response Function for: <',obj.ID_label,'>'],...
                  'FontWeight', 'Bold', 'Interpreter', 'none');           
       end
       
       drawnow
       if(1==nargout)
           varargout{1} = h_ax;
       end
   end 
   %-----------------------------------------------------------------------          
   function plot_3d_db(obj, varargin)
       % ALLOWED USAGE:
       %   A.plot_3d_db
       %   A.plot_3d_db(h_ax)

       switch(length(varargin))
           case 0
                   hf         = figure();
                   hax        = axes();
           case 1
                   hax        = varargin{1};
                   hold(hax, 'on');
           otherwise
               error('###_UNKNOWN arg list to PLOT_3D_DB !');
       end
       
       % recall:  p = -zeta.wn + j.wn.sqrt(1-zeta^2)
                 rp     = real(obj.P_col); 
                 rp     = abs(rp);
                 max_rp = max(rp);
       if(length(obj.s_w_fhz_col)>500)
            % the_w_list       = 2*pi*obj.s_w_fhz_col;  % was taking too long 
            the_w_list       = 2*pi*linspace(obj.s_w_fhz_col(1), obj.s_w_fhz_col(end), 700);
            the_sigma_list   = linspace(-10*max_rp, 0, length(the_w_list) );
       else
            the_w_list       = 2*pi*linspace(obj.s_w_fhz_col(1), obj.s_w_fhz_col(end), 600);
            the_sigma_list   = linspace(-10*max_rp, 0, length(the_w_list) );
       end
       
       % Recall:
       %    s = sigma + j.w

       [THE_SIG, THE_W] = meshgrid(the_sigma_list, the_w_list);
                 THE_S  = THE_SIG + j*THE_W;
                 THE_FRF= calc_frf(obj, THE_S);
       
       % do the 3D surface plot          
       THE_F_HZ = THE_W/(2*pi);
       hsf      = surf(hax, THE_SIG, THE_F_HZ, db(THE_FRF) );
       
           axis('tight'); grid('on');
           hsf.EdgeColor = 'none';
           xlabel('\sigma = REAL(s)', 'FontSize', 14);
           ylabel('f [Hz] = IMAG(s)/(2*pi)');    
           zlabel('|H(s)| [dB]');
           title('s-plane view of our TF and FRF', 'FontWeight', 'Bold');
       % create a couple of lights to illuminate the surface    
       light('Parent',hax,'Position',[0.310, -6.41, 17.00]);
       light('Parent',hax,'Position',[0.06063, 1.76569, -18.697008]);

       lighting gouraud
       
       % and superimpose the s=j.w plot
       the_s   = j*the_w_list;
       the_frf = calc_frf(obj,the_s);
       the_x   = zeros(size(the_s));
       the_y   = the_w_list/(2*pi);
       %the_y   = the_w_list;
       the_z   = obj.db(the_frf);

       hold(hax, 'on');
       plot3(the_x, the_y, the_z, '-m', 'LineWidth', 3);
            view(hax,[76.5 25.2]);
            hax.Box = 'on';
       %hax.BoxStyle = 'full';

       % Maybe you want to plot contours OR poles
       % so pick a Z-height to draw this at
       Z_height = min(db(THE_FRF),[], "all");

       % superimpose a contour plot
       %[~, hContour] = contour(hax, THE_SIG, THE_F_HZ, db(THE_FRF), 10, 'LineWidth', 1);
       % hContour.ZLocation = Z_height;

       % superimpose the POLES
       % hold(hax, 'on');
       % plot3( real(obj.P_col), imag(obj.P_col)/(2*pi), ...
       %        Z_height*ones(size(obj.P_col)), '.r', 'LineWidth', 3, ...
       %        MarkerSize=30);
   end
   %-----------------------------------------------------------------------
   function print(OBJ)

     for kk=1:numel(OBJ)
       obj = OBJ(kk);  
       fprintf('\n%s',repmat('-',1,75));
       fprintf('\n ID_label = %s',obj.ID_label);
       fprintf('\n');

       phase_R_degs  = angle(obj.R_col) * 180/pi;

       % Normal_mode_R = (obj.zeta_col .* obj.wn_col .* real(obj.R_col)) - ...
       %                 obj.wn_col .* sqrt(1 - obj.zeta_col.^2) .* imag(obj.R_col);
       % 
       % Normal_mode_R =2 * Normal_mode_R;
       % 
       % tmp_data = [ [1:obj.Num_modes]',   obj.wn_col/(2*pi),  obj.zeta_col, ...
       %              real(obj.R_col), imag(obj.R_col), phase_R_degs,  Normal_mode_R];

       tmp_data = [ [1:obj.Num_modes]',   obj.wn_col/(2*pi),  obj.zeta_col, ...
                    real(obj.R_col), imag(obj.R_col), phase_R_degs];

       fprintf('\n %s      %s      %s      %s      %s', ...
                  'mode#', 'Wn[Hz]       DAMP[-]       Real(R)          Imag(R)        Phase(R)[degs]')         
       fprintf('\n %2d       %8.3f   %10.5f    %14.6g   %14.6g  %9.2f  ', tmp_data.');
       fprintf('\n');
       fprintf('\n E = %8.6g + i*%8.6g',real(obj.E), imag(obj.E)  );
       fprintf('\n F = %8.6g + i*%8.6g',real(obj.F), imag(obj.F)  );
       %fprintf('\n%s',repmat('-',1,75));
       %fprintf('\n');
     end
   end
   %-------------------------------------------------------------------
end
%_#####################################################################
%_ PRIVATE methods
%_#####################################################################
methods(Access = private)       
   function out = calc_frf(obj, THE_S)
       H = zeros(size(THE_S)) + j*zeros(size(THE_S));
     
     for kk=1:obj.Num_modes

          R_kk      = obj.R_col(kk);
        c_R_kk      = conj( R_kk );

          lambda_kk = obj.P_col(kk);
        c_lambda_kk = conj( lambda_kk );

            H       =   H                                + ...
                        (R_kk ./ (THE_S - lambda_kk))    + ...                         
                      (c_R_kk ./ (THE_S - c_lambda_kk));
     end

     H     =  H   +   obj.E   +   (obj.F ./ (THE_S.^2));  

     out   =  H;      
   end
   %-------------------------------------------------------------------  
end
end 
