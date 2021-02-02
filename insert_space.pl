#! /usr/bin/perl

#  NC�f�[�^�̃u���b�N�ԂɃX�y�[�X��t������X�N���v�g        #
#  ex.G90G40G80 -> G90 G40 G80                               #
#  �u���b�N�Ԃ�tab,�X�y�[�X�����������Ă��P�X�y�[�X�ɂ���  #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$new_line= "";
		while(/([^A-Z\s]*)[\s]*([A-Z]+[^A-Z\s]+)/){
			($pre_line,$block,$_)= ($`.$1,$2,$');
			$new_line= $new_line.$pre_line." ".$block;
		}
		if(substr($new_line,0,1) eq " "){ $new_line= substr($new_line,1); }
		$_= $new_line.$_;
	}
	elsif(/^(N[0-9]*)[\s]*([\(\%])/){ $_= $1." ".$2.$'; }
	print OUT;
}
close(OUT);
close(IN);

