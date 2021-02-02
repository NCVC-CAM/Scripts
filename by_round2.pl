#! /usr/bin/perl

#  NCデータ中の座標値を 1/1000(小数第３位) 四捨五入し、     #
#  1/100(小数第２位) に変換するスクリプト                   #
#  X,Y,Z,I,J,K,R,C,U,V,Wの後の数字が対象となる              #
#  小数点表記にのみ対応。整数表記には未対応(使えません)     #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$new_line= "";
		while(/([XYZIJKRCUVW])([\-\d\.]+)/){
			($pre_line,$char,$num,$_)= ($`,$1,$2,$');
			$round = (int($num*100 + ($num>0 ? 0.5 : -0.5))) / 100;
			if ( $round !~ /\./ and $round != 0) {
				$round = $round."\.";
			}
			$new_line= $new_line.$pre_line.$char.$round;
		}
		$_= $new_line.$_;
	}
	print OUT;
}