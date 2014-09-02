#!/usr/local/bin/perl

# $Revision: 1.4 $
# $Date: 2000/08/14 19:52:52 $

#================================================================
#  NAME:	 update_momdump.pl
#
#  DESCRIPTION:
#	Updates the UNLOAD_SUMMARY.txt file for momentum dumps
#  since the last.  When started it:
#
#      1. Finds last momentum dump from UNLOAD_SUMMARY.txt
#      2. Runs A_SYSMOM.ltt to find new momentum dumps
#      3. Updates the UNLOAD_SUMMARY.txt file with new data
#a
#  HISTORY:
#    Date	    Author	     Description
#  ____________ ____________    ________________________
#
#    6-25-01	 Jeff Shirer	   Original Version
#================================================================
$" = "\n";

require 'misc.pl';

#"constants"
$database_hostname = "browning";
$database_name = "trend24";


$last_dump_day = find_last();  # Find out when the last momentum dump
                              # was processed.
($num_dumps, @new_dumps) = run_ltt($last_dump_day);  # Find all dumps since the last 
#print"$num_dumps \t @new_dumps";


if ($num_dumps > 0)
{
   print "\nFound $num_dumps new momentum dumps starting at:\n@new_dumps\n";
   update(@new_dumps);
}
else
{
    print "\nFound no new momentum dumps since $last_dump_day\n";
}

###########################################################################

sub find_last
{

    my ($outdir, $outfile, $found_it, @whole);
    my ($lastdump, $last_dump_time, $last_dump_day);

    $last_dump = "";

    $outdir = "../AXAFUSER/output/SYSTEMS/PROP/MOMENTUM";
    
    $outfile = "$outdir\/UNLOAD_SUMMARY.txt";

    open (OUT, $outfile) || die ("Can't open $outfile");

    @whole = <OUT>;

    while ($last_dump !~ /\w/) {$last_dump = pop(@whole);}

    
    ($last_dump_time) = split(/\s+/,$last_dump);
    $last_dump_day = int($last_dump_time);
    print "The last processed momentum dump was on $last_dump_day\n\n";
    
    return($last_dump_day);
}

sub run_ltt
{

    
    my $last_dump_day = shift;
    my ($start_day, $current_day, $current_year, $end_day);
    my ($command, $outdir, $outfile);
    my $found_it = 0;
    my ($reftime,$mean,$min,$max,$std,$timemin,$timemax);
    my ($num_dumps, @new_dumps);

    $start_day = $last_dump_day + 1;

    $current_day =  (gmtime)[7] + 1;
    $current_year = (gmtime)[5] + 1900 ;
    #$end_day = "$current_year"."$current_day";    #removed 07jan2002 (caused problems with days < 100)
    $end_day = int($current_year*1000 + $current_day);

    print "Finding momentum dumps from $start_day to $end_day ...\n\n";

    $command = "dectrend_plot.pl DATABASE $database_name HOSTNAME $database_hostname PORT 5432 NPLOTS 3 TIME $start_day $end_day /home/pcad/ltt/A_SYSMOM.ltt";
    system "$command";  # This queries the ltt database.  Now, we have to find where the new dumps occurred.



    $outdir = "../AXAFUSER/ltt";
    
    $outfile = "$outdir\/GCA_TOTMOM.dat";

    open (OUT, $outfile) || die ("Can't open $outfile");


   while (<OUT>)
    {
	if ($found_it == 0)
	{
	    if (/AOUNLOAD/) {$found_it = 1;}
	}
	else
	{
	    ($reftime,$mean,$min,$max,$std,$timemin, $timemax) = split(/\s+/);
            
	    if ($max > 0) 
	    {
		push(@new_dumps, $timemax);
		$num_dumps++;
	    }
	}
    }

    return($num_dumps, @new_dumps);

}


sub update
{
    $" = "\n";
    my @new_dumps = @_;
    
    
# Get all of the telemetry files
    opendir(DIR,"/home/greta/AXAFHOME/MODE/flight/data");
    @tlm_files = sort(readdir(DIR));
    closedir(DIR);

    
    opendir(DIR,"/home/greta/AXAFHOME/MODE/flight/archive/tlm/current");
    @tmp_files = sort(readdir(DIR));
    push(@tlm_files,@tmp_files);
     @tlm_files = sort(@tlm_files);
    closedir(DIR);

    print "\n\nUsing VCDU files:\n";

    foreach $dump (@new_dumps)
    {
	$day = int($dump);
        @day_tlm_files = grep(/$day/,@tlm_files);
	print "@day_tlm_files\n";

        # Want telemetry data from 1 minute before the dump start for about 15 minutes
        $data_start = decrement_greta_time($dump,60);
        $data_end = decrement_greta_time($dump,-900);

	$command = "decom98 -d P_POST_MOMDUMP.dec -m 3 -f ztlm\@$day_tlm_files[0] -n $day_tlm_files[0] -ts $data_start -tp $data_end -a DEFAULT";
        print" command is: \n $command \n\n";
        system "$command"; 

	$command = "perl proc_momdump.pl";
        system "$command";   



        
   
    }
}
   
			 




