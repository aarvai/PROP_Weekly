%Fix_dropouts.m
%For use when the dropouts routine catches normal heater cycle
clear all
close all
clc

load('/home/pcad/Investigations/MUPS_2_Temp_Sensor/dropouts.mat')
StartTimes = time();
EndTimes = time();
msids = {};

for i = 1:length(dropouts) - 1
    msids{i} = dropouts(i).msid;
    StartTimes = [StartTimes dropouts(i).StartTime];
    EndTimes = [EndTimes dropouts(i).EndTime];
end

disp('MSIDs with Recorded Dropouts:')
disp('')
disp(unique(msids)')

msid_remove = input('MSID to look at?:  ','s');


matches = find(strcmp(msid_remove,msids));
disp('')
disp('Dropouts recorded on:')
for i = 1:length(matches)
    i_match = matches(i);
    disp(char(StartTimes(i_match)))
end

disp(' ')
remove = input('Remove them all? (y/n):  ','s');

if strcmp(remove,'y')
    for i = 1:length(matches)
        i_match = matches(i);
        dropouts(i_match) = [];
    end
end

disp('')
save_results = input('Save Results?  (y/n):  ','s');

if strcmp(save_results, 'y')
    system('cd /home/pcad/Investigations/MUPS_2_Temp_Sensor/')
    saveas('dropouts.mat',dropouts)
    disp('Modified structure saved to /home/pcad/Investigations/MUPS_2_Temp_Sensor/home/pcad/Investigations/MUPS_2_Temp_Sensor/dropouts.mat')
end
