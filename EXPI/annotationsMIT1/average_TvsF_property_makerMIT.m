load('./subjectNameMappingMIT.mat');
% kk = [kk(1:7),kk(9)];
avg_array = zeros(size(kk,2),20+2);
targets_denom_array = zeros(size(kk,2),20+2);
denominator_array = zeros(size(kk,2),20);
subnum  =size(kk,2);
% kk represents subject names stores in a cell array

for i = 1 :subnum
    load(fullfile([char(kk(i)) '.mat'])); 
    ResultAnnotation = sortrows(ResultAnnotation,'Foiltarget','descend');
    xx = find(ResultAnnotation.Foiltarget=='foil''',1);
    ResultAnnotationT = ResultAnnotation(1:xx-1, 1:26);
    ResultAnnotationF = ResultAnnotation(xx:end, 1:26);
  %faces vs scenes begins  
    cnt_face=0;
    cnt_face_corr=0;
    cnt_scene = 0;
    cnt_scene_corr = 0;   
    for j = 1:size(ResultAnnotationT,1)
        if ResultAnnotationT.facescene(j) == 'face'''
            cnt_face=cnt_face+1;
            if ResultAnnotationT.Correct1yes0no(j)>0
                cnt_face_corr=cnt_face_corr+1;
            end
        else
            cnt_scene = cnt_scene+1;
            if ResultAnnotationT.Correct1yes0no(j)==1
                cnt_scene_corr=cnt_scene_corr+1;
            end    
        end
    end    
    avg_array(i,47) = cnt_face_corr/cnt_face;
    avg_array(i,48) = cnt_scene_corr/cnt_scene;
    denominator_array(i,47) = cnt_face;
    denominator_array(i,48) = cnt_scene;
    
    cnt_face=0;
    cnt_face_corr=0;
    cnt_scene = 0;
    cnt_scene_corr = 0;   
    for j = 1:size(ResultAnnotationF,1)
        if ResultAnnotationF.facescene(j) == 'face'''
            cnt_face=cnt_face+1;
            if ResultAnnotationF.Correct1yes0no(j)>0
                cnt_face_corr=cnt_face_corr+1;
            end
        else
            cnt_scene = cnt_scene+1;
            if ResultAnnotationF.Correct1yes0no(j)==1
                cnt_scene_corr=cnt_scene_corr+1;
            end    
        end
    end    
    avg_array(i,49) = cnt_face_corr/cnt_face;
    avg_array(i,50) = cnt_scene_corr/cnt_scene;
    denominator_array(i,49) = cnt_face;
    denominator_array(i,50) = cnt_scene;  
%faces vs scenes done
    for j = 1:20
        numerator = 0;
        denominator = 0;
        rows = size(ResultAnnotationT,1);
        parfor k = 1:rows
            if ResultAnnotationT{k,7+j-1} == 1 
                if ResultAnnotationT.Correct1yes0no(k) == 1
                   numerator = numerator + 1; 
                end
                denominator = denominator +1;
            end
        end
        if denominator >= 1
            denominator_array(i,7+2*(j-1)) = denominator;
            avg_array(i,7+2*(j-1)) = numerator/denominator;
        else 
            disp(['no error Target: dividing by  zero therefore putting NaN: ' char(kk(i)) ' ' num2str(j) ' ' denominator]);
            avg_array(i,7+2*(j-1)) = NaN;                
        end
        
        rows = size(ResultAnnotationF,1);
        numerator = 0;
        denominator = 1;
        parfor k = 1:rows
            if ResultAnnotationF{k,7+j-1} == 1 
                if ResultAnnotationF.Correct1yes0no(k) == 1
                   numerator = numerator + 1; 
                end
                denominator = denominator +1;
            end
        end
        if denominator >= 1
            denominator_array(i,7+2*j-1) = denominator;
            avg_array(i,7+2*j-1) = numerator/denominator;
        else 
            disp(['no error Foil: dividing by  zero therefore putting NaN: ' char(kk(i)) ' ' num2str(j) ' ' denominator]);
            avg_array(i,7+2*j-1) = NaN;                
        end
        
    end    
end

final_data = array2table(avg_array(:,7:end));
final_den_arr= array2table(denominator_array(:,7:end));
for i = 1:44
    final_data{8,i} = mean(final_data{~isnan(final_data{1:subnum,i}),i});
    final_data{9,i} = std(final_data{~isnan(final_data{1:subnum,i}),i})/sqrt(sum(~isnan(final_data{1:subnum,i})));
    final_den_arr{8,i} =  mean(final_den_arr{1:subnum,i});
    final_den_arr{9,i} =  std(final_den_arr{1:subnum,i})/sqrt(sum(~isnan(final_den_arr{1:subnum,i})));    
end
final_data(:,:) =  [final_data(:,41:44),final_data(:,1:40)];
final_den_arr(:,:) =  [final_den_arr(:,41:44),final_den_arr(:,1:40)];
final_den_arr.Properties.RowNames = [kk 'average' 'sem'];
final_data.Properties.RowNames = [kk 'average' 'sem'];
final_data.Properties.VariableNames = {'FacesT','FacesF','ScenesT','ScenesF','MaleT','MaleF','FemaleT','FemaleF','YoungT','YoungF',...
    'OldT','OldF',	'OneFaceT','OneFaceF',	'MultipleFacesT','MultipleFacesF',	'PersonexecutinganactionT','PersonexecutinganactionF',	'NoactionT','NoactionF',	'PersontalkingT','PersontalkingF',	'PersonnottalkingT','PersonnottalkingF',	'DistinctivepersonT','DistinctivepersonF',	'NondistinctivepersonT','NondistinctivepersonF',...
    'InteractingwsubjectT','InteractingwsubjectF',	'NotinteractingwsubjectT','NotinteractingwsubjectF',	'MovementT','MovementF',	'NomovementT','NomovementF',	'DistinctivesceneT','DistinctivesceneF',	'NondistinctivesceneT','NondistinctivesceneF',	'PeopleinbackgroundT','PeopleinbackgroundF','NopeopleT','NopeopleF'};
final_den_arr.Properties.VariableNames = {'FacesT','FacesF','ScenesT','ScenesF','MaleT','MaleF','FemaleT','FemaleF','YoungT','YoungF',	'OldT','OldF',	'OneFaceT','OneFaceF',	'MultipleFacesT','MultipleFacesF',	'PersonexecutinganactionT','PersonexecutinganactionF',	'NoactionT','NoactionF',	'PersontalkingT','PersontalkingF',	'PersonnottalkingT','PersonnottalkingF',	'DistinctivepersonT','DistinctivepersonF',	'NondistinctivepersonT','NondistinctivepersonF',	'InteractingwsubjectT','InteractingwsubjectF',	'NotinteractingwsubjectT','NotinteractingwsubjectF',	'MovementT','MovementF',	'NomovementT','NomovementF',	'DistinctivesceneT','DistinctivesceneF',	'NondistinctivesceneT','NondistinctivesceneF',	'PeopleinbackgroundT','PeopleinbackgroundF','NopeopleT','NopeopleF'};

close all
figure
hold on
titles = {'A    Faces vs Scenes', 'B    Gender' ,  'C    Age of person','D    Number of Faces', 'E    Presence of action' ...
          'F    Individual talking', 'G     Distinctiveness of Individual', 'H    Interacting with subject'...
            'I    Movement', 'J    Distinctive Scene' , 'K   People in background'};
for i = 1:11
    if i<=10
        s = subplot(4,3,i);
    elseif i==11
        s = subplot(4,3,12);
    end
    c= categorical(final_data.Properties.VariableNames(1,1+4*(i-1):4*(i)));
    b= bar(c,[final_data{8,1+4*(i-1):4*(i)}]);
        hold on
    e= errorbar(c,[final_data{8,1+4*(i-1):4*(i)}],[final_data{9,1+4*(i-1):4*(i)}],'.');
    ylim([0 1.000001]);
    yticks([0:0.1:1]);
    set(b,'FaceColor',[0.5 0.5 0.5]);
    set(b,'BarWidth',0.5);
    set(e,'LineWidth',2);
    set(e,'Color','r');
    set(s,'FontSize',14);
    set(s,'FontWeight','bold');
    title(titles{i});
end

% T3 = cell(0);
% hyp=cell(0);
% hype=cell(1,4);
% rnk = cell(1,4);
% rnkk =cell(0);
% anova = cell(0);
% ann = cell(1,4);
% for i = 1:11
%     disp('**************************************');
%     nn = final_data.Properties.VariableNames(1+4*(i-1):4*(i));
%     T = final_data{1:9,1+4*(i-1):4*(i)};
%     [p,tbl,stats] = anova1(T);
%     [c,~,~,gnames] = multcompare(stats);
%     
%     ann(1,1:4) =  final_data.Properties.VariableNames(1+4*(i-1):4*(i));
%     ann{1,3} = p<.05;
%     ann{1,4} = p;
%     
%     for kk = 1:size(c,1)
%         hype{kk,1} = nn{c(kk,1)};
%         hype{kk,2} = nn{c(kk,2)};       
%         [hype{kk,3},hype{kk,4},~,~] = ttest2(T(:,c(kk,1)),T(:,c(kk,2)));
%         
%         rnk{kk,1} = nn{c(kk,1)};
%         rnk{kk,2} = nn{c(kk,2)};       
%         [rnk{kk,4},rnk{kk,3},~] = ranksum(T(:,c(kk,1)),T(:,c(kk,2)));
%     end
%     
%     rnkk = [rnkk(:,:);rnk];
%     hyp=[hyp(:,:);hype];
%     anova = [anova(:,:);ann];
% end
% ANOVA = anova;
% TTEST2 = hyp;
% RANKSUM  = rnkk;
% clearvars -except final_data final_target_den_arr ANOVA TTEST2 RANKSUM
% sum([RANKSUM{:,3}])


