#! /usr/bin/perl

# NCVCで作成したGコードを、NC旋盤用に変換するスクリプト #


%ZX= ("Z","X","X","Y","K","I","I","J");

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$_= change_ZXXY($_);
		$_= Y_to_Y2($_);
	}
	print OUT;
}

close(OUT);
close(IN);


sub change_ZXXY{
	my ($line)= @_;
	my $new_line;
	while($line =~ /([XZIK])([0-9\-\.]+)/){
		$new_line= $new_line.$`.$ZX{$1}.$2;
		$line= $';
	}
	return $new_line.$line;
}

sub Y_to_Y2{
	my ($line)= @_;
	my ($new_line,$pre_line,$num);
	while($line =~ /Y([\-\d\.]+)/){
		($pre_line,$num,$line)= ($`,$1,$');
		$num= int($num*1000/2) ;
		$num= $num / 1000;
		if($num !~ /\./ and $num != 0){ $num = $num."\.";}
		$new_line= $new_line.$pre_line."Y".$num;
	}
	return $new_line.$line;
}