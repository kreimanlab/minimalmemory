function [FIX, sacdur,sacmag,totalx,totaly] = EYE_INFO_NEW(fname,obs)
    % files worth the bucks:
    % MAT VID DATA,EXTRAPOLATE,MAT,annotationsInfoMFA
    % finding fixation and gaze data related to eas
    disp('new more sensible');
    fix=[];
    global fix2  ep2 valid2
    if obs == 20 
        load(fullfile('annotationInfoMFA','RA2',[ 'Amanda' '.mat']));
        load(fullfile('DATA','MAT',[ 'MS_' num2str(19) '.mat']));
        load(fullfile('EXTRAPOLATE',[ 'MS_' num2str(19) '.mat']));
    else
        load(fullfile('annotationInfoMFA','RA2',[ 'Connor' '.mat']));
        load(fullfile('DATA','MAT',[ 'MS_' num2str(20) '.mat']));
        load(fullfile('EXTRAPOLATE',[ 'MS_' num2str(20) '.mat']));
    end
    fix2 = fix;
    ep2 = ep;
    valid2 = valid;
    
    load(fullfile('MAT VID DATA',[fname 'MS' num2str(obs) '.mat']));
    load(fullfile('EXTRAPOLATE',[ 'MS_' num2str(obs) '.mat']));
    load(fullfile('annotationInfoMFA','RA2',[ fname '.mat']));
    load(fullfile('DATA','MAT',[ 'MS_' num2str(obs) '.mat']));
    [m,~] =size(ResultAnnotation2);    
    
    ResultAnnotation2.index = string(ResultAnnotation2.index);
    RA = sortrows(ResultAnnotation2,{'Foiltarget','index'});
    RA = sortrows(ResultAnnotation2,{'Foiltarget','Facescene','index'},{'ascend','ascend','ascend'});
    ResultAnnotation2 = RA;
    clear RA;

    FIX = zeros(m,1);
    sacdur = zeros(m,1);
    sacmag = zeros(m,1);
    totalx = zeros(m,1);
    totaly = zeros(m,1);
    for j = 1:m
        %for targets
        entry = ResultAnnotation2(j,:);
        if strcmp(string(entry.Foiltarget),string('target'''))
%             display('aaya');
            flag = 0;
            [n,~] = size(MFAVideoData);
            for i = 1:n
                st1 = extractBefore(string(entry.Filename),string('.'));
                st2 = string(MFAVideoData.Savedas(i));
                try
                    if strcmp(st1,st2)
%                         display('aaya 1');
                        flag =1;
                        [fff,ssdd,ssmm]    = doFixStuff(MFAVideoData,i,fix,obs,0); 
                        [ttx,tty] = doEPStuff(MFAVideoData,i,ep,valid,obs,0);
                        FIX(j)=fff;
                        sacdur(j)=ssdd;
                        sacmag(j)=ssmm;
                        totalx(j)=ttx;
                        totaly(j)=tty;
                        break;
                    end
                catch
                    disp('error in block 1');
                    FIX(j)=-1;
                    sacdur(j)=-111;
                    sacmag(j)=-111;
                    totalx(j)=-111;
                    totaly(j)=-111;
                end
            end

            if flag ==0 
                [n,~] = size(MFAVideoDataS1);
                for i = 1:n       
                    st1 = extractBefore(string(entry.Filename),string('.'));
                    st2 = string(MFAVideoDataS1.Savedas(i));
                    try
                        if strcmp(st1,st2)  
%                             display('aaya 2');
                            [fff,ssdd,ssmm]    = doFixStuff(MFAVideoDataS1,i,fix,obs,0); 
                            [ttx,tty] = doEPStuff(MFAVideoDataS1,i,ep,valid,obs,0);
                            FIX(j)=fff;
                            sacdur(j)=ssdd;
                            sacmag(j)=ssmm;
                            totalx(j)=ttx;
                            totaly(j)=tty;
                        break;
                        end
                    catch
                        disp('error in block 2');
                        FIX(j)=-11;
                        sacdur(j)=-11;
                        sacmag(j)=-11;
                        totalx(j)=-11;
                        totaly(j)=-11;
                    end
                end
            end
        else   %for foils 
%             display('aaya3');
            [n,~] = size(MFAVideoDataS3);
            for i = 1:n
                st1 = extractBefore(string(entry.Filename),string('.'));
                st2 = string(MFAVideoDataS3.mainFileName(i));
                try
                    if strcmp(st1,st2) 
    %                         whos
                            [fff,ssdd,ssmm]    = doFixStuff(MFAVideoDataS3,i,fix,obs,1); 
                            [ttx,tty] = doEPStuff(MFAVideoDataS3,i,ep,valid,obs,1);
                            FIX(j)=fff;
                            sacdur(j)=ssdd;
                            sacmag(j)=ssmm;
                            totalx(j)=ttx;
                            totaly(j)=tty;
                        break;            
                    end
                catch
                    disp('error in block 3');
                    FIX(j)=-1;
                    sacdur(j)=-1;
                    sacmag(j)=-1;
                    totalx(j)=-1;
                    totaly(j)=-1;
                end
            end
                        %doing this because it does not make sense
                        %quantifying this for foils using this
                        FIX(j)   =-1;
                        sacdur(j)=-1;
                        sacmag(j)=-1;
                        totalx(j)=-1;
                        totaly(j)=-1;            
        end
    end
end

function [FIXX, avSAC, avMAG] = doFixStuff(TTT,i,fix,obs,flag)
            global fix2
            %incoporating stuff for foils
            if flag==1
                fix = fix2;   
            end
                
            seg = char(string(extractBefore(TTT.Videofile(i),".")));
            seg = int8(seg(end)) - 48;
            startIndexFix = find(fix.seg>=seg & fix.segtime>=TTT.Timesec(i),1,'first');
            FIXX=0;
            avSAC = 0;
            avMAG = 0;
            avg_saccade_dur_check = [];
            try
                if ~isempty(startIndexFix)
                    if ~isempty(...
                        find(abs((fix.segtime(startIndexFix-1:startIndexFix+1)-TTT.Timesec(i)))<=1,1,'first'))
                        FIXX = 1;
                        avg_saccade_dur_check = abs((fix.segtime(startIndexFix-2:startIndexFix+2)-TTT.Timesec(i)))<=1;
                        for k=1:5
                               if avg_saccade_dur_check(k)==1
                                  avSAC = avSAC + fix.sacdur.m(startIndexFix+k-1); 
                                  avMAG = avMAG + fix.sacmag.m(startIndexFix+k-1);
                               end
                        end
                        avSAC = avSAC/sum(avg_saccade_dur_check);
                        avMAG = avMAG/sum(avg_saccade_dur_check);
                    end
                end
            catch
%                  disp(['error in fix block 1  ' num2str(i) '   ' num2str(startIndexFix) '   ' avg_saccade_dur_check ' ' num2str(flag)]);
%                  disp('fixation data may not be available for corresponding video');
            end 
end

function [totalx, totaly] = doEPStuff(TTT,i,ep,valid,obs,flag)
            global valid2
            global ep2
            %incoporating stuff for foils 
            if flag==1               
                 ep = ep2;
                 valid =  valid2;
            end
            seg = char(string(extractBefore(TTT.Videofile(i),".")));
            seg = int8(seg(end)) - 48;
            startSegIndexValid = find(ep.seg>=seg & ep.segtime>=TTT.Timesec(i),1,'first');
            totalx=0;
            totaly=0;
            try
                totalx_check = valid.x.g(startSegIndexValid:startSegIndexValid+60)~=-2000;
                for k =1:60
                    if totalx_check(k) ==1
                           totalx = totalx + valid.x.g(startSegIndexValid+k-1);
                           totaly = totaly + valid.y.g(startSegIndexValid+k-1);
                    end
                end
            catch
%                disp(['error in ep block 1  ' num2str(i) '  '  num2str(totalx_check) ' ' num2str(flag)]); 
%                disp('EP data may not be available for corresponding video');
            end
end
