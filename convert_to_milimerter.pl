#! /usr/bin/perl

#  NC�f�[�^���̐��l�ɏ����_�����Ă��Ȃ��ꍇ�A        #
#  1/1000�{�����l�ɕϊ����ď����_��t������X�N���v�g  #
#  �Ώۂ̃A�h���X(�ݒ�\)�̌�̐��l���ΏۂƂȂ�      #
#  ex. X500Y80Z30. -> X0.5Y0.08Z30.                    #

########################################################
# �ΏۂƂ���A�h���X��A���ŋL�q���Ă�������
#ex. XYZIJKRCUVW
$TARGET_ADDRESS = 'XYZIJKRCUVW';
########################################################


$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	
	$new_line= "";
	$comment_line = "";
	
	while(/\(.*\)\s*/){
		$comment_line = $comment_line . $&;
		$_ = $`.$';
	}
	
	while(/([$TARGET_ADDRESS])([\-\d\.]+)/){
		($pre_line,$char,$num,$_)= ($`,$1,$2,$');
		
		if($num !~ /\./){
			$num= int($num*1000)/1000000;
			if($num !~ /\./ and $num != 0){ $num= $num."\."; }
		}
		$new_line= $new_line.$pre_line.$char.$num;
	}
	
	$_= $new_line.$_.$comment_line;
	
	print OUT;
}