% load('subjectNameMapping.mat');
load('./subjectNameMappingMIT.mat');
avg_array = zeros(size(kk,2),20);
numerator_array = zeros(size(kk,2),20);
denominator_array = zeros(size(kk,2),20);
subnum  =size(kk,2);
% kk represents subject names stores in a cell array

for i = 1 :subnum
%     load(fullfile('annotationsMIT1',[char(kk(i)) '.mat']));
    load(fullfile([char(kk(i)) '.mat']));
    rows = size(ResultAnnotation,1);
    cols = 34;
    numerator = 0;
    denominator = 0;
    
    
    rows = size(ResultAnnotation,1);
    cols = 34;
    numerator = 0;
    target_den = 0;
    denominator = 0;
    cnt_face=0;
    cnt_face_corr=0;
    cnt_scene = 0;
    cnt_scene_corr = 0;
    
    
    for j = 1:size(ResultAnnotation,1)
        if ResultAnnotation.facescene(j)== 'face'''
            cnt_face=cnt_face+1;
            if ResultAnnotation.Correct1yes0no(j)>0
                cnt_face_corr=cnt_face_corr+1;
            end
        else
            cnt_scene = cnt_scene+1;
            if ResultAnnotation.Correct1yes0no(j)==1
                cnt_scene_corr=cnt_scene_corr+1;
            end    
        end
    end
    
    avg_array(i,27) = cnt_face_corr/cnt_face;
    avg_array(i,28) = cnt_scene_corr/cnt_scene;
    denominator_array(i,27) = cnt_face;
    denominator_array(i,28) = cnt_scene;
    numerator_array(i,27) = cnt_face_corr;
    numerator_array(i,28) = cnt_scene_corr;
    
    for j = 6+1:6+20  
        numerator = 0;
        denominator = 0;
        parfor k = 1:rows
            if ResultAnnotation{k,j} == 1
                if ResultAnnotation.Correct1yes0no(k) == 1
                   numerator = numerator + 1; 
                end
                denominator = denominator +1;
            end

        end
        if denominator ~= 0
            numerator_array(i,j) = numerator;
            denominator_array(i,j) = denominator;
            avg_array(i,j) = numerator/denominator;
        else 
            disp(['no error: dividing by zero therefore putting chance value: ' char(kk(i)) ' ' num2str(j) ]);
            avg_array(i,j) = -2000;                
        end
    end    
end

final_num_arr= array2table(numerator_array(:,7:end));
final_deno_arr= array2table(denominator_array(:,7:end));
final_data = array2table(avg_array(:,7:end));
for i = 1:22
    final_data{8,i} = mean(final_data{final_data{1:subnum,i}>=0,i});
    final_data{9,i} = std(final_data{final_data{1:subnum,i}>=0,i})/sqrt(sum(final_data{1:subnum,i}>=0));

    final_num_arr{8,i} =  mean(final_num_arr{1:subnum,i});
    final_num_arr{9,i} =  std(final_num_arr{1:subnum,i})/sqrt(7);    
    final_deno_arr{8,i} =  mean(final_deno_arr{1:subnum,i});
    final_deno_arr{9,i} =  std(final_deno_arr{1:subnum,i})/sqrt(7);

end

final_data(:,:) =  [final_data(:,21:22),final_data(:,1:20)];
final_deno_arr(:,:) =  [final_deno_arr(:,21:22),final_deno_arr(:,1:20)];
final_num_arr(:,:) =  [final_num_arr(:,21:22),final_num_arr(:,1:20)];

final_data.Properties.VariableNames=  ['faces','scenes' ,ResultAnnotation.Properties.VariableNames(7:end)] ;
final_deno_arr.Properties.VariableNames=  ['faces','scenes' ,ResultAnnotation.Properties.VariableNames(7:end)] ;
final_num_arr.Properties.VariableNames=  ['faces','scenes' ,ResultAnnotation.Properties.VariableNames(7:end)] ;

final_data.Properties.RowNames = [kk 'average' 'sem'];
final_deno_arr.Properties.RowNames = [kk 'average' 'sem'];
final_num_arr.Properties.RowNames = [kk 'average' 'sem'];


close all
figure
hold on
titles = {'A    Gender' ,  'B    Age of person', 'C    Number of Faces', 'D    Presence of action' ...
           'E  Individual talking','F  Distinctive(Faces)', 'G  Subject Intreraction', 'H   Movement'...
            'I   Distinctive(Scene)' ,'J  Presence of People'};
for i = 1:10
    s = subplot(2,5,i);
    c= categorical(final_data.Properties.VariableNames(1,1+2*(i-1):2*(i)));
    b= bar(c,[final_data{8,1+2*(i-1):2*(i)}]);
        hold on
    e= errorbar(c,[final_data{8,1+2*(i-1):2*(i)}],[final_data{9,1+2*(i-1):2*(i)}],'.');
    ylim([0 1.009]);
%     xlim([.23 3])
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
rnkk = cell(0);
rnk = cell(1,4);
for i = 1:10
    disp('**************************************');
    nn = final_data.Properties.VariableNames(1+2*(i-1):2*(i));
    T = final_data{1:7,1+2*(i-1):2*(i)};
    [p,tbl,stats] = anova1(T);
    [c,~,~,gnames] = multcompare(stats);
    for kk = 1:size(c,1)
        hype{kk,1} = nn{c(kk,1)};
        hype{kk,2} = nn{c(kk,2)};       %c(kk,2);
        [hype{kk,3},hype{kk,4},~,~] = ttest2(T(:,c(kk,1)),T(:,c(kk,2)));
                
        rnk{kk,1} = nn{c(kk,1)};
        rnk{kk,2} = nn{c(kk,2)};       
        [rnk{kk,4},rnk{kk,3},~] = ranksum(T(:,c(kk,1)),T(:,c(kk,2)));
    end
    hyp=   [hyp(:,:);hype];
    rnkk = [rnkk(:,:);rnk];
end
% ANOVA = T3;
TTEST2 = hyp;
RANKSUM = rnkk; 
clearvars -except final_data TTEST2 RANKSUM

