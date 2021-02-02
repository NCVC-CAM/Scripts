#! /usr/bin/perl

#  NC�f�[�^���̍��W�l�� 1/1000(������R��) �l�̌ܓ����A     #
#  1/100(������Q��) �ɕϊ�����X�N���v�g                   #
#  X,Y,Z,I,J,K,R,C,U,V,W�̌�̐������ΏۂƂȂ�              #
#  �����_�\�L�ɂ̂ݑΉ��B�����\�L�ɂ͖��Ή�(�g���܂���)     #

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