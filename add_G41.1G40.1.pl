#! /usr/bin/perl

#  G02�̍s�̒��O��G41.1�A�����G40.1��t������X�N���v�g  #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		if(/G0?2[^\d]/){
			print OUT "G41.1\n";
			print OUT;
			print OUT "G40.1\n";
		}
		else{ print OUT; }
	}
	else{ print OUT; }
}

close(OUT);
close(IN);
