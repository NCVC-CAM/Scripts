#! /usr/bin/perl

#  ���[�U�[���H�@�p��G�R�[�h��ϊ�����X�N���v�g  #
#  (G08, G11.1, G11 ���Ώ�)							  #
#  ��΍��W�n(G90)�̂ݑΉ�								  #


use Math::Trig;
$EPSILON = 0.0001;

$pre_file= $ARGV[0];
$out_file= $ARGV[1];

open(IN,$pre_file);
@line = <IN>;
close(IN);

open(OUT,">$out_file");

my ($line,$i);
my ($G0X,$radius);
my $word;
my $commentLine;

my ($x,$y);	#�ړ��O�̍��W���i�[
my @abso;	#�ړ���̍��W
my @pass;	#�ʉߓ_�̍��W
my @destination;	#�ړ���̍��W
my @center;	#�~�ʂ̒��S���W
my @passAx;	#�~�ʕ�Ԏ��ɂ܂������̃��X�g

%XYZ = ("X",0,"Y",1,"Z",2,"I",0,"J",1);

for($i=0;$i<=$#line;$i++){
	$_ = $line[$i];
	
	if(/^\s*[\%]/){ print OUT; }
	else{
		($_, $commentLine) = divideComment($_);
		
		if(/G0*?([018])[A-Z\s]/){ $G0X = $1; }
		elsif(/G11[A-Z\s]/){ $G0X = 11; }
		elsif(/G11.1[A-Z\s]/){ $G0X = 11.1; }
		
		if($G0X == 8 and /D([^A-Z\s]+)/){
			
			$radius = marume($1/2);
			
			#�������R�����g�o��
			outputOriginal($line[$i]);
			
			#G08,D_,K_�ȊO+�R�����g���o��
			while(/[A-CE-JL-Z][^A-Z\s]+/g){
				$word = $&;
				if($word !~ /G0*8/){
					print OUT $word;
				}
			}
			print OUT $commentLine."\n";
			
			$startX = marume($abso[0] + $radius);
			$abso[0] = marume($abso[0] + $startX);
			print OUT "G00X".$startX."\n";
			print OUT "G03I-".$radius."\n";
		}
		elsif($G0X == 11){
			($pass[0],$pass[1]) = ($abso[0],$abso[1]);
			
			#�������R�����g�o��
			outputOriginal($line[$i]);
			
			while(/([XY])([^A-Z\s]+)/g){
				$pass[$XYZ{$1}] = $2;
			}
		}
		elsif($G0X == 11.1){
			
			#�������R�����g�o��
			outputOriginal($line[$i]);
			
			($destination[0],$destination[1]) = ($abso[0],$abso[1]);
			while(/([XY])([^A-Z\s]+)/g){
				$destination[$XYZ{$1}] = $2;
			}
			
			($center[0],$center[1]) = getCenterFrom3P($abso[0],$abso[1],$pass[0],$pass[1],$destination[0],$destination[1]);
			
			if($center[0] eq "error"){
				print OUT "(-- �~�ʕ�Ԃł��܂��� --)\n";
			}
			else{
				$word = getG02orG03($abso[0],$abso[1],$destination[0],$destination[1],
											$pass[0],$pass[1],$center[0],$center[1]);
				
				$radius = getRadius($center[0]-$abso[0],$center[1]-$abso[1]);
				print OUT $word."X".$destination[0]."Y".$destination[1].
								"R".$radius."\n";
				
				($abso[0],$abso[1]) = ($destination[0],$destination[1]);
			}
		}
		
		else{
			print OUT $line[$i];
			while(/([XYZ])([^A-Z\s]+)/g){
				$abso[$XYZ{$1}] = $2;
			}
		}
	}
}

close(OUT);


sub marume{
	my ($num) = @_;

	if($coordinateNotation == 1){
		return int($num+0.5);
	}
	else{
		$num = int($num * 1000);
		$num = $num / 1000;
		if($num !~ /\./ and $num != 0){ $num = $num.'.'; }
		return $num;
	}
}

sub getCenterFrom3P{
	my ($x1,$y1,$x2,$y2,$x3,$y3) = @_;
	my ($A,$B,$C,$D,$E,$xc,$yc);
	
	$E = ($x1-$x3)*($y1-$y2) - ($x1-$x2)*($y1-$y3);
	if(abs($E) <= $EPSILON){
		return "error";
	}
	else{
		$A = ($y1-$y2)*($x1*$x1-$x3*$x3+$y1*$y1-$y3*$y3)/2;
		$B = ($y1-$y3)*($x1*$x1-$x2*$x2+$y1*$y1-$y2*$y2)/2;
		$C = ($x1-$x3)*($x1*$x1-$x2*$x2+$y1*$y1-$y2*$y2)/2;
		$D = ($x1-$x2)*($x1*$x1-$x3*$x3+$y1*$y1-$y3*$y3)/2;
		
		$xc = ($A-$B)/$E;
		$yc = ($C-$D)/$E;
		return ($xc,$yc);
	}
}

sub getG02orG03{
	my ($xs,$ys,$xe,$ye,$xp,$yp,$xc,$yc) = @_;
	my ($As,$Ae,$Ap);
	
	$As = getAngle($xs-$xc,$ys-$yc);
	$Ae = getAngle($xe-$xc,$ye-$yc);
	$Ap = getAngle($xp-$xc,$yp-$yc);
	
	#CCW���ǂ����𔻒肷��
	#�ʉߓ_���J�n�_�ƏI���_�̊Ԃ̊p�x�ɂ���΁ACCW
	#�J�n�_���I���_�����傫���p�x�̂Ƃ��ACCW�Ȃ�Α�4�ی������1�ی��ɉ��͂�
	if($Ae < $As){
		#��4�ی������1�ی��ɉ��Ƃ��A�I���_���ʉߓ_�����傫���p�x�Ȃ�΁A
		#�ʉߓ_�͑�4�ی������1�ی��ɉ������Œʉ߂���͂�
		if($Ap < $Ae){
			$Ap += 2*pi;
		}
		$Ae += 2*pi;
	}
	
	if($As < $Ap and $Ap < $Ae){
		return "G03";
	}
	else{
		return "G02";
	}
}

sub getAngle{
	my ($x,$y) = @_;
	my $theta = atan2($y,$x);
	if($theta < 0){ $theta += 2*pi; }
	return $theta;
}


sub getRadius{
	my ($dx,$dy) = @_;
	
	return marume(sqrt($dx*$dx+$dy*$dy));
}

sub divideComment{
	my ($line) = @_;
	my ($word, $newLine, $commentLine);
	
	$newLine = "";
	$commentLine = "";
#	while( $line =~ /([A-Z][^A-Z\s\(]+|\s*\(.*?\)\s*)/g ){
	while( $line =~ /([A-Z][^A-Z\s\(]+|\s*\(.*?\))/g ){
		$word = $&;
		if($word =~ /\(/){
			$commentLine = $commentLine . $word;
		}
		else{
			$newLine = $newLine . $word;
		}
	}
	
	#if($commentLine eq ""){
	#	return $commentLine;
	#}
	#else{
		return ($newLine,$commentLine);
	#}
}

sub outputOriginal{
	my ($line) = @_;
	
	$line =~ s/\s*$//;
	print OUT "(-- " .$line. " --)\n";
}
