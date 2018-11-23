%% edits_here!!!!!!!!!!
%WARNING! has a save at the end CAREFUL!
% targets only  CV_HL_EYE  &  HL_EYE (without annotations)
function [   mdlSVMCV_HL_EYEmx,meanPredSVMCV_HL_EYE,stdPredSVMCV_HL_EYE,maxPredSVMCV_HL_EYE...
            ,mdlENCV_HL_EYEmx,meanPredENCV_HL_EYE,stdPredENCV_HL_EYE,maxPredENCV_HL_EYE...
            ,mdlSVM_HL_EYEmx,meanPredSVM_HL_EYE,stdPredSVM_HL_EYE,maxPredSVM_HL_EYE...
            ,mdlEN_HL_EYEmx,meanPredEN_HL_EYE,stdPredEN_HL_EYE,maxPredEN_HL_EYE] = pred_CV_HL_ADDEYE(fname,obs, reps)       

load(fullfile('annotationInfoMFA','RA2','RA_NO_FIX',[ fname '.mat']));
load(fullfile('FEATURES','FC7',[ 'MS_CLSF_' num2str(obs) '.mat']));
ResultAnnotation2.index = string(ResultAnnotation2.index);
RA = sortrows(ResultAnnotation2,{'Foiltarget','Facescene','index'},{'ascend','ascend','ascend'});
ResultAnnotation2 = RA;
clear RA;

[FIX, sacdur,sacmag,totalx,totaly] = EYE_INFO_NEW(fname,obs);
[m,~] =size(ResultAnnotation2);

T2 = table([1:m]',ResultAnnotation2.VarName1,ResultAnnotation2.Foiltarget,ResultAnnotation2.correct,...
   ResultAnnotation2.Filename,ResultAnnotation2(:,7:22),FIX, sacdur,sacmag,totalx,totaly,'VariableNames',{'mainIndex' 'VarName1'...
   'Foiltarget' 'correct' 'Filename' 'annotatedfeatures','FIX','sacdur','sacmag','totalx','totaly'});

kkk = [T2.mainIndex(T2.correct==1 & T2.Foiltarget=='target''' )];
lll = [T2.mainIndex(T2.correct==0 & T2.Foiltarget=='target''' )];

[m1,~] = size(kkk);
[m2,~] = size(lll);

predSVMCV_HL_EYE = zeros(reps,1);
predENCV_HL_EYE = zeros(reps,1);
predSVM_HL_EYE = zeros(reps,1);
predEN_HL_EYE = zeros(reps,1);

maxPredSVMCV_HL_EYE = 0;
maxPredENCV_HL_EYE = 0;
maxPredSVM_HL_EYE=0;
maxPredEN_HL_EYE=0;

mdlSVMCV_HL_EYEmx = [];
mdlENCV_HL_EYEmx = [];
mdlSVM_HL_EYEmx=[];
mdlEN_HL_EYEmx=[];

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
        trainHL_EYE(:,:) =  tttt(:,1:end);       
        % adding alexnet features with other features
        tt1(:,:) = T.featuresMean(useIndex1(:),:);
        tt0(:,:) = T.featuresMean(useIndex0(:),:);
        kk1(:,:) = [tttt(1:trainSZ,:),          tt1(:,:)];
        kk0(:,:) = [tttt(trainSZ+1:trainSZ*2,:),tt0(:,:)];
        %final training data
        trainFeaturesCV_HL_EYE(:,:) = [kk1(:,:);kk0(:,:)];%CV_HL_EYE features with alexnet fc7
        train_HL_EYE(:,:) = double(trainHL_EYE(:,:));
        
        useIndex1  = test1.mainIndex(:);
        useIndex0  = test0.mainIndex(:);
        testE(:,:) = [[test1{:,6},test1(:,7:11)] ;[test0{:,6} ,test0(:,7:11)]];
        uuuu(:,:)  = testE{:,:};
        testHL_EYE(:,:) =  uuuu(:,1:end);
        % adding alexnet features with other features
        ttt1(:,:) = T.featuresMean(useIndex1(:),:);
        ttt0(:,:) = T.featuresMean(useIndex0(:),:);
        kkk1(:,:) = [uuuu(1:testSZ,:),ttt1(:,:)];
        kkk0(:,:) = [uuuu(testSZ+1:testSZ*2,:),ttt0(:,:)];
        %final testing data
        testFeaturesCV_HL_EYE(:,:) = [kkk1(:,:);kkk0(:,:)]; %CV_HL_EYE features with alexnet fc7
        test_HL_EYE(:,:) = double(testHL_EYE(:,:));
        
        clear kk0 kk1 kk3 kk4 tt1 tt0 uuuu ttt0 ttt1 tttt kkk1 kkk0 kkk3 kkk4 useIndex0 useIndex1 train0 train1 test0 test1 testHL_EYE trainHL_EYE trainE testE
        
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

        mdlSVMCV_HL_EYE = fitcsvm(trainFeaturesCV_HL_EYE,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMCV_HL_EYE,testFeaturesCV_HL_EYE);
        svmpredCV_HL_EYE = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlENCV_HL_EYE = fitensemble(trainFeaturesCV_HL_EYE,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENCV_HL_EYE, testFeaturesCV_HL_EYE);
        enpredCV_HL_EYE = sum(pred2(:)==testTarget(:))/(testSZ*2);
        
        mdlSVM_HL_EYE = fitcsvm(train_HL_EYE,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVM_HL_EYE,test_HL_EYE);
        svmpred_HL_EYE = sum(pred1(:)==testTarget(:))/(testSZ*2);


        mdlEN_HL_EYE = fitensemble(train_HL_EYE,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlEN_HL_EYE, test_HL_EYE);
        enpred_HL_EYE = sum(pred2(:)==testTarget(:))/(testSZ*2);

        if j==1
            maxPredSVMCV_HL_EYE = svmpredCV_HL_EYE;
            maxPredENCV_HL_EYE = enpredCV_HL_EYE;
            maxPredSVM_HL_EYE = svmpred_HL_EYE;
            maxPredEN_HL_EYE = enpred_HL_EYE;

            mdlSVM_HL_EYEmx=mdlSVM_HL_EYE;
            mdlEN_HL_EYEmx=mdlEN_HL_EYE;
            mdlSVMCV_HL_EYEmx = mdlSVMCV_HL_EYE;
            mdlENCV_HL_EYEmx = mdlENCV_HL_EYE;

        elseif svmpredCV_HL_EYE > maxPredSVMCV_HL_EYE
            maxPredSVMCV_HL_EYE = svmpredCV_HL_EYE;
            mdlSVMCV_HL_EYEmx = mdlSVMCV_HL_EYE;
        elseif enpredCV_HL_EYE > maxPredENCV_HL_EYE
            maxPredENCV_HL_EYE = enpredCV_HL_EYE;
            mdlENCV_HL_EYEmx = mdlENCV_HL_EYE;
        elseif svmpred_HL_EYE > maxPredSVM_HL_EYE
            maxPredSVM_HL_EYE = svmpred_HL_EYE;
            mdlSVM_HL_EYEmx = mdlSVM_HL_EYE;
        elseif enpred_HL_EYE > maxPredEN_HL_EYE
            maxPredEN_HL_EYE = enpred_HL_EYE;
            mdlEN_HL_EYEmx = mdlEN_HL_EYE;     
        end    
%         disp('******************************************************')
        predSVMCV_HL_EYE(j,1) = svmpredCV_HL_EYE;
        predENCV_HL_EYE(j,1) = enpredCV_HL_EYE;
        predSVM_HL_EYE(j,1) = svmpred_HL_EYE;
        predEN_HL_EYE(j,1) = enpred_HL_EYE;
    end
meanPredSVMCV_HL_EYE = mean(predSVMCV_HL_EYE);
stdPredSVMCV_HL_EYE= std(predSVMCV_HL_EYE);
meanPredENCV_HL_EYE = mean(predENCV_HL_EYE);
stdPredENCV_HL_EYE=std(predENCV_HL_EYE);

meanPredSVM_HL_EYE = mean(predSVM_HL_EYE);
stdPredSVM_HL_EYE= std(predSVM_HL_EYE);
meanPredEN_HL_EYE = mean(predEN_HL_EYE);
stdPredEN_HL_EYE=std(predEN_HL_EYE);

% save(fullfile('CV_HL_ADDEYE', [fname num2str(obs) '_CV_HL_ADDEYE.mat']),'fname','obs','reps', 'mdlSVMCV_HL_EYEmx','meanPredSVMCV_HL_EYE','stdPredSVMCV_HL_EYE','maxPredSVMCV_HL_EYE'...
%             ,'mdlENCV_HL_EYEmx','meanPredENCV_HL_EYE','stdPredENCV_HL_EYE','maxPredENCV_HL_EYE'...
%             ,'mdlSVM_HL_EYEmx','meanPredSVM_HL_EYE','stdPredSVM_HL_EYE','maxPredSVM_HL_EYE'...
%             ,'mdlEN_HL_EYEmx','meanPredEN_HL_EYE','stdPredEN_HL_EYE','maxPredEN_HL_EYE');
end