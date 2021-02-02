#! /usr/bin/perl

#  NCデータの()の行を削除するスクリプト  #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*\(/){ print OUT; }
}
close(OUT);
close(IN);
