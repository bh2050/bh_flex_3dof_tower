classdef CLS_meas_frf
%MEAS_FRF A data container for a measured Fequency Reesponse Function(FRF)
%==========================================================================
% USAGE:
%  #1.)   >> OBJ = CLS_meas_frf(the_fhz_col, the_real_col, the_imag_col)
%  #2.)   >> OBJ = CLS_meas_frf(the_fhz_col, the_real_col, the_imag_col, coher_col)
%==========================================================================
% DESCRIPTION:
%  The MEAS_FRF class is used to store a measured FRF
%==========================================================================
% INPUTS:
%  the_fhz_col   : an array of frequencies that we have an FRF measurement for
%                  The fequency UNITS must be in [Hz]
%
%  the_real_col  : an array of the real part of the FRF
%                   
%  the_imag_col  : an array the imaginary part of the FRF
%
%  the_coher_col : an array of the coherance associated with the FRF measurement 
%==========================================================================
% CLASS_METHODS:
%   frf    = obj.frf
%   fhz    = obj.fhz
%   re     = obj.real
%   im     = obj.imag
%   ph_deg = obj.phase
%   ph_deg = obj.phase('DEGS')
%   ph_rad = obj.phase('RADS')
%   mag    = obj.mag
%   db     = obj.db
%            obj.plot_db
%            obj.plot_db(h_ax)
%   h_ax   = obj.plot_db 
%            obj.plot_coher_db
%            obj.plot_coher_db(h_ax)
%   h_ax   = obj.plot_coher_db 
%==========================================================================
% NOTES:
%  When you set the "working_fhz_range" field, ALL subsequent manipulations
%  of the FRF are done over this specified frequency range.  The default value 
%  for "working_fhz_range" is FULL, ie: all of the frequencies.
%==========================================================================
% TYPICAL_USAGE: 
% 
% A_WORKING_EXAMPLE_TEST_SCRIPT:
%
%     >> bh_test_harness_for_CE_algorithm
%--------------------------------------------------------------------------
% USAGE #1:
%     >> my_frf_OBJ = CLS_meas_frf(     f_hz_col,  ...
%                                   real(new_frf), ...
%                                   imag(new_frf), ...
%                                      coher_col );
% 
%     >> my_frf_OBJ.plot_coher_db();     
%--------------------------------------------------------------------------
%
% USAGE #2:
%     >> my_frf_OBJ = CLS_meas_frf(     f_hz_col,  ...
%                                   real(new_frf), ...
%                                   imag(new_frf), ...
%                                      coher_col );
%
%     >> my_frf_OBJ.working_fhz_range = [20 100];   % <---sets freq band of interest
%
%     >> my_frf_OBJ.plot_coher_db();   
%     >> my_frf_OBJ.mag();   
%     >> my_frf_OBJ.db();   
%     >> my_frf_OBJ.phase('DEGS');   
%==========================================================================
% Bradley Horton :    bradley.horton@mathworks.com.au
%==========================================================================
   properties(SetAccess = private, GetAccess = public)
       df_hz               = [];
       fhz_max             = [];
       fhz_min             = [];
       N_samples           = [];
   end
   
   properties(SetAccess = public, GetAccess = public)
       ID_label           = '---';
       working_fhz_range  = [0 0];
       display_plot_title = true;
       input_sensor_label  = '123_X';
       output_sensor_label = '456_Z';
       type                = 'Receptance';
   end
  
   properties(Hidden = true, SetAccess = private, GetAccess = private)
       fhz_col           = [];
       real_col          = [];
       imag_col          = []; 
       coher_col         = [];
       Fs_hz             = 0; 
       Nyquist_hz        = 0;
       working_fhz_ind   = [];
       working_fhz_max   = [];
       working_fhz_min   = [];   
   end
   %_#####################################################################
   %_ PUBLIC methods
   %_#####################################################################
   methods
       function obj = CLS_meas_frf(the_fhz_col, the_real_col, the_imag_col, varargin)
                 
         obj.fhz_col           = the_fhz_col(:);
         obj.real_col          = the_real_col(:);
         obj.imag_col          = the_imag_col(:);
         
         if(length(varargin) >= 1)
              obj.coher_col = varargin{1}(:);
         else
              obj.coher_col = [];
         end
        
         obj.ID_label          = '-----';   
         
         obj.N_samples         = length(obj.fhz_col);
         obj.df_hz             = obj.fhz_col(2) - obj.fhz_col(1);
         obj.Fs_hz             = obj.N_samples * obj.df_hz;
         obj.Nyquist_hz        = obj.Fs_hz/2;
         obj.fhz_min           = min(obj.fhz_col(:));
         obj.fhz_max           = max(obj.fhz_col(:));

         
         obj.working_fhz_range = [obj.fhz_min  obj.fhz_max];
         obj.working_fhz_max   = obj.fhz_max;
         obj.working_fhz_min   = obj.fhz_min;   
         obj.working_fhz_ind   = 1:length(obj.fhz_col);
       end
       %-------------------------------------------------------------------
       function obj = set.working_fhz_range(obj, the_fhz_range)
         % Allowed USAGE:
         %   A.working_fhz_range = [20 100]
         %   A.working_fhz_range = 'full'
           
         if( ischar(the_fhz_range) )
             if( strcmp(lower(the_fhz_range),'full') )
                obj.working_fhz_min   = obj.fhz_col(1);
                obj.working_fhz_max   = obj.fhz_col(end);
                obj.working_fhz_range = [obj.working_fhz_min   obj.working_fhz_max];
                obj.working_fhz_ind   = [1:length(obj.fhz_col)]; 
             else
                 error('###_ERROR: Unknown string');
             end
         else
             % eg: [20 100]
             obj.working_fhz_min   = the_fhz_range(1);
             obj.working_fhz_max   = the_fhz_range(2);
             obj.working_fhz_range = [obj.working_fhz_min   obj.working_fhz_max];
             obj.working_fhz_ind   = find( (obj.fhz_col <= obj.working_fhz_max) & ...
                                       (obj.fhz_col >= obj.working_fhz_min) );
         end
       end
       %-------------------------------------------------------------------   
       function out = frf(obj)
         out =  obj.working_real + j*obj.working_imag;  
       end
       %-------------------------------------------------------------------   
       function out = real(obj)
         out =  obj.working_real; 
       end 
       %-------------------------------------------------------------------                      
       function out = imag(obj)
         out =  obj.working_imag; 
       end           
       %-------------------------------------------------------------------   
       function out = fhz(obj)
         out =  obj.working_fhz; 
       end              
       %-------------------------------------------------------------------         
       function out = mag(obj)
         out = abs( obj.working_real + j*obj.working_imag ); 
       end
       %-------------------------------------------------------------------
       function out = db(obj, varargin)
         out = 20*log10(  abs( obj.working_real + j*obj.working_imag )  );
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
         % out = phase(obj.working_real + j*obj.working_imag);

         THE_FRF = obj.working_real + j*obj.working_imag;
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
       function out = coher(obj)
         out = working_coher(obj);
       end
       %-------------------------------------------------------------------
       function  plot(obj)      
          figure
          hax(1) = subplot(2,1,1);
          hax(2) = subplot(2,1,2);
          
          obj.plot_db(hax(1));
          obj.plot_phase(hax(2));
        end
       %-------------------------------------------------------------------
       function varargout = plot_db(obj, varargin)
           % ALLOWED USAGE:
           %   A.plot_db
           %   A.plot_db(h_ax)
           %   A.plot_db(h_ax, '-r.')
           %   h_ax = A.plot_db 
           
           % Check INPUT arguments
           switch(length(varargin))
               case 0
                       h_f        = figure();
                       h_ax       = axes('Tag', obj.ID_label);
                       LSPEC      = '-b';
               case 1
                       h_ax       = varargin{1};
                       hold on
                       LSPEC      = '-b';
               case 2
                       h_ax       = varargin{1};
                       hold on
                       LSPEC      = varargin{2}; 
               otherwise
                   error('###_UNKNOWN arg list to PLOT !');
           end
       
           plot(h_ax, obj.working_fhz, obj.db, LSPEC,'LineWidth',2);
           xlabel(h_ax,'[Hz]', 'FontWeight', 'Bold');
           ylabel(h_ax,'[dB]', 'FontWeight', 'Bold'); 
           grid(h_ax,'on');
           axis(h_ax,'tight');
           if(obj.display_plot_title)
               title(h_ax,['MEAS Frequency Response Function for: <',obj.ID_label,'>'],...
                      'FontWeight', 'Bold', 'Interpreter', 'none');           
           end
           
           drawnow
           if(1==nargout)
               varargout{1} = h_ax;
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

         hold(h_ax,"on")
                  
           plot(h_ax, obj.working_fhz, obj.phase(opts_T.UNITS), LSPEC,'LineWidth',2);
           xlabel(h_ax,'[Hz]',   'FontWeight', 'Bold');
              tmp_list = ['[',opts_T.UNITS,']'];
           ylabel(h_ax,tmp_list, 'FontWeight', 'Bold'); 
           grid(h_ax,'on');
           axis(h_ax,'tight');
           if(obj.display_plot_title)
               title(h_ax,['MEAS Frequency Response Function for: <',obj.ID_label,'>'],...
                      'FontWeight', 'Bold', 'Interpreter', 'none');           
           end
           
           drawnow
           if(1==nargout)
               varargout{1} = h_ax;
           end
       end 
       %-------------------------------------------------------------------
       function varargout = plot_coher_db(obj, varargin)
           % ALLOWED USAGE:
           %   A.plot_coher_db
           %   A.plot_coher_db(h_ax)
           %   h_ax = A.plot 
   
           % Check INPUT arguments
           switch(length(varargin))
               case 0
                       h_ax       = axes('Tag', obj.ID_label);
               case 1
                       h_ax       = varargin{1};
               otherwise
                   error('###_UNKNOWN arg list to PLOT !');
           end
       
           if( isempty(obj.coher_col) )
              plot(h_ax, obj.working_fhz, obj.db);
              xlabel('[Hz]', 'FontWeight', 'Bold');
              ylabel('[dB]', 'FontWeight', 'Bold'); 
              grid on, axis tight
              title(['Frequency Response Function for: <',obj.ID_label,'>'],'FontWeight', 'Bold');
           else
               axes(h_ax);
              [AX,H1,H2] = plotyy(obj.working_fhz, obj.db, ...
                                  obj.working_fhz, obj.coher,'plot'); 
               grid on
               title(['Frequency Response Function for: <',obj.ID_label,'>'],'FontWeight', 'Bold');
               
               set(H2,    'Color',  'red', 'LineWidth', 2);
               set(AX(2),'YColor', 'red');
               
               %axis(AX,'tight')
               h_ax = AX;
               
               h_ax(2).Tag  = 'TAG_AX_COHER';
               
               xlim(h_ax(1), [obj.working_fhz_min   obj.working_fhz_max]);
               xlim(h_ax(2), [obj.working_fhz_min   obj.working_fhz_max]);
           end
           
           if(1==nargout)
               varargout{1} = h_ax;
           end
       end
       %-------------------------------------------------------------------  
       function hax = update_stab_plot(OBJ, fn_hz)
           h = findobj('Type','axes', 'Tag','TAG_AX_COHER');
           
           if(isempty(h))
               hax      = OBJ.plot_coher_db();
               h_ax_tgt = hax(2);
           else
               h_ax_tgt = h(1);
           end
           hold(h_ax_tgt,'on') 
           
           y = 0.5 + 0.5*rand(size(fn_hz));
           
           plot(h_ax_tgt, fn_hz, y,'ro','MarkerEdgeColor','k', ...
                    'MarkerFaceColor','g', 'MarkerSize',6);
                
           drawnow;               
       end
       %-------------------------------------------------------------------  
   end
   %_#####################################################################
   %_ PRIVATE methods
   %_#####################################################################
   methods(Access = private)
       function out = working_fhz(obj)
         out = obj.fhz_col(obj.working_fhz_ind);    
       end
       %-------------------------------------------------------------------
       function out = working_real(obj)
         out = obj.real_col(obj.working_fhz_ind);    
       end
       %-------------------------------------------------------------------
       function out = working_imag(obj)
         out = obj.imag_col(obj.working_fhz_ind);    
       end 
       %-------------------------------------------------------------------
       function out = working_coher(obj)
         out = obj.coher_col(obj.working_fhz_ind);    
       end 
       %-------------------------------------------------------------------       
       function out = working_phase(obj)
         out = obj.phase('DEGS');    
       end 
       %-------------------------------------------------------------------            
   end
   
end 
