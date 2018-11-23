function [ratio,RA,history_dep] = conditionalProbabilityUNSEQ(fname,obs,size_hist)
load(fullfile('MAT VID DATA',[fname 'MS' num2str(obs) '.mat']));
load(fullfile('annotationInfoMFA',[ fname '.mat']));
[m,~] =size(ResultAnnotation);    

beginningframe = zeros(m,1);
segnum = zeros(m,1);
ordered = zeros(m,1);
for j = 1:m
    %for targets
    entry = ResultAnnotation(j,:);
    if strcmp(string(entry.Foiltarget),string('target'''))
        flag = 0;
        [n,~] = size(MFAVideoData);
        for i = 1:n
            st1 = extractBefore(string(entry.Filename),string('.'));
            st2 = string(MFAVideoData.Savedas(i));
            try
                if strcmp(st1,st2)
                    flag =1;
                    seg = char(string(extractBefore(MFAVideoData.Videofile(i),".")));
                    seg = int8(seg(end)) - 48;
                    segnum(j) = seg;
                    beginningframe(j) = MFAVideoData.BeginningFramesecondsx30framessec(i);
                end
            catch
                disp('error in block 1');
            end
        end

        if flag ==0 
            [n,~] = size(MFAVideoDataS1);
            for i = 1:n       
                st1 = extractBefore(string(entry.Filename),string('.'));
                st2 = string(MFAVideoDataS1.Savedas(i));
                try
                    if strcmp(st1,st2)    
                        seg = char(string(extractBefore(MFAVideoDataS1.Videofile(i),".")));
                        seg = int8(seg(end)) - 48;
                        segnum(j) = seg;
                        beginningframe(j) = MFAVideoDataS1.BeginningFramesecondsx30framessec(i);                        
                    break;
                    end
                catch
                    disp('error in block 2');
                end
            end
        end
    else   %for foils 
        [n,~] = size(MFAVideoDataS3);
        for i = 1:n
            st1 = extractBefore(string(entry.Filename),string('.'));
            st2 = string(MFAVideoDataS3.mainFileName(i));
            try
                if strcmp(st1,st2) 
                        seg = char(string(extractBefore(MFAVideoDataS3.Videofile(i),".")));
                        seg = int8(seg(end)) - 48;
                        segnum(j) = seg;
                        beginningframe(j) = MFAVideoDataS3.BeginningFramesecondsx30framessec(i);
                    break;            
                end
            catch
                disp('error in block 3');
            end
        end           
    end
end



for i = 1:n
   ordered(i) = str2num(char(extractBefore(extractAfter(ResultAnnotation.Filename(i),'s_'),'.')));
end
ResultAnnotation.ordered = ordered;
ResultAnnotation.seg = segnum;
ResultAnnotation.beginningframe = beginningframe;
ResultAnnotation = sortrows(ResultAnnotation,{'Foiltarget','seg','beginningframe'},{'descend','ascend','ascend'});
temp = find(strcmp(string(ResultAnnotation.Foiltarget),'foil'''),1,'first');
RA = ResultAnnotation(1:temp-1,:);


ratio = zeros(size_hist,1);
% prev = RA.correct(1);
m = size(RA,1);
for history_dep = 1:size_hist
    cnt = 0;   
    for i = 1+history_dep:m
        if RA.correct(i) == 1
            if RA.correct(i-history_dep) == 1
            cnt = cnt+1;
            end
        end
    end    
%     history_dep
%     disp([fname ' conditional probability P(i=1|(..i-' num2str(history_dep) ')=1) : ' num2str(cnt/sum(RA.correct(1+history_dep:end)))]);
%     disp(num2str((cnt/sum(RA.correct(1+history_dep:end)))/(sum(RA.correct)/m)));
    ratio(history_dep) = (cnt/sum(RA.correct(1+history_dep:end)))/(sum(RA.correct)/m);
        if cnt<=20
            history_dep
            break;
        end
end
end