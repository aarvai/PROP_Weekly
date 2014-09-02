% rearrange prop month structure so gretaplot can be used 
load /home/pcad/PROP_Weekly/prop_month

a.time=prop_month.time;

a.msids.MOM_R.index=prop_month.msids.MSID_MOMX.index;
a.msids.MOM_R.values=prop_month.msids.MSID_MOMX.values;
a.msids.MOM_P.index=prop_month.msids.MSID_MOMY.index;
a.msids.MOM_P.values=prop_month.msids.MSID_MOMY.values;
a.msids.MOM_Y.index=prop_month.msids.MSID_MOMZ.index;
a.msids.MOM_Y.values=prop_month.msids.MSID_MOMZ.values;

a.msids.TOTMOM.index=prop_month.msids.MSID_TOTMOM.index;
a.msids.TOTMOM.values=prop_month.msids.MSID_TOTMOM.values;

a.msids.DUMPFLAG.index=prop_month.msids.MSID_DUMPFLAG.index;
a.msids.DUMPFLAG.values=prop_month.msids.MSID_DUMPFLAG.values;


gretaplot(a);
print -dpng -r80 -noui -zbuffer Monthly_MOM.png

% create seperate pressure plot
figure(6)
plot(prop_month.time(prop_month.msids.MSID_PRES.index), prop_month.msids.MSID_PRES.values);
set(gca,'YLim',[280 300]);
title('PMTANKP')
timeZoom;
print -dpng -r80 -noui -zbuffer PMTANKP.png

if min(prop_month.msids.MSID_PRES.values)<281
    msgbox(strvcat('The pressure has dropped below 281.',  'The current yellow limit is 280.',...
        'If this low is expected please update the limit.',  'If this is a sudden drop assess subsystem health.'))
end

if min(prop_month.msids.MSID_PRES.values)<251
    
    msgbox('Per the CARD the pulse width and period must be edited once the pressure drops below 250psi.')
    
    msgbox(strvcat('The pressure has dropped below 251.',  'The current red limit is 250.',...
        'If this low is expected please update the limit.',  'If this is a sudden drop assess subsystem health.'))
  
end

if max(prop_month.msids.MSID_PRES.values)-min(prop_month.msids.MSID_PRES.values)>10
    msgbox('There appears to be a significant change in the MUPS Tank Pressure.  This may be a sign of a subsystem problem')
end
