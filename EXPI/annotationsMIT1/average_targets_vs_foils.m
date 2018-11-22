load('./subjectNameMappingMIT.mat');
fff = zeros(1,7);
ttt = zeros(1,7);
subnum  =size(kk,2);
for i = 1 :subnum
    load(fullfile([char(kk(i)) '.mat'])); 
    ResultAnnotation = sortrows(ResultAnnotation,'Foiltarget','descend');
    xx = find(ResultAnnotation.Foiltarget=='foil''',1);
    ResultAnnotationT = ResultAnnotation(1:xx-1, :);
    ResultAnnotationF = ResultAnnotation(xx:end, :);
    
    fff(i) = sum(ResultAnnotationF.Correct1yes0no==1)/size(ResultAnnotationF,1);
    ttt(i) = sum(ResultAnnotationT.Correct1yes0no==1)/size(ResultAnnotationT,1);
end