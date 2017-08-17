function ap = apcal(score, gt)
%
% compute average precision
%ap for score(j,:)
% gt is the binary label
[x y]=sort(-score');
noright = 0;
apsum = 0;
for t=1:length(y)
    idx = y(t);
    if gt(idx) == 1
        noright = noright + 1;
        apsum = apsum + noright/t;
    end
end
ap = apsum/sum(gt); 