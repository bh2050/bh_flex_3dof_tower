classdef bh_joint_CLS
    properties
        theta         (1,1) {isnumeric} =   0;  % (rad)
        theta_dot     (1,1) {isnumeric} =   0;  % (rad/sec)
        Damp          (1,1) {isnumeric, mustBePositive} =   0.01;   % (N.m/(rad/sec));
    end
end     % classdef