load('../../subjectNameMappingMIT.mat')
for po1ooo = 1: size(kk,2)
   clearvars -except kk ll po1ooo
   load( fullfile('./',[kk{po1ooo} char(string(ll(po1ooo))) '__OnlyH_MIT.mat']));
   fname = kk{po1ooo};
   clear filename
   save(fullfile('./',[kk{po1ooo} char(string(ll(po1ooo))) '__OnlyH_MIT.mat']));
end
