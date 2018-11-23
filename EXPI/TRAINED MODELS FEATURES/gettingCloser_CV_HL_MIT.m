%  [mdlSVMALLmx,mdlENALLmx,meanPredSVMALL,stdPredSVMALL,maxPredSVMALL,meanPredENALL,stdPredENALL,maxPredENALL...
function [mdlSVMCV_HLmx,mdlENCV_HLmx,meanPredSVMCV_HL,stdPredSVMCV_HL,maxPredSVMCV_HL,meanPredENCV_HL,stdPredENCV_HL,maxPredENCV_HL...         
          ,mdlSVMFmx,mdlENFmx,meanPredSVMF,stdPredSVMF,maxPredSVMF,meanPredENF,stdPredENF,maxPredENF ] = gettingCloser_CV_HL_MIT(fname,obs, reps)
load(fullfile('annotationsMIT1',[ fname '.mat']));
load(fullfile('FEATURES','FC7',[ 'MS_CLSF_MIT_' num2str(obs) '.mat']));
[m,~] =size(ResultAnnotation);
T2 = table([1:m]',ResultAnnotation.VarName1,ResultAnnotation.Foiltarget,ResultAnnotation.Correct1yes0no,...
           ResultAnnotation.Filename,ResultAnnotation(:,7:end),'VariableNames',{'mainIndex' 'VarName1'...
           'Foiltarget' 'correct' 'Filename' 'annotatedfeatures'});

kkk = [T2.mainIndex(T2.correct==1),];
lll = [T2.mainIndex(T2.correct==0),];
[m1,~] = size(kkk);
[m2,~] = size(lll);

predSVMCV_HL = zeros(reps,1);
predENCV_HL = zeros(reps,1);
predSVMF = zeros(reps,1);
predENF = zeros(reps,1);

maxPredSVMF = 0;
maxPredENF = 0;
maxPredSVMCV_HL=0;
maxPredENCV_HL=0;

mdlSVMCV_HLmx=[];
mdlENCV_HLmx=[];
mdlSVMFmx = [];
mdlENFmx = [];
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
        trainOnlyH(:,:) =  tttt(:,1:end);       
        tt1(:,:) = T.featuresMean(useIndex1(:),:);
        tt0(:,:) = T.featuresMean(useIndex0(:),:);
        kk3(:,:) = [trainOnlyH(1:size(tt1,1),:),tt1(:,:)];
        kk4(:,:) = [trainOnlyH(size(tt1,1)+1:size(tt1,1)*2,:),tt0(:,:)];      
        %final train set
        trainCV_HL(:,:) = [kk3(:,:);kk4(:,:)];
        trainF(:,:) = [tt1(:,:);tt0(:,:)]; %only alexnet fc7
    
        %creating test set
        useIndex1  = test1.mainIndex(:);
        useIndex0  = test0.mainIndex(:);
        testE(:,:) = [[test1{:,6}] ;[test0{:,6}]];
        uuuu(:,:)  = testE{:,:};
        testOnlyH(:,:) =  uuuu(:,1:end);       
        ttt1(:,:) = T.featuresMean(useIndex1(:),:);
        ttt0(:,:) = T.featuresMean(useIndex0(:),:);
        kkk3(:,:) = [testOnlyH(1:size(ttt1,1),:),ttt1(:,:)];
        kkk4(:,:) = [testOnlyH(size(ttt1,1)+1:size(ttt1,1)*2,:),ttt0(:,:)];
        %final test set
        testCV_HL(:,:) = [kkk3(:,:);kkk4(:,:)];
        testF(:,:) = [ttt1(:,:);ttt0(:,:)];   %only alexnet fc7
        
        clear kk0 kk1 kk3 kk4 tt1 tt0 uuuu ttt0 ttt1 tttt kkk1 kkk0 kkk3 kkk4 useIndex0 useIndex1 train0 train1 test0 test1
        
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
        
        mdlSVMCV_HL = fitcsvm(trainCV_HL,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMCV_HL,testCV_HL);
        svmpredCV_HL = sum(pred1(:)==testTarget(:))/(testSZ*2);

        mdlENCV_HL = fitensemble(trainCV_HL,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENCV_HL, testCV_HL);
        enpredCV_HL = sum(pred2(:)==testTarget(:))/(testSZ*2);

        mdlSVMF = fitcsvm(trainF,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMF,testF);
        svmpredF = sum(pred1(:)==testTarget(:))/(testSZ*2);

        mdlENF = fitensemble(trainF,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENF, testF);
        enpredF = sum(pred2(:)==testTarget(:))/(testSZ*2);
        if j==1
            maxPredSVMCV_HL = svmpredCV_HL;
            maxPredENCV_HL = enpredCV_HL;
            maxPredSVMF = svmpredF;
            maxPredENF = enpredF;

            mdlSVMCV_HLmx = mdlSVMCV_HL;
            mdlENCV_HLmx = mdlENCV_HL;
            mdlSVMFmx = mdlSVMF;
            mdlENFmx = mdlENF;
            
        elseif svmpredCV_HL > maxPredSVMCV_HL
            maxPredSVMCV_HL = svmpredCV_HL;
            mdlSVMCV_HLmx = mdlSVMCV_HL;
        elseif enpredCV_HL > maxPredENCV_HL
            maxPredENCV_HL = enpredCV_HL;
            mdlENCV_HLmx = mdlENCV_HL;
        elseif svmpredF > maxPredSVMF
            maxPredSVMF = svmpredF;
            mdlSVMFmx = mdlSVMF;      
        elseif enpredF > maxPredENF
            maxPredENF = enpredF;
            mdlENFmx = mdlENF;        
        end    
%         disp('******************************************************')
        predSVMCV_HL(j,1) = svmpredCV_HL;
        predENCV_HL(j,1) = enpredCV_HL;
        predSVMF(j,1) = svmpredF;
        predENF(j,1) = enpredF;
    end
meanPredSVMCV_HL = mean(predSVMCV_HL);
stdPredSVMCV_HL= std(predSVMCV_HL);
meanPredENCV_HL = mean(predENCV_HL);
stdPredENCV_HL=std(predENCV_HL);

meanPredSVMF=mean(predSVMF);
stdPredSVMF=std(predSVMF);
meanPredENF= mean(predENF);
stdPredENF=std(predENF);
end

