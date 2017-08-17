## CDC训练数据使用指南

- [官方公布的项目代码](https://bitbucket.org/columbiadvmm/cdc/)

### 数据生成部分

1. `videodata`中存放正负样本视频，运行`extract_frame.py`提取所有

2. `c3d_data_prepare`文件夹中是生成c3d训练数据的脚本，实现的功能是将视频的每一帧抽成图片，存放在`all_frames_pervideo`中，分正负样本存放

3. 将正负样本的中的`video*`文件夹分别拷贝到`cdc_data_prepare\THUMOS14\predata`下的`test`/`train`中的`all_frames_pervideo`文件夹中，然后运行`gen_test/train_bin_and_list.py`,生成的数据存放在`window`中，同时生成`.lst`文件列表

4. 将整个`window`的文件夹上传至服务器,在服务器上的数据存放路径为`~/cdc/THUMOS14/train`或者`~/cdc/THUMOS14/test`