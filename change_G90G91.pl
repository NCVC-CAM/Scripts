#! /usr/bin/perl

#  絶対座標系(G90)と相対座標系(G91)を入れ替えるスクリプト  #
#  Ver.1.300

#######################################
# G90をG91にする場合は1,しない場合は0
$G90toG91= 1;

# G91をG90にする場合は1,しない場合は0
$G91toG90= 1;

# 座標を小数点表示する場合は 0
# 1/1000表示する場合は 1
# を設定してください。
$coordinateNotation= 0;

#######################################

%XYZ= ("X",0,"Y",1,"Z",2,"R",2);

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

$kotei_flag= 0;
$initZ= 0;
while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		$jouken= '([XYZ])([^A-Z\s]+)';

		if(/G92/){
			while(/$jouken/g){ $abso[$XYZ{$1}]= $2; }
		}
		if(/G9([01])/){ $G90G91= $1; }
		if(/G99/){ $return_R= 1;}

		if($kotei_flag == 1){
			$kotei_flag= koteiCycle_cancel($_);
			if($kotei_flag == 0){ $abso[2]= $initZ; }
		}
		else{ $kotei_flag= koteiCycle_start($_); }
		$initZ= $abso[2];

		if($G90G91 == 0 and $G90toG91 == 1){
			s/G90/G91/;
			if($kotei_flag == 1){
				if(/R([^A-Z\s]+)/){
					$R= $1;
					$incli_R= marume($R,$initZ,'-');
					$_= $`."R".$incli_R.$';
					if($return_R == 1){
						$initZ = $R;
						$return_R = 0;
					}
				}
				else{ $R= $initZ; }
				if(/Z([^A-Z\s]+)/){
					$incl= marume($1,$R,'-');
					$_= $`."Z".$incl.$';
				}
				$jouken= '([XY])([^A-Z\s]+)';
			}
			if(!/G92/){
				$new_line= "";
				while(/$jouken/){
					($pre_line,$char,$num,$_)= ($`,$1,$2,$');
					$incl= marume($num,$abso[$XYZ{$char}],'-');
					$abso[$XYZ{$char}]= $num;
					$new_line= $new_line.$pre_line.$char.$incl;
				}
				$_= $new_line.$_;
			}
		}

		elsif($G90G91 == 0 and $G90toG91 == 0){
			if($kotei_flag == 1){
				if(/R([^A-Z\s]+)/){
					$R= $1;
					if($return_R == 1){
						$initZ= $R;
						$return_R= 0;
					}
				}
				else{ $R= $initZ; }
				$jouken= '([XY])([^A-Z\s]+)';
			}
			if(!/G92/){
				while(/$jouken/g){
					($char,$num)= ($1,$2);
					$abso[$XYZ{$char}]= $num;
				}
			}
		}

		elsif($G90G91 == 1 and $G91toG90 == 1){
			s/G91/G90/;

			if($kotei_flag == 1){
				if(/R([^A-Z\s]+)/){
					$abso_R= marume($1,$initZ);
					$_= $`."R".$abso_R.$';
					if($return_R == 1){
						$initZ= $abso_R;
						$return_R= 0;
					}
				}
				else{ $abso_R= $initZ; }
				if(/Z([^A-Z\s]+)/){
					$absol= marume($1,$abso_R);
					$_= $`."Z".$absol.$';
				}
				$jouken= '([XY])([^A-Z\s]+)';
			}

			if(!/G92/){
				$new_line= "";
				while(/$jouken/){
					($pre_line,$char,$num,$_)= ($`,$1,$2,$');
					$abso[$XYZ{$char}]= marume($num,$abso[$XYZ{$char}]);
					$new_line= $new_line.$pre_line.$char.$abso[$XYZ{$char}];
				}
			}
			$_= $new_line.$_;
		}

		elsif($G90G91 == 1 and $G91toG90 == 0){
			if($kotei_flag == 1){
				if(/R([^A-Z\s]+)/){
					$abso_R= marume($1,$initZ);
					if($return_R == 1){
						$initZ= $abso_R;
						$return_R= 0;
					}
				}
				$jouken= '([XY])([^A-Z\s]+)';
			}

			if(!/G92/){
				while(/$jouken/g){
					($char,$num)= ($1,$2);
					$abso[$XYZ{$char}]= marume($num,$abso[$XYZ{$char}]);
				}
			}
		}

	}
	print OUT;
}

close(OUT);
close(IN);


sub marume{
	my ($num1,$num2,$enzanshi)= @_;
	my $num;
	
	if($coordinateNotation == 1){
		if($enzanshi eq '-'){ $num= $num1 - $num2; }
		else{ $num= $num1 + $num2; }
		return int($num);
	}
	else{
		$num1 *= 1000;
		$num2 *= 1000;
		$num1= int($num1);
		$num2= int($num2);
		if($enzanshi eq '-'){ $num= ($num1 - $num2) / 1000; }
		else{ $num= ($num1 + $num2) / 1000; }
		if($num !~ /\./ and $num != 0){ $num= $num."\.";}
		return $num;
	}
} 

sub koteiCycle_start{
	($_) = @_;
	if(/G7[346]/ or /G8[1-9]/){ return 1; }
	else{ return 0; }
}

sub koteiCycle_cancel{
	($_) = @_;
	if(/G80/ or /G0*[0123][A-Z\s]/ or /G33/){ return 0; }
	else{ return 1; }
}
