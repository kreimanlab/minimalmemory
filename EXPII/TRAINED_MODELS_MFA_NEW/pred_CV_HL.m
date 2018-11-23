%% edits_here!!!!!!!!!!
%WARNING! has a save at the end CAREFUL!
% CV_HL   &  HL (without eye data)
function [   mdlSVMCV_HLmx,meanPredSVMCV_HL,stdPredSVMCV_HL,maxPredSVMCV_HL...
            ,mdlENCV_HLmx,meanPredENCV_HL,stdPredENCV_HL,maxPredENCV_HL...
            ,mdlSVM_HLmx,meanPredSVM_HL,stdPredSVM_HL,maxPredSVM_HL...
            ,mdlEN_HLmx,meanPredEN_HL,stdPredEN_HL,maxPredEN_HL] = pred_CV_HL(fname,obs, reps)       

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

predSVMCV_HL = zeros(reps,1);
predENCV_HL = zeros(reps,1);
predSVM_HL = zeros(reps,1);
predEN_HL = zeros(reps,1);

maxPredSVMCV_HL = 0;
maxPredENCV_HL = 0;
maxPredSVM_HL=0;
maxPredEN_HL=0;

mdlSVMCV_HLmx = [];
mdlENCV_HLmx = [];
mdlSVM_HLmx=[];
mdlEN_HLmx=[];

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
        trainE(:,:) = [train1{:,6};train0{:,6}];
        tttt(:,:)  = trainE{:,:};
        trainHL(:,:) =  tttt(:,1:end);       
        % adding alexnet features with other features
        tt1(:,:) = T.featuresMean(useIndex1(:),:);
        tt0(:,:) = T.featuresMean(useIndex0(:),:);
        kk1(:,:) = [tttt(1:trainSZ,:),          tt1(:,:)];
        kk0(:,:) = [tttt(trainSZ+1:trainSZ*2,:),tt0(:,:)];
        %final training data
        trainFeaturesCV_HL(:,:) = [kk1(:,:);kk0(:,:)];%CV_HL features with alexnet fc7
        train_HL(:,:) = double(trainHL(:,:));
        
        useIndex1  = test1.mainIndex(:);
        useIndex0  = test0.mainIndex(:);
        testE(:,:) = [test1{:,6};test0{:,6}];
        uuuu(:,:)  = testE{:,:};
        testHL(:,:) =  uuuu(:,1:end);
        % adding alexnet features with other features
        ttt1(:,:) = T.featuresMean(useIndex1(:),:);
        ttt0(:,:) = T.featuresMean(useIndex0(:),:);
        kkk1(:,:) = [uuuu(1:testSZ,:),ttt1(:,:)];
        kkk0(:,:) = [uuuu(testSZ+1:testSZ*2,:),ttt0(:,:)];
        %final testing data
        testFeaturesCV_HL(:,:) = [kkk1(:,:);kkk0(:,:)]; %CV_HL features with alexnet fc7
        test_HL(:,:) = double(testHL(:,:));
        
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

        mdlSVMCV_HL = fitcsvm(trainFeaturesCV_HL,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMCV_HL,testFeaturesCV_HL);
        svmpredCV_HL = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlENCV_HL = fitensemble(trainFeaturesCV_HL,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENCV_HL, testFeaturesCV_HL);
        enpredCV_HL = sum(pred2(:)==testTarget(:))/(testSZ*2);
        
        mdlSVM_HL = fitcsvm(train_HL,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVM_HL,test_HL);
        svmpred_HL = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlEN_HL = fitensemble(train_HL,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlEN_HL, test_HL);
        enpred_HL = sum(pred2(:)==testTarget(:))/(testSZ*2);

        if j==1
            maxPredSVMCV_HL = svmpredCV_HL;
            maxPredENCV_HL = enpredCV_HL;
            maxPredSVM_HL = svmpred_HL;
            maxPredEN_HL = enpred_HL;

            mdlSVM_HLmx=mdlSVM_HL;
            mdlEN_HLmx=mdlEN_HL;
            mdlSVMCV_HLmx = mdlSVMCV_HL;
            mdlENCV_HLmx = mdlENCV_HL;

        elseif svmpredCV_HL > maxPredSVMCV_HL
            maxPredSVMCV_HL = svmpredCV_HL;
            mdlSVMCV_HLmx = mdlSVMCV_HL;
        elseif enpredCV_HL > maxPredENCV_HL
            maxPredENCV_HL = enpredCV_HL;
            mdlENCV_HLmx = mdlENCV_HL;
        elseif svmpred_HL > maxPredSVM_HL
            maxPredSVM_HL = svmpred_HL;
            mdlSVM_HLmx = mdlSVM_HL;
        elseif enpred_HL > maxPredEN_HL
            maxPredEN_HL = enpred_HL;
            mdlEN_HLmx = mdlEN_HL;     
        end    
%         disp('******************************************************')
        predSVMCV_HL(j,1) = svmpredCV_HL;
        predENCV_HL(j,1) = enpredCV_HL;
        predSVM_HL(j,1) = svmpred_HL;
        predEN_HL(j,1) = enpred_HL;
    end
meanPredSVMCV_HL = mean(predSVMCV_HL);
stdPredSVMCV_HL= std(predSVMCV_HL);
meanPredENCV_HL = mean(predENCV_HL);
stdPredENCV_HL=std(predENCV_HL);

meanPredSVM_HL = mean(predSVM_HL);
stdPredSVM_HL= std(predSVM_HL);
meanPredEN_HL = mean(predEN_HL);
stdPredEN_HL=std(predEN_HL);

% save(fullfile('CV_HL', [fname num2str(obs) '_CV_HL.mat']),  'mdlSVMCV_HLmx','meanPredSVMCV_HL','stdPredSVMCV_HL','maxPredSVMCV_HL'...
%             ,'mdlENCV_HLmx','meanPredENCV_HL','stdPredENCV_HL','maxPredENCV_HL'...
%             ,'mdlSVM_HLmx','meanPredSVM_HL','stdPredSVM_HL','maxPredSVM_HL'...
%             ,'mdlEN_HLmx','meanPredEN_HL','stdPredEN_HL','maxPredEN_HL', 'fname','obs','reps');
end