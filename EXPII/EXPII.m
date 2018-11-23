%FIGURE 2C
% plot performance of each subject for EXP II
[perf,scene_corr,face_corr,fpr,tpr] = results_allsubjects_graphMFA;
figure(1)
bar(perf)
%FIGURE 2F
% plot fpr and tpr for EXP II
figure(2)
scatter(fpr,tpr)

display('close other figures and press enter to proceed')
pause
% Figure 4
average_properties_makerMFA

display('close other figures and press enter to proceed')
pause
addpath('./annotationInfoMFA/RA2/')
% Figure 3 A2-I2
averageTargetsVFoils_similar_exp1_MFA


display('close other figures and press enter to proceed')
pause
%Figure S3 B
[mmm,sss] = time_distribution_between_framesMFA
figure(3)
bar([1:50],mmm(1:50))
hold on
errorbar([1:50],mmm(1:50),sss(1:50)/sqrt(9))

display('close other figures and press enter to proceed')
pause
%Figure S4C
figure(4)
[kkkk] = time_dependence_checker_MFA
ft = fittype('testExp(x,b,c)');
yfit = fit([1:100]',kkkk(1:100),ft,'Lower',[0,-Inf],'Upper',[Inf,0]);
scatter([1:100],kkkk(1:100))
hold on
plot(yfit);
% yfit

display('close other figures and press enter to proceed')
pause
% Figure 5B and S6B (set bar width to 0.1 for proper visualization)
addpath(genpath('./TRAINED_MODELS _MFA_NEW'))
% cd into TRAINED_MODELS _MFA_NEW and run the following function
classifier_graphs_new_MFA













