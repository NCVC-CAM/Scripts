#! /usr/bin/perl

#  NC�f�[�^��()�̍s���폜����X�N���v�g  #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*\(/){ print OUT; }
}
close(OUT);
close(IN);
