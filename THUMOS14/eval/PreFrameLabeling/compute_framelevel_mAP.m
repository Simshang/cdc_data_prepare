clear;

load('multi-label-test.mat');   % load ground truth

ap=zeros(20,1);
load('../../test/postprocess/proball.mat');
prob = proball';

%% simple temporal smoothing via NMS of 5-frames window
probsmooth = squeeze(max(cat(1,reshape(prob,[1,size(prob)]),reshape([prob(1,:);prob(1:(end-1),:)],[1,size(prob)]),...
    reshape([prob(2:end,:);prob(end,:)],[1,size(prob)]),reshape([prob(1:2,:);prob(1:(end-2),:)],...
    [1,size(prob)]),reshape([prob(3:end,:);prob((end-1):end,:)],[1,size(prob)]))));

%% eval
prob = probsmooth;
prob(prob(:,6)>prob(:,9),9) = prob(prob(:,6)>prob(:,9),6);	% assign cliff diving as diving

% remove ambiguous
prob=prob(label_test(:,22)==0,:);
label_test=label_test(label_test(:,22)==0,:);

for i=2:21
    gt = label_test(1:end,i);
    fprintf([num2str(sum(gt)) '\n']);
    ap(i-1) = apcal(prob(1:end,i),gt);
end

map = mean(ap)


