function PROP_Weekly_b(sd,ed)

%   Matlab Script to run the Propulsion weekly and generate the 
%   required plots and stats
%
% SYNTAX: PROP_Weekly(start day (yyyyddd), end day (yyyyddd))

addpath('/home/pcad/PROP_Weekly','-end')
addpath('/home/pcad/matlab/Dump_Process','-begin')
addpath('/home/pcad/Investigations/PLINE03T/')
addpath('/home/pcad/Investigations/PLINE03T/ViolationPlots/')
ltt_root='/home/pcad/AXAFUSER/ltt/';

cd /home/pcad/PROP_Weekly;
dir=['Weekly_' num2str(sd) '_' num2str(ed)];
mkdir(dir);
cd(dir);

st=time(sd);
et=time(ed); 

% check for new dumps & process any found

et=et+86400;  % ltt goes to end of day, decom98 does not, so add a day
load dump_stats
d=collect_stats(d,st,et);  % ltt goes to end of day, decom98 does not, so add a day
d=warm_starts(d);
d=fuel_calcs(d);
d=new_ISP_calc(d);
sort_by_time
remove_repeats

% life remaining trending plots
dump_stats_plots(d)

% create MUPS-B1 trending plot
b1_thruster_efficiency()

% print out summary report
Weekly_Summary(d,st,et)

% update data on Noodle
save dump_stats d
system('cp dump_stats.mat /home/pcad/matlab/Dump_Process');
system('cp *png /share/FOT/engineering/prop/plots'); 
close all

% check for new thermistor dropouts
addpath('/home/pcad/Investigations/MUPS_2_Temp_Sensor')
which dropouts.mat
load dropouts
PropThermDropouts(dropouts)
system('cp dropouts.mat /home/pcad/Investigations/MUPS_2_Temp_Sensor');

% update thruster valve heater trending webpage
cd '/home/pcad/python/htr_dc'
system('/proj/sot/ska/bin/python run_htr_dc.py');



