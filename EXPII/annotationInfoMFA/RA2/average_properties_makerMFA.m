load('subjectNameMappingMFA.mat')
kk = [kk(1:3),kk(5:7),kk(9)];
avg_array = zeros(size(kk,2),34);
targets_denom_array = zeros(size(kk,2),34);
denominator_array = zeros(size(kk,2),34);
subnum  =size(kk,2);
% kk represents subject names stores in a cell array

for i = 1 :subnum
    load(fullfile([char(kk(i)) '.mat']));
    ResultAnnotation2 = sortrows(ResultAnnotation2,'Foiltarget','descend');
    ptr = find(ResultAnnotation2.Foiltarget=='foil''',1,'first')-1;
    ResultAnnotation2 =ResultAnnotation2(1:ptr,:);
    rows = size(ResultAnnotation2,1);
    cols = 34;
    numerator = 0;
    target_den = 0;
    denominator = 0;
    for j = 6+1:6+34  
        numerator = 0;
        denominator = 0;
        target_den = 0;
        parfor k = 1:rows
            if ResultAnnotation2{k,j} == 1 
                if ResultAnnotation2.correct(k) == 1
                   numerator = numerator + 1; 
                end
                if ResultAnnotation2.Foiltarget(k)=='target'''
                    target_den = target_den+1;
                end
                denominator = denominator +1;
            end
        end
        targets_denom_array(i,j) = target_den;
        if denominator >= 8
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
final_deno_arr= array2table(denominator_array(:,7:end));
final_deno_arr.Properties.VariableNames = ResultAnnotation2.Properties.VariableNames(7:end-1);
final_data.Properties.VariableNames=  [ResultAnnotation2.Properties.VariableNames(7:end-1)] ;
for i = 1:34
    final_data{8,i} = mean(final_data{~isnan(final_data{1:subnum,i}),i});
    final_data{9,i} = std(final_data{~isnan(final_data{1:subnum,i}),i})/sqrt(sum(~isnan(final_data{1:subnum,i})));
    if i<35
    final_target_den_arr{8,i} =  mean(final_target_den_arr{1:subnum,i});
    final_target_den_arr{9,i} =  std(final_target_den_arr{1:subnum,i})/sqrt(8);    
    final_deno_arr{8,i} =  mean(final_deno_arr{1:subnum,i});
    final_deno_arr{9,i} =  std(final_deno_arr{1:subnum,i})/sqrt(8);
    end
end
final_deno_arr.Properties.RowNames = [kk 'average' 'sem'];
final_target_den_arr.Properties.RowNames = [kk 'average' 'sem'];
final_deno_arr.Properties.VariableNames = ResultAnnotation2.Properties.VariableNames(7:end-1);
final_target_den_arr.Properties.VariableNames = ResultAnnotation2.Properties.VariableNames(7:end-1);
final_deno_arr.Properties.VariableNames{23} = 'NonDistinctivePersonFIX';
final_deno_arr.Properties.VariableNames{24} = 'NondistinctivePersonnoFIX';
final_target_den_arr.Properties.VariableNames{23} = 'NonDistinctivePersonFIX';
final_target_den_arr.Properties.VariableNames{24} = 'NondistinctivePersonnoFIX';

final_data.Properties.VariableNames{13} = 'ActionFIX';
final_data.Properties.VariableNames{17} = 'PersonTalkingFIX';
final_data.Properties.VariableNames{18} = 'PersonTalkingNoFIX';
final_data.Properties.VariableNames{19} = 'NoTalkingFIX';
final_data.Properties.VariableNames{20} = 'NoTalkingNoFIX';


final_data.Properties.VariableNames{21} = 'DistinctiveFIX';
final_data.Properties.VariableNames{22} = 'DistinctiveNoFIX';
final_data.Properties.VariableNames{23} = 'NonDistinctiveFIX';
final_data.Properties.VariableNames{24} = 'NonDistinctiveNoFIX';

final_data.Properties.VariableNames{25} = 'DistinctiveObjFIX';
final_data.Properties.VariableNames{26} = 'DistinctiveObjNoFIX';
final_data.Properties.VariableNames{27} = 'NonDistinctObjFIX';
final_data.Properties.VariableNames{28} = 'NonDistinctObjNoFIX';

for i = 1:size(final_data.Properties.VariableNames,2)
    try
         st1 = extractBefore(final_data.Properties.VariableNames{i},'no');
         final_data.Properties.VariableNames{i} = [st1 'NoFIX'];
    catch
        
    end
end

% return
% removing people FIX, people NO FIX
final_data_notIncluded = final_data(:,29:30);
final_data = [final_data(:,1:28) final_data(:,31:34)];
final_target_den_arr = [final_target_den_arr(:,1:28) final_target_den_arr(:,31:34)];
final_data.Properties.RowNames = [kk 'average' 'sem'];
% return;
% 29,30 5-9 no use in alyssa plots
close all
figure
hold on
titles = {'A    Gender' , 'B    Number of Faces', 'C    Age of person', 'D    Presence of action' ...
          'E    Individual talking', 'F     Distinctiveness of Individual', 'G    Distinctiveness of object'...
            'H    Category of artwork'};
for i = 1:8
    s = subplot(2,4,i);
    c= categorical(final_data.Properties.VariableNames(1,1+4*(i-1):4*(i)));
    b= bar(c,[final_data{8,1+4*(i-1):4*(i)}]);
        hold on
    e= errorbar(c,[final_data{8,1+4*(i-1):4*(i)}],[final_data{9,1+4*(i-1):4*(i)}],'.');
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
hype=cell(6,4);
rnk = cell(6,4);
rnkk =cell(0);
anova = cell(0);
ann = cell(1,6);
for i = 1:8
    // disp('**************************************');
    nn = final_data.Properties.VariableNames(1+4*(i-1):4*(i));
    T = final_data{1:7,1+4*(i-1):4*(i)};
    [p,tbl,stats] = anova1(T);
    [c,~,~,gnames] = multcompare(stats);
    
    ann(1,1:4) =  final_data.Properties.VariableNames(1+4*(i-1):4*(i));
    ann{1,5} = p<.05;
    ann{1,6} = p;
    
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
