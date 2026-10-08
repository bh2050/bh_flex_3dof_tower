classdef CLS_BLN

    properties (SetAccess=protected)
        F_pass_Hz 
        F_stop_Hz 
        Fs_Hz
        dt
        F_nyq_Hz
        Hd
        %----------------------------------
        y_col
        t_col
        f_hz_col
    end

    methods
        function obj = CLS_BLN(F_pass_Hz, F_stop_Hz, Fs_Hz)
            obj.F_pass_Hz = F_pass_Hz;
            obj.F_stop_Hz = F_stop_Hz;
            obj.Fs_Hz     = Fs_Hz;
            obj.F_nyq_Hz  = Fs_Hz/2;
            obj.dt        = 1/Fs_Hz;

            obj = design_LPF(obj);
        end
        %------------------------------------------------------------------
        function obj = create_sig(obj,N_points, Mag_y)
            rng(0);

            tmp_sig      = randn(N_points,1);

            tmp_sig      = tmp_sig / max(abs(tmp_sig));
            tmp_sig      = Mag_y * tmp_sig;

            obj.y_col    = obj.Hd.filter(tmp_sig);
            obj.t_col    = obj.dt * [0:(N_points-1)]';

            df_hz = 1/(obj.dt * N_points);

            obj.f_hz_col = df_hz * [0:(N_points-1)]';
        end
        %------------------------------------------------------------------
        function plot(obj, hax)
            if(nargin == 1)
                hax = axes();
            end

            axes(hax);

            plot(obj.t_col, obj.y_col, "-b.");
                xlabel("secs");
                ylabel(" (NEWTONS)");
                axis tight
        end
        %------------------------------------------------------------------
        function plot_psd(obj)
             pwelch(obj.y_col, [], [], [], obj.Fs_Hz);
                axis tight
        end
        %------------------------------------------------------------------
    end
%-#########################################################################    
methods (Access=protected)
    function obj = design_LPF(obj)
        Apass = 1;       % Passband Ripple (dB)
        Astop = 100;      % Stopband Attenuation (dB)
        match = 'both';  % Band to match exactly
        
        Fpass = obj.F_pass_Hz/obj.F_nyq_Hz;
        Fstop = obj.F_stop_Hz/obj.F_nyq_Hz;

        % Construct an FDESIGN object and call its ELLIP method.
        h  = fdesign.lowpass(Fpass, Fstop, Apass, Astop);
        Hd = design(h, 'ellip', 'MatchExactly', match); 

        obj.Hd = Hd;
    end


end % methods (Access=protected)

end % classdef


