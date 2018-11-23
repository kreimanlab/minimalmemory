function classifier_graphs_new_MFA

    load('./subjectNameMappingMFA.mat');
    % excluding subject Nick; lack of eye tracking data
    % kk = [kk(1:7),kk(9)];
    % ll = [ll(1:7),ll(9)];

    mean_onlyE= [];
    mean_onlyCV= [];
    mean_onlyHL= [];
    mean_onlyHLEYE = [];
    mean_CV_EYE = [];
    mean_HL_EYE = [];
    mean_CV_HL = [];
    mean_CV_HL_EYE = []; % everything except fixation annotataions
    mean_CV_HLEYE = []; % this has everything


    std_onlyE= [];
    std_onlyCV= [];
    std_onlyHL= [];
    std_onlyHLEYE = [];
    std_CV_EYE = [];
    std_HL_EYE = [];
    std_CV_HL = [];
    std_CV_HL_EYE = []; 
    std_CV_HLEYE = [];

    for i = 1:size(kk,2)
        fnam=kk{i};
        obs = ll(i);
        load(['./EYE/' fnam num2str(obs) '_EYE_tOnly.mat']);
        load(['./CV/' fnam num2str(obs) '_CV.mat']);
        load(['./CV_EYE/' fnam num2str(obs) '_CV_EYE_onltT.mat']);
        load(['./CV_HL/' fnam num2str(obs) '_CV_HL.mat']);
        load(['./CV_HL_ADDEYE/' fnam num2str(obs) '_CV_HL_ADDEYE.mat']);
        load(['./CV_HLEYE/' fnam num2str(obs) '_CV_HLEYE.mat']);

        mean_onlyCV        = [mean_onlyCV(:);      meanPredENF];
        mean_onlyHL        = [mean_onlyHL(:);      meanPredEN_HL];
        mean_CV_HL         = [mean_CV_HL(:);       meanPredENCV_HL];    
        if strcmp(kk{i},'Nick') || strcmp(kk{i},'Kristi')
            mean_onlyE         = [mean_onlyE(:);       NaN];
            mean_onlyHLEYE     = [mean_onlyHLEYE(:);   NaN];
            mean_CV_EYE        = [mean_CV_EYE(:);      NaN];
            mean_HL_EYE        = [mean_HL_EYE(:);      NaN];
            mean_CV_HL_EYE     = [mean_CV_HL_EYE(:);   NaN];
            mean_CV_HLEYE      = [mean_CV_HLEYE(:);    NaN];

        else
            mean_onlyE         = [mean_onlyE(:);       meanPredENE];
            mean_onlyHLEYE     = [mean_onlyHLEYE(:);   meanPredEN_HLEYE];
            mean_CV_EYE        = [mean_CV_EYE(:);      meanPredENCV_EYE];
            mean_HL_EYE        = [mean_HL_EYE(:);      meanPredEN_HL_EYE]; 
            mean_CV_HL_EYE     = [mean_CV_HL_EYE(:);   meanPredENCV_HL_EYE];
            mean_CV_HLEYE      = [mean_CV_HLEYE(:);    meanPredENALL];
        end
    end

    clearvars -except mean_onlyE  mean_onlyCV  mean_onlyHL  mean_onlyHLEYE   mean_CV_EYE   mean_HL_EYE   mean_CV_HL   mean_CV_HL_EYE   mean_CV_HLEYE   
    % return
        avg_onlyE         =   mean(mean_onlyE(~isnan      (mean_onlyE(:))    ));
        avg_onlyCV        =   mean(mean_onlyCV(~isnan     (mean_onlyCV(:))    ));
        avg_onlyHL        =   mean(mean_onlyHL(~isnan     (mean_onlyHL(:))    ));
        avg_onlyHLEYE     =   mean(mean_onlyHLEYE(~isnan  (mean_onlyHLEYE(:)) ));
        avg_CV_EYE        =   mean(mean_CV_EYE(~isnan     (mean_CV_EYE(:))    ));
        avg_HL_EYE        =   mean(mean_HL_EYE(~isnan     (mean_HL_EYE(:))    ));
        avg_CV_HL         =   mean(mean_CV_HL(~isnan      (mean_CV_HL(:))     ));
        avg_CV_HL_EYE     =   mean(mean_CV_HL_EYE(~isnan  (mean_CV_HL_EYE(:)) ));
        avg_CV_HLEYE      =   mean(mean_CV_HLEYE(~isnan   (mean_CV_HLEYE(:))  ));

        SEM_onlyE         =   std(mean_onlyE(~isnan      (mean_onlyE(:))    ))/ sqrt(sum((~isnan      (mean_onlyE(:))) ));
        SEM_onlyCV        =   std(mean_onlyCV(~isnan     (mean_onlyCV(:))    ))/ sqrt(sum((~isnan     (mean_onlyCV(:))) ));
        SEM_onlyHL        =   std(mean_onlyHL(~isnan     (mean_onlyHL(:))    ))/ sqrt(sum((~isnan     (mean_onlyHL(:))) ));
        SEM_onlyHLEYE     =   std(mean_onlyHLEYE(~isnan  (mean_onlyHLEYE(:)) ))/ sqrt(sum((~isnan  (mean_onlyHLEYE(:))) ));
        SEM_CV_EYE        =   std(mean_CV_EYE(~isnan     (mean_CV_EYE(:))    ))/ sqrt(sum((~isnan     (mean_CV_EYE(:)))));
        SEM_HL_EYE        =   std(mean_HL_EYE(~isnan     (mean_HL_EYE(:))    ))/ sqrt(sum((~isnan     (mean_HL_EYE(:))) ));
        SEM_CV_HL         =   std(mean_CV_HL(~isnan      (mean_CV_HL(:))     ))/ sqrt(sum((~isnan      (mean_CV_HL(:))) ));
        SEM_CV_HL_EYE     =   std(mean_CV_HL_EYE(~isnan  (mean_CV_HL_EYE(:)) ))/ sqrt(sum((~isnan  (mean_CV_HL_EYE(:))) ));
        SEM_CV_HLEYE      =   std(mean_CV_HLEYE(~isnan   (mean_CV_HLEYE(:))  ))/ sqrt(sum((~isnan   (mean_CV_HLEYE(:))) ));
    % return
    figure(20)
    hold on
    bar(categorical({'1onlyE',  '2onlyCV',  '3onlyHL',  '4onlyHLEYE',   '5CV+EYE',   '6HL+EYE',   '7CV+HL',   '8CV+HL+EYE',  '9CV+HLEYE'}),...
    [avg_onlyE, avg_onlyCV, avg_onlyHL, avg_onlyHLEYE,  avg_CV_EYE,  avg_HL_EYE,  avg_CV_HL,  avg_CV_HL_EYE,  avg_CV_HLEYE ]);	
    %  bar(categorical({'1onlyE',  '2onlyCV',  '3onlyHL',  '4onlyHLEYE',   '5CV+EYE',   '6HL+EYE',   '7CV+HL',   '8CV+HL+EYE',  '9CV+HLEYE'}),...
    % [avg_onlyE, avg_onlyCV, avg_onlyHL, avg_onlyHLEYE,  avg_CV_EYE,  avg_HL_EYE,  avg_CV_HL,  avg_CV_HL_EYE,  avg_CV_HLEYE ]);	
    hold on
    errorbar(categorical({'1onlyE',  '2onlyCV',  '3onlyHL',  '4onlyHLEYE',   '5CV+EYE',   '6HL+EYE',   '7CV+HL',   '8CV+HL+EYE',  '9CV+HLEYE'}),...
        [avg_onlyE, avg_onlyCV, avg_onlyHL, avg_onlyHLEYE,  avg_CV_EYE,  avg_HL_EYE,  avg_CV_HL,  avg_CV_HL_EYE,  avg_CV_HLEYE ], [SEM_onlyE, SEM_onlyCV, SEM_onlyHL, SEM_onlyHLEYE,  SEM_CV_EYE,  SEM_HL_EYE,  SEM_CV_HL,  SEM_CV_HL_EYE,  SEM_CV_HLEYE]);

    figure(10)
    hold on

    kkkk = 0.095;
    yyyy = kkkk;
    bar([1:9]-4*kkkk,mean_onlyE,'BarWidth',yyyy);
    bar([1:9]-3*kkkk,mean_onlyCV,'BarWidth',yyyy);
    bar([1:9]-2*kkkk,mean_onlyHL,'BarWidth',yyyy);
    bar([1:9]-kkkk,mean_onlyHLEYE ,'BarWidth',yyyy);
    bar([1:9],mean_CV_EYE ,'BarWidth',yyyy);
    bar([1:9]+kkkk,mean_HL_EYE ,'BarWidth',yyyy);
    bar([1:9]+2*kkkk,mean_CV_HL ,'BarWidth',yyyy);
    bar([1:9]+3*kkkk,mean_CV_HL_EYE ,'BarWidth',yyyy);
    bar([1:9]+4*kkkk,mean_CV_HLEYE ,'BarWidth',yyyy);


%     T = table([mean_onlyE, mean_onlyCV, mean_onlyHL, mean_onlyHLEYE , mean_CV_EYE , mean_HL_EYE , mean_CV_HL , mean_CV_HL_EYE , mean_CV_HLEYE ]);
%     T=T.Var1(:,:);
%     [p,~,stats] = anova1(T);
%     [c,~,~,gnames] = multcompare(stats);
%     T2 = table(gnames(c(:,1)), gnames(c(:,2)), num2cell(c(:,3:6)));
%     T2 = T2(:,:);
%     hype=cell(36,4);
%     rnk = cell(36,4);
%     nn = {'onlyE',  'onlyCV',  'onlyHL',  'onlyHLEYE',   'CV+EYE',   'HL+EYE',   'CV+HL',   'CV+HL+EYE',  'CV+HLEYE'};
%     for kk = 1:36
%         hype{kk,1} = nn{c(kk,1)};
%         hype{kk,2} = nn{c(kk,2)};       %c(kk,2);
%         [hype{kk,3},hype{kk,4},~,~] = ttest2(T(:,c(kk,1)),T(:,c(kk,2)));
% 
%         rnk{kk,1} = nn{c(kk,1)};
%         rnk{kk,2} = nn{c(kk,2)};       
%         [rnk{kk,4},rnk{kk,3},~] = ranksum(T(:,c(kk,1)),T(:,c(kk,2)));
%     end
%     % 
%     TTEST2 = hype;
%     pANOVA = p;
%     ANOVA = T2;
%     RANKSUM  = rnk;

    clearvars -except mean_onlyHL  mean_onlyE mean_onlyCV mean_onlyHL mean_onlyHLEYE  mean_CV_EYE  mean_HL_EYE  mean_CV_HL  mean_CV_HL_EYE  mean_CV_HLEYE ...
               SEM_onlyHL  SEM_onlyE SEM_onlyCV SEM_onlyHL SEM_onlyHLEYE  SEM_CV_EYE  SEM_HL_EYE  SEM_CV_HL  SEM_CV_HL_EYE  SEM_CV_HLEYE...
               avg_onlyHL  avg_onlyE avg_onlyCV avg_onlyHL avg_onlyHLEYE  avg_CV_EYE  avg_HL_EYE  avg_CV_HL  avg_CV_HL_EYE  avg_CV_HLEYE...
               TTEST2 pANOVA ANOVA RANKSUM


end











