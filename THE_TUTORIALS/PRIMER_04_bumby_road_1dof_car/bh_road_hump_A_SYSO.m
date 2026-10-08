classdef bh_road_hump_A_SYSO < matlab.System

    % Public, tunable properties
    properties
        Hy          = 0 % Height of hump (y direction)
        Lx          = 0 % Length of hump (x direction)
        P           = 0 % Period of window
        x_offset    = 0 % X direction offset
        NUM_PERIODS = 0 % Number of Periods 
    end

    methods
        %------------------------------------------------------------------
        function obj = bh_road_hump_A_SYSO(varargin)
            % Support name-value pair arguments when constructing object
             setProperties( obj,  nargin, varargin{:})
        end
        %------------------------------------------------------------------
        function y = get_y(OBJ, x)
        
            Hy         = OBJ.Hy;       % Height of hump (y direction)
            Lx         = OBJ.Lx;       % Length of hump (x direction)
            P          = OBJ.P;        % Period of block
            x_offset   = OBJ.x_offset; % X direction offset

            y = bh_road_profile_half_sine_periodic(x, x_offset, Lx, Hy, P);
            
            tf_x_beyond_block = x > (OBJ.x_offset + OBJ.P * OBJ.NUM_PERIODS);
            
            y(tf_x_beyond_block) = 0;
            
        end
        %------------------------------------------------------------------
        function plot_X_domain(OBJ, options)
            arguments
               OBJ
               options.Parent  = []
            end
            
            if(isempty(options.Parent))
                figure;
                hax = axes;
            else
                hax = options.Parent;
            end
            
            % choose a sensible dX for plotting
            dx = OBJ.Lx / 100;
            
            % Produce a list of x values to plot
            if(isinf(OBJ.NUM_PERIODS))
                x_list = (0 : dx : (OBJ.x_offset + 10*OBJ.P) );
            else
                x_list = (0 : dx : (OBJ.x_offset + OBJ.NUM_PERIODS*OBJ.P) );
            end
                
            y_list = get_y(OBJ, x_list);            
            
            plot(hax, x_list, y_list, '-b.');
                xlabel("X (m)");  ylabel("Y (m)");
                grid("on");
                title("X-domain of road profile");
                
                if(OBJ.Hy > 0)
                  ylim([0, 1.2*OBJ.Hy]);
                else
                  ylim([1.2*OBJ.Hy, 0]);  
                end
        end
        %------------------------------------------------------------------
        function plot_t_domain(OBJ, speed, options)
            arguments
               OBJ
               speed          (1,1) double 
               options.Parent       = []
               options.units  (1,1) string {mustBeMember(options.units,["m/s", "km/hr"])}  
               options.t_max  (1,1) = -1 % seconds
            end
            
            if(isempty(options.Parent))
                figure;
                hax = axes;
            else
                hax = options.Parent;
            end
                       
            % convert speed into m/s
            if(options.units=="km/hr")
                speed_mps   = speed * 1000 / 3600;
                speed_kmphr = speed;
            else
                speed_mps   = speed;
                speed_kmphr = speed * 3600 / 1000;
            end
            
            % what time range should we plot 
            if( options.t_max > 0 )
                t_max = options.t_max;
            else
                % t = dist/speed
                t_max = (OBJ.P*OBJ.NUM_PERIODS + OBJ.x_offset) / speed_mps; 
            end
                      
            t_list = 0:0.001:t_max;           
            x_list = speed_mps * t_list;            
            y_list = get_y(OBJ, x_list);
            
            plot(hax, t_list, y_list, '-k.');
                xlabel("t (secs)");  ylabel("Y (m)");
                grid("on");
                title("Car VELOCITY = "+speed_mps+" (m/sec)"+" = "+speed_kmphr+" (km/hr)");
                
                if(OBJ.Hy > 0)
                  ylim([0, 1.2*OBJ.Hy]);
                else
                  ylim([1.2*OBJ.Hy, 0]);  
                end
        end
       %------------------------------------------------------------------
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
        end

        function y = stepImpl(obj,u)
            % Implement algorithm. Calculate y as a function of input u and
            % discrete states.
            y = get_y(obj, u);  % u is the car's position X
        end

        function resetImpl(obj)
            % Initialize / reset discrete-state properties
        end

        %% Backup/restore functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        %% Simulink functions
        function ds = getDiscreteStateImpl(obj)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function validateInputsImpl(obj,u)
            % Validate inputs to the step method at initialization
        end

        function flag = isInputSizeMutableImpl(obj,index)
            % Return false if input size cannot change
            % between calls to the System object
            flag = false;
        end

        function num = getNumInputsImpl(obj)
            % Define total number of inputs for system with optional inputs
            num = 1;
            % if obj.UseOptionalInput
            %     num = 2;
            % end
        end

        function out = getOutputSizeImpl(obj)
            % Return size for each output port
            %out = [1 1];

            % Example: inherit size from first input port
            out = propagatedInputSize(obj,1);
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = mfilename("class"); % Use class name
            % icon = "My System"; % Example: text icon
            % icon = ["My","System"]; % Example: multi-line text icon
            % icon = matlab.system.display.Icon("myicon.jpg"); % Example: image file icon
        end

        function name = getInputNamesImpl(obj)
            % Return input port names for System block
            name = 'X_car';
        end

        function name = getOutputNamesImpl(obj)
            % Return output port names for System block
            name = 'Y_road';
        end
    end

    methods(Static, Access = protected)
        %% Simulink customization functions
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename("class"));
        end

        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename("class"));
            group.Actions = matlab.system.display.Action(@(~,obj)...
                                  plot_X_domain(obj),'Label','Plot X-domain');
                                                          
        end
    end
end
%_#########################################################################
%  LOCAl Subfunctions
%_#########################################################################
