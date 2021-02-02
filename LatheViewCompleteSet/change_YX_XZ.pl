#! /usr/bin/perl

# NC旋盤用Gコードを、NCVCで表示するため軸変換するスクリプト #


%XZ= ("Z","X","X","Y","K","I","I","J");

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		if(/[ZXKI]/){
			$new_line= "";
			while(/([ZXKI])([0-9\-\.]+)/){
				$new_line= $new_line.$`.$XZ{$1}.$2;
				$_= $';
			}
			$_= $new_line.$_;
		}
	}
	print OUT;
}

close(OUT);
close(IN);
