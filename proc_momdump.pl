#!/usr/local/bin/perl

# $Revision: 1.4 $
# $Date: 2000/08/14 19:52:52 $

#================================================================
#  NAME:	 proc_momdump.pl
#
#  DESCRIPTION:
#	Processes the output file for a momentum dump.
#  Calculates momentum unloaded, fuel used, est. thrust, and 
#  PVT fuel remaining.
#
#  HISTORY:
#    Date	    Author	     Description
#  ____________ ____________    ________________________
#
#    8-17-99	 Jeff Shirer	   Original Version
#    9-17-99     Jeff Shirer       Added ACA rate and err calcs.
#    9-18-99     Jeff Shirer       Added pmtankp and pcad mode
#                                  to output.  Also added data file
#                                  saving capability.
#    10-15-99     Jeff Shirer      Updated pcad mode logic to print
#                                  out the right name.
#    10-29-99     Jeff Shirer      Updated thrust calc to avoid div by 0
#                                  problems.
#    11-5-99      Jeff Shirer      Fixed output problems.
#    01-07-00      Jeff Shirer     Updated fuel used calc.
#================================================================

&initialize;
&process;
&PVT;
&output;

sub initialize
{

$thrust = .25;  #BOL valves
$isp    = 205;

$outdir = "../AXAFUSER/output";

$infile = "$outdir\/P_POST_MOMDUMP.txt";

open (IN, $infile) || die ("Can't open $infile");

$header = <IN>;
$out_header = "FLAG\t TIME\t AOSYMOM1\t AOSYMOM2\t AOSYMOM3\t  AOATTQT1\t  AOATTQT2\t AOATTQT3\t  AOATTQT4\n";  

$unloading = 0;

# Set MUPS moment arms (feet)
$roll_arm = 5.91;
$pitch_arm = 8.24;
$yaw_arm = 4.76;

}

sub process
{
  while (<IN>)
    {

      s/ \. / /g;
      s/ \* / /g;

     ($time, 
     $vcdu, 
     $aofunlst,
     $mom1, 
     $mom2, 
     $mom3, 
     $aothrst1,
     $aothrst2,
     $aothrst3,
     $aothrst4,
     $pmtankp,
     $pmtank1t,
     $pmtank2t,
     $pmtank3t,
     $vdesel,
     $rate1,
     $rate2,
     $rate3,
     $atterr1,
     $atterr2,
     $atterr3,
     $pcadmd) = split(/\s+/);

     &get_mags;
     $pushit=0;

     if ($aofunlst =~ /GRND|AUTO/ && $laofunlst =~/NONE/)  # Unload start
       {
	 $unload_start = $time;
         
         $hack = substr($time, 0, 7);
         $svcdu = $vcdu;
	 $smom1 = $mom1;
	 $smom2 = $mom2;
	 $smom3 = $mom3;
	 $saothrst1 = $aothrst1;
	 $saothrst2 = $aothrst2;
	 $saothrst3 = $aothrst3;
	 $saothrst4 = $aothrst4;

         $pushit = 1;
       }
     elsif ($aofunlst =~ /NONE/ && $laofunlst =~/AUTO|GRND/) #Unload end
       {
	 $unload_end = $time;

         $evcdu = $vcdu;
	 $emom1 = $mom1;
	 $emom2 = $mom2;
	 $emom3 = $mom3;

	 $eaothrst1 = $aothrst1;
	 $eaothrst2 = $aothrst2;
	 $eaothrst3 = $aothrst3;
	 $eaothrst4 = $aothrst4;

         $pushit = 1;
	 $pcadmd_ref = $pcadmd;

       }
     elsif ($aofunlst =~ /AUTO|GRND/ && $laofunlst =~/AUTO|GRND/) #Middle of unload
       {
	 $pushit = 1;
       }
 
       $laofunlst = $aofunlst;
       $ltime = $time;

       if ($pushit) {push (@rates, $rate_mag); push (@errs, $err_mag);}
    }



$unload_time = ($evcdu-$svcdu)*.25625;  
$unload_min = int($unload_time/60);
$unload_sec = int($unload_time - $unload_min*60);

$mom_delt1 = $emom1 - $smom1;
$mom_delt2 = $emom2 - $smom2;
$mom_delt3 = $emom3 - $smom3;

$cnt_delt1 = $eaothrst1 - $saothrst1; 
$cnt_delt2 = $eaothrst2 - $saothrst2;
$cnt_delt3 = $eaothrst3 - $saothrst3;
$cnt_delt4 = $eaothrst4 - $saothrst4;

$time_delt1 = $cnt_delt1/100;
$time_delt2 = $cnt_delt2/100;
$time_delt3 = $cnt_delt3/100;
$time_delt4 = $cnt_delt4/100;

$fuel_used = ($thrust/$isp)*($time_delt1+$time_delt2+$time_delt3+$time_delt4);

$thrust_roll = 0;
$thrust_pitch = 0;
$thrust_yaw = 0;

$time_net_roll = $time_delt2 + $time_delt4 - $time_delt1 - $time_delt3;
$time_net_pitch = $time_delt3 + $time_delt4 - $time_delt1 - $time_delt2;
$time_net_yaw = $time_delt2 + $time_delt3 - $time_delt1 - $time_delt4;

 if (abs($time_net_roll) > 0) {$thrust_roll = $mom_delt1/($time_net_roll*$roll_arm);}
 if (abs($time_net_pitch) > 0){$thrust_pitch = $mom_delt2/($time_net_pitch*$pitch_arm);}
 if (abs($time_net_yaw) > 0) {$thrust_yaw= $mom_delt3/($time_net_yaw*$yaw_arm);}

if ($vdesel =~ /A/)
{
	$m1a = $eaothrst1;
	$m2a = $eaothrst2;
	$m3a = $eaothrst3;
	$m4a = $eaothrst4;

	$m1b = "";
        $m2b = "";
	$m3b = "";
        $m4b = "";
}
else
{
	$m1a = "";
        $m2a = "";
	$m3a = "";
        $m4a = "";

	$m1b = $eaothrst1;
	$m2b = $eaothrst2;
	$m3b = $eaothrst3;
	$m4b = $eaothrst4;
}


if ($pcadmd_ref =~ /NPNT/)
{
  @sort_rates = sort numerically @rates;
  @sort_errs = sort numerically @errs;

  $max_rate = pop @sort_rates;
  $max_err = pop @sort_errs;

}
else
{
  $max_rate="";
  $max_err="";
}

}

sub PVT
{
  $vsys = 2383;     # System volume [in**3]
  $rho  = 0.036511; # Density of hydrazine [lbm/in**3]
  $mgas = 0.1;      # Mass of helium [lbm]
  $Rgas = 4632;      # Gas constant for helium [in-lbf/lbmol-R]

  $del_pmtankp = 0.816;  # Deadband for pressure measurements
  $del_pmtankt = 0.559;  # Deadband for temperature measurements

  $avg_temp = ($pmtank1t + $pmtank2t + $pmtank3t)/3 + 459.67;
  $fuel_remain = $rho*($vsys - (($mgas*$Rgas*$avg_temp)/$pmtankp));


  # Calculate highest fuel left based on deadbands
  $pmtankp += $del_pmtankp;
  $pmtank1t -= $del_pmtankt;
  $pmtank2t -= $del_pmtankt;
  $pmtank3t -= $del_pmtankt;

  $high_fuel_remain = $rho*($vsys - (($mgas*$Rgas*$avg_temp)/$pmtankp));
  $plus = $high_fuel_remain - $fuel_remain;

  # Calculate lowest  fuel left based on deadbands
  $pmtankp -= 2*$del_pmtankp;
  $pmtank1t += 2*$del_pmtankt;
  $pmtank2t += 2*$del_pmtankt;
  $pmtank3t += 2*$del_pmtankt;

  $low_fuel_remain = $rho*($vsys - (($mgas*$Rgas*$avg_temp)/$pmtankp));
  $minus = $fuel_remain - $low_fuel_remain;

  $uncertainty = ($plus + $minus)/2;
}

sub output
{
  $vdesel="A";
  print "\n\n\t********* UNLOADING SUMMARY *********\n\n";

  print  "Start Time                    = $unload_start\n";
  print  "End Time                      = $unload_end\n";
  printf("Duration                      = %2d min. %2d sec.\n", $unload_min, $unload_sec);
  printf "VDE                           = $vdesel\n";
  printf("Momentum Change [ft-lb-sec]   = %.2f\t%.2f\t%.2f\n",
                                      $mom_delt1, $mom_delt2, $mom_delt3);
  printf("Estimated Thrust [lbf]        = %.2f\t%.2f\t%.2f\n",
                                      $thrust_roll, $thrust_pitch, $thrust_yaw);
  printf("Thruster Ontimes [sec]        = %.3f\t%.3f\t%.3f\t%.3f\t\n",
                  $time_delt1, $time_delt2, $time_delt3, $time_delt4);
  printf("MUPS Tank Pressure [psia]     = %.1f\n", $pmtankp);
  printf("Fuel Used for Unload [lbm]    = %.3f\n", $fuel_used);
  printf("PVT Fuel Remaining [lbm]      = %.2f \+\- %.3f\n",$fuel_remain,
                                          $uncertainty);
  print  "PCAD Mode                     = $pcadmd_ref \n";
  printf("Max ACA Rate [arcsec/sec]     = %.2f \n",$max_rate);
  printf("Max ACA Attitude Err [arcsec] = %.2f \n",$max_err);


  $outfile = "../AXAFUSER/output/SYSTEMS/PROP/MOMENTUM/UNLOAD_SUMMARY.txt";
  open(OUT, ">>$outfile") || die "Can't open output file";

  print "\n\n********* Updating $outfile with results\n\n";
  printf OUT ("%s\t%s\t%d\t%d\t%s\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.1f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%s\t%.3f\t%.3f\n", 
  $unload_start,$unload_end,$unload_min,$unload_sec,
  $vdesel,$mom_delt1,$mom_delt2,$mom_delt3,$time_delt1,$time_delt2,
  $time_delt3,$time_delt4,$m1a,$m2a,$m3a,$m4a,$m1b,$m2b,$m3b,$m4b,
  $pmtankp,$fuel_used,$fuel_remain,$uncertainty, 
  $thrust_roll,$thrust_pitch,$thrust_yaw,
  $pcadmd_ref,$max_rate,$max_err);


# Save the data file 

  $data_name = "$unload_start.out";
  $data_dir = "SYSTEMS/PROP/MOMENTUM/data";
  $command = "cp $infile $outdir\/$data_dir\/$data_name \; gzip $outdir\/$data_dir\/$data_name";

  system "$command";


  print "\n********* Saved and gzipped $outdir\/$data_name\n"
  

}


sub get_mags
{
  $aca_roll_rate = $rate1/100;
  $aca_roll_err = $atterr1/100;

  $rate_mag = sqrt($aca_roll_rate**2 + $rate2**2 + $rate3**2);
  $err_mag = sqrt($aca_roll_err**2 + $atterr2**2 + $atterr3**2);

}

sub numerically {$a <=> $b}
