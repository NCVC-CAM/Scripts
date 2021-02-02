#! /usr/bin/perl

#  (^^ 、(---で始まる行を削除するスクリプト  #

($pre_file,$out_file)= ($ARGV[0],$ARGV[1]);
open(IN,$pre_file);
open(OUT,">$out_file");
while(<IN>){
	if(!/^\(\-\-\-/ and !/^\(\^\^\s/){ print OUT; }
}
close(OUT);
close(IN);