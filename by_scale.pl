#! /usr/bin/perl

#  NCデータ中の座標値を定めた比率に変換するスクリプト       #
#  X,Y,Z,I,J,K,R,C,U,V,Wの後の数字が設定した倍率になる      #
#  倍率をかけた値が0以外の整数となるとき、小数点を付加する  #
#  ex.(ratio= 2.0;)  X50.3Y80Z30. -> X100.6Y160.Z60.        #

#######################
#倍率を入れてください
$ratio = 2.0;
#######################

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$new_line= "";
		while(/([XYZIJKRCUVW])([\-\d\.]+)/){
			($pre_line,$char,$num,$_)= ($`,$1,$2,$');

			$num= int(int($num*1000) * $ratio);
			$num= $num/1000;
			if($num !~ /\./ and $num != 0){ $num= $num."\."; }
			$new_line= $new_line.$pre_line.$char.$num;
		}
		$_= $new_line.$_;
	}
	print OUT;
}