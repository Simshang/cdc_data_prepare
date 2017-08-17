clear;

load class.mat;
filepath = '../annotation/annotation_val/';
FPS = 30;	% following SCNN to use 30FPS for val video

mu = zeros(20,1);
sigma = zeros(20,1);
range = zeros(20,2);
for i = 1:20
    f = fopen([filepath, classid{i}, '_val.txt']);
    window_length = [];
    while ~feof(f)
        line = fgetl(f);
        line = regexp(line,' ','split');
        window_length = [window_length,log2(FPS*(str2double(line{4})-str2double(line{3})))];
    end
    [mu(i),sigma(i)] = normfit(window_length);
end

save('weight_normfit.mat','mu','sigma');



