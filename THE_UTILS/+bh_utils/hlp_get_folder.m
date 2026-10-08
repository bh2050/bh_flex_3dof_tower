function folder_name = hlp_get_folder()

  p = mfilename("fullpath");

  [folder_name,name,ext] = fileparts(p);

  folder_name = string(folder_name);
end