#! /usr/bin/perl

#  NC�f�[�^�ɃV�[�P���X�ԍ���t������X�N���v�g            #
#  �ԍ��������Ă���s�Ɠ����Ă��Ȃ��s���������Ă���ꍇ��  #
#  �S�ĐV�����ԍ��ɂ��Ȃ���                              #

######################################
#�s�ԍ��̌��������Ă��������B
$K= 4;

#�s�ԍ��̐擪�̔ԍ������Ă��������B
$lead_number= 1000;

#�s�ԍ��̑����������Ă��������B
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
