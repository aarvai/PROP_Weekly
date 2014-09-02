function [data]=PROP_Trend(data)

s=data.time(end)  % start on next day
%s=time(1999220)
e=time(clock)

times=s:86400:e;
times=times(2:end);

for n=2:length(times)
    
    d=gretafetch('PROP_Trend.dec',times(n-1),times(n)-1);
    
    data.time=[data.time, times(n-1)];
    
    pres=[min(d.msids.MSID_PRES.values),mean(d.msids.MSID_PRES.values),max(d.msids.MSID_PRES.values)];
    
    data.pres=[data.pres; pres];
    
    mom_x=[min(d.msids.MSID_MOMX.values),mean(d.msids.MSID_MOMX.values),max(d.msids.MSID_MOMX.values)];   
    
    data.mom_x=[data.mom_x; mom_x];   
    
    mom_y=[min(d.msids.MSID_MOMY.values),mean(d.msids.MSID_MOMY.values),max(d.msids.MSID_MOMY.values)];   
    
    data.mom_y=[data.mom_y; mom_y];   
    
    mom_z=[min(d.msids.MSID_MOMZ.values),mean(d.msids.MSID_MOMZ.values),max(d.msids.MSID_MOMZ.values)];   
    
    data.mom_z=[data.mom_z; mom_z];   
    
    totmom=[min(d.msids.MSID_TOTMOM.values),mean(d.msids.MSID_TOTMOM.values),max(d.msids.MSID_TOTMOM.values)];   
    
    data.totmom=[data.totmom; totmom];   
    
    dumpflag=[max(d.msids.MSID_DUMPFLAG.values)];
    
    data.dumpflag=[data.dumpflag; dumpflag];
    
    save new_prop_ltd data
    
end

figure(1)
plot(data.time,data.pres);
figure(2)
plot(data.time,data.totmom);