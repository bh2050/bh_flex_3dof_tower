function goto_tutorial_03()

    % Navigate to the folder of interest
    tut_folder         = bh_get_folder("TUT_03");
    
    cd(tut_folder);

    % Bring the File/Folder browser into view
    pause(1)
    filebrowser

    % open the starting tutorial file
    open START_HERE_PLEASE_tut03_ema_intro.mlx

    % And we're done
    fprintf("\n ... we are good to go <goto_tutorial_03()>")
end
