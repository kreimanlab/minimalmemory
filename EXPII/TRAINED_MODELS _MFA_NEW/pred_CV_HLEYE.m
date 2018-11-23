%% edits_here!!!!!!!!!!
%WARNING! has a save at the end CAREFUL!
% targets only  CV_HLEYE & HLEYE (fixation annotations +  saccade info) 
function [   mdlSVMALLmx,meanPredSVMALL,stdPredSVMALL,maxPredSVMALL...
            ,mdlENALLmx,meanPredENALL,stdPredENALL,maxPredENALL...
            ,mdlSVM_HLEYEmx,meanPredSVM_HLEYE,stdPredSVM_HLEYE,maxPredSVM_HLEYE...
            ,mdlEN_HLEYEmx,meanPredEN_HLEYE,stdPredEN_HLEYE,maxPredEN_HLEYE] = pred_CV_HLEYE(fname,obs, reps)       

load(fullfile('annotationInfoMFA','RA2',[ fname '.mat']));
load(fullfile('FEATURES','FC7',[ 'MS_CLSF_' num2str(obs) '.mat']));
ResultAnnotation2.index = string(ResultAnnotation2.index);
RA = sortrows(ResultAnnotation2,{'Foiltarget','Facescene','index'},{'ascend','ascend','ascend'});
ResultAnnotation2 = RA;
clear RA;

[FIX, sacdur,sacmag,totalx,totaly] = EYE_INFO_NEW(fname,obs);
[m,~] =size(ResultAnnotation2);

T2 = table([1:m]',ResultAnnotation2.VarName1,ResultAnnotation2.Foiltarget,ResultAnnotation2.correct,...
   ResultAnnotation2.Filename,[ResultAnnotation2(:,7:34), ResultAnnotation2(:,37:40) ],FIX, sacdur,sacmag,totalx,totaly,'VariableNames',{'mainIndex' 'VarName1'...
   'Foiltarget' 'correct' 'Filename' 'annotatedfeatures','FIX','sacdur','sacmag','totalx','totaly'});

kkk = [T2.mainIndex(T2.correct==1 & T2.Foiltarget=='target''' ),];
lll = [T2.mainIndex(T2.correct==0 & T2.Foiltarget=='target''' ),];

[m1,~] = size(kkk);
[m2,~] = size(lll);

predSVMALL = zeros(reps,1);
predENALL = zeros(reps,1);
predSVM_HLEYE = zeros(reps,1);
predEN_HLEYE = zeros(reps,1);

maxPredSVMALL = 0;
maxPredENALL = 0;
maxPredSVM_HLEYE=0;
maxPredEN_HLEYE=0;

mdlSVMALLmx = [];
mdlENALLmx = [];
mdlSVM_HLEYEmx=[];
mdlEN_HLEYEmx=[];

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
        trainE(:,:) = [[train1{:,6},train1(:,7:11)] ;[train0{:,6} ,train0(:,7:11)]];
        tttt(:,:)  = trainE{:,:};
        trainHLEYE(:,:) =  tttt(:,1:end);       
        % adding alexnet features with other features
        tt1(:,:) = T.featuresMean(useIndex1(:),:);
        tt0(:,:) = T.featuresMean(useIndex0(:),:);
        kk1(:,:) = [tttt(1:trainSZ,:),          tt1(:,:)];
        kk0(:,:) = [tttt(trainSZ+1:trainSZ*2,:),tt0(:,:)];
        %final training data
        trainFeaturesALL(:,:) = [kk1(:,:);kk0(:,:)];%all features with alexnet fc7
        train_HLEYE(:,:) = trainHLEYE(:,:);
        
        useIndex1  = test1.mainIndex(:);
        useIndex0  = test0.mainIndex(:);
        testE(:,:) = [[test1{:,6},test1(:,7:11)] ;[test0{:,6} ,test0(:,7:11)]];
        uuuu(:,:)  = testE{:,:};
        testHLEYE(:,:) =  uuuu(:,1:end);
        % adding alexnet features with other features
        ttt1(:,:) = T.featuresMean(useIndex1(:),:);
        ttt0(:,:) = T.featuresMean(useIndex0(:),:);
        kkk1(:,:) = [uuuu(1:testSZ,:),ttt1(:,:)];
        kkk0(:,:) = [uuuu(testSZ+1:testSZ*2,:),ttt0(:,:)];
        %final testing data
        testFeaturesALL(:,:) = [kkk1(:,:);kkk0(:,:)]; %all features with alexnet fc7
        test_HLEYE(:,:) = testHLEYE(:,:);
        
        clear kk0 kk1 kk3 kk4 tt1 tt0 uuuu ttt0 ttt1 tttt kkk1 kkk0 kkk3 kkk4 useIndex0 useIndex1 train0 train1 test0 test1 testHLEYE trainHLEYE trainE testE
        
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

        mdlSVMALL = fitcsvm(trainFeaturesALL,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMALL,testFeaturesALL);
        svmpredALL = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlENALL = fitensemble(trainFeaturesALL,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENALL, testFeaturesALL);
        enpredALL = sum(pred2(:)==testTarget(:))/(testSZ*2);
        
        mdlSVM_HLEYE = fitcsvm(train_HLEYE,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVM_HLEYE,test_HLEYE);
        svmpred_HLEYE = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlEN_HLEYE = fitensemble(train_HLEYE,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlEN_HLEYE, test_HLEYE);
        enpred_HLEYE = sum(pred2(:)==testTarget(:))/(testSZ*2);

        if j==1
            maxPredSVMALL = svmpredALL;
            maxPredENALL = enpredALL;
            maxPredSVM_HLEYE = svmpred_HLEYE;
            maxPredEN_HLEYE = enpred_HLEYE;

            mdlSVM_HLEYEmx=mdlSVM_HLEYE;
            mdlEN_HLEYEmx=mdlEN_HLEYE;
            mdlSVMALLmx = mdlSVMALL;
            mdlENALLmx = mdlENALL;

        elseif svmpredALL > maxPredSVMALL
            maxPredSVMALL = svmpredALL;
            mdlSVMALLmx = mdlSVMALL;
        elseif enpredALL > maxPredENALL
            maxPredENALL = enpredALL;
            mdlENALLmx = mdlENALL;
        elseif svmpred_HLEYE > maxPredSVM_HLEYE
            maxPredSVM_HLEYE = svmpred_HLEYE;
            mdlSVM_HLEYEmx = mdlSVM_HLEYE;
        elseif enpred_HLEYE > maxPredEN_HLEYE
            maxPredEN_HLEYE = enpred_HLEYE;
            mdlEN_HLEYEmx = mdlEN_HLEYE;     
        end    
%         disp('******************************************************')
        predSVMALL(j,1) = svmpredALL;
        predENALL(j,1) = enpredALL;
        predSVM_HLEYE(j,1) = svmpred_HLEYE;
        predEN_HLEYE(j,1) = enpred_HLEYE;
    end
meanPredSVMALL = mean(predSVMALL);
stdPredSVMALL= std(predSVMALL);
meanPredENALL = mean(predENALL);
stdPredENALL=std(predENALL);

meanPredSVM_HLEYE = mean(predSVM_HLEYE);
stdPredSVM_HLEYE= std(predSVM_HLEYE);
meanPredEN_HLEYE = mean(predEN_HLEYE);
stdPredEN_HLEYE=std(predEN_HLEYE);

% save(fullfile('CV_HLEYE', [fname num2str(obs) '_CV_HLEYE.mat']),'fname','obs','reps', 'mdlSVMALLmx','meanPredSVMALL','stdPredSVMALL','maxPredSVMALL'...
%             ,'mdlENALLmx','meanPredENALL','stdPredENALL','maxPredENALL'...
% 			,'mdlSVM_HLEYEmx','meanPredSVM_HLEYE','stdPredSVM_HLEYE','maxPredSVM_HLEYE'...
%             ,'mdlEN_HLEYEmx','meanPredEN_HLEYE','stdPredEN_HLEYE','maxPredEN_HLEYE');
end