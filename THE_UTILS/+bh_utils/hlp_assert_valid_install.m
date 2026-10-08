function hlp_assert_valid_install()

    tf_is_valid_install       = false;   

    % echo the date
    dt = datetime('now','Format','dd-MMM-yyyy HH:mm:ss');
    ds = string(dt);

    fprintf("\n%s", repmat('-',1,50));
    fprintf("\n DATE of test:  [%s] .... version= [%s]", ds, version);

    fprintf("\n%s", repmat('-',1,50));

    % query the installation
    tf_has_all_required_prods = bh_utils.hlp_assert_valid_toolboxes();
    tf_is_valid_release       = bh_utils.hlp_assert_valid_release();
    
    % create THUMBS up/down
    if( tf_has_all_required_prods & tf_is_valid_release)
          tf_is_valid_install       = true;
    end

    if(true==tf_is_valid_install)
        LOC_show_thumbs("UP");
    else
        LOC_show_thumbs("DOWN");

        error("###_INVALID_INSTALLATION: please see the Pass/FAIL comments for your installation")
    end

end
%_#########################################################################
% SUBFUNCTIONS
%_#########################################################################
function LOC_show_thumbs(type_str)
    arguments
        type_str (1,1) string {mustBeMember(type_str, ["UP", "DOWN"])}
    end
    
    if(type_str=="UP")
       im_file = bh_utils.hlp_get_folder() + filesep + "bh_THUMBS_UP.png";
    else
       im_file = bh_utils.hlp_get_folder() + filesep + "bh_THUMBS_DOWN.png";
    end

    figure;
        imshow(im_file);

end
%--------------------------------------------------------------------------
