#!/usr/bin/perl
#Converts all the .signal files in the specified path into .txt files output to the specified output path 
#using sig2text that must be in the current directory
#All paths must be specified with no trailing back slash
$sPath = $ARGV[0];
$sOutputPath = $ARGV[1];

ConvertFiles();
CommentOutHeader();

sub ConvertFiles{
	#Get file names
	@aFiles = <$sPath/*.signal>;
	#Loop through file names
	for ($j=0;$j<=$#aFiles;$j++) {
		#Split file name on /
		$sTag = "/";@aFileName = split(/$sTag/,$aFiles[$j]);
		#Search last entry of split for .signal and compile output file name
		$sTag = ".signal";$_ = $aFileName[$#aFileName];/$sTag/;$sTxtFile = "$sOutputPath/$`.txt";
		#Run sig2text command
		system(".sig2text $aFiles[$j] $sTxtFile");
		print ".sig2text $aFiles[$j] $sTxtFile \n";

	}
}

sub CommentOutHeader{
	#Get file names
	@aFiles = <$sOutputPath/*.txt>;
	#Loop through file names
	for ($j=0;$j<=$#aFiles;$j++) {
		#open the current txt file for read/write access
		open(IN,"+<","$aFiles[$j]") or die "Error opening IN file: $! \n";
		#momentarily set the read in controller to be undefined 
		undef $/;
		#this command then reads the whole of the file text into the scalar variable		
		$filetext = <IN>;
		#reset the read in controller and go back to the start of the file
		$/ = "\n";
		seek(IN, 0, 0);
		#Add a matlab comment sign to the start of the first line
		$filetext = '%' . $filetext;
		print(IN $filetext);				
		#close the file
		close(IN);
		print "$aFiles[$j] \n";		
	}	

}
	
