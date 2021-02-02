#! /usr/bin/perl

#  X座標を2倍に変換するスクリプト  #

$ratio = 2.0;

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$new_line= "";
		while(/X([\-\d\.]+)/){
			($pre_line,$num,$_)= ($`,$1,$');
			$num= int(int($num*1000) * $ratio);
			$num= $num/1000;
			if($num !~ /\./ and $num != 0){ $num = $num."\.";}
			$new_line= $new_line.$pre_line."X".$num;
		}
		$_= $new_line.$_;
	}
	print OUT;
}

close(OUT);
close(IN);
