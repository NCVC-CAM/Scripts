#! /usr/bin/perl

#  NC�f�[�^�̃��[�h�Ԃ̃X�y�[�X�A�^�u���폜����X�N���v�g  #
#  ex.G90 G40 G80 -> G90G40G80                             #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){ $_ =~ s/(\S)\s+(\S)/$1$2/g; }
	elsif(/(N[0-9]+)[\s]*([\(\%])/){ $_= $1.$2.$'; }
	print OUT;
}
close(OUT);
close(IN);
