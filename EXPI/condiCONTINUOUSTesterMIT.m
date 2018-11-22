load('./subjectNameMappingMIT.mat')
fff = zeros(5000,7);
break_pt=zeros(1,7);
min_zero = 5000;
for i = 1:7
    fname = kk{i};
    obs =ll(i);
    [zzz,~, ~,first_zero] = condProbCONTINUOUS_MIT(fname,obs);
    fff(:,i) = zzz;
    clear zzz
    if min_zero>first_zero
        min_zero = first_zero;
    end
end

for i=1:200
    [h,p] = ttest(fff(i,:),1,'Alpha', 0.05/25);
%     disp(['N_' num2str(i) ' h: ' num2str(h) ' p: ' num2str(p) ]);
end

kkkk = zeros(5000,1);
for i = 1:5000
kkkk(i) = mean(fff( i, ~isnan(fff(i,:))));
end

ft = fittype('testExp(x,b,c)');
scatter([1:100]',kkkk(1:100)');
hold on
yfit = fit([1:100]',kkkk(1:100),ft,'Lower',[0,-Inf],'Upper',[Inf,0]);
plot(yfit);


% 
% 
% 
load('./subjectNameMappingMIT.mat')
fff = zeros(5000,7);
break_pt=zeros(1,7);
min_zero = 5000;
for i = 1:7
    fname = kk{i};
    obs =ll(i);
    [zzz,~, ~,first_zero] = condProbCONTINUOUS_MIT_3M(fname,obs);
    fff(:,i) = zzz;
    clear zzz
    if min_zero>first_zero
        min_zero = first_zero;
    end
end

for i=1:200
    [h,p] = ttest(fff(i,:),1,'Alpha', 0.05/25);
%     disp(['N_' num2str(i) ' h: ' num2str(h) ' p: ' num2str(p) ]);
end

kkkk = zeros(5000,1);
for i = 1:5000
kkkk(i) = mean(fff( i, ~isnan(fff(i,:))));
end

figure(2)
ft = fittype('testExp(x,b,c)');
scatter([2:100]',kkkk(2:100)');
hold on
yfit = fit([2:100]',kkkk(2:100),ft,'Lower',[0,-Inf],'Upper',[Inf,0]);
plot(yfit);