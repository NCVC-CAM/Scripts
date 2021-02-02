#! /usr/bin/perl

#  NC�f�[�^���̍��W�l���߂��䗦�ɕϊ�����X�N���v�g       #
#  X,Y,Z,I,J,K,R,C,U,V,W�̌�̐������ݒ肵���{���ɂȂ�      #
#  �{�����������l��0�ȊO�̐����ƂȂ�Ƃ��A�����_��t������  #
#  ex.(ratio= 2.0;)  X50.3Y80Z30. -> X100.6Y160.Z60.        #

#######################
#�{�������Ă�������
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