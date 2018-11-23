function [mdlSVMHmx, mdlENHmx, meanPredSVMH, stdPredSVMH, maxPredSVMH, meanPredENH, stdPredENH, maxPredENH ] =  gettingCloser_OnlyH_MIT(fname,obs, reps)
load(fullfile('annotationsMIT1',[ fname '.mat']));
load(fullfile('FEATURES','FC7',[ 'MS_CLSF_MIT_' num2str(obs) '.mat']));
[m,~] =size(ResultAnnotation);
T2 = table([1:m]',ResultAnnotation.VarName1,ResultAnnotation.Foiltarget,ResultAnnotation.Correct1yes0no,...
           ResultAnnotation.Filename,ResultAnnotation(:,7:end),'VariableNames',{'mainIndex' 'VarName1'...
           'Foiltarget' 'correct' 'Filename' 'annotatedfeatures'});

%this line defines the nature of splits
kkk = [T2.mainIndex(T2.correct==1),];
lll = [T2.mainIndex(T2.correct==0),];

[m1,~] = size(kkk);
[m2,~] = size(lll);


predSVMH = zeros(reps,1);
predENH = zeros(reps,1);

maxPredSVMH  = 0;
maxPredENH   = 0;

mdlSVMHmx   = [];
mdlENHmx    = [];

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

        train(:,:) = [[train1{:,6}] ;[train0{:,6}]];
        ttthe(:,:)  = train{:,:};
        ttth(:,:) = ttthe(:,1:end);

        test(:,:) = [[test1{:,6}] ;[test0{:,6}]];
        uuuhe(:,:)  = test{:,:};
        uuuh(:,:) = uuuhe(:,1:end);

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

        mdlSVMH = fitcsvm(ttth,trainTarget,'KernelFunction','rbf');
        pred1 = predict(mdlSVMH,uuuh);
        svmpredh = sum(pred1(:)==testTarget(:))/(testSZ*2);

        mdlENH = fitensemble(ttth,trainTarget,'AdaBoostM1',101,'Tree');
        pred2 = predict(mdlENH, uuuh);
        enpredh = sum(pred2(:)==testTarget(:))/(testSZ*2);

        if j==1
            maxPredSVMH = svmpredh;
            maxPredENH = enpredh;
            mdlSVMHmx = mdlSVMH;
            mdlENHmx = mdlENH;            
        elseif svmpredh > maxPredSVMH
            maxPredSVMH = svmpredh;
            mdlSVMHmx = mdlSVMH;
        elseif enpredh > maxPredENH
            maxPredENH = enpredh;
            mdlENHmx = mdlENH;     
        end    
%         disp('******************************************************')
        predSVMH(j,1) = svmpredh;
        predENH(j,1) = enpredh;
    end

meanPredSVMH = mean(predSVMH);
stdPredSVMH= std(predSVMH);
meanPredENH = mean(predENH);
stdPredENH=std(predENH);
end