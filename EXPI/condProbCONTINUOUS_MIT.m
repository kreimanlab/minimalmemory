function [probT,dependence, num_cases,first_zero] = condProbCONTINUOUS_MIT(fname,obs)
load(fullfile('MAT VID DATA','MIT',[fname 'MS' num2str(obs) '.mat']));
load(fullfile('annotationsMIT1',[ fname '.mat']));
ResultAnnotation = sortrows(ResultAnnotation,'Foiltarget','descend');
m = find(strcmp(string(ResultAnnotation.Foiltarget),"foil'"),1,'first')-1 ;
ResultAnnotation = ResultAnnotation(1:m,:);
beginningframe = zeros(m,1);
segnum = zeros(m,1);
if ~strcmp(fname,'Gillis')
    for j = 1:m
        %for targets
        entry = ResultAnnotation(j,:);
        if strcmp(string(entry.Foiltarget),string('target'''))
            flag = 0;
            [n,~] = size(MITVideoData);
            for i = 1:n
                st1 = extractBefore(string(entry.Filename),string('.'));
                st2 = string(MITVideoData.Savedas(i));
                    if strcmp(st1,st2)
                        flag =1;
                        try
                            seg = str2double( extractAfter(extractBefore(string(MITVideoData.Videofile(i)),"."), ...
                                                    strcat('_', num2str(obs), '_' ) ));
                        segnum(j) = seg;
                        catch
                            segnum(j) = segnum(j-1);
                        end
                        beginningframe(j) = MITVideoData.BeginningFramesecondsx30framessec(i);
                    end
            end

            if flag ==0 
                [n,~] = size(MITVideoDataS1);
                for i = 1:n       
                    st1 = extractBefore(string(entry.Filename),string('.'));
                    st2 = string(MITVideoDataS1.Savedas(i));
                        if strcmp(st1,st2)
                            try
                            seg = str2double( extractAfter(extractBefore(string(MITVideoData.Videofile(i)),"."), ...
                                                    strcat('_', num2str(obs), '_' ) ));
                            segnum(j) = seg;
                            catch
                                segnum(j) = segnum(j-1);
                            end
                            beginningframe(j) = MITVideoDataS1.BeginningFramesecondsx30framessec(i);                        
                        break;
                        end
                end
            end
        else     %for foils        
        end
    end
    ResultAnnotation.seg = segnum;
    ResultAnnotation.beginningframe = beginningframe;
    ResultAnnotation = sortrows(ResultAnnotation,{'Foiltarget','seg','beginningframe'},{'descend','ascend','ascend'});
    RA = ResultAnnotation;
else
    [n,~] = size(MITVideoData);
    for j = 1:m
        entry = ResultAnnotation(j,:);
        for i =1:n
            if entry.seg == MITVideoData.seg(i) && entry.im == MITVideoData.map(i) && strcmp(string(entry.facescene),strcat(string(MITVideoData.SceneFace(i)), "'"))
                beginningframe(j) =  MITVideoData.BeginningFramesecondsx30framessec(i);
            end
        end        
    end
ResultAnnotation.beginningframe = beginningframe;
ResultAnnotation = sortrows(ResultAnnotation,{'Foiltarget','seg','beginningframe'},{'descend','ascend','ascend'});
RA = ResultAnnotation;
end

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
       if RA.Correct1yes0no(i) ==1  
           if RA.Correct1yes0no(j)==1
            dependence(pntr(i)-pntr(j)) = dependence(pntr(i)-pntr(j)) + 1;
           end
            num_cases(pntr(i)-pntr(j)) = num_cases(pntr(i)-pntr(j))+1;
       end
    end   
    catch
%        i ;
    end
end

% num_cases(2) = num_cases(2)+num_cases(1);
% dependence(2) = dependence(2)+dependence(1);
% num_cases = num_cases(2:end);
% dependence = dependence(2:end);
% len_hyp = len_hyp-1;
% return;
probI = sum(RA.Correct1yes0no)/size(RA,1);
probT = zeros(5000,1);
for i = 1:len_hyp
    if num_cases(i) >= 20 
       probT(i) = (dependence(i)/num_cases(i))/probI;
    else
       probT(i) = NaN;
    end
end


% fff = filter(ones(1,8),1,num_cases);
% ddd = filter(ones(1,8),1,dependence);
% 
% probI = sum(RA.Correct1yes0no)/size(RA,1);
% probT = zeros(1,len_hyp);
% for i = 1:len_hyp
%     try
%     if num_cases(i) >= 8 
%        probT(i) = (ddd(i)/fff(i))/probI;
%     else
%        probT(i) = NaN;
%     end
%     catch
%         i
%     end
% end

first_zero = find(num_cases(1:end) == 0,1,'first');
probT = probT(1:5000,1);
end