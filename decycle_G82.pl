#! /usr/bin/perl

#  G82を他のNCコードに変換するスクリプト  #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

$initZ= 0;
$kotei_flag= 0;
$G82_flag= 0;
$i= 0;		# コメント用変数
$G98G99= "G98";

while(<IN>){
	if(!/^N?[0-9\s]*[\(\%]/){
		if(/G92/){
			if(/Z([\-\d\.]+)/){ $absoZ= $1; }
		}
		if(/G90/ or /G91/){ $G90G91= $&; }
		if(/G98/ or /G99/){ $G98G99= $&; }
		if($kotei_flag == 1){
			$kotei_flag= koteiCycle_cancel($_);
			if($kotei_flag == 0){ $absoZ= $initZ; }
		}
		else{ $kotei_flag= koteiCycle_start($_); }
		if($G82_flag == 1){ $G82_flag= G82_cancel($_); }

		$initZ= $absoZ;

		if(/G82/){
			$G82_flag= 1;

			if(/[KL]([\d]+)/){ $kurikaeshi_suu= $1; }
			else{ $kurikaeshi_suu= 1; }
			if(/G90/ or /G91/){ print OUT $&."\n"; }
			if(/G98/ or /G99/){ print OUT $&."\n"; }
			while(/[SM][\d\.]+/g){ print OUT $&."\n"; }

			@G82cycle= ();
			($XY_move,$Z_move)= ("","");

			### 1 X，Y座標早送り動作
			if(/[XY]/){
				$XY_move= "G00";
				while(/[XY][\-\d\.]+/g){ $XY_move= $XY_move.$&; }
				$XY_move= $XY_move."\n";
			}
			### 2 R点接近動作
			if(/R([\-\d\.]+)/){
				$R= $1;	 #R点復帰用変数
				$Z_move= "G00Z".$R."\n";
			}
			else{ undef($R); }
			### 3 穴開け動作
			if(/Z([\-\d\.]+)/){
				$kirikomiZ= $1;	 #切り込み深さ用変数
				if(/F[\d\.]+/){ push(@G82cycle,"G01Z".$kirikomiZ.$&."\n"); }
				else{ push(@G82cycle,"G01Z".$kirikomiZ."\n"); }
			}
			### 4 ドウェル動作
			if(/P[\d\.]+/){	push(@G82cycle,"G04".$&."\n"); }
			### ５ Z座標復帰動作
			## G90のとき
			## G98ならイニシャル点に、G99ならR点に戻る
			if($G90G91 eq "G90"){
				if($G98G99 eq "G98"){ push(@G82cycle,"G00Z".$initZ."\n"); }
				else{
					push(@G82cycle,"G00Z".$R."\n");
					$initZ= $R;
				}
			}
			## G91のとき
			## 前提として$R、$kirikomiZはマイナスの値。2,3の行程で格納済み
			## G99のときはR点に戻るので、切り込んだZの移動量だけ上昇すればよい
			## G98のときはイニシャル点に戻るので、切り込んだZの移動量と、
			## R点があった場合は、R点までの移動量だけさらに上昇
			else{
				$kirikomiZ =~ s/-//;
				## G98のときはイニシャル点まで上昇
				if($G98G99 eq "G98"){
					if(/R/){
						if($R =~ /-/){ $return_R= $'; }
						$kirikomiZ= marume($kirikomiZ,$return_R);
					}
					push(@G82cycle,"G00Z".$kirikomiZ."\n");
				}
				## G99のときは切り込んだ分だけ上昇、R点を記憶
				else{
					push(@G82cycle,"G00Z".$kirikomiZ."\n");
					if(/R/){ $initZ= marume($initZ, $R); }
				}
			}

			for($j=1;$j<=$kurikaeshi_suu;$j++){
				$i++;
				print OUT "(Drilling Cycle $i)\n";
				print OUT $XY_move;
				if($j == 1){ print OUT $Z_move; }
				elsif($G98G99 eq "G98" and defined($R)){ print OUT "G00Z".$R."\n"; }
				foreach (@G82cycle){
					print OUT;
				}
			}
		}

		else{
			if($G82_flag == 1 and /[XY][\d\-\.\s]+/){
				$XY_move= "";
				while(/[XY][\d\.\-]+/g){
					$XY_move= $XY_move.$&;
					$_= $`.$';
				}
				if(!/[N\d\s]/){	print OUT;}
				$i++;
				print OUT "(Drilling Cycle $i)\n";
				print OUT "G00".$XY_move."\n";
				if($G98G99 eq "G98" and defined($R)){ print OUT "G00Z".$R."\n"; }
				foreach (@G82cycle){
					print OUT;
				}
			}
			else{
				## G82モードでない場合、そのまま出力
				print OUT;
				### イニシャル点記憶用の処理
				## G90のとき
				if($G90G91 eq "G90"){
					## G99のときはR点に戻る
					if($G98G99 eq "G99"){
						if(/R([\-\d\.]+)/){ $initZ= $1; }
					}
					## G98があるときのZの次の数字は切り込みの深さであって、復帰する座標ではない
					## G98ではイニシャル点、つまりそれ以前に移動したZ座標に復帰するので$initZを変更する必要はない
					## よって、それ以外の時のZの移動座標を監視する
					else{
						if(/Z([\-\d\.]+)/){ $initZ= $1; }
					}
				}
				## G91のときはその都度の相対量で対処できるが、途中でG91からG90に移行した場合、絶対座標が分からなくなる。
				## そこで、Zの絶対座標を移動の相対量で把握しておく必要がある
				else{
					if($G98G99 eq "G99"){
						if(/R([^A-Z\s]+)/){ $initZ= marume($initZ, $1); }
					}
					else{
						if(/Z([^A-Z\s]+)/){ $initZ= marume($initZ, $1); }
					}
				}
			}
		}
	}
	else{ print OUT; }
}

close(OUT);
close(IN);

sub marume{
	my ($num1,$num2,$enzanshi) = @_;
	my $num;
	$num1 *= 1000;
	$num2 *= 1000;
	$num1= int($num1);
	$num2= int($num2);
	if($enzanshi eq '-'){ $num= ($num1 - $num2) / 1000; }
	else{ $num= ($num1 + $num2) / 1000; }
	if($num !~ /\./ and $num != 0){ $num= $num."\."; }
	return $num;
} 

sub koteiCycle_start{
	($_)= @_;
	if(/G7[346]/ or /G8[1-9]/){ return 1; }
	else{ return 0; }
}

sub koteiCycle_cancel{
	($_)= @_;
	if(/G80/ or /G0*[0123][A-Z\s]/ or /G33/){ return 0; }
	else{ return 1;}
}

sub G82_cancel{
	($_)= @_;
	if(/G7[346]/ or /G8[013-9]/ or /G0*[0123][A-Z\s]/ or /G33/){ return 0; }
	else{ return 1; }
}
