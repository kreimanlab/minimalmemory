function [kkkk] = time_dependence_checker_MFA
    load('./subjectNameMappingMFA.mat')
    fff = zeros(2000,9);
    break_pt=zeros(1,9);
    min_zero = 5000;
    for i = 1:9
        fname = kk{i};
        obs =ll(i);
        [zzz,~, ~,first_zero] = condProbMFA(fname,obs);
        fff(:,i) = zzz;
        clear zzz
        if min_zero>first_zero
            min_zero = first_zero;
        end
    end

    for i=1:200
        [h,p] = ttest(fff(i,:),1,'Alpha', 0.05/25);
        % disp(['N_' num2str(i) ' h: ' num2str(h) ' p: ' num2str(p) ]);
    end

    kkkk = zeros(2000,1);
    for i = 1:2000
        kkkk(i) = mean(fff( i, ~isnan(fff(i,:))));
    end
end
