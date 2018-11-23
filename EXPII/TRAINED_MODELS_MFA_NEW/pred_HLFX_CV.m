%% edits_here!!!!!!!!!!
%WARNING! has a save at the end CAREFUL!
% targets only  HLFX, CV+HLFX
function [   mdlSVM_CV_HLXmx,meanPredSVM_CV_HLX,stdPredSVM_CV_HLX,maxPredSVM_CV_HLX...
            ,mdlEN_CV_HLXmx,meanPredEN_CV_HLX,stdPredEN_CV_HLX,maxPredEN_CV_HLX...
            ,mdlSVM_HLXmx,meanPredSVM_HLX,stdPredSVM_HLX,maxPredSVM_HLX...
            ,mdlEN_HLXmx,meanPredEN_HLX,stdPredEN_HLX,maxPredEN_HLX] = pred_HLFX_CV (fname,obs, reps)       

load(fullfile('annotationInfoMFA','RA2',[ fname '.mat']));
load(fullfile('FEATURES','FC7',[ 'MS_CLSF_' num2str(obs) '.mat']));
ResultAnnotation2.index = string(ResultAnnotation2.index);
RA = sortrows(ResultAnnotation2,{'Foiltarget','Facescene','index'},{'ascend','ascend','ascend'});
ResultAnnotation2 = RA;
clear RA;

% [FIX, sacdur,sacmag,totalx,totaly] = EYE_INFO_NEW(fname,obs);
[m,~] =size(ResultAnnotation2);

T2 = table([1:m]',ResultAnnotation2.VarName1,ResultAnnotation2.Foiltarget,ResultAnnotation2.correct,...
   ResultAnnotation2.Filename,[ResultAnnotation2(:,7:34), ResultAnnotation2(:,37:40) ],'VariableNames',{'mainIndex' 'VarName1'...
   'Foiltarget' 'correct' 'Filename' 'annotatedfeatures'});

kkk = [T2.mainIndex(T2.correct==1 & T2.Foiltarget=='target''' ),];
lll = [T2.mainIndex(T2.correct==0 & T2.Foiltarget=='target''' ),];

[m1,~] = size(kkk);
[m2,~] = size(lll);

predSVM_CV_HLX = zeros(reps,1);
predEN_CV_HLX = zeros(reps,1);
predSVM_HLX = zeros(reps,1);
predEN_HLX = zeros(reps,1);

maxPredSVM_CV_HLX = 0;
maxPredEN_CV_HLX = 0;
maxPredSVM_HLX=0;
maxPredEN_HLX=0;

mdlSVM_CV_HLXmx = [];
mdlEN_CV_HLXmx = [];
mdlSVM_HLXmx=[];
mdlEN_HLXmx=[];

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
        trainE(:,:) = [[train1{:,6}] ;[train0{:,6}]];
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
        testE(:,:) = [[test1{:,6}] ;[test0{:,6}]];
        uuuu(:,:)  = testE{:,:};
        testHLEYE(:,:) =  uuuu(:,1:end);
        % adding alexnet features with other features
        ttt1(:,:) = T.featuresMean(useIndex1(:),:);
        ttt0(:,:) = T.featuresMean(useIndex0(:),:);
        kkk1(:,:) = [uuuu(1:testSZ,:),ttt1(:,:)];
        kkk0(:,:) = [uuuu(testSZ+1:testSZ*2,:),ttt0(:,:)];
        %final testing data
        testCV_HLX(:,:) = [kkk1(:,:);kkk0(:,:)]; %all features with alexnet fc7
        test_HLX(:,:) = testHLEYE(:,:);
        
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

        mdlSVM_CV_HLX = fitcsvm(trainFeaturesALL,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVM_CV_HLX,testCV_HLX);
        svmpredALL = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlEN_CV_HLX = fitensemble(trainFeaturesALL,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlEN_CV_HLX, testCV_HLX);
        enpredALL = sum(pred2(:)==testTarget(:))/(testSZ*2);
        
        mdlSVM_HLX = fitcsvm(train_HLEYE,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVM_HLX,test_HLX);
        svmpred_HLEYE = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlEN_HLX = fitensemble(train_HLEYE,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlEN_HLX, test_HLX);
        enpred_HLEYE = sum(pred2(:)==testTarget(:))/(testSZ*2);

        if j==1
            maxPredSVM_CV_HLX = svmpredALL;
            maxPredEN_CV_HLX = enpredALL;
            maxPredSVM_HLX = svmpred_HLEYE;
            maxPredEN_HLX = enpred_HLEYE;

            mdlSVM_HLXmx=mdlSVM_HLX;
            mdlEN_HLXmx=mdlEN_HLX;
            mdlSVM_CV_HLXmx = mdlSVM_CV_HLX;
            mdlEN_CV_HLXmx = mdlEN_CV_HLX;

        elseif svmpredALL > maxPredSVM_CV_HLX
            maxPredSVM_CV_HLX = svmpredALL;
            mdlSVM_CV_HLXmx = mdlSVM_CV_HLX;
        elseif enpredALL > maxPredEN_CV_HLX
            maxPredEN_CV_HLX = enpredALL;
            mdlEN_CV_HLXmx = mdlEN_CV_HLX;
        elseif svmpred_HLEYE > maxPredSVM_HLX
            maxPredSVM_HLX = svmpred_HLEYE;
            mdlSVM_HLXmx = mdlSVM_HLX;
        elseif enpred_HLEYE > maxPredEN_HLX
            maxPredEN_HLX = enpred_HLEYE;
            mdlEN_HLXmx = mdlEN_HLX;     
        end    
%         disp('******************************************************')
        predSVM_CV_HLX(j,1) = svmpredALL;
        predEN_CV_HLX(j,1) = enpredALL;
        predSVM_HLX(j,1) = svmpred_HLEYE;
        predEN_HLX(j,1) = enpred_HLEYE;
    end
meanPredSVM_CV_HLX = mean(predSVM_CV_HLX);
stdPredSVM_CV_HLX= std(predSVM_CV_HLX);
meanPredEN_CV_HLX = mean(predEN_CV_HLX);
stdPredEN_CV_HLX=std(predEN_CV_HLX);

meanPredSVM_HLX = mean(predSVM_HLX);
stdPredSVM_HLX= std(predSVM_HLX);
meanPredEN_HLX = mean(predEN_HLX);
stdPredEN_HLX=std(predEN_HLX);
reps=100;
% save(fullfile('CV_HLX', [fname num2str(obs) '_CV_HLX.mat']),'fname','obs','reps', 'mdlSVM_CV_HLXmx','meanPredSVM_CV_HLX','stdPredSVM_CV_HLX','maxPredSVM_CV_HLX'...
%             ,'mdlEN_CV_HLXmx','meanPredEN_CV_HLX','stdPredEN_CV_HLX','maxPredEN_CV_HLX'...
% 			,'mdlSVM_HLXmx','meanPredSVM_HLX','stdPredSVM_HLX','maxPredSVM_HLX'...
%             ,'mdlEN_HLXmx','meanPredEN_HLX','stdPredEN_HLX','maxPredEN_HLX');
end