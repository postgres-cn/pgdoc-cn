# convert all sgml files from UTF8 to GBK

use strict;
use autodie;
use File::Copy;

my $sourceDir = "postgresql";
my $targetDir = "build";


sub process
{
	(my $sourceFile,my $targetFile)=@_;
	#print STDERR  "$sourceFile\n";
	if (-d $sourceFile){
		mkdir $targetFile unless (-d $targetFile);
		my $handle;
		if (opendir($handle, $sourceFile)) {
			while (my $subpath = readdir($handle)) {
				 if (!($subpath =~ m/^\.$/) and !($subpath =~ m/^(\.\.)$/)) {
				 	my $sourceF = $sourceFile."/$subpath";
				 	my $targetF = $targetFile."/$subpath";
				 	process($sourceF,$targetF);
				 }
			}
		}
		closedir($handle);
	}else{
		copy $sourceFile,$targetFile ;
	}
}

process $sourceDir,$targetDir ;