function goto_PRIMER_00()

    % Navigate to the folder of interest
    tut_folder         = bh_get_folder("PRI_00");
    
    cd(tut_folder);

    % Bring the File/Folder browser into view
    pause(1)
    filebrowser
    
    % open the START_HERE file for the tutorial
    open bh_START_HERE_PLEASE_1LINK_ROBOT.mlx

    % And we're done
    fprintf("\n ... we are good to go <goto_PRIMER_00()>")
end
