function goto_exercise_01()

    % Navigate to the Exercise folder of interest
    tgt_folder         = bh_get_folder("EX_01");
    
    cd(tgt_folder);

    % Bring the File/Folder browser into view
    pause(1)
    filebrowser
    
    % open the START_HERE file for the tutorial
    open EX1_START_HERE_PLEASE.mlx

    % And we're done
    fprintf("\n ... we are good to go <goto_exercise_01()>")
end
