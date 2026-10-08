function tf_is_valid_release = hlp_assert_valid_release()

   tf_is_too_old = isMATLABReleaseOlderThan("R2026b");

   fprintf("\n ... Confirming you have a valid MATLAB release installed ---> ");

   if(tf_is_too_old)
       fprintf("[***_FAILED_***] , R2026b or a newer release is required")
   else
       fprintf("[PASSED]");
   end

   tf_is_valid_release = ~tf_is_too_old;

   % assert( ~tf_is_too_old, "###_MATLAB_RELEASE is too old you need R2024a or newer");

   fprintf("\n%s \n", repmat('-',1,50))
end