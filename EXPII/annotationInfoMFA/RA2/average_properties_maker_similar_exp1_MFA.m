load('../../subjectNameMappingMFA.mat')
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

    RA(:,1:6) = ResultAnnotation2(:,1:6);
    for j = 1:16
        RA{:,7+j-1} = [ResultAnnotation2{:,7+2*(j-1)} | ResultAnnotation2{:,7+2*(j-1)+1}];
    end
    RA(:,23) = ResultAnnotation2(:,end);
    RA.Properties.VariableNames = [ResultAnnotation2.Properties.VariableNames(1:6),{'Male','Female' , 'OneFace','ManyFaces', 'Young','Old', 'Action','NoAction' ...
              'Talking','NoTalking', 'DistinctIndividual','NonDistinctIndividual', 'DistinctObject','NonDistinctObject'...
                'Statue','Painting','index'}];
    ResultAnnotation2 = RA;
    clear RA;

    rows = size(ResultAnnotation2,1);
    cols = 34;
    numerator = 0;
    target_den = 0;
    denominator = 0;
    cnt_face=0;
    cnt_face_corr=0;
    cnt_scene = 0;
    cnt_scene_corr = 0;
    
    for j = 1:size(ResultAnnotation2,1)
        if sum(ResultAnnotation2{j,7:18})>0
            cnt_face=cnt_face+1;
            if ResultAnnotation2.correct(j)>0
                cnt_face_corr=cnt_face_corr+1;
            end
        else
            cnt_scene = cnt_scene+1;
            if ResultAnnotation2.correct(j)==1
                cnt_scene_corr=cnt_scene_corr+1;
            end    
        end
    end
    
    avg_array(i,23) = cnt_face_corr/cnt_face;
    avg_array(i,24) = cnt_scene_corr/cnt_scene;
    targets_denom_array(i,23) = cnt_face;
    targets_denom_array(i,24) = cnt_scene;
%     denominator_array(i,23) = cnt_face;
%     denominator_array(i,24) = cnt_scene;
    for j = 7:22
        numerator = 0;
        denominator = 0;
        target_den = 0;
        parfor k = 1:rows
            if ResultAnnotation2{k,j} == 1 
                if ResultAnnotation2.correct(k) == 1
                   numerator = numerator + 1; 
                end
                if ResultAnnotation2.Foiltarget(k)=='target''' ||  ResultAnnotation2.Foiltarget(k)=='foil''' 
                    target_den = target_den+1;
                end
                denominator = denominator +1;
            end
        end
        targets_denom_array(i,j) = target_den;
        if denominator >= 0
            denominator_array(i,j) = denominator;
            avg_array(i,j) = numerator/denominator;
        else 
            // disp(['no error: dividing by zero therefore putting NaN: ' char(kk(i)) ' ' num2str(j) ' ' denominator]);
            avg_array(i,j) = NaN;                
        end
    end    
end



final_data = array2table(avg_array(:,7:end));
final_target_den_arr= array2table(targets_denom_array(:,7:end));
for i = 1:18
    final_data{10,i} = mean(final_data{~isnan(final_data{1:subnum,i}),i});
    final_data{11,i} = std(final_data{~isnan(final_data{1:subnum,i}),i})/sqrt(sum(~isnan(final_data{1:subnum,i})));
    if i<35
    final_target_den_arr{10,i} =  mean(final_target_den_arr{1:subnum,i});
    final_target_den_arr{11,i} =  std(final_target_den_arr{1:subnum,i})/sqrt(9);    
    end
end
final_data(:,:) =  [final_data(:,17:18),final_data(:,1:16)];
final_target_den_arr(:,:) =  [final_target_den_arr(:,17:18),final_target_den_arr(:,1:16)];
final_target_den_arr.Properties.RowNames = [kk 'average' 'sem'];
final_data.Properties.RowNames = [kk 'average' 'sem'];
final_target_den_arr.Properties.VariableNames = ['faces','scenes' ,ResultAnnotation2.Properties.VariableNames(7:end-1)];
final_data.Properties.VariableNames =  ['faces','scenes' ,ResultAnnotation2.Properties.VariableNames(7:end-1)];


close all
figure
hold on
titles = {'A    Faces vs Scenes', 'B    Gender' , 'C    Number of Faces', 'D    Age of person', 'E    Presence of action' ...
          'F    Individual talking', 'G     Distinctiveness of Individual', 'H    Distinctiveness of object'...
            'I    Category of artwork'};
for i = 1:9
    s = subplot(3,3,i);
    c= categorical(final_data.Properties.VariableNames(1,1+2*(i-1):2*(i)));
    b= bar(c,[final_data{10,1+2*(i-1):2*(i)}]);
        hold on
    e= errorbar(c,[final_data{10,1+2*(i-1):2*(i)}],[final_data{11,1+2*(i-1):2*(i)}],'.');
    ylim([0 1.009]);
    set(b,'FaceColor',[0.5 0.5 0.5]);
    set(b,'BarWidth',0.5);
    set(e,'LineWidth',2);
    set(e,'Color','r');
    set(s,'FontSize',14);
    set(s,'FontWeight','bold');
    title(titles{i});
end
T3 = cell(0);
hyp=cell(0);
hype=cell(1,4);
rnk = cell(1,4);
rnkk =cell(0);
anova = cell(0);
ann = cell(1,4);
for i = 1:9
    // disp('**************************************');
    nn = final_data.Properties.VariableNames(1+2*(i-1):2*(i));
    T = final_data{1:8,1+2*(i-1):2*(i)};
    [p,tbl,stats] = anova1(T);
    [c,~,~,gnames] = multcompare(stats);
    
    ann(1,1:2) =  final_data.Properties.VariableNames(1+2*(i-1):2*(i));
    ann{1,3} = p<.05;
    ann{1,4} = p;
    
    for kk = 1:size(c,1)
        hype{kk,1} = nn{c(kk,1)};
        hype{kk,2} = nn{c(kk,2)};       
        [hype{kk,3},hype{kk,4},~,~] = ttest2(T(:,c(kk,1)),T(:,c(kk,2)));
        
        rnk{kk,1} = nn{c(kk,1)};
        rnk{kk,2} = nn{c(kk,2)};       
        [rnk{kk,4},rnk{kk,3},~] = ranksum(T(:,c(kk,1)),T(:,c(kk,2)));
    end
    
    rnkk = [rnkk(:,:);rnk];
    hyp=[hyp(:,:);hype];
    anova = [anova(:,:);ann];
end
ANOVA = anova;
TTEST2 = hyp;
RANKSUM  = rnkk;
clearvars -except final_data final_target_den_arr ANOVA TTEST2 RANKSUM
sum([RANKSUM{:,3}])