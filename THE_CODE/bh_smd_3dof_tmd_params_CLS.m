classdef bh_smd_3dof_tmd_params_CLS

    % The following properties MUST be defined in your EXCEL file
    properties (GetAccess=public, Hidden = false )
            m1      (1,1) double = 0
            m2      (1,1) double = 0
            m3      (1,1) double = 0
            kG      (1,1) double = 0
            k1      (1,1) double = 0
            k2      (1,1) double = 0   
            L1      (1,1) double = 0
            L2      (1,1) double = 0
            LG      (1,1) double = 0   
            %-----------------------------------------------
            ma      (1,1) double = 0
            mb      (1,1) double = 0
            mc      (1,1) double = 0
    end

    properties (GetAccess=protected, Hidden = true)
       EXCEL_table
       EXCEL_fname      (1,1) string
       EXCEL_sheet_name (1,1) string
    end
%_#########################################################################
    methods
        function OBJ = bh_smd_3dof_tmd_params_CLS(EXCEL_FNAME, SHEET_NAME)
            arguments 
                EXCEL_FNAME (1,1) string = "bh_smd_3dof_tmd_params_database.xlsx"
                SHEET_NAME  (1,1) string = "DEFAULT"
            end

            OBJ = init(OBJ, EXCEL_FNAME, SHEET_NAME);

        end
%--------------------------------------------------------------------------
     function data_table = summary(OBJ)
          % get list of public properties for this OBJECT   
          str_list_obj_props = string( properties(OBJ) );
        
          data_table         = OBJ.EXCEL_table;

          % Populate the table with the OBJECTS public properties
          for kk=1:length(str_list_obj_props)
                         A           = str_list_obj_props(kk);
              data_table{A, "Value"} = OBJ.(A); 
          end
 
          % remove the Symbol column
          data_table = removevars(data_table, "Symbol");
     end
%--------------------------------------------------------------------------
    end % methods
%_*************************************************************************
%   Protected methods
%_*************************************************************************
    methods (Access = protected)
%--------------------------------------------------------------------------
        function OBJ = init(OBJ, EXCEL_FNAME, SHEET_NAME)

             OBJ.EXCEL_table      = readtable(EXCEL_FNAME, "Sheet", SHEET_NAME);
             OBJ.EXCEL_fname      = EXCEL_FNAME;
             OBJ.EXCEL_sheet_name = SHEET_NAME;

             %_####################
             % ASSERTION_CHECKS_#1:
             %_####################
             % assert that the Excel COLUMN names are the following
             REQUIRED_EXCEL_COL_NAMES = ["Parameter", "Symbol", "Value", "Units"];

             str_list_excel_columns   = string(OBJ.EXCEL_table.Properties.VariableNames);

             for kk=1:length(REQUIRED_EXCEL_COL_NAMES)
                 A = REQUIRED_EXCEL_COL_NAMES(kk);
                 tmp_tf = ismember(A, str_list_excel_columns);
    
                 assert(tmp_tf, "###_ERROR:  your EXCEL table does NOT ..." + ...
                                "contain the COLUMN: <" + A + ">")
             end

             % Take the strings in the Symbol column and make these the ROW Names
             OBJ.EXCEL_table.Properties.RowNames = OBJ.EXCEL_table.Symbol;

             %_####################
             % ASSERTION_CHECKS_#2:
             %_####################
             % assert that ALL of this OBJECTS public properties are cited
             % in the EXCEL table

              % get list of public properties for this OBJECT   
              str_list_obj_props = string( properties(OBJ) );

              % get a list of the ROW labels of the EXCEL table
              str_list_EXCEL  = string(OBJ.EXCEL_table.Properties.RowNames);

              for kk=1:length(str_list_obj_props)
                   A      = str_list_obj_props(kk);
                   tmp_tf = ismember(A, str_list_EXCEL);
        
                    assert(tmp_tf, "###_ERROR:  your EXCEL table does NOT ..." + ...
                                   "contain the property: <" + A + ">")
              end % for

             %_#######################################
             % POPULATE the Object Public Properties:
             %_########################################
             % Populate the OBJECTS public properties using the EXCEL table
             for kk=1:length(str_list_obj_props)
                       A  = str_list_obj_props(kk);
                  OBJ.(A) = OBJ.EXCEL_table{A, "Value"}; 
             end              
        end % init()
%--------------------------------------------------------------------------
    end % methods (Access = protected)
end % classdef
%_#########################################################################
%     L O C A L   F U N C T I O N S
%_#########################################################################
