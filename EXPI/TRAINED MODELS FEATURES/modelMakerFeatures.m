reps =100;
for i = 1:size(kk,2)
    fname = kk{i};
    obs = ll(i);
    [mdlSVMCV_HLmx,mdlENCV_HLmx,meanPredSVMCV_HL,stdPredSVMCV_HL,maxPredSVMCV_HL,meanPredENCV_HL,stdPredENCV_HL,maxPredENCV_HL...         
          ,mdlSVMFmx,mdlENFmx,meanPredSVMF,stdPredSVMF,maxPredSVMF,meanPredENF,stdPredENF,maxPredENF ] = gettingCloser_CV_HL_MIT(fname,obs, reps);
    %           ,mdlSVMFmx,mdlENFmx,meanPredSVMF,stdPredSVMF,maxPredSVMF,meanPredENF,stdPredENF,maxPredENF ] = gettingCloser_CV_HL_Overall(fname,obs, reps);
    save(char(string([fname num2str(obs) '_CV_HL_MIT.mat'])),'fname','obs','mdlSVMCV_HLmx','mdlENCV_HLmx','meanPredSVMCV_HL','stdPredSVMCV_HL','maxPredSVMCV_HL','meanPredENCV_HL','stdPredENCV_HL','maxPredENCV_HL','mdlSVMFmx','mdlENFmx','meanPredSVMF','stdPredSVMF','maxPredSVMF','meanPredENF','stdPredENF','maxPredENF');
% 
%     [mdlSVMALLmx,mdlENALLmx,meanPredSVMALL,stdPredSVMALL,maxPredSVMALL,meanPredENALL,stdPredENALL,maxPredENALL...
%           ,mdlSVMCV_EYEmx,mdlENCV_EYEmx,meanPredSVMCV_EYE,stdPredSVMCV_EYE,maxPredSVMCV_EYE,meanPredENCV_EYE,stdPredENCV_EYE,maxPredENCV_EYE] = gettingCloser_CV_EYE_HL_TargetsOnly(fname,obs, reps);       
%     save(char(string([fname num2str(obs) '_CV_EYE_HL_targOnly.mat'])),'fname','obs','mdlSVMALLmx','mdlENALLmx','meanPredSVMALL','stdPredSVMALL','maxPredSVMALL','meanPredENALL','stdPredENALL','maxPredENALL','mdlSVMCV_EYEmx','mdlENCV_EYEmx','meanPredSVMCV_EYE','stdPredSVMCV_EYE','maxPredSVMCV_EYE','meanPredENCV_EYE','stdPredENCV_EYE','maxPredENCV_EYE');
end
