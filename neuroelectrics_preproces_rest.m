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
% load resting-state EEG data 
%----------------------------
condition = '' % condition name will appear in figure title and file names. Make sure to update this line for different datasets not to overwrite previous ones. E.g., 'eyes-closed', 'eyes-open'

EEG = pop_easy(filepath, 0, 0, []) %EEG data is loaded into Matlab. We add no info on accelerometer, but include all channels (which is coded as the last variable)

%---------------------------
% Task: Open the EEG structure from the workspace and inspect its fields.
% EEG data is stored inside the 'data' field where channels are rows and
% time points are columns. The field that is named 'pnts' stores 
% information on the number of data points. In the EEG structure you can also find the sampling 
% rate that was used to record your data in the 'srate' field. It represent
% the number of data points in a second of your data recording. Using this 
% information we can now see how long is the recording.
%----------------------------

length_of_recording = EEG.pnts/EEG.srate % dividing the number of data points by sampling rate will give you the length of recording in seconds. 


%---------------------------
% EEG data consists of activity in various frequency ranges. As a first 
% step we should filter the data to the frequency range of our interest. 
%----------------------------

EEG = pop_eegfiltnew(EEG, 'locutoff', 1,'hicutoff', 40,'plotfreqz',0); % here we filter the data between 1 and 40 Hz

%---------------------------
% Remove bad data segments. EEG data often contains gross artefacts - 
% signal segments that are related to artefacts and not genuine brain 
% activity (e.g., muscle noise). We should remove it by cutting it out of 
% the data. 
%----------------------------

pop_eegplot(EEG, 1, 1, 1) % a window will pop showing your EEG data. You should scroll through it to mark and later reject bad data segments. You can play around with its settings to enlarge the time window or reduce the scale.

%---------------------------
% In case you found data segments that were contaminated by artefacts, your
% data will get shorter. You can check how long is
% the data after artefact rejection.
%----------------------------

length_of_clean_recording = EEG.pnts/EEG.srate % the length of clean data recording in seconds 

%---------------------------
% It is a common practice to re-reference the data for better data quality.
% Here we re-reference it to common average reference.
%----------------------------

EEG = pop_reref(EEG, []) % the second input denotes the new reference channel. Here '[]' indicates that all channels are used for common average reference.

%---------------------------
% Now as you cleaned, pre-processed, and saw your data in time-domain, you
% can inspect it also in the frequency domain. Here we plot Welch's power 
% spectral density (PSD) to see power in different frequency ranges. Different
% EEG channels here are shown as different lines.
%----------------------------

fig =figure, plot_spec(EEG.data',EEG.srate, 40), title(['PSD: ', condition]), ...
xlabel('Frequency (Hz)'), ylabel('Power / Frequency(dB/Hz)'); 

%---------------------------
% Save the figure to the directory you indicated at the beginning of the
% code
%----------------------------

saveas(fig, [figurepath, condition,'-PSD.jpg']); 

%---------------------------
% PSD doesn't hold any spatial information about the signal and where does
% the highest amplitude come from. To see that we should look into the topography. 
%----------------------------
chan_names = struct('labels', { 'PO7' 'F3' 'P3' 'Cz' 'Pz' 'F4'  'P4'  'PO8'}); % use BESA file int he drop down window
chan_locs = pop_chanedit(chan_names);

alphaEEG = pop_eegfiltnew(EEG, 'locutoff', 8,'hicutoff', 12,'plotfreqz',0); % here we filter the data between 1 and 40 Hz

figure, topoplot(mean(alphaEEG.data'), chan_locs, 'electrodes', 'labels', 'maplimits', 'maxmin'), colorbar

saveas(fig, [figurepath, condition,'-topoplot.jpg']); % this line saves the last figure


