%% edits_here!!!!!!!!!!
%WARNING! has a save at the end CAREFUL!
% CV   &  HL (without eye data)
function [ meanPredSVMCV,stdPredSVMCV...
            ,meanPredENCV,stdPredENCV] = pred_CV(fname,obs, reps)       

load(fullfile('..','annotationInfoMFA','RA2','RA_NO_FIX',[ fname '.mat']));
load(fullfile('..','FC7',[ fname '_CLSF_' num2str(obs) '.mat']));
ResultAnnotation2.index = string(ResultAnnotation2.index);
RA = sortrows(ResultAnnotation2,{'Foiltarget','Facescene','index'},{'ascend','ascend','ascend'});
ResultAnnotation2 = RA;
clear RA;

[m,~] =size(ResultAnnotation2);

T2 = table([1:m]',ResultAnnotation2.VarName1,ResultAnnotation2.Foiltarget,ResultAnnotation2.correct,...
   ResultAnnotation2.Filename,ResultAnnotation2(:,7:22),'VariableNames',{'mainIndex' 'VarName1'...
   'Foiltarget' 'correct' 'Filename' 'annotatedfeatures'});

kkk = [T2.mainIndex(T2.correct==1)];
lll = [T2.mainIndex(T2.correct==0)];

[m1,~] = size(kkk);
[m2,~] = size(lll);

predSVMCV = zeros(reps,1);
predENCV = zeros(reps,1);

    for j =1:reps

        index1 = randperm(m1);
        index0 = randperm(m2);

        totalsize = min(m1,m2)-4;
        trainSZ =  fix(totalsize*3/4);
        testSZ = totalsize - trainSZ;

        train1 = T2(kkk(sort(index1(1:trainSZ))',:),:);
        train0 = T2(lll(sort(index0(1:trainSZ))',:),:);

        test1 = T2(kkk(sort(index1(trainSZ+1:totalsize))',:),:);
        test0 = T2(lll(sort(index0(trainSZ+1:totalsize))',:),:);

        %to use extracted features from FEATURES and frame info etc
        useIndex1 = train1.mainIndex(:);
        useIndex0 = train0.mainIndex(:);    
        % adding alexnet features with other features
        tt1(:,:) = T.featuresTotal(useIndex1(:),:);
        tt0(:,:) = T.featuresTotal(useIndex0(:),:);
        %final training data
        trainFeaturesCV(:,:) = [tt1(:,:);tt0(:,:)];%CV features with alexnet fc7
        
        useIndex1  = test1.mainIndex(:);
        useIndex0  = test0.mainIndex(:);
        % adding alexnet features with other features
        ttt1(:,:) = T.featuresTotal(useIndex1(:),:);
        ttt0(:,:) = T.featuresTotal(useIndex0(:),:);
        %final testing data
        testFeaturesCV(:,:) = [ttt1(:,:);ttt0(:,:)]; %CV features with alexnet fc7

        
        clear kk0 kk1 kk3 kk4 tt1 tt0 uuuu ttt0 ttt1 tttt kkk1 kkk0 kkk3 kkk4 useIndex0 useIndex1 train0 train1 test0 test1 testHL trainHL trainE testE
        
        for i = 1:trainSZ*2
            if i <= trainSZ
                trainTarget(i) = 1;
            else
                trainTarget(i) = 0;
            end
        end
        trainTarget=trainTarget';
        for i = 1:testSZ*2
            if i <= testSZ
                testTarget(i) = 1;
            else
                testTarget(i) = 0;
            end
        end
        testTarget=testTarget';

        mdlSVMCV = fitcsvm(trainFeaturesCV,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMCV,testFeaturesCV);
        svmpredCV = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlENCV = fitensemble(trainFeaturesCV,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENCV, testFeaturesCV);
        enpredCV = sum(pred2(:)==testTarget(:))/(testSZ*2);
% 
%         if j==1
%             maxPredSVMCV = svmpredCV;
%             maxPredENCV = enpredCV;
% 
%             mdlSVMCVmx = mdlSVMCV;
%             mdlENCVmx = mdlENCV;
% 
%         elseif svmpredCV > maxPredSVMCV
%             maxPredSVMCV = svmpredCV;
%             mdlSVMCVmx = mdlSVMCV;
%         elseif enpredCV > maxPredENCV
%             maxPredENCV = enpredCV;
%             mdlENCVmx = mdlENCV;    
%         end    
%         disp('******************************************************')
        predSVMCV(j,1) = svmpredCV;
        predENCV(j,1) = enpredCV;
    end
meanPredSVMCV = mean(predSVMCV);
stdPredSVMCV= std(predSVMCV);
meanPredENCV = mean(predENCV);
stdPredENCV=std(predENCV);

% save(fullfile('CV', [fname num2str(obs) '_CV_TOTAL.mat']), 'meanPredSVMCV','stdPredSVMCV','meanPredENCV','stdPredENCV');
end