function Weekly_Summary_b(d,s,e)

smo=find(d.s.time>time(clock)-86400*365) ;  %index to last year of dumps
f_use=(d.fuel_left(smo(1)-1)-d.fuel_left(end));% fuel use last year
yof=num2str(d.fuel_left(end)/f_use);


if f_use<d.fuel_left(end)/100  % attempt to avoid displaying innane numbers caused by
    f_use= [' < ' num2str(d.fuel_left(end)/100,2)];  % low fuel use and big errors
    yof=' > 100';
else
    f_use=num2str(f_use)
end
    
recent_ws=d.warm_starts(end,:)-d.warm_starts(smo(1)-1,:);  % warm start rate
%ws_years_remaining=(1250-d.warm_starts(end,:))./(recent_ws); %years to qual
%to_B=(938-d.warm_starts(end,:))./(recent_ws); % years to swap


fid=fopen('Prop_Summary.txt','w+');
fprintf(fid,'Performance and Health:\n\n');

fprintf(fid,'MUPS Report:\n\n');
fprintf(fid,'Fuel Remaining:          %6.2f lbs\n',d.fuel_left(end));
fprintf(fid,'Tank Pressure:           %6.2f psi\n',d.e.pres(end));
fprintf(fid,'\n');
fprintf(fid,'Fuel Usage Rate for last year:      %s lbs/year\n',f_use);
fprintf(fid,'Years of Fuel Remaining at this rate:   %s years\n',yof);
fprintf(fid,'\n');
fprintf(fid,'Momentum Dump Rate for last year:   %6.2f dumps/year\n\n',length(smo));
fprintf(fid,'Rate per individual thruster for last year:\n');
fprintf(fid,'                             MUPS-1A    %6.0f dumps/year\n',   recent_ws(1));
fprintf(fid,'                             MUPS-2A    %6.0f dumps/year\n',   recent_ws(2));
fprintf(fid,'                             MUPS-3A    %6.0f dumps/year\n',   recent_ws(3));
fprintf(fid,'                             MUPS-4A    %6.0f dumps/year\n\n',   recent_ws(4));
fprintf(fid,'\n');
fprintf(fid,'                             MUPS-1B    %6.0f dumps/year\n',   recent_ws(5));
fprintf(fid,'                             MUPS-2B    %6.0f dumps/year\n',   recent_ws(6));
fprintf(fid,'                             MUPS-3B    %6.0f dumps/year\n',   recent_ws(7));
fprintf(fid,'                             MUPS-4B    %6.0f dumps/year\n\n',   recent_ws(8));
fprintf(fid,'\n\n');
fprintf(fid,'Unloading Summary:\n');


% find this week's dumps
this_week=find(d.s.time>s & d.s.time<e);
fuel_this_week=0;
if length(this_week)==0
    fprintf(fid,'none\n');
else
    fprintf(fid,'Start time\tDuration\tMom_R\tMom_P\tMom_Y\tMom_Tot\tFuel Used\tMode\tVDE\n');
    for n=1:length(this_week)
        ii=this_week(n);
     text_pcad_mode=num2str(d.mode(ii));
        text_pcad_mode=strrep(text_pcad_mode,'1','NPM');
        text_pcad_mode=strrep(text_pcad_mode,'2','NMM');
        
        text_vde_selected=num2str(d.vde(ii));
        text_vde_selected=strrep(text_vde_selected,'0','A');
        text_vde_selected=strrep(text_vde_selected,'1','B');
        
        fuel_used=d.flow_rate(ii)*sum(d.e.counts(ii,:)-d.s.counts(ii,:),2)/100; % divide counts by 100 for seconds
        fuel_this_week= fuel_this_week + fuel_used;
        delta_momentum=d.e.mom(ii,:)-d.s.mom(ii,:);
        delta_momentum= [delta_momentum sqrt(delta_momentum(:,1).^2 + delta_momentum(:,2).^2 + delta_momentum(:,3).^2 )];
        
        fprintf(fid,'%s\t%4.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.3f\t%s\t%s\n',  ...
            char(d.s.time(ii)), ...
            (d.e.time(ii)-d.s.time(ii)),  ...
            delta_momentum, ...
            fuel_used, ...
            text_pcad_mode, ...
            text_vde_selected);
        
        if d.e.time(ii)-d.s.time(ii)>1200'
            msgbox(strvcat('This dump duration seems too long, take a closer look.', 'Check for signs of a stuck closed thruster or washout.'))
        end
    end
end

fprintf(fid,'\n\n%s %6.3f \n\n','Fuel used this week:   ', fuel_this_week);
fprintf(fid,'\nPlots:')  ;
fclose(fid);





