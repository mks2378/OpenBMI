%%
clc; clear all; close all;

%% data load
field={'x','t','fs','y_dec','y_logic','y_class','class', 'chan'};
% marker={'1','right';'2','left';'3','rest';'11','pause';'22','resume';'111','start';'222','end'};
marker={'1','1';'2','2';'3','3'};
%'11','pause';'22','resume';'111','start';'222','end'};
% marker={'1','up';'2','left'; '3', 'right'; '4', 'down'};
fs=500;   %chan_resampling
%% data path
file='C:\openvibe-2.0\record-[2018.03.19-21.45.57]';
file='C:\Vision\Raw Files\ear_exp\ss02_1_ear_2';
% filename='record-[2018.03.16-17.33.51]';
% file='C:\Vision\Raw Files\test33333';

%% eeg - ear
% ear EEG - eeg file
% filepath='C:\Users\cvpr\Documents\data';
% ear_file='record-[2018.01.18-15.46.53]';
% ear_file=sprintf('ear_%s',filename);
% file=fullfile(filepath,filename);
[ear_EEG.data, ear_EEG.marker, ear_EEG.info]=Load_EEG(file,{'device','brainVision';'marker',marker;'fs',fs});
ear_cnt=opt_eegStruct({ear_EEG.data, ear_EEG.marker, ear_EEG.info}, field);
%%
ear_cnt=prep_filter(ear_cnt, {'frequency', [5 60]});
ear_smt=prep_segmentation(ear_cnt, {'interval', [0 5000]});
%% eeg - cap
% cap EEG data
cap_file=sprintf('cap_%s',filename);
file=fullfile(filepath,cap_file);
[cap_EEG.data, cap_EEG.marker, cap_EEG.info]=Load_EEG(file,{'device','brainVision';'marker',marker;'fs',fs});
cap_cnt=opt_eegStruct({cap_EEG.data, cap_EEG.marker, cap_EEG.info}, field);
cap_cnt=prep_filter(cap_cnt, {'frequency', [5 60]});
cap_smt=prep_segmentation(cap_cnt, {'interval', [0 5000]});
