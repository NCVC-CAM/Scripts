#! /usr/bin/perl

#  レーザー加工機用のGコードを変換するスクリプト  #
#  (G08, G11.1, G11 が対象)							  #
#  絶対座標系(G90)のみ対応								  #


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

my ($x,$y);	#移動前の座標を格納
my @abso;	#移動後の座標
my @pass;	#通過点の座標
my @destination;	#移動後の座標
my @center;	#円弧の中心座標
my @passAx;	#円弧補間時にまたぐ軸のリスト

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
			
			#原文をコメント出力
			outputOriginal($line[$i]);
			
			#G08,D_,K_以外+コメントを出力
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
			
			#原文をコメント出力
			outputOriginal($line[$i]);
			
			while(/([XY])([^A-Z\s]+)/g){
				$pass[$XYZ{$1}] = $2;
			}
		}
		elsif($G0X == 11.1){
			
			#原文をコメント出力
			outputOriginal($line[$i]);
			
			($destination[0],$destination[1]) = ($abso[0],$abso[1]);
			while(/([XY])([^A-Z\s]+)/g){
				$destination[$XYZ{$1}] = $2;
			}
			
			($center[0],$center[1]) = getCenterFrom3P($abso[0],$abso[1],$pass[0],$pass[1],$destination[0],$destination[1]);
			
			if($center[0] eq "error"){
				print OUT "(-- 円弧補間できません --)\n";
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
	
	#CCWかどうかを判定する
	#通過点が開始点と終了点の間の角度にあれば、CCW
	#開始点が終了点よりも大きい角度のとき、CCWならば第4象限から第1象限に回るはず
	if($Ae < $As){
		#第4象限から第1象限に回るとき、終了点が通過点よりも大きい角度ならば、
		#通過点は第4象限から第1象限に回った後で通過するはず
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
