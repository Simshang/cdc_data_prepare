%

% ----------------------------------------------------------------------------------------------------------------
% Segment-CNN
% Copyright (c) 2016 , Digital Video & Multimedia (DVMM) Laboratory at Columbia University in the City of New York.
% Licensed under The MIT License [see LICENSE for details]
% Written by Zheng Shou, Dongang Wang, and Shih-Fu Chang.
% ----------------------------------------------------------------------------------------------------------------

clear;

AP_all=cell(0);
PR_all=cell(0);
mAP=[];
REC_all=[];

detfilename = 'tmp.txt';
gtpath = 'annotation/annotation_test/';
subset = 'test';

for threshold = 0.3:0.1:0.7

    load('../../test/postprocess/res_seg_swin.mat');
    seg_swin=seg_swin(seg_swin(:,11)~=0,:);

    % adjust conf via the distribution of window length
    load('window_weight/weight_normfit.mat');
    for i=1:length(seg_swin)
        seg_swin(i,9)=seg_swin(i,9).*normpdf(log2(seg_swin(i,2)),mu(seg_swin(i,11)),sigma(seg_swin(i,11)));
    end
    
	% ===============================
	% NMS after detection - per video
	overlap_nms = threshold - 0.1;
	videoid = unique(seg_swin(:,1));
	tic; 
	pick_nms = [];
	for id=videoid'
		for cls=1:20
			inputpick = find((seg_swin(:,1)==id)&(seg_swin(:,11)==cls));
			pick_nms = [pick_nms; inputpick(nms_temporal([seg_swin(inputpick,5) ...
				,seg_swin(inputpick,6),seg_swin(inputpick,9)],overlap_nms))]; 
		end
	end
	toc;

	% ===============================

	%% rank score by overlap score
	seg_swin = seg_swin([pick_nms],:);
	[~,order]=sort(-seg_swin(:,9));
	seg_swin = seg_swin(order,:);
    
    %seg_swin = seg_swin(seg_swin(:,9)>0,:);

	%% eval mAP

	numkeep = length(seg_swin);
	fout = fopen('tmp.txt','w');
	eval_seg_swin = seg_swin(1:numkeep,:);  % use det score for computing mAP
	for i=1:size(eval_seg_swin,1)
        if eval_seg_swin(i,11)==5
            fprintf(fout,['video_test_' num2str(eval_seg_swin(i,1),'%07d') ' ' num2str(eval_seg_swin(i,5),'%.1f') ' ' num2str(eval_seg_swin(i,6),'%.1f') ' ' num2str(8) ' ' num2str(eval_seg_swin(i,9)) ' ' '\n']);
        end
		fprintf(fout,['video_test_' num2str(eval_seg_swin(i,1),'%07d') ' ' num2str(eval_seg_swin(i,5),'%.1f') ' ' num2str(eval_seg_swin(i,6),'%.1f') ' ' num2str(eval_seg_swin(i,11)) ' ' num2str(eval_seg_swin(i,9)) ' ' '\n']);
	end
	fclose(fout);

    [pr_all,ap_all,map] = TH14evalDet_Updated(detfilename,gtpath,subset,threshold);
    mAP=[mAP,map];
    AP_all{end+1}=ap_all;
    PR_all{end+1}=pr_all;
    ave_rec = 0;
    for ii=1:20
        ave_rec = ave_rec + pr_all(ii).rec(end);
    end
    ave_rec = ave_rec/20;
    REC_all=[REC_all,ave_rec];
end

save('res_CDC_thumos14.mat','PR_all','AP_all','REC_all','mAP');

