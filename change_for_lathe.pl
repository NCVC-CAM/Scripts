#! /usr/bin/perl

#  ver.1.1

#  NCVCで作成したGコードを、NC旋盤用に変換するスクリプト #


%XY= ("X","Z","Y","X","I","K","J","I");

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$_= change_XZYX($_);
		$_= X_to_2X($_);
		$_= G17_G18($_);
	}
	print OUT;
}

close(OUT);
close(IN);


sub change_XZYX{
	my ($line)= @_;
	my $new_line;
	while($line =~ /([XYIJ])([0-9\-\.]+)/){
		$new_line= $new_line.$`.$XY{$1}.$2;
		$line= $';
	}
	return $new_line.$line;
}

sub X_to_2X{
	my ($line)= @_;
	my ($new_line,$pre_line,$num);
	while($line =~ /X([\-\d\.]+)/){
		($pre_line,$num,$line)= ($`,$1,$');
		$num= int($num*1000) * 2;
		$num= $num / 1000;
		if($num !~ /\./ and $num != 0){ $num = $num."\.";}
		$new_line= $new_line.$pre_line."X".$num;
	}
	return $new_line.$line;
}

sub G17_G18{
	my ($line)= @_;
	$line =~ s/G17/G18/;
	return $line;
}

