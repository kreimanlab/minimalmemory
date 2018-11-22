load('../subjectNameMappingMIT2.mat')
for po1ooo = 1: size(kk,2)
   clearvars -except kk ll po1ooo
   load( fullfile('./',[kk{po1ooo} '.mat']));
   fname = kk{po1ooo};
   clear filename
   save([kk{po1ooo} '.mat']);
end
