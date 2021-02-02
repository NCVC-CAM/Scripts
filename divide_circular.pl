#! /usr/bin/perl

#  円弧補間を象限ごとに分割するスクリプト  #
#  絶対座標系(G90)のみ対応                 #

####各種設定################################
# 座標を小数点表示する場合は 0
# 1/1000表示する場合は 1
# を設定してください。
$coordinateNotation= 1;
############################################

use Math::Trig;
$EPSILON = 0.0001;

$pre_file= $ARGV[0];
$out_file= $ARGV[1];

open(IN,$pre_file);
@line = <IN>;
close(IN);

open(OUT,">$out_file");

my ($line,$i,$j);
my ($G0X,$radius);
my @point;
my @currentIJ;

my ($x,$y);	#移動前の座標を格納
my @abso;	#移動後の座標
my @destination;	#移動前の座標から移動後の座標までの相対座標
my @center;	#移動前の座標から円弧の中心までの相対座標
my @passAx;	#円弧補間時にまたぐ軸のリスト

%XYZ = ("X",0,"Y",1,"Z",2,"I",0,"J",1);

for($i=0;$i<=$#line;$i++){
	$_ = $line[$i];
	
	if(/^\s*[\(\%]/){ print OUT; }
	else{
		if(/G0*?([0123])[A-Z\s]/){ $G0X = $1; }
		elsif(/G8[0-9][A-Z\s]/){ $G0X = 9; }
		
		if($G0X =~ /[23]/ and /[XYIJ][^A-Z\s]+/){
			($x,$y) = ($abso[0],$abso[1]);
			($center[0],$center[1]) = (0,0);
			($destination[0],$destination[1]) = (0,0);
			
			while(/([XY])([^A-Z\s]+)/g){
				$destination[$XYZ{$1}] = $2 - $abso[$XYZ{$1}];
				$abso[$XYZ{$1}]=$2;
			}
			
			if(/R([^A-Z\s]+)/){
				$radius = $1;
				@center = getCenter($destination[0],$destination[1],$radius,$G0X);
				
				$sAngle = getAngle(-$center[0],-$center[1]);
				$eAngle = getAngle($destination[0]-$center[0],$destination[1]-$center[1]);
				@passAx = getPassAxis($sAngle,$eAngle,$G0X);
				
				if($#passAx>=0){
					if($radius<0){ $radius = marume(abs($radius)); }
					@point = getIntersectionPoint($passAx[0],$x,$y,$radius,@center);
					while(/G[^A-Z\s]+/g){
						print OUT $&;
					}
					print OUT "X".$point[0];
					print OUT "Y".$point[1];
					print OUT "R".$radius;
					while(/[A-FHK-QS-VZ][^A-Z\s]+/g){
						print OUT $&;
					}
					print OUT "\n";
					
					for($j=1; $j<=$#passAx; $j++){
						@point = getIntersectionPoint($passAx[$j],$x,$y,$radius,@center);
						print OUT "X".$point[0];
						print OUT "Y".$point[1];
						print OUT "R".$radius."\n";
					}
					
					print OUT "X".$abso[0]."Y".$abso[1]."R".$radius."\n";
				}
				else{
					print OUT;
				}
			}
			else{
				while(/([IJ])([^A-Z\s]+)/g){
					$center[$XYZ{$1}] = $2;
				}
				$radius = getRadius($center[0],$center[1]);
				$sAngle = getAngle(-$center[0],-$center[1]);
				$eAngle = getAngle($destination[0]-$center[0],$destination[1]-$center[1]);
				@passAx = getPassAxis($sAngle,$eAngle,$G0X);
				
				if($#passAx>=0){
					@point = getIntersectionPoint($passAx[0],$x,$y,$radius,@center);
					while(/G[^A-Z\s]+/g){
						print OUT $&;
					}
					print OUT "X".$point[0];
					print OUT "Y".$point[1];
					while(/[A-FH-VZ][^A-Z\s]+/g){
						print OUT $&;
					}
					print OUT "\n";
					
					for($j=1; $j<=$#passAx; $j++){
						@point = getIntersectionPoint($passAx[$j],$x,$y,$radius,@center);
						print OUT "X".$point[0];
						print OUT "Y".$point[1];
						@currentIJ = getCurrentIJ($passAx[$j-1],$radius);
						if($currentIJ[0] != 0){ print OUT "I".$currentIJ[0]; }
						if($currentIJ[1] != 0){ print OUT "J".$currentIJ[1]; }
						print OUT "\n";
					}
					print OUT "X".$abso[0]."Y".$abso[1];
					@currentIJ = getCurrentIJ($passAx[$#passAx],$radius);
					if($currentIJ[0] != 0){ print OUT "I".$currentIJ[0]; }
					if($currentIJ[1] != 0){ print OUT "J".$currentIJ[1]; }
					print OUT "\n";
				}
				else{
					print OUT;
				}
			}
#print "G0X:$G0X, R:$radius\n";
#print "center:@center\n";
#print "@passAx\n\n";

		}
		else{
			print OUT;
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

sub getRadius{
	my ($dx,$dy) = @_;
	
	return marume(sqrt($dx*$dx+$dy*$dy));
}

sub getCenter{
	my ($dx,$dy,$r,$g0x) = @_;
	my ($fugou,$f1,$f2);
	my (@center);
	
	$dx = int(($dx) * 1000);
	$dy = int(($dy) * 1000);
	$r = int($r * 1000);
	
	my $obj = sqrt(4*$r*$r/($dx*$dx+$dy*$dy) - 1);
	if($r > 0){ $f1 = 1; }
	else{ $f1 = -1; }
	if($g0x == 2){ $f2 = 1; }
	else{ $f2 = -1; }
	$fugou = $f1 * $f2;
	
	$center[0] = ($dx + $fugou*$dy*$obj)/2000;
	$center[0] = marume($center[0]);
	$center[1] = ($dy - $fugou*$dx*$obj)/2000;
	$center[1] = marume($center[1]);
	return @center;
}

sub getAngle{
	my ($x,$y) = @_;
	my $theta = atan2($y,$x);
	if($theta < 0){ $theta += 2*pi; }
	return $theta;
}


sub getPassAxis{
	my ($s,$e,$g) = @_;
	my ($ax,@passAxisList);
	# @passAxisList:
	#  0: +x軸
	#  1: +y軸
	#  2: -x軸
	#  3: -y軸
	
	# 開始点、終了点の象限を取得
	#    0 <= Theta <  90: 1
	#	 90 <= Theta < 180: 2
	#	180 <= Theta < 270: 3
	#  270 <= Theta < 360: 4
	my $sQuadrant = int($s / (pi/2)) + 1;
	my $eQuadrant = int($e / (pi/2)) + 1;
	
	if($g == 2){	# 時計回り
		if($sQuadrant == $eQuadrant and $s > $e){ return; }	# 軸をまたがない場合
		if($sQuadrant <= $eQuadrant){ $sQuadrant += 4;}	# 第1象限から第4象限のとき(+x軸をまたぐ場合)
		
		#開始点が軸上の場合は軸をまたがないので
		if(abs(sin($s*2)) < $EPSILON){ $sQuadrant -= 1; }
		
		for($ax=$sQuadrant; $ax>$eQuadrant; $ax--){
			push(@passAxisList,($ax-1)%4);	# 時計回りなので(象限-1)%4の軸を通過する
		}
	}
	else{	# 反時計回り
		if($sQuadrant == $eQuadrant and $s < $e){ return; }	# 軸をまたがない場合
		if($sQuadrant >= $eQuadrant){ $eQuadrant += 4;}	# 第4象限から第1象限のとき(+x軸をまたぐ場合)
		
		#終了点が軸上の点は軸をまたがないので
		if(abs(sin($e*2)) < $EPSILON){ $eQuadrant -= 1; }
		
		for($ax=$sQuadrant; $ax<$eQuadrant; $ax++){
			push(@passAxisList,($ax)%4);	# 反時計回りなので(象限)%4の軸を通過する
		}
	}
	return @passAxisList;
}

sub getIntersectionPoint{
	my ($ax,$x,$y,$radius,@center) = @_;
	# $Ax
	#  0: +x軸
	#  1: +y軸
	#  2: -x軸
	#  3: -y軸
	
	my @xAx = (1,0,-1,0);
	my @yAx = (0,1,0,-1);
	my @ip;
	
	$ip[0] = marume($x + $center[0] + $radius*$xAx[$ax]);
	$ip[1] = marume($y + $center[1] + $radius*$yAx[$ax]);
	
	return @ip;
}

sub getCurrentIJ{
	my ($ax,$radius) = @_;
	# $Ax
	#  0: +x軸
	#  1: +y軸
	#  2: -x軸
	#  3: -y軸
	
	my @iAx = (-1,0,1,0);
	my @jAx = (0,-1,0,1);
	my @ij;
	
	$ij[0] = marume($radius * $iAx[$ax]);
	$ij[1] = marume($radius * $jAx[$ax]);

	return @ij;
}
