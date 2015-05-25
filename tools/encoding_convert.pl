# convert all sgml files from UTF8 to GBK

use strict;
use autodie;
use Try::Tiny;
use File::Copy;
use encoding "utf8";
use encoding  "gbk";

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
	}elsif($sourceFile =~ /.sgml$/){
		open(FIN, "<:encoding(utf8)",$sourceFile);# or die $!;
		open(FOUT, ">:encoding(gbk)",$targetFile);# or die $!;
		while(<FIN>) {
			print FOUT $_;
		}
		close(FIN);
		close(FOUT);
	}else{
		copy $sourceFile,$targetFile ;
	}
}

process $sourceDir,$targetDir ;