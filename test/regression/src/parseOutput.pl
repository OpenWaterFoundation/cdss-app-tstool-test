#!/usr/bin/perl

##################################################################
# Author: Kurt Tometich
# Date: 2006-10-17
# 
# Purpose: This perl program parses the output from running 
#          a commands file in TSTool.  The ant target "regTest"
#          runs TSTool, copies the output file to the results
#          folder and runs this Perl script to generate the
#          final result of the commands run by TSTool.  This
#          was needed since there is too much output generated
#          by TSTool to sift through when tests are done running.
#          If a test fails, then the developer should check the
#          result log file generated by TSTool in the Regression
#          results folder.  
#
##################################################################
#
#  PUT REVISIONS LOG HERE....
#
##################################################################


#### get the date ####
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime(); 
$year+=1900;
$mon+=1;

$fname = "../results/Regression." . "$year" . "$mon" . "$mday" . ".log";
$flag = 0;
$command_count = 0;
$outcome = "PASS";
$numFail = 0;
$numPass = 0;
$totalCmds = 0;
$totalTime = 0;

open(OUT, ">../results/ParsedOutput.log") or die "cannot open file to write to because $! \n";
print OUT "\n-------------------------------------------------------------------------------------------------------------\n";
print OUT "| # |\tSECTION  \t\t|\tTEST NAME\t|\tNUM CMDS\t|\tTIME\t|\tRESULT\t|\n";
print OUT "-------------------------------------------------------------------------------------------------------------\n";

open(FILE, "$fname") or die "cannot open file:$fname because $!\n";
while(<FILE>)
{
	$line = $_;
	chomp($line);

	# start of commands 
	if($line =~ /Reading commands file/ || $flag == 1)
	{
		$flag = 1;

		### get the command name if processing a command
		if($line =~ /Reading commands file/ )
		{
			$command_count++;
			@r_values = getCommandName($line);
			$section = $r_values[1];
			$cmd_name = $r_values[0];
			print OUT "| $command_count |";
			$len = length($cmd_name);
			if($len < 8)
			{
				$cmd_name = "$cmd_name" . "  ";
			}
			print OUT "\t$section\t|\t$cmd_name\t"; 
		}

		### find out how many commands and time taken to
		### run the commands
		if($line =~ /Processing/ )
		{
			if($line =~ /seconds/)	# time taken to run
			{
				$time = getTime($line);		
				$totalTime += $time;	
				print OUT "|\t$time\t";
				
				### increment pass/fail ratios
				if($outcome =~ /FAIL/i)
				{
					$numFail++;
				}
				else
				{
					$numPass++;
				}
				
				print OUT "|\t$outcome\t|\n";
				print OUT "-------------------------------------------------------------------------------------------------------------\n";
			}
			else		# number of commands
			{
				$num_cmds = getNumCommands($line);	
				$totalCmds += $num_cmds;		
				print OUT "|\t$num_cmds\t\t\t";
			}
		}

		### Check for warnings or errors
		if($line =~ /^Warning/ || $line =~ /^Error/)
		{
			$outcome = "FAIL";
		}

		### sequence of commands is done, reset counters
		### so the next set of commands will start at zero
		if($line =~ /done processing/)
		{
			print "\n";
			$flag = 0;
			$outcome = "PASS";
		}

	}


}

### print the totals ###
print OUT "\n TOTALS \n"; 
print OUT "-------------------------------------------------------------------------------------------------------------\n";
print OUT "| $command_count |\tN/A\     \t|\tN/A      \t|\t$totalCmds\t\t\t|\t$totalTime\t|\t$numPass/$numFail    \t|\n";
print OUT "-------------------------------------------------------------------------------------------------------------\n";

close(OUT);
close(FILE);


#########################################
# Sub-routine: getCommandName()
# Function: manipulate the command name
#           and section found in the
#           output file from TSTool to
#           a more readable format.
# 
# Return: array of section name and 
#         test name.
#########################################
sub getCommandName()
{
	my $param = $_;
	my @split_space = split(/ /, $param);
	my $length = @split_space;	
 	my $length--;	
	$file_name = $split_space[$length];

	my @split_slash = split(/\\/, $file_name);
	$length = @split_slash;
	$length--;
	my $test_name = $split_slash[$length];
	my $section = $split_slash[$length - 1];
	my $test = (split(/\./, $test_name))[0];
	
	## trim whitespace 
	$test =~ s/^\s+//;
	$test =~ s/\s+$//;
	$section =~ s/^\s+//;
	$section =~ s/\s+$//;

	my @result = ();
	push(@result, $test);
	push(@result, $section);
	
	return @result;
}

#########################################
# Sub-routine: getNumCommands()
# Function: find the number of commands
#           in the current commands file
#           being processed.
# 
# Return: integer number of commands.
#########################################
sub getNumCommands()
{
	my $param = $_;
	my $result = (split(/ /, $param))[2];

	## trim whitespace 
	$result =~ s/^\s+//;
	$result =~ s/\s+$//;

	return $result;
}

#########################################
# Sub-routine: getTime()
# Function: find the time (usually in
#           seconds that TSTool took to 
#           process the current commands.
# 
# Return: time in decimal format (seconds)
#########################################
sub getTime()
{
	my $param = $_;
	my $mult = (split(/ /, $param))[3];
	
	my $result = $mult;

	## trim whitespace 
	$result =~ s/^\s+//;
	$result =~ s/\s+$//;

	return $result;
}
