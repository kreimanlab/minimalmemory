load('../../subjectNameMapping.mat')

% for i = 1:9
%    fname = kk{i};
%    obs = ll(i);
%    load([fname num2str(obs) '_CV_EYE_HL_targOnly.mat']);
%    clear maxPredENALL maxPredSVMALL mdlENALLmx mdlSVMALLmx meanPredENALL meanPredSVMALL stdPredENALL stdPredSVMALL
%    save([fname num2str(obs) '_CV_EYE_onltT'],'maxPredENCV_EYE','maxPredSVMCV_EYE','mdlENCV_EYEmx','mdlSVMCV_EYEmx','meanPredENCV_EYE','meanPredSVMCV_EYE','stdPredENCV_EYE','stdPredSVMCV_EYE');
% end


for i = 1:9
   fname = kk{i};
   obs = ll(i);
   load([fname num2str(obs) '_targetsOnlyHE_.mat']);
   clearvars -except maxPredENE maxPredSVME mdlENEmx mdlSVMEmx meanPredENE meanPredSVME stdPredENE stdPredSVME fname obs i kk ll 
   save([fname num2str(obs) '_EYE_tOnly'],'maxPredENE', 'maxPredSVME', 'mdlENEmx', 'mdlSVMEmx', 'meanPredENE', 'meanPredSVME', 'stdPredENE', 'stdPredSVME','fname','obs');
end