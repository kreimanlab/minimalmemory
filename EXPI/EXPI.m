
% Figure 2 A, B
[perf,scene_corr,face_corr,fpr,tpr] = results_allsubjects_graphMIT(1)
figure(1)
bar(perf)

[perf,scene_corr,face_corr,fpr,tpr] = results_allsubjects_graphMIT(2)
figure(2)
bar(perf)


% Figure 3 A1-I1
addpath('annotationsMIT1')
average_TvsF_property_makerMIT


% Figure 5a and S6 A
classifier_graphsMIT

% Figure S4 A, B
condiCONTINUOUSTesterMIT