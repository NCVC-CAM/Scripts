#! /usr/bin/perl

#  NC�f�[�^�̃V�[�P���X�ԍ����폜����X�N���v�g  #
#  ex.N0001X0Y0 -> X0Y0                          #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(/^N[\d\s]+/){ $_= $'; }
	print OUT;
}
close(OUT);
close(IN);
