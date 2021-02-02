#! /usr/bin/perl

#  NCデータにシーケンス番号を付加するスクリプト            #
#  番号が入っている行と入っていない行が混ざっている場合は  #
#  全て新しい番号につけなおす                              #

######################################
#行番号の桁数を入れてください。
$K= 4;

#行番号の先頭の番号を入れてください。
$lead_number= 1000;

#行番号の増加数を入れてください。
$increase_number= 10;
######################################

$line_number= $lead_number;

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(/^([A-NP-Z])[\-\d\.]+/){
		if($1 eq "N"){ $_= $'; }
		$k= length($line_number);

		if($k < $K){ $line_number= "0"x($K-$k).$line_number; }
		$_= "N".$line_number.$_;
		$line_number += $increase_number;
	}
	print OUT;
}

close(OUT);
close(IN);
