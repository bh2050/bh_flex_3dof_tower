function goto_PRIMER_02()

    % Navigate to the folder of interest
    tut_folder         = bh_get_folder("PRI_02");
    
    cd(tut_folder);

    % Bring the File/Folder browser into view
    pause(1)
    filebrowser
    
    % open the START_HERE file for the tutorial
    open START_HERE_PLEASE_1_floor.mlx

    % And we're done
    fprintf("\n ... we are good to go <goto_PRIMER_02()>")
end
