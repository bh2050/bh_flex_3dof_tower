function startup_goto_tutorial()

    % clear the COMMAND WINDOW
    clc

    % define some unicode CHAR constants
    c_GOOD = char(10003);
    c_BAD  = char(10007);

    % Echo Workshop banner into command window
    fprintf("\n%s", repmat('-',1,75));
    fprintf("\n Workshop Mechanical Vibrations and Flexible Bodies - the 3-floor-tower")
    fprintf("\n%s", repmat('-',1,75));

    % Clear the contents of the BUILD folder
    the_folder = bh_get_folder("THE_BUILD");
    bh_clear_THE_FOLDER(the_folder);
    fprintf("\n --> [%c] BUILD folder cleared - 1st clean", c_GOOD);

    % Load the Simscape library into memory - so that models launch faster (?)
    % the first time
    try
        tic;    load_system('simulink');    fprintf("\n ... [%c] Simulink    loaded in [%f] seconds", c_GOOD, toc);
        tic;    load_system('simscape');    fprintf("\n ... [%c] Simscape    loaded in [%f] seconds", c_GOOD, toc);
        tic;    load_system('sm_lib');      fprintf("\n ... [%c] Simscape_SM loaded in [%f] seconds", c_GOOD, toc);
    catch ME
        fprintf("\n ### [%c] ERROR:  Unable to load Simulink or Simscape libraries", c_BAD);
    end

    % Perhaps redundant, run the GREASE model to again load some
    % libraries into memory
    try
          tic;  bh_grease_it.bh_apply_grease;  fprintf("\n ... [%c] GREASE model run in [%f] seconds", c_GOOD, toc);         
    catch ME
          fprintf("\n ### [%c] ERROR:  Unable to run the GREASE model", c_BAD);
    end

    % Clear the contents of the BUILD folder
    the_folder = bh_get_folder("THE_BUILD");
    bh_clear_THE_FOLDER(the_folder);
    fprintf("\n --> [%c] BUILD folder cleared - 2nd clean", c_GOOD);

    % Navigate to the THE_TUTORIAL folder
    tut_root         = bh_get_folder("THE_TUTORIALS");
    tut_start_folder = tut_root;
    
    cd(tut_start_folder);

    % IFF it's open close the "START_HERE_PLEASE_PROJECT.mlx"
    % bh_close_file_in_editor("START_HERE_PLEASE_PROJECT.mlx")
       
    % Launch the Tutorials START_HERE
    open START_HERE_PLEASE_TUTORIALS.mlx

    % Bring the File/Folder browser into view
    % pause(1)
    % filebrowser

    % And we're done
    fprintf("\n ... [%c] completed <startup_goto_tutorial()>", c_GOOD);
    fprintf("\n%s", repmat('-',1,75));
    fprintf("\n");
end
