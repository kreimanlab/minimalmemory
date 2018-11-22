load('./subjectNameMappingMIT.mat')
mean_onlyH= [];
mean_onlyCV= [];
mean_CVH = [];

std_onlyH= [];
std_onlyCV= [];
std_CVH = [];

for i = 1:7
    fname=kk{i};
    obs = ll(i);
    load(['./TRAINED MODELS/MIT/' fname num2str(obs) '__OnlyH_MIT.mat']);
    load(['./TRAINED MODELS FEATURES/MIT/' fname num2str(obs) '_CV_HL_MIT.mat']);
    mean_onlyH =   [mean_onlyH(:); meanPredENH];
    mean_onlyCV =  [mean_onlyCV(:); meanPredENF];
    mean_CVH =     [mean_CVH(:);meanPredENCV_HL];
     
    std_onlyH =   [std_onlyH(:); stdPredENH];
    std_onlyCV =  [std_onlyCV(:); stdPredENF];
    std_CVH =     [std_CVH(:);stdPredENCV_HL];

end

clearvars -except mean_onlyH  mean_onlyE  mean_onlyCV  mean_HE  mean_CVH  mean_CVE  mean_HCVE  std_onlyH  std_onlyE  std_onlyCV  std_HE  std_CVH  std_CVE  std_HCVE

avg_onlyH =  mean(mean_onlyH);
avg_onlyCV =  mean(mean_onlyCV);
avg_CVH =  mean(mean_CVH);

SEM_onlyH =  std(mean_onlyH)/sqrt(7);
SEM_onlyCV =  std(mean_onlyCV)/sqrt(7);
SEM_CVH =  std(mean_CVH)/sqrt(7);


figure(3)
hold on
bar(categorical({'avg_onlyH', 'avg_onlyCV', 'avg_CVH'}),[avg_onlyH, avg_onlyCV, avg_CVH])
hold on
errorbar(categorical({'avg_onlyH', 'avg_onlyCV', 'avg_CVH'}),[avg_onlyH, avg_onlyCV, avg_CVH],[SEM_onlyH ,SEM_onlyCV ,SEM_CVH ]);


figure(9)
hold on
bar([1:7],mean_onlyCV,'BarWidth',0.2)
bar([1:7]+.2,mean_onlyH,'BarWidth',0.2)
bar([1:7]-.2,mean_CVH,'BarWidth',0.2)
errorbar([1:7],mean_onlyCV,std_onlyCV/10)
errorbar([1:7]+.2,mean_onlyH,std_onlyH/10)
errorbar([1:7]-.2,mean_CVH,std_CVH/10)

% T = table([mean_onlyH,mean_onlyCV,mean_CVH]);
% T=T.Var1(:,:);
% [p,~,stats] = anova1(T);
% [c,~,~,gnames] = multcompare(stats);
% T2 = table(gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6)));
% T2 = T2(:,:);
% hype=cell(3,4);
% rnk = cell(3,4);
% nn = {'onlyH','onlyCV','CV+H'};
%     
% for kk = 1:size(c,1)
%     hype{kk,1} = nn{c(kk,1)};
%     hype{kk,2} = nn{c(kk,2)};       %c(kk,2);
%     [hype{kk,3},hype{kk,4},~,~] = ttest2(T(:,c(kk,1)),T(:,c(kk,2)));
%     
%     rnk{kk,1} = nn{c(kk,1)};
%     rnk{kk,2} = nn{c(kk,2)};       
%     [rnk{kk,4},rnk{kk,3},~] = ranksum(T(:,c(kk,1)),T(:,c(kk,2)));
% end
% 
% TTEST2 = hype;
% pANOVA = p;
% ANOVA = T2;
% RANKSUM  = rnk;

clearvars -except mean_onlyH  mean_onlyE  mean_onlyCV  mean_HE  mean_CVH  mean_CVE  mean_HCVE ...
           std_onlyH  std_onlyE  std_onlyCV  std_HE  std_CVH  std_CVE  std_HCVE...
           avg_onlyH avg_onlyE avg_onlyCV avg_HE avg_CVH avg_CVE avg_HCVE ...
           SEM_onlyH SEM_onlyE SEM_onlyCV SEM_HE SEM_CVH SEM_CVE SEM_HCVE ...
           TTEST2 pANOVA ANOVA RANKSUM
