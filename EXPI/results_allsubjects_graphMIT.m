function [perf,scene_corr,face_corr,fpr,tpr] = results_allsubjects_graphMIT(inp)
if inp~=1
    load('./subjectNameMappingMIT2.mat');
else 
    load('./subjectNameMappingMIT.mat');
end
subnum  =size(kk,2);
tpr=[];
fpr=[];
perf=[];
face_corr = [];
scene_corr=[];
for j = 1:subnum
            fname = kk{j};
            load(['Score file results/',fname])
            presentations_order_matrix=memparams.presentations_order_matrix;
%             presentations_order_matrix(1:1050,:);

            Foils = {'target','foil'};
            Responses = {'no','yes'};

            result = [presentations_order_matrix,responses];

            for i = 1:length(responses)
                Result{i,1} = result(i,1);
                Result{i,2} = Foils{result(i,2)};
                Result{i,3} = Responses{result(i,3)};

                if (strcmp(Result{i,2},'target') && strcmp(Result{i,3},'yes'))
                    Result{i,4} = 1;
                elseif (strcmp(Result{i,2},'target') && strcmp(Result{i,3},'no'))
                    Result{i,4} = 0;
                elseif (strcmp(Result{i,2},'foil') && strcmp(Result{i,3},'yes'))
                    Result{i,4} = 0;
                elseif (strcmp(Result{i,2},'foil') && strcmp(Result{i,3},'no'))
                    Result{i,4} = 1;
                end

                if (Result{i,1} <= 250)
                    Result{i,5} = 'face';
                else
                    Result{i,5} = 'scene';
                end

                % Get filenames
                if strcmp(Result{i,2},'target') % if target
                    dirstruct = memparams.dir_target(Result{i,1});
                else % if foil
                    dirstruct = memparams.dir_foil(Result{i,1});
                end
                Result{i,6} = dirstruct.name;
            end

%             disp(Result)

            % Statistics

            fprintf('Fraction correct: %f\n',sum([Result{:,4}])/length(Result))
            fprintf('Fraction yes: %f\n',sum(strcmp({Result{:,3}},'yes'))/length(Result))
            fprintf('Scenes fraction correct: %f\n',sum([Result{strcmp({Result{:,5}},'scene'),4}]) / length({Result{strcmp({Result{:,5}},'scene'),3}}))
            fprintf('Scenes fraction yes: %f\n',sum(strcmp({Result{strcmp({Result{:,5}},'scene'),3}},'yes')) / length({Result{strcmp({Result{:,5}},'scene'),3}}))
            fprintf('Faces fraction correct: %f\n',sum([Result{strcmp({Result{:,5}},'face'),4}]) / length({Result{strcmp({Result{:,5}},'face'),3}}))
            fprintf('Faces fraction yes: %f\n',sum(strcmp({Result{strcmp({Result{:,5}},'face'),3}},'yes')) / length({Result{strcmp({Result{:,5}},'face'),3}}))

            % Calculate TPR, FPR
            % FPR
            num_foils = sum(strcmp(Result(:,2),'foil'));
            num_tn = sum(strcmp(Result(:,2),'foil') & strcmp(Result(:,3),'no'));
            FPR = 1 - num_tn/num_foils;
            % TPR
            num_targets = sum(strcmp(Result(:,2),'target'));
            num_fn = sum(strcmp(Result(:,2),'target') & strcmp(Result(:,3),'no'));
            TPR = 1 - num_fn/num_targets;
            fprintf('FPR: %.3f\tTPR: %.3f\n',FPR,TPR)

            perf = [perf(:);sum([Result{:,4}])/length(Result)];
            scene_corr = [scene_corr(:); sum([Result{   strcmp({Result{:,5}},'scene'),4   }]) / length({Result{strcmp({Result{:,5}},'scene'),3}})];
            face_corr = [face_corr(:);sum([Result{strcmp({Result{:,5}},'face'),4}]) / length({Result{strcmp({Result{:,5}},'face'),3}})];
            tpr = [tpr(:);TPR];
            fpr = [fpr(:);FPR];
end

end