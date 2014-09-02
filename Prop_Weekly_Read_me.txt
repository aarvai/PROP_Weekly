Running PROP_Weekly

From /home/pcad/PROP_Weekly

Launch matlab

At the command line:  Prop_Weekly(yyyyddd, YYYYDDD) 
 yyyyddd=start of week,  YYYYDDDD= end of week

Prop_Weekly is a batch scripts that will:

* run Jeff's momentum dump update script

* run Bill's ISP calculator

* create a directory for this week

* generate plots for:  Fuel Remaining, Warm Starts, Thrust and ISP, last 30 days pressure, last 30 days momentum (x,y,z,tot, unload flag)

* Generate a PROP Summary text file which becomes the weekly


Once the files have been generated go to the Office net.  The WORD version of this file contains a macro to format the text file and add the links.  Open the summary, run the macro (PROP_Links_and_Format) and put the output file, warm_starts and ISP_Thrust in the weekly directory.

If word will not allow you to run the macro:

Open the summary.txt file in word:

Insert hyperlinks to warm_starts.png and Thrust_ISP.png under the Plots: line
Select all-Font-Times-10
if there was a dump this week convert the tab delim dump summary to a table (Table-Convert-Text to Table) and turn the headings maroon.

Save as web page
Put the web page, warm starts and Thrust_ISP in the weekly directory.







