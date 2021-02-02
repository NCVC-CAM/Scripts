#! /usr/bin/perl

#  Z軸方向に切削送りで下降し、                                               #
#  水平方向に直線補間で進む場合、下降の直前に進む方向に工具の向きを修正する  #
#  円弧補間で進む場合、刃先を法線方向にむけながら進む命令を付加する          #
#  連続した補間の場合、工具の向きの修正が必要な場合は一度R点に復帰して       #
#  次の方向に工具の向きを修正した後、再び工具を下ろし補間を続行する          #
#  円弧補間後、次の行が円弧補間でない場合、法線方向をキャンセルする          #
#  という命令を付加するスクリプト                                            #

#  絶対座標系(G90)のみ対応                                                   #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];

open(IN,$pre_file);
@line= <IN>;
close(IN);

open(OUT,">$out_file");

%XYZ= ("X",0,"Y",1,"Z",2,"I",0,"J",1);
$PI= 3.1415926535897932;
$RAD= 180/$PI;
$cutter_direction= -1;

for($i=0;$i<=$#line;$i++){
	$_= $line[$i];

	if(/^N?[\d]*[\(\%]/){ print OUT; }
	else{
		if(/G0*?([0123])[A-Z\s]/){ $G0X= $1; }
		elsif(/G8[0-9][A-Z\s]/){ $G0X= 9; }

		if($housenMode == 1){
			if($G0X !~ /[23]/){
				$housenMode= 0;
				print OUT "G40.1\n";
			}
		}
		if($G0X == 1 and /Z([^A-Z\s]+)/){
			$pointR= $abso[2];
			$abso[2]= $1;
			$kirikomiMode= 1;
			$FxyMode= 0;
			if(/F([^A-Z\s]+)/){ $okuriZ= $1; }
		
			$next_line= $line[$i+1];
			if($next_line =~ /G0*?([0123])[A-Z\s]/){ $G0X= $1; }
			if($next_line =~ /G8[0-9]/){ $G0X= 9; }

			if($next_line =~ /[XY]/ and $G0X == 1){
				if($next_line =~ /F([^A-Z\s]+)/){
					$okuriXY= $1;
					if($okuriZ != $okuriXY){ $FxyMode= 1; }
				}
				($incli[0],$incli[1])= (0,0);
				while($next_line =~ /([XY])([^A-Z\s]+)/g){
					($char,$num)= ($1,$2);
					$incli[$XYZ{$char}]= marume($num,$abso[$XYZ{$char}],'-');
					$abso[$XYZ{$char}]= $num;
				}
				$angle= get_angle(-$incli[1],$incli[0]);
				if($cutter_direction != $angle){ print OUT "C".$angle."\n"; }
				print OUT "M3\n";
				print OUT;
				print OUT $next_line;
				$i++;
			}
			elsif($G0X =~ /[23]/){
				$housenMode= 1;
				if($next_line =~ /F([^A-Z\s]+)/){
					$okuriXY= $1;
					if($okuriZ != $okuriXY){ $FxyMode= 1; }
				}
				($center[0],$center[1])= (0,0);
				if($next_line =~ /R([^A-Z\s]+)/){
					$radius= $1;
					($destination[0],$destination[1])= (0,0);
					while($next_line =~ /([XY])([^A-Z\s]+)/g){
						$destination[$XYZ{$1}]= marume($2,$abso[$XYZ{$1}],'-');  #移動前の点から移動後の点までの相対座標
						$abso[$XYZ{$1}]= $2;
					}
					if($G0X == 2) {
						@center= get_center($destination[0],$destination[1],$radius);  #移動前の点から円弧の中心までの相対座標
					}
					else{
						@center= get_center($destination[0],$destination[1],-$radius);
					}
				}
				else{
					while($next_line =~ /([IJ])([^A-Z\s]+)/g){
						$center[$XYZ{$1}]= $2;
					}
				}
				if($G0X == 2){ $angle= get_angle(-$center[0],-$center[1]); }
				else{ $angle= get_angle($center[0],$center[1]); }
				if($cutter_direction != $angle){ print OUT "C".$angle."\n"; }
				print OUT "M3\n";
				print OUT;
				if($G0X == 2){
					$kaitenHoukou= 2;
					print OUT "G41.1";
				}
				else{
					$kaitenHoukou= 3;
					print OUT "G42.1";
				}
				print OUT $next_line;
				
				if($next_line =~ /R[^A-Z\s]+/){
					$center[0]= marume($center[0],$destination[0],'-');  #移動後の点から円弧の中心までの相対座標
					$center[1]= marume($center[1],$destination[1],'-');
				}
				else{
					while($next_line =~ /([XY])([^A-Z\s]+)/g){
						$incli_sub= marume($abso[$XYZ{$1}],$2,'-');  #移動後の点から移動前の点までの相対座標
						$center[$XYZ{$1}]= marume($center[$XYZ{$1}],$incli_sub);  #移動後の点から中心までの相対座標
						$abso[$XYZ{$1}]= $2;
					}
				}
				
				if($G0X == 2){ $cutter_direction= get_angle(-$center[0],-$center[1]); }  #移動後の点でのカッターの角度
				else{ $cutter_direction= get_angle($center[0],$center[1]); }
				$i++;
			}
			else{ print OUT; }
		}
		elsif($G0X == 1 and $kirikomiMode == 1 and /[XY]/){
			($incli[0],$incli[1])= (0,0);
			while(/([XY])([^A-Z\s]+)/g){
				($char,$num)= ($1,$2);
				$incli[$XYZ{$char}]= marume($num,$abso[$XYZ{$char}],'-');
				$abso[$XYZ{$char}]= $num;
			}
			$angle= get_angle(-$incli[1],$incli[0]);
			if($cutter_direction != $angle){
				print OUT "G00Z".$pointR."\n";
				print OUT "M5\nC".$angle."\nM3\n";
				if($FxyMode == 1){
					print OUT "G01Z".$abso[2]."F".$okuriZ."\n";
					if(!/F([^A-Z\s]+)/){
						if(/\s*$/){
							print OUT $`."F".$okuriXY.$&;
						}
					}
					else{ print OUT; }
				}
				else{
					print OUT "G01Z".$abso[2]."\n";
					print OUT;
				}
				$cutter_direction= $angle;
			}
			else{ print OUT; }
		}
		elsif($G0X =~ /[23]/ and $kirikomiMode == 1){
			($center[0],$center[1])= (0,0);
			if(/R([^A-Z\s]+)/){
				$radius= $1;
				($destination[0],$destination[1])= (0,0);
				while(/([XY])([^A-Z\s]+)/g){
					$destination[$XYZ{$1}]= marume($2,$abso[$XYZ{$1}],'-');
					$abso[$XYZ{$1}]= $2;
				}
				if($G0X == 2) {
					@center= get_center($destination[0],$destination[1],$radius);
				}
				else{
					@center= get_center($destination[0],$destination[1],-$radius);
				}
			}
			else{
				while(/([IJ])([^A-Z\s]+)/g){
					$center[$XYZ{$1}]= $2;
				}
			}
			if($G0X == 2){ $angle= get_angle(-$center[0],-$center[1]); }
			else{ $angle= get_angle($center[0],$center[1]); }

			if($cutter_direction != $angle){
				if($housenMode == 1){ print OUT "G40.1\n"; }
				print OUT "G00Z".$pointR."\n";
				print OUT "M5\nC".$angle."\nM3\n";
				if($FxyMode == 1){
					print OUT "G01Z".$abso[2]."F".$okuriZ."\n";
					if($G0X == 2){
						$kaitenHoukou= 2;
						print OUT "G41.1\n";
						if($housenMode == 1 and !/G0*?2[A-Z\s]/){ print OUT "G02"; }
					}
					if($G0X == 3){
						$kaitenHoukou= 3;
						print OUT "G42.1\n";
						if($housenMode == 1 and !/G0*?3[A-Z\s]/){ print OUT "G03"; }
					}
					if(!/F([^A-Z\s]+)/){
						if(/\s*$/){
							print OUT $`."F".$okuriXY.$&;
						}
					}
					else{ print OUT; }
				}
				else{
					print OUT "G01Z".$abso[2]."\n";
					if($G0X == 2){
						$kaitenHoukou= 2;
						print OUT "G41.1\n";
						if($housenMode == 1 and !/G0*?2[A-Z\s]/){ print OUT "G02"; }
					}
					if($G0X == 3){
						$kaitenHoukou= 3;
						print OUT "G42.1\n";
						if($housenMode == 1 and !/G0*?3[A-Z\s]/){ print OUT "G03"; }
					}
					print OUT;
				}
			}
			else{
				if($housenMode == 1){
					if($G0X == 2 and $kaitenHoukou == 3){
						$kaitenHoukou= 2;
						print OUT "G41.1\n";
					}
					elsif($G0X == 3 and $kaitenHoukou == 2){
						$kaitenHoukou= 3;
						print OUT "G42.1\n";
					}
				}
				else{
					if($G0X == 2){
						$kaitenHoukou= 2;
						print OUT "G41.1\n";
					}
					else{
						$kaitenHoukou= 3;
						print OUT "G42.1\n";
					}
				}
				print OUT;
			}
				
			if(/R[^A-Z\s]+/){
				$center[0]= marume($center[0],$destination[0],'-');
				$center[1]= marume($center[1],$destination[1],'-');
			}
			else{
				while(/([XY])([^A-Z\s]+)/g){
					$incli_sub= marume($abso[$XYZ{$1}],$2,'-');
					$center[$XYZ{$1}]= marume($center[$XYZ{$1}],$incli_sub);
					$abso[$XYZ{$1}]= $2;
				}
			}

			if($G0X == 2){ $cutter_direction= get_angle(-$center[0],-$center[1]); }
			else{ $cutter_direction= get_angle($center[0],$center[1]); }
			$housenMode= 1;
		}
		elsif($G0X == 0 and /Z([^A-Z\s]+)/){
			$pointZ= $1;
			if($kirikomiMode == 1 and $pointZ > $abso[2]){
				$kirikomiMode= 0;
				print OUT;
				print OUT "M5\n";
			}
			else{ print OUT; }
			$abso[2]= $pointZ;
		}
		else{
			print OUT;
			while(/([XYZ])([^A-Z\s]+)/g){
				$abso[$XYZ{$1}]= $2;
			}
		}
	}
}

close(OUT);


sub marume{
	my ($num1,$num2,$enzanshi)= @_;
	my $num;
		
	$num1= int($num1*1000);
	$num2= int($num2*1000);
	if($enzanshi eq '-'){ $num= ($num1 - $num2) / 1000; }
	else{ $num= ($num1 + $num2) / 1000; }
	if($num !~ /\./ and $num != 0){ $num= $num.'.'; }
	return $num;
} 

sub marume2{
	my ($num)= @_;
	$num= int($num * 1000);
	$num= $num / 1000;
	if($num !~ /\./ and $num != 0){ $num= $num.'.'; }
	return $num;
}

sub get_angle{
	my ($x,$y)= @_;
	my $theta= atan2($y,$x)*$RAD;
	if($y < 0){ $theta += 360; }
	$theta= marume2($theta);
	return $theta;
}

sub get_center{
	my ($x,$y,$r)= @_;
	my (@center,$fugou);
	$x= int($x * 1000);
	$y= int($y * 1000);
	$r= int($r * 1000);
	my $obj= sqrt(4*$r*$r/($x*$x+$y*$y) - 1);
	if($r > 0){ $fugou= 1; }
	else{ $fugou= -1; }
	$center[0]= ($x + $fugou*$y*$obj)/2000;
	$center[1]= ($y - $fugou*$x*$obj)/2000;
	$center[0]= marume2($center[0]);
	$center[1]= marume2($center[1]);
	return @center;
}
