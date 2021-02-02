#! /usr/bin/perl

#  NCデータのシーケンス番号を削除するスクリプト  #
#  ex.N0001X0Y0 -> X0Y0                          #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(/^N[\d\s]+/){ $_= $'; }
	print OUT;
}
close(OUT);
close(IN);
