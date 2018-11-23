function [probT,dependence, num_cases,first_zero] = condProbMFA(fname,obs)
    load(fullfile('MAT VID DATA',[fname 'MS' num2str(obs) '.mat']));
    load(fullfile('annotationInfoMFA/RA2',[ fname '.mat']));
    ResultAnnotation = ResultAnnotation2;
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



    clearvars -except RA kk ll fname obs
    m = size(RA,1);
    track = zeros(m)-1;
    pntr = zeros(1,m)-1;

    curr_seg=1;
    pntr(1)=0; 
    for i=2:m
        if RA.seg(i) ==  curr_seg && i~=m
            pntr(i) = pntr(i-1) + RA.beginningframe(i) - RA.beginningframe(i-1);
        else
            pntr(i) = pntr(i-1) + RA.beginningframe(i) + 21240 - RA.beginningframe(i-1);
            curr_seg = RA.seg(i);
        end    
    end
    pntr = (pntr')/30;

    % length of hypothesis of temporal depdendence
    len_hyp = max(pntr);
    num_cases = zeros(1,len_hyp);
    dependence = zeros(1,len_hyp);
    for i = m:-1:2
        try
        for j = i-1:-1:1
           if RA.correct(i) ==1  
               if RA.correct(j)==1
                dependence(pntr(i)-pntr(j)) = dependence(pntr(i)-pntr(j)) + 1;
               end
                num_cases(pntr(i)-pntr(j)) = num_cases(pntr(i)-pntr(j))+1;
           end
        end   
        catch
           i 
        end
    end

    probI = sum(RA.correct)/size(RA,1);
    probT = zeros(5000,1);
    for i = 1:len_hyp
        if num_cases(i) >= 10
           probT(i) = (dependence(i)/num_cases(i))/probI;
        else
           probT(i) = NaN;
        end
    end

    % fff = filter(ones(1,2),1,num_cases);
    % ddd = filter(ones(1,2),1,dependence);
    % 
    % probI = sum(RA.correct)/size(RA,1);
    % probT = zeros(len_hyp,1);
    % for i = 1:len_hyp
    %     try
    %     if num_cases(i) >= 10 
    %        probT(i) = (ddd(i)/fff(i))/probI;
    %     else
    %        probT(i) = NaN;
    %     end
    %     catch
    %         i
    %     end
    % end

    first_zero = find(num_cases(1:end) == 0,1,'first');
    probT = probT(1:2000,1);
end
