load('subjectNameMappingMFA.mat')
% kk = [kk(1:7),kk(9)];
avg_array = zeros(size(kk,2),22+2);
targets_denom_array = zeros(size(kk,2),22+2);
denominator_array = zeros(size(kk,2),22);
subnum  =size(kk,2);
% kk represents subject names stores in a cell array

for i = 1 :subnum
    load(fullfile([char(kk(i)) '.mat'])); 
    ResultAnnotation2 = sortrows(ResultAnnotation2,'Foiltarget','descend');
    ResultAnnotation2 = [ResultAnnotation2(:,1:34) , ResultAnnotation2(:,37:end) ];
    xx = find(ResultAnnotation2.Foiltarget=='foil''',1);
    ResultAnnotation2T = ResultAnnotation2(1:xx-1, :);
    ResultAnnotation2F = ResultAnnotation2(xx:end, :);
    RAT(:,1:6) = ResultAnnotation2T(:,1:6);
    RAF(:,1:6) = ResultAnnotation2F(:,1:6);
    for j = 1:16
        RAT{:,7+j-1} = [ResultAnnotation2T{:,7+2*(j-1)} | ResultAnnotation2T{:,7+2*(j-1)+1}];
        RAF{:,7+j-1} = [ResultAnnotation2F{:,7+2*(j-1)} | ResultAnnotation2F{:,7+2*(j-1)+1}];
    end
    RAT(:,23) = ResultAnnotation2T(:,end);
    RAF(:,23) = ResultAnnotation2F(:,end);
    RAT.Properties.VariableNames = [ResultAnnotation2.Properties.VariableNames(1:6),{'Male','Female' , 'OneFace','ManyFaces', 'Young','Old', 'Action','NoAction' ...
              'Talking','NoTalking', 'DistinctIndividual','NonDistinctIndividual', 'DistinctObject','NonDistinctObject'...
                'Statue','Painting','index'}];
    RAF.Properties.VariableNames = [ResultAnnotation2.Properties.VariableNames(1:6),{'Male','Female' , 'OneFace','ManyFaces', 'Young','Old', 'Action','NoAction' ...
              'Talking','NoTalking', 'DistinctIndividual','NonDistinctIndividual', 'DistinctObject','NonDistinctObject'...
                'Statue','Painting','index'}];
    ResultAnnotation2T = RAT;
    ResultAnnotation2F = RAF;
    clear RAT RAF xx
  %faces vs scenes begins  
    cnt_face=0;
    cnt_face_corr=0;
    cnt_scene = 0;
    cnt_scene_corr = 0;   
    for j = 1:size(ResultAnnotation2T,1)
        if sum(ResultAnnotation2T{j,7:18})>0
            cnt_face=cnt_face+1;
            if ResultAnnotation2T.correct(j)>0
                cnt_face_corr=cnt_face_corr+1;
            end
        else
            cnt_scene = cnt_scene+1;
            if ResultAnnotation2T.correct(j)==1
                cnt_scene_corr=cnt_scene_corr+1;
            end    
        end
    end    
    avg_array(i,39) = cnt_face_corr/cnt_face;
    avg_array(i,41) = cnt_scene_corr/cnt_scene;
    denominator_array(i,39) = cnt_face;
    denominator_array(i,41) = cnt_scene;
    
    cnt_face=0;
    cnt_face_corr=0;
    cnt_scene = 0;
    cnt_scene_corr = 0;   
    for j = 1:size(ResultAnnotation2F,1)
        if sum(ResultAnnotation2F{j,7:18})>0
            cnt_face=cnt_face+1;
            if ResultAnnotation2F.correct(j)>0
                cnt_face_corr=cnt_face_corr+1;
            end
        else
            cnt_scene = cnt_scene+1;
            if ResultAnnotation2F.correct(j)==1
                cnt_scene_corr=cnt_scene_corr+1;
            end    
        end
    end    
    avg_array(i,40) = cnt_face_corr/cnt_face;
    avg_array(i,42) = cnt_scene_corr/cnt_scene;
    denominator_array(i,40) = cnt_face;
    denominator_array(i,42) = cnt_scene;  
%faces vs scenes done
    for j = 1:16
        numerator = 0;
        denominator = 0;
        rows = size(ResultAnnotation2T,1);
        parfor k = 1:rows
            if ResultAnnotation2T{k,7+j-1} == 1 
                if ResultAnnotation2T.correct(k) == 1
                   numerator = numerator + 1; 
                end
                denominator = denominator +1;
            end
        end
        if denominator >= 8
            denominator_array(i,7+2*(j-1)) = denominator;
            avg_array(i,7+2*(j-1)) = numerator/denominator;
        else 
%              disp(['no error Target: dividing by  zero therefore putting NaN: ' char(kk(i)) ' ' num2str(j) ' ' denominator]);
            avg_array(i,7+2*(j-1)) = NaN;                
        end
        
        rows = size(ResultAnnotation2F,1);
        numerator = 0;
        denominator = 0;
        parfor k = 1:rows
            if ResultAnnotation2F{k,7+j-1} == 1 
                if ResultAnnotation2F.correct(k) == 1
                   numerator = numerator + 1; 
                end
                denominator = denominator +1;
            end
        end
        if denominator >= 8
            denominator_array(i,7+2*j-1) = denominator;
            avg_array(i,7+2*j-1) = numerator/denominator;
        else 
%              disp(['no error Foil: dividing by  zero therefore putting NaN: ' char(kk(i)) ' ' num2str(j) ' ' denominator]);
            avg_array(i,7+2*j-1) = NaN;                
        end
        
    end    
end

final_data = array2table(avg_array(:,7:end));
final_den_arr= array2table(denominator_array(:,7:end));
for i = 1:36
    final_data{10,i} = mean(final_data{~isnan(final_data{1:subnum,i}),i});
    final_data{11,i} = std(final_data{~isnan(final_data{1:subnum,i}),i})/sqrt(sum(~isnan(final_data{1:subnum,i})));
    final_den_arr{10,i} =  mean(final_den_arr{1:subnum,i});
    final_den_arr{11,i} =  std(final_den_arr{1:subnum,i})/sqrt(sum(~isnan(final_den_arr{1:subnum,i})));    
end
final_data(:,:) =  [final_data(:,33:36),final_data(:,1:32)];
final_den_arr(:,:) =  [final_den_arr(:,33:36),final_den_arr(:,1:32)];
final_den_arr.Properties.RowNames = [kk 'average' 'sem'];
final_data.Properties.RowNames = [kk 'average' 'sem'];
final_data.Properties.VariableNames = {'facesT','facesF','scenesT','scenesF','MaleT','MaleF','FemaleT' ,'FemaleF',  'OneFaceT','OneFaceF','ManyFacesT','ManyFacesF', 'YoungT','YoungF','OldT','OldF', 'ActionT','ActionF','NoActionT','NoActionF' ...
              'TalkingT','TalkingF','NoTalkingT','NoTalkingF', 'DistinctIndividualT','DistinctIndividualF','NonDistinctIndividualT','NonDistinctIndividualF', 'DistinctObjectT','DistinctObjectF','NonDistinctObjectT','NonDistinctObjectF'...
                'StatueT','StatueF','PaintingT','PaintingF'};
final_den_arr.Properties.VariableNames = {'facesT','facesF','scenesT','scenesF','MaleT','MaleF','FemaleT' ,'FemaleF',  'OneFaceT','OneFaceF','ManyFacesT','ManyFacesF', 'YoungT','YoungF','OldT','OldF', 'ActionT','ActionF','NoActionT','NoActionF' ...
              'TalkingT','TalkingF','NoTalkingT','NoTalkingF', 'DistinctIndividualT','DistinctIndividualF','NonDistinctIndividualT','NonDistinctIndividualF', 'DistinctObjectT','DistinctObjectF','NonDistinctObjectT','NonDistinctObjectF'...
                'StatueT','StatueF','PaintingT','PaintingF'};
% return
close all
figure
hold on
titles = {'A    Faces vs Scenes', 'B    Gender' , 'C    Number of Faces', 'D    Age of person', 'E    Presence of action' ...
          'F    Individual talking', 'G     Distinctiveness of Individual', 'H    Distinctiveness of object'...
            'I    Category of artwork'};
for i = 1:9
    s = subplot(3,3,i);
    c= categorical(final_data.Properties.VariableNames(1,1+4*(i-1):4*(i)));
    b= bar(c,[final_data{10,1+4*(i-1):4*(i)}]);
        hold on
    e= errorbar(c,[final_data{10,1+4*(i-1):4*(i)}],[final_data{11,1+4*(i-1):4*(i)}],'.');
    ylim([0 1.009]);
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
% for i = 1:9
% %     disp('**************************************');
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


