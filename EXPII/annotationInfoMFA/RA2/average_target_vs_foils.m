load('../../subjectNameMapping.mat')
fff = zeros(1,9);
ttt = zeros(1,9);
subnum  =size(kk,2);
for i = 1 :subnum
    load(fullfile([char(kk(i)) '.mat'])); 
    ResultAnnotation2 = sortrows(ResultAnnotation2,'Foiltarget','descend');
    ResultAnnotation2 = [ResultAnnotation2(:,1:34) , ResultAnnotation2(:,37:end) ];
    xx = find(ResultAnnotation2.Foiltarget=='foil''',1);
    ResultAnnotation2T = ResultAnnotation2(1:xx-1, :);
    ResultAnnotation2F = ResultAnnotation2(xx:end, :);
    RAT(:,1:6) = ResultAnnotation2T(:,1:6);
    RAF(:,1:6) = ResultAnnotation2F(:,1:6);
    for j = 1:16
        RAT{:,7+j-1} = [ResultAnnotation2T{:,7+2*(j-1)} | ResultAnnotation2T{:,7+2*(j-1)+1}];
        RAF{:,7+j-1} = [ResultAnnotation2F{:,7+2*(j-1)} | ResultAnnotation2F{:,7+2*(j-1)+1}];
    end
    RAT(:,23) = ResultAnnotation2T(:,end);
    RAF(:,23) = ResultAnnotation2F(:,end);
    RAT.Properties.VariableNames = [ResultAnnotation2.Properties.VariableNames(1:6),{'Male','Female' , 'OneFace','ManyFaces', 'Young','Old', 'Action','NoAction' ...
              'Talking','NoTalking', 'DistinctIndividual','NonDistinctIndividual', 'DistinctObject','NonDistinctObject'...
                'Statue','Painting','index'}];
    RAF.Properties.VariableNames = [ResultAnnotation2.Properties.VariableNames(1:6),{'Male','Female' , 'OneFace','ManyFaces', 'Young','Old', 'Action','NoAction' ...
              'Talking','NoTalking', 'DistinctIndividual','NonDistinctIndividual', 'DistinctObject','NonDistinctObject'...
                'Statue','Painting','index'}];
    ResultAnnotation2T = RAT;
    ResultAnnotation2F = RAF;
    clear RAT RAF xx
    
    fff(i) = sum(ResultAnnotation2F.correct==1)/size(ResultAnnotation2F,1);
    ttt(i) = sum(ResultAnnotation2T.correct==1)/size(ResultAnnotation2T,1);
end