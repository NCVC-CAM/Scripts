#! /usr/bin/perl

#  (^^ �A(---�Ŏn�܂�s���폜����X�N���v�g  #

($pre_file,$out_file)= ($ARGV[0],$ARGV[1]);
open(IN,$pre_file);
open(OUT,">$out_file");
while(<IN>){
	if(!/^\(\-\-\-/ and !/^\(\^\^\s/){ print OUT; }
}
close(OUT);
close(IN);