function [mmm,sss] = time_distribution_between_framesMFA
load('./subjectNameMappingMFA.mat');
kkks = cell(9,1);
for i = 1: size(kk,2)
    fname  = kk{i};
    obs = ll(i);
    size_hist = 1;
    
    [ratio,RA] = conditionalProbabilityUNSEQ(fname,obs,size_hist);
    t_dist = fix(round((RA.beginningframe(2:end)-RA.beginningframe(1:end-1))/30));
    kkk= t_dist;
    kkk(t_dist<0) = 0;
    kkk = sort(kkk);
    kkks{i} = kkk(find(kkk>0,1,'first'):end);
end

av =zeros(9,1);
sdv = zeros(9,1);
fff = zeros(390,9);
for i = 1: size(kk,2)
    zzzzz = kkks{i};
    av(i) =  mean(zzzzz(1:end-10));   
    sdv(i) =  std(zzzzz(1:end-10));   
    [counts, bins]= hist(kkks{i},max(kkks{i}));
    fff(1:size(counts,2),i) =  fff(1:size(counts,2),i)  +  counts(1,:)';
end
fff = fff';

mmm = zeros(390,1);
sss = zeros(390,1);
for i = 1:390 
    mmm(i) = mean(fff(:,i));
    sss(i) = std(fff(:,i));
end

bar([1:50],mmm(1:50))
hold on
errorbar([1:50],mmm(1:50),sss(1:50)/sqrt(9))




% load('../../MIT/subjectNameMapping.mat')
% kkks = cell(7,1);
% mx = -1;
% for i = 1: 7
%     fname  = kk{i};
%     obs = ll(i);
%     size_hist = 1;
%     
%     [ratio,RA] = conditionalProbabilityUNSEQ_MIT(fname,obs,size_hist);
%     t_dist = fix(round((RA.beginningframe(2:end)-RA.beginningframe(1:end-1))/30));
%     kkk= t_dist;
%     kkk(t_dist<0) = 0;
%     kkk = sort(kkk);
%     kkks{i} = kkk(find(kkk>0,1,'first'):end);
%     if mx < max(kkks{i})
%         mx = max(kkks{i});
%     end
% end
% 
% av =zeros(7,1);
% sdv = zeros(7,1);
% fff = zeros(mx,7);
% for i = 1: size(kk,2)
%     zzzzz = kkks{i};
%     av(i) =  mean(zzzzz(1:end-10));   
%     sdv(i) =  std(zzzzz(1:end-10));  
%     [counts, bins]= hist(kkks{i},max(kkks{i}));
%     fff(1:size(counts,2),i) =  fff(1:size(counts,2),i)  +  counts(1,:)';
% end
% fff = fff';
% 
% mmm = zeros(mx,1);
% sss = zeros(mx,1);
% for i = 1:mx 
%     mmm(i) = mean(fff(:,i));
%     sss(i) = std(fff(:,i));
% end
% 
% plot([1:mx],mmm)
% hold on
% errorbar([1:mx],mmm,sss/sqrt(7))



% load('../../MIT/subjectNameMapping.mat')
% kkks = cell(7,1);
% mx = -1;
% for i = 1: 7
%     fname  = kk{i};
%     obs = ll(i);
%     size_hist = 1;
%     
%     [ratio,RA] = conditionalProbabilityUNSEQ_3M_MIT(fname,obs,size_hist);
%     t_dist = fix(round((RA.beginningframe(2:end)-RA.beginningframe(1:end-1))/30));
%     kkk= t_dist;
%     kkk(t_dist<0) = 0;
%     kkk = sort(kkk);
%     kkks{i} = kkk(find(kkk>0,1,'first'):end);
%     if mx < max(kkks{i})
%         mx = max(kkks{i});
%     end
% end
% 
% av =zeros(7,1);
% sdv = zeros(7,1);
% fff = zeros(mx,7);
% for i = 1: size(kk,2)
%     zzzzz = kkks{i};
%     av(i) =  mean(zzzzz(1:end-10));   
%     sdv(i) =  std(zzzzz(1:end-10));  
%     [counts, bins]= hist(kkks{i},max(kkks{i}));
%     fff(1:size(counts,2),i) =  fff(1:size(counts,2),i)  +  counts(1,:)';
% end
% fff = fff';
% 
% mmm = zeros(mx,1);
% sss = zeros(mx,1);
% for i = 1:mx 
%     mmm(i) = mean(fff(:,i));
%     sss(i) = std(fff(:,i));
% end
% 
% plot([1:mx],mmm)
% hold on
% errorbar([1:mx],mmm,sss/sqrt(7))













