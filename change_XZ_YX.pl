#! /usr/bin/perl

# NCVC�ō쐬����G�R�[�h���ANC���՗p�Ɏ��ϊ�����X�N���v�g #


%XY= ("X","Z","Y","X","I","K","J","I");

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		if(/[XYIJ]/){
			$new_line= "";
			while(/([XYIJ])([0-9\-\.]+)/){
				$new_line= $new_line.$`.$XY{$1}.$2;
				$_= $';
			}
			$_= $new_line.$_;
		}
	}
	print OUT;
}

close(OUT);
close(IN);
