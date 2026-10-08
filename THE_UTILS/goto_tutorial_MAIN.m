function goto_tutorial_MAIN()

    tut_root         = bh_get_folder("THE_TUTORIALS");
    tut_start_folder = tut_root;
    
    cd(tut_start_folder);

    open START_HERE_PLEASE_TUTORIALS.mlx

    % Bring the File/Folder browser into view
    filebrowser

    % And we're done
    fprintf("\n ... we are good to go <goto_tutorial_MAIN()>")    
end
