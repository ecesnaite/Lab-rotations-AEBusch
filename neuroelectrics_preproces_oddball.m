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
filepath = '' % location of the .easy file containing EEG data
figurepath = '' % the path to your local directory where the figures will be saved

%---------------------------
% load task EEG data 
%----------------------------
EEG = pop_easy(filepath, 0, 0, []) %EEG data is loaded into Matlab. We add no info on accelerometer, but include all channels (which is coded as the last variable)

removebase = 1 % if we would like to remove baseline
addchanloc = 0 % if we would like to add channel location

%---------------------------
% EEG data consists of activity in various frequency ranges. As a first 
% step we should filter the data to the frequency range of our interest 
% (here data is filtered between 0.1 and 20 Hz). 
%----------------------------

EEG = pop_eegfiltnew(EEG, 'locutoff', 0.1,'hicutoff', 20, 'plotfreqz',0);

%---------------------------
% The Oddball task contained two types of trials: (i) including standard 
% stimuli that were often presented in a  form of a grid with black and 
% white squares, and (ii) and oddball stimuli in a form of a grid of
% colorful squares. To compare one condition to another, we should fist
% epoch the data (i.e., cut the data into epochs of specific length around
% the time of stimulus presentation). Here, time is marked in seconds: 0 is
% the time of stimulus presentation.
%----------------------------

EEG = pop_epoch( EEG, {}, [-0.250, 0.700], 'epochinfo', 'yes'); % we epoch the data 250ms before and 700ms after stimulus presentation

%---------------------------
% Remove epochs contaminated by bad data segments. EEG data often contains 
% gross artefacts - signal segments that are related to artefacts and not 
% genuine brain activity (e.g., muscle noise). We should remove it by 
% clicking on it and cutting it out of the data. 
%----------------------------

pop_eegplot(EEG, 1,1,1)

%---------------------------
% In case you rejected some of the epochs, your data will get shorter. 
% You can check how long is the data after artefact rejection.
%----------------------------

length_of_clean_recording = EEG.pnts/EEG.srate % the length of clean data recording in seconds 

%---------------------------
% Remove baseline
%----------------------------
if removebase
    EEG = pop_rmbase( EEG, [-0.250 0] ,[]);
end

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
% plot average over parietal electrodes 
%----------------------------

fig = plot_erp_oddball_avg_parietal({EEGcon, EEGincon},{'P3', 'PZ','P4'}) %standard error: 'plotstd', 'fill'

    saveas(fig, ['']);

%plot ERPs for every channel
for p = 1:length({EEG.chanlocs.labels})
    fig = plot_erp_oddball({EEGcon, EEGincon}, EEG.chanlocs(p).labels) %standard error: 'plotstd', 'fill'
    saveas(fig, ['', EEG.chanlocs(p).labels, '']);
    close
end

