% It's the first script to preprocess your resting-state EEG data. The
% script loads the data, filters it, allows you to remove gross artefacts,
% and plot power spectral density. It should be run for eyes-closed and
% eyes-open conditions separately.
% The script is intended for teaching purposes.

clear all, close all


%---------------------------
% Add the path to your EEGLAB folder and call it
%----------------------------

addpath('')
eeglab

%---------------------------
% set paths to where the data is stored
%----------------------------
filepath = '' % location of the .easy file containing EEG data + filename
figurepath = '' % the path to your local directory where the figures will be saved

%---------------------------
% load task EEG data
%----------------------------
EEG = pop_easy(filepath, 0, 0, []) %EEG data is loaded into Matlab. We add no info on accelerometer, but include all channels (which is coded as the last variable)


%---------------------------
% EEG data consists of activity in various frequency ranges. As a first
% step we should filter the data to the frequency range of our interest
% (here the data is filtered between 0.1 and 20 Hz).
%----------------------------

EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1,'hicutoff', 20, 'plotfreqz',0);

%---------------------------
% Remove bad data segments. EEG recordings might contain bad data segments
% (segments contaminated by muscle noise).This is especially true at the
% beginning and the end of the recording. Such segments should be marked and cut out
% of the data
%----------------------------

pop_eegplot(EEG, 1,1,1)

%---------------------------
% Independent Component Analysis (ICA). Continuous noise that appears throughout
% the whole recording (e.g., eye blinks, horizontal eye movements) can be
% removed using ICA. Here we aim to detect primarily artefact sources
% related to eye blinks and eye movements to remove them them out from the data
%----------------------------

% To perform further steps we need to add channel location
chan_names = struct('labels', { 'PO7' 'F3' 'P3' 'Cz' 'Pz' 'F4'  'P4'  'PO8'});
chan_locs = pop_chanedit(chan_names); % use BESA file int he drop down window
EEG.chanlocs = chan_locs

[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );

EEG = pop_runica(EEG, 'icatype', 'runica'); % we use Infomax algorithm here

%---------------------------
% IClabel can be used to classify different ICA components to one of the 6 
% categories (in this order): Brain, Muscle, Eye, Heart, Line Noise, 
% Channel Noise, Other. Here we will apply threshold criteria for marking
% components that will be removed from the data.
%----------------------------

EEG = iclabel(EEG); % run IClabel classification

threshold = [0 0;0 0; 0.85 1; 0 0; 0 0; 0 0; 0 0]; % only components that were identified as related to eye movements will be marked

EEG = pop_icflag(EEG, threshold)

[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET);

EEG = pop_selectcomps(EEG, [1:8]); % you can inspect these components now visually

remove_ics = find(EEG.reject.gcompreject); % indices of components that will be removed from the data

EEG = pop_subcomp(EEG, remove_ics, 0);

%---------------------------
% Task: now you can inspect how a cleaned EEG data looks like. Are there
% any blinks left?
%----------------------------

pop_eegplot(EEG, 1,1,0) 



%---------------------------
% In case eye blinks and eye movements were not removed from the data
% sufficiently well, we can apply a higher high-pass filter cutoff value.
% For this, please un-comment the lines below and repeat lines 69-88. 
%----------------------------
% 

%EEGfilt = pop_eegfiltnew(EEG, 'locutoff', 2,'hicutoff', 20, 'plotfreqz',0);

%EEGfilt = pop_runica(EEGfilt, 'icatype', 'runica');

% EEG.icachansind = EEGfilt.icachansind
% EEG.icasphere = EEGfilt.icasphere
% EEG.icaweights = EEGfilt.icaweights
% EEG.icawinv = EEGfilt.icawinv



%---------------------------
% The Oddball task contained two types of trials: (i) including standard
% stimuli that were often presented in a form of a grid with black and
% white squares, and (ii) oddball stimuli in a form of a grid of
% colorful squares. To compare one condition to another, we should fist
% epoch the data (i.e., cut the data into epochs of specific length around
% the time of stimulus presentation). Here, time is marked in seconds: 0 is
% the time of stimulus presentation.
%----------------------------

EEG = pop_epoch( EEG, {}, [-0.250, 0.700], 'epochinfo', 'yes'); % we epoch the data 250ms before and 700ms after stimulus presentation

%---------------------------
% Visually inspect epochs and remove the ones that are contaminated by bad 
% data segments. We should remove it by clicking on the bad data segment.
%----------------------------

pop_eegplot(EEG, 1,1,1)


%---------------------------
% Remove baseline
%----------------------------

EEG = pop_rmbase( EEG, [-0.250 0] ,[]);

%---------------------------
% Split data into epochs that inlcude standard (congruent) and
% oddball (incongruent) stimuli 
%----------------------------

EEGcon = pop_epoch( EEG, {'6'}, [-0.200, 0.700], 'epochinfo', 'yes');
EEGincon = pop_epoch(EEG, {'7'}, [-0.200, 0.700], 'epochinfo', 'yes');

%---------------------------
% Task: see how many epochs/trials you have for each condition
%----------------------------

%---------------------------
% Plot average event-related potential (ERP) in a given time window for 
% two different conditionsover parietal electrodes. Are the conditions
% different between 300-600 ms?
%----------------------------

fig = plot_erp_oddball_avg_parietal({EEGcon, EEGincon},{'P3', 'PZ','P4'}) 

%---------------------------
% Save figure
%----------------------------
saveas(fig, [figurepath, condition,'-oddball.jpg']);



