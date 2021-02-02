#! /usr/bin/perl

#
#  Y軸座標をC軸回転角度に変換するスクリプト
#

use Math::Trig; ## 変数piを使うおまじない

#####################################################
# 直径を指定してください
$D=75;
#####################################################

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

$piD = $D*pi;

while ( <IN> ) {
	if ( !/^\W/ ) {
		$newline = "";
		while ( /Y(-*\d+\.*\d*)/ ) {
			($pre, $Ynum, $_) = ($`, $1, $');
			$deg = int(360*$Ynum/$piD*1000+0.5) / 1000;
			$newline = $newline.$pre."C".$deg;
		}
		$_ = $newline.$_;
	}
	print OUT;
}

close(OUT);
close(IN);
