function goto_PRIMER_04()

    % Navigate to the folder of interest
    tut_folder         = bh_get_folder("PRI_04");
    
    cd(tut_folder);

    % Bring the File/Folder browser into view
    pause(1)
    filebrowser
    
    % open the START_HERE file for the tutorial
    open bh_START_HERE_1dof_car.mlx

    % And we're done
    fprintf("\n ... we are good to go <goto_PRIMER_04()>")
end
