#! /usr/bin/perl

#  �ݒ肵�������R�[�h�̎��̐����ɏ����_��t������X�N���v�g  #
#  �������A0�ɂ͕t�����Ȃ�                                   #
#  ex.X50 -> X50. , X0 -> X0                                 #

#####################################################
#�����_��t�������������R�[�h��A���œ���Ă�������
#ex. XYZIJR
$add_code= 'XYZIJR';
#####################################################

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$new_line= "";
		while(/([$add_code])([\-\d\.]+)/){
			($pre_line,$char,$num,$_)= ($`,$1,$2,$');
			if($num !~ /\./ and $num != 0){ $num= $num."\."; }
			$new_line= $new_line.$pre_line.$char.$num;
		}
		$_= $new_line.$_;
	}
	print OUT;
}
close(OUT);
close(IN);
