#! /usr/bin/perl

#  Transpose_macro(FANUC)
#  Version 2.5.2

#  マクロ呼び出し命令、サブプログラム呼び出し命令を含むNCデータを、    #
#  それらが実行された状態に置換して、一つのプログラムにするスクリプト  #
#  また、マクロ文を平易なNC文に変換する                                #

# 2016.06.15 defined関数の仕様変更によるバグを修正
# 2018.02.20 未定義の変数が行末の場合に、改行が消えるバグを修正
# 2018.02.23 WHILE及びDOループ中からGOTOでループ外に出ないバグを修正
# 2018.03.23 システム変数5001,5002,5003に対応
# 2018.03.28 G66関連のバグを修正
# 2018.05.30 加減算のバグを修正
# 2018.11.08 G66中のG65関連のバグを修正
# 2019.05.03 軽微なバグを修正
# 2019.05.12 無限ループになる状態を回避(ループ数に上限を設定)
# 2019.05.14 軽微なバグを修正
# 2019.05.23 実機でエラーになる文法をチェックする機能を追加
# 2019.09.09 条件文内の内部変換に文法チェックがかかる不具合を修正
# 2020.03.27 ATAN[ ]がA TAN[ ]と扱われて文法チェックがかかる不具合を修正
#            ASIN,ACOSに対応、数値直後に#,[,関数の場合の文法チェックを追加
# 2020.03.30 IF文等の条件式の文法チェックの不具合を修正
# 2020.04.16 IF文等の条件式の内部処理の不具合を修正

####各種設定############################################################
# マクロプログラム、サブプログラム用のフォルダのパスを登録してください。
# フォルダ名の最後に\はつけないで下さい。
$macro_folder= 'C:\Program Files\NCVC\macro';

# システム変数を使用する場合で、初期値が必要なものは値を登録してください。
# 初期状態のGコードのモーダル情報が違う場合も同様。
#%system_value= (,);

# 内部処理及び、変換前の原文をコメント出力する場合は1、しない場合は0を設定してください。
# ただし、最低限の内部処理は0を設定しても出力されます。
$debug_flag= 0;
# モーダル情報をコメント出力する場合は1、しない場合は0を設定してください。
$modal_flag= 0;

# Fコードで指定する数値の小数点以下が0のとき、
# 小数点を出力しない場合は0、
# 小数点を出力する場合は1を設定してください。
$F_flag= 0;

# オプショナルブロックスキップを有効(ON)にしたい場合は1、
# 無効(OFF)にしたい場合は0を設定してください。
$OBS_switch= 0;

# M98の繰り返し数の指定方法について、
# M98P○○○○L○○○○のLで指定する方式の場合は0、
# M98P○○○○○○○○の前4桁で指定する方式の場合は1を設定してください。
$M98_houshiki= 0;

# システム変数 #5001,#5002,#5003の変化をコメント出力する場合は1、
# しない場合は0を設定してください。
$debug_flag2= 0;

# WHILEやDOループ内でのループ数の上限数を設定してください。
# 条件式などでループが終わらない場合に無限ループを防ぎます。
$loop_max = 300;

# プログラム全体でのGOTO命令の上限数を設定してください。
# GOTO処理での無限ループを防ぎます。
$GOTO_exe_max = 500;

# (おそらく実機でエラーになる)文法の誤りが検出された場合、
# 誤りの内容を出力し、処理を停止する場合は 1
# 誤りを無視してそのまま処理を続行する場合は 0 を設定してください。
# なお、WHILE構文などプログラム全体の流れに関するエラーは
# この設定に関わらず処理を停止します。
$break_flag = 1;
########################################################################

use Math::Trig;

$RAD = 180/pi;
#$PI= 3.1415926535897932;
#$RAD= 180/$PI;

%c= ("A","1","B","2","C","3","D","7","E","8","F","9","H","11","I","4","J","5","K","6","M","13","Q","17","R","18","S","19","T","20","U","21","V","22","W","23","X","24","Y","25","Z","26");

%G_group= (0,1,1,1,2,1,3,1,15,17,16,17,17,2,18,2,19,2,20,6,21,6,22,4,23,4,33,1,40,7,41,7,42,7,40.1,19,150,19,41.1,19,151,19,42.1,19,152,19,43,8,44,8,49,8,50,11,51,11,50.1,18,51.1,18,54,14,54.1,14,55,14,56,14,57,14,58,14,59,14,61,15,62,15,63,15,64,15,66,12,67,12,68,16,19,16,73,9,74,9,75,1,76,9,77,1,78,1,79,1,80,9,81,9,82,9,83,9,84,9,85,9,86,9,87,9,88,9,89,9,90,3,91,3,94,5,95,5,96,13,97,13,98,10,99,10,160,20,161,20);

%initial_G= (1,00,17,15,2,17,4,22,7,40,19,40.1,8,49,11,50,18,50.1,14,54,15,64,12,67,16,69,9,80,3,90,5,94,13,97,10,98,20,160);

%system_value_modal= ("B",4102,"F",4109,"H",4111,"M",4113,"S",4119,"T",4120);

$macro_folder= $macro_folder."\\";

($pre_file,$out_file)= ($ARGV[0],$ARGV[1]);
open(IN,$pre_file);
while(<IN>){
	push(@main,$_);
}
close(IN);

$pre_folder= $pre_file;
$pre_folder =~ s/\\[^\\]+?$/\\/;

opendir(DIR,$pre_folder);
@macro_files2= readdir(DIR);
closedir(DIR);

opendir(DIR,$macro_folder);
@macro_files= readdir(DIR);
closedir(DIR);

open(OUT,">$out_file");
main();
close(OUT);

sub main{
	my ($i,$j);

	$macro_level= 0;
	$yobidashi_tajuudo= 0;
	$proto_prog_No= 0;
	$G66_modal_tajuudo= 0;
	$G66_yobidashi_tajuudo= 0;
	$GOTO_count= 0;

	@initial_G_key= keys(%initial_G);
	@initial_G_key= sort{$a <=> $b} @initial_G_key;
	if($modal_flag == 1){ print OUT '(----Gコード各グループのモーダル初期化開始----)'."\n"; }
	foreach $key(@initial_G_key){
		modal_shori($key+4000,$initial_G{$key});
	}
	if($modal_flag == 1){ print OUT '(----Gコード各グループのモーダル初期化終了----)'."\n"; }

	@system_value_key= keys(%system_value);
	
	# H30.03.23 追加
	$value[5001] = 0;
	$value[5002] = 0;
	$value[5003] = 0;
	#
	
	if(@system_value_key != 0){
		@system_value_key= sort{$a <=> $b} @system_value_key;
		if($debug_flag == 1){ print OUT '(---システム変数登録開始---)'."\n"; }
		foreach $key(@system_value_key){
			$value[$key]= $system_value{$key};
			print OUT '(---#'.$key.'= '.$system_value{$key}.'---)'."\n";
		}
		if($debug_flag == 1){ print OUT '(---システム変数登録終了---)'."\n"; }
	}


	for($i=0;$i<=$#main;$i++){
		$_= $main[$i];
		original_print($_);

		if(/^\s*\//){
			if($OBS_switch == 1){
				OBS_skip_print();
				next;
			}
			else{ $_= $'; }
		}

		if(/^\s*(\%)/){ print OUT $1.$'; }
		elsif(/^\s*O([0-9]+)/){
			$proto_prog_No= $1;
			print OUT $_;
			modal_shori(4115,$proto_prog_No);
		}
		else{
			if(/^\s*N0*([0-9]+)/){
				modal_shori(4114,$1);
				$_= $';
			}
			if(/\(/){ $_= kakko_print($_); }
			shikaku_kakko_kensa($_);

			if(/IF/){ $i= bunki_shori($_, $i, @main); }
			elsif(/GOTO/){ $i= idou_shori($_, @main); }
			elsif(/WHILE/){ $i= kurikaeshi_shori($_, $i, $proto_prog_No, @main); }
			elsif(/DO/){ $i= kurikaeshi_shori2($_, $i, $proto_prog_No, @main); }
			elsif(/^\s*G65/){
				$i= macro_G65($_, $i);
				modal_shori(4115, $proto_prog_No);
			}
			elsif(/^\s*G66/){ $i= macro_G66($_, $i, $proto_prog_No, @main); }
			elsif(/^\s*M98/){
				$i= sub_M98($_, $i);
				modal_shori(4115, $proto_prog_No);
			}
			else{
				$_= main_henkan($_);
				if(/(M30)/ or /(M0?2)[A-Z\s]/){
					print OUT $1."\n\%\n";
					last;
				}
				if(/M99/){
					print OUT;
					last;
				}
				extra_print($_);
			}

			if($i eq "M30" or $i eq "M02" or $i eq "M2" or $i eq "M99"){
				print OUT $i."\n\%\n";
				last;
			}
		}
	}
}

sub hikisuu_watashi{
	($_)= @_;
	my ($mode_J,$mode_K,$IJK);
	$IJK= 0;
	while(/([ABCDEFIJKHMQRSTUVWXYZ])([0-9\.\-]+)/g){
		($char,$num)= ($1,$2);
		if($char=~ /[ABCDEFHMQRSTUVWXYZ]/){
			$local_value[$macro_level][$c{$char}]= $num;
			if($debug_flag == 1){ print OUT '(---#'.$c{$char}.'= '.$num.'---)'."\n"; }
		}
		elsif($char =~ /I/){
			$IJK++;
			($mode_J,$mode_K)= (0,0);
			$local_value[$macro_level][3*$IJK+1]= $num;
			if($debug_flag == 1){ print OUT '(---#'.(3*$IJK+1).'= '.$num.'---)'."\n"; }
		}
		elsif($char =~ /J/){
			if($IJK == 0 or $mode_J == 1 or $mode_K == 1){
				$IJK++;
				$mode_K= 0;
			}
			$mode_J= 1;
			$local_value[$macro_level][3*$IJK+2]= $num;
			if($debug_flag == 1){ print OUT '(---#'.(3*$IJK+2).'= '.$num.'---)'."\n"; }
		}
		elsif($char =~ /K/){
			if($IJK == 0 or $mode_K == 1){
				$IJK++;
			}
			$mode_K= 1;
			$local_value[$macro_level][3*$IJK+3]= $num;
			if($debug_flag == 1){ print OUT '(---#'.(3*$IJK+3).'= '.$num.'---)'."\n"; }
		}
	}
}

sub hensuu_haki{
	my $i;
	for($i=1;$i<=33;$i++){
		undef($local_value[$macro_level][$i]);
	}
}

sub prog_yomikomi{
	my ($prog_No)= @_;
	my ($prog_file,@prog);
	my ($prog_flag1,$prog_flag2)= (0,0);
	my $i;

	for($i=0;$i<=$#main;$i++){
		$_= $main[$i];
		if(/^\s*O0*$prog_No/){ ($prog_flag1,$prog_flag2)= (1,1); }
		elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }

		if($prog_flag2 == 1){ push(@prog,$_); }
	}

	if($prog_flag1 == 0){
		for($i=0;$i<=$#present_prog;$i++){
			$_= $present_prog[$i];
			if(/^\s*O0*$prog_No/){ ($prog_flag1,$prog_flag2)= (1,1); }
			elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }

			if($prog_flag2 == 1){ push(@prog,$_); }
		}
	}

	if($prog_flag1 == 0){
		foreach(@macro_files2){
			if(/O0*$prog_No[^\d]/ and (/O0*$prog_No\s*\./ or /O0*$prog_No\s*\(.*?\)\s*\./)){
				$prog_file= $pre_folder.$_;
				last;
			}
		}

		if(! defined($prog_file)){
			foreach(@macro_files){
				if(/O0*$prog_No[^\d]/ and (/O0*$prog_No\s*\./ or /O0*$prog_No\s*\(.*?\)\s*\./)){
					$prog_file= $macro_folder.$_;
					last;
				}
			}
		}

		if(defined($prog_file)){
			undef(@present_prog);

			open (IN, $prog_file) or return;
			while(<IN>){
				push(@present_prog,$_);
			}
			close (IN);

			foreach(@present_prog){
				if(/^\s*O0*([\d]+)/){
					if($1 == $prog_No){ $prog_flag1= 1; }
					else{ $prog_flag2= 1; }
				}
			}

			if($prog_flag1 == 1){
				for($i=0;$i<=$#present_prog;$i++){
					$_= $present_prog[$i];
					if(/^\s*O0*$prog_No/){ $prog_flag2= 1; }
					elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }

					if($prog_flag2 == 1){ push(@prog,$_); }
				}
			}
			elsif($prog_flag2 == 0){ @prog= @present_prog; }
		}
	}

	return @prog;
}

sub macro_G65{
	my ($line,$gyou)= @_;
	my ($i,$j,$k,$macro_No,$kurikaeshi_suu,@macro);

	$line= main_henkan($line);
	if($line =~ /P0*([0-9]+)/){
		$macro_No= $1;
		if($line =~ /L([0-9]+)/){ $kurikaeshi_suu= $1; }
		else{ $kurikaeshi_suu= 1; }

		@macro= prog_yomikomi($macro_No);
		if(! @macro){
			print OUT $line;
			print OUT '(---O'.$macro_No.'が見つかりません---)'."\n";
			return $gyou;
		}

		$macro_level++;		
		$yobidashi_tajuudo++;
		if($macro_level == 5){
			print OUT '(---マクロ多重度が限度を超えました---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}
		if($yobidashi_tajuudo == 9){
			print OUT '(---呼び出し多重度が限度を超えました---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}

		print OUT '(---G65 start---)'."\n";

		for($j=1;$j<=$kurikaeshi_suu;$j++){
			print OUT '(---O'.$macro_No.' start---)'."\n";
			modal_shori(4115,$macro_No);
			hensuu_haki();
			hikisuu_watashi($line);
			for($i=0;$i<=$#macro;$i++){
				$_= $macro[$i];
			 	original_print($_);
				
				if(/^\s*\//){
					if($OBS_switch == 1){
					OBS_skip_print();
					next;
					}
					else{ $_= $'; }
				}

				if(!/^\s*\%/){
					if(/^\s*(O[0-9]+)/){ print OUT '('.$1.')'.$'; }
					else{
						if(/^\s*N0*([0-9]+)/){
							modal_shori(4114,$1);
							$_= $';
						}
						if(/\(/){ $_= kakko_print($_); }
						shikaku_kakko_kensa($_);

						if(/IF/){ $i= bunki_shori($_,$i,@macro); }
						elsif(/GOTO/){ $i= idou_shori($_,@macro); }
						elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$macro_No,@macro); }
						elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$macro_No,@macro); }
						elsif(/^\s*G65/){
							$i= macro_G65($_,$i);
							modal_shori(4115,$macro_No);
						}
						elsif(/^\s*G66/){ $i= macro_G66($_,$i,$macro_No,@macro); }
						elsif(/^\s*M98/){
							$i= sub_M98($_,$i);
							modal_shori(4115,$macro_No);
						}
						else{
							$_= main_henkan($_);

							if(/M99/){
								$_= $`.$';
								if(/[A-MO-Z]/){ extra_print($_); }
								print OUT '(---O'.$macro_No.' end---)'."\n";
								last;
							}
							elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
							else{ extra_print($_); }
						}

						if($i eq "M99"){
							print OUT '(---O'.$macro_No.' end---)'."\n";
							last;
						}
						elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
					}
				}
			}
		}
		$macro_level--;
		$yobidashi_tajuudo--;
		print OUT '(---G65 end---)'."\n";
		return $gyou;
	}

	else{
		print OUT $line;
		print OUT '(---プログラム番号が指定されていません---)'."\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
}

sub macro_G66{
	my ($line,$G66_start,$parent_prog_No,@prog)= @_;
	my ($i,$j,$macro_No,$G66_end,$G66_flag,$kurikaeshi_suu,$idou_sequence,@macro);

	$line= main_henkan($line);
	if($line =~ /P0*([0-9]+)/){
		$macro_No= $1;

		if($line =~ /L([0-9]+)/){ $kurikaeshi_suu= $1; }
		else{ $kurikaeshi_suu= 1; }

		$G66_flag= 1;
		for($i=$G66_start+1; $i<=$#prog; $i++){
			$_= $prog[$i];
			if(/^\s*N?[0-9]*\s*G66/){ $G66_flag++; }
			elsif(/^\s*N?[0-9]*\s*G67/){
				$G66_flag--;
				if($G66_flag == 0){
					$G66_end= $i;
					last;
				}
			}
		}

		if($prog[$i] !~ /\s*N?[0-9]*\s*G67/){
			print OUT "(---G67がありません---)\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}

		@macro= prog_yomikomi($macro_No);
		if(! @macro){
			for($i=$G66_start; $i<=$G66_end; $i++){
				$_= $prog[$i];
				print OUT;
			}
			print OUT '(---O'.$macro_No.'が見つかりません---)'."\n";
			return $G66_end;
		}

		print OUT '(---G66 modal mode --O'.$macro_No.'-- start---)'."\n";
		$G66_modal_tajuudo++;
		if($G66_modal_tajuudo == 1){ modal_shori(4012,66); }
		G66_modal_touroku($G66_modal_tajuudo,$line,$macro_No,$kurikaeshi_suu,@macro);

		# H30.11.8 呼び出し直前に変更
		#$macro_level++;
		#hensuu_haki();
		#hikisuu_watashi($line);
		#$macro_level--;

		# H30.03.27,28
		#G66_modal_yobidashi($G66_modal_tajuudo - $G66_yobidashi_tajuudo);

		for($i=$G66_start+1; $i<=$G66_end-1; $i++){
			$_= $prog[$i];
			original_print($_);

			if(/^\s*\//){
				if($OBS_switch == 1){
					OBS_skip_print();
					next;
				}
				else{ $_= $'; }
			}

			if(!/^\s*\%/){
				if(/^\s*N0*([0-9]+)/){
					modal_shori(4114,$1);
					$_= $';
				}
				if(/\(/){ $_= kakko_print($_); }
				shikaku_kakko_kensa($_);

				if(/IF/){ $i= bunki_shori($_,$i,@prog); }
				elsif(/GOTO/){ $i= idou_shori($_,@prog); }
				elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$parent_prog_No,@prog); }
				elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$parent_prog_No,@prog); }
				elsif(/^\s*N?[0-9]*\s*G65/){ 
					$i= macro_G65($_,$i);
					modal_shori(4115,$parent_prog_No);
				}
				elsif(/^\s*N?[0-9]*\s*G66/){
					$i= macro_G66($_,$i,$parent_prog_No,@prog);
				}
				elsif(/^\s*N?[0-9]*\s*M98/){
					$i= sub_M98($_,$i);
					modal_shori(4115,$parent_prog_No);
				}
				else{
					$_= main_henkan($_);

					if(/M99/){
						$_= $`.$';
						if(/[A-MO-Z]/){
							extra_print($_);
						}
						last;
					}
					elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
					else{ extra_print($_); }
				}

				if($i eq "M99"){
					print OUT '(---O'.$prog_No.' end---)'."\n";
					return $i;
				}
				elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
			}
		}
		print OUT '(---G66 modal mode --O'.$macro_No.'-- end---)'."\n";
		$G66_modal_tajuudo--;
		if($G66_modal_tajuudo == 0){ modal_shori(4012,67); }
		return $G66_end;
	}
	else{
		print OUT $line;
		print OUT '(---プログラム番号が指定されていません---)'."\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
}

sub G66_modal_touroku{
	my ($i,$line,$macro_No,$kurikaeshi_suu,@macro)= @_;

	$G66_line[$i]= $line;
	$G66_macro_No[$i]= $macro_No;
	$G66_kurikaeshi_suu[$i]= $kurikaeshi_suu; 
	$G66_macro[$i]= \@macro;
}

sub G66_modal_yobidashi{
	my ($t)= @_;
	my ($line,$macro_No,$kurikaeshi_suu)= ($G66_line[$t],$G66_macro_No[$t],$G66_kurikaeshi_suu[$t]);
	my @macro= @{$G66_macro[$t]};
	my ($i,$j,$parent_prog_No);
	
	$parent_prog_No= $value[4115];
	$G66_yobidashi_tajuudo++;

	print OUT '(---G66 modal --O'.$macro_No.'-- start---)'."\n";
	for($j=1;$j<=$kurikaeshi_suu;$j++){
		$macro_level++;
		$yobidashi_tajuudo++;
		if($macro_level == 5){
			print OUT '(---マクロ多重度が限度を超えました---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}
		if($yobidashi_tajuudo == 9){
			print OUT '(---呼び出し多重度が限度を超えました---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}

		print OUT '(---O'.$macro_No.' start---)'."\n";
		modal_shori(4115,$macro_No);

		# H30.11.8 コメントアウト解除
		hensuu_haki();
		hikisuu_watashi($line);

		for($i=0;$i<=$#macro;$i++){
			$_= $macro[$i];
			original_print($_);

			if(/^\s*\//){
				if($OBS_switch == 1){
					OBS_skip_print();
					next;
				}
				else{ $_= $'; }
			}

			if(!/^\s*\%/){
				if(/^\s*(O[0-9]+)/){ print OUT '('.$1.')'.$'; }
				else{
					if(/^\s*N0*([0-9]+)/){
						modal_shori(4114,$1);
						$_= $';
					}
					if(/\(/){ $_= kakko_print($_); }
					shikaku_kakko_kensa($_);

					if(/IF/){ $i= bunki_shori($_,$i,@macro); }
					elsif(/GOTO/){ $i= idou_shori($_,@macro); }
					elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$macro_No,@macro); }
					elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,@macro); }
					elsif(/^\s*G65/){
						$i= macro_G65($_,$i);
						modal_shori(4115,$macro_No);
					}
					elsif(/^\s*G66/){ $i= macro_G66($_,$i,$macro_No,@macro); }
					elsif(/^\s*M98/){
						$i= sub_M98($_,$i);
						modal_shori(4115,$macro_No);
					}
					else{
						$_= main_henkan($_);
						if(/M99/){
							$_= $`.$';
							if(/[A-MO-Z]/){ extra_print($_); }
							print OUT '(---O'.$macro_No.' end---)'."\n";
							last;
						}
						elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
						else{ extra_print($_); }
					}

					if($i eq "M99"){
						print OUT '(---O'.$macro_No.' end---)'."\n";
						last;
					}
					elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
				}
			}
		}
		$macro_level--;
		$yobidashi_tajuudo--;
	}
	print OUT '(---G66 modal --O'.$macro_No.'-- end---)'."\n";
	$G66_yobidashi_tajuudo--;
	modal_shori(4115,$parent_prog_No);
}

sub sub_M98{
	my ($line,$gyou)= @_;
	my ($i,$j,$k,$kurikaeshi_suu,$prog_No,$jikkou_bun,$comment,@sub);

	$_= main_henkan($line);
	if(/M98\s*P([0-9]+)\s*/){
		$jikkou_bun= $`.$';
		if($M98_houshiki == 0){
			$prog_No= $1;

			if($jikkou_bun =~ /L([0-9]+)/){
				$jikkou_bun= $`.$';
				$kurikaeshi_suu= $1;
			}
			else{ $kurikaeshi_suu= 1; }
		}
		else{
			if(length($1) <= 4){
				$prog_No= $1;
				if($jikkou_bun =~ /L([0-9]+)/){
					$jikkou_bun= $`.$';
					$kurikaeshi_suu= $1;
				}
				else{ $kurikaeshi_suu= 1; }
			}
			else{
				$under_line= $1;
				if($under_line =~ /(.+)(.{4})$/){
					$kurikaeshi_suu= $1;
					$prog_No= $2;
				}
			}
		}

		$prog_No =~ s/^0+//;
		if($jikkou_bun =~ /[A-KMO-Z]/){
			$jikkou_bun= main_henkan($jikkou_bun);
			extra_print($jikkou_bun);
		}

		@sub= prog_yomikomi($prog_No);
		if(! @sub){
			print OUT $line;
			print OUT '(---O'.$prog_No.'が見つかりません---)'."\n";
			return $gyou;
		}

		$yobidashi_tajuudo++;
		if($yobidashi_tajuudo == 9){
			print OUT '(---呼び出し多重度が限度を超えました---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}

		print OUT '(---M98 start---)'."\n";
		for($j=1;$j<=$kurikaeshi_suu;$j++){;
			print OUT '(---O'.$prog_No.' start---)'."\n";
			modal_shori(4115,$prog_No);
			for($i=0;$i<=$#sub;$i++){
				$_= $sub[$i];
				original_print($_);

				if(/^\s*\//){
					if($OBS_switch == 1){
						OBS_skip_print();
						next;
					}
					else{ $_= $'; }
				}

				if(!/^\s*\%/){
					if(/^\s*(O[0-9]+)/){ print OUT '('.$1.')'.$'; }
					else{
						if(/^\s*N0*([0-9]+)/){
							modal_shori(4114,$1);
							$_= $';
						}
						if(/\(/){ $_= kakko_print($_); }
						shikaku_kakko_kensa($_);

						if(/IF/){ $i= bunki_shori($_,$i,@sub); }
						elsif(/GOTO/){ $i= idou_shori($_,@sub); }
						elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$prog_No,@sub); }
						elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$prog_No,@sub); }
						elsif(/^\s*G65/){
							$i= macro_G65($_,$i);
							modal_shori(4115,$prog_No);
						}
						elsif(/^\s*G66/){ $i= macro_G66($_,$i,$prog_No,@sub); }
						elsif(/^\s*M98/){
							$i= sub_M98($_,$i);
							modal_shori(4115,$prog_No);
						}
						else{
							$_= main_henkan($_);
							if(/M99/){
								$_= $`.$';
								if(/[A-MO-Z]/){ extra_print($_); }
								print OUT '(---O'.$prog_No.' end---)'."\n";
								last;
							}
							elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
							else{ extra_print($_); }
						}

						if($i eq "M99"){
							print OUT '(---O'.$prog_No.' end---)'."\n";
							last;
						}
						elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
					}
				}
			}
		}
		print OUT '(---M98 end---)'."\n";
		$yobidashi_tajuudo--;
		return $gyou;
	}
	else{
		print OUT $line;
		print OUT '(---プログラム番号が指定されていません---)'."\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
}

sub idou_shori{
	my ($line,@prog)= @_;
	my ($i,$idou_sequence);
	
	$_= main_henkan($line);
	if(/GOTO\s*0*([0-9]+)/){
		$idou_sequence= $1;
		$GOTO_count++;
		if($GOTO_count > $GOTO_exe_max){
			print OUT "(---GOTO文の実行回数が上限値$GOTO_exe_maxを超えたので、処理を中止しました。---)";
			close(OUT);
			exit;
		}
		
		for($i=0;$i<=$#prog;$i++){
			if($prog[$i] =~ /^\s*N0*([0-9]+)/){
				if($1 == $idou_sequence){
					if($debug_flag == 1){ print OUT '(---move to N' . $idou_sequence .'---)'."\n"; }
					return ($i - 1);
				}
			}
		}
		
		print OUT '(---N'.$idou_sequence.'がありません---)'."\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
	else{
		print OUT '(---GOTO構文が正しくありません---)'."\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
}

sub bunki_shori{
	my ($line,$gyou,@prog)= @_;
	my ($joukenshiki,$jikkoubun,$flag);
	
	$_= $line;
	if(/IF\s*\[\s*(.+)\s*\]\s*(GOTO\s*)/){
		($joukenshiki,$jikkoubun)= ($1,$2.$');
		$flag= jouken_handan($joukenshiki);
		if($flag == 1){
			if($debug_flag == 1){ print OUT '(---true---)'."\n"; }
			$gyou= idou_shori($jikkoubun,@prog);
			return $gyou;
		}
		else{
			if($debug_flag == 1){ print OUT '(---false---)'."\n"; }
			return $gyou;
		}
	}
	elsif(/IF\s*\[\s*(.+)\s*\]\s*THEN\s*/){
		($joukenshiki,$jikkoubun)= ($1,$');
		$flag= jouken_handan($joukenshiki);
		if($flag == 1){
			if($debug_flag == 1){ print OUT '(---true---)'."\n"; }
			$_= main_henkan($jikkoubun);
			if(/M99/){
				$_= $`.$';
				if(/[A-Z]/){ extra_print($_); }
				return "M99";
			}
			elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
			else{ extra_print($_); }
			return $gyou;
		}
		else{
			if($debug_flag == 1){ print OUT '(---false---)'."\n"; }
			return $gyou;
		}
	}
	else{
		print OUT '(---IF構文が正しくありません---)'."\n";
		return $gyou;
	}
}

sub kurikaeshi_shori{
	my ($line, $while_start, $parent_prog_No, @prog)= @_;
	my ($i, $while_end, $joukenshiki, $shikibetsu_bangou);

	$_= $line;
	if(/WHILE\s*\[\s*(.+)\s*\]\s*DO\s*([123])/){
		($joukenshiki, $shikibetsu_bangou)= ($1, $2);

		for($i=$while_start+1; $i<=$#prog; $i++){
			$_= $prog[$i];
			if(/^\s*N?[0-9]*\s*END\s*$shikibetsu_bangou/){
				$while_end= $i;
				last;
			}
		}
		if(! defined($while_end)){
			print OUT '(---END'.$shikibetsu_bangou.'がありません---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}
		
		my $loopCount= 0;
		for(;;){
			$loopCount++;
			$flag= jouken_handan($joukenshiki);

			if($flag == 0){
				if($debug_flag == 1){ print OUT '(---DO'.$shikibetsu_bangou.' false---)'."\n"; }
				return $while_end;
			}
			if($debug_flag == 1){ print OUT '(---DO'.$shikibetsu_bangou.' true---)'."\n"; }
			for($i=$while_start+1;$i<=$while_end-1;$i++){
				$_= $prog[$i];
				original_print($_);

				if(/^\s*\//){
					if($OBS_switch == 1){
						OBS_skip_print();
						next;
					}
					else{ $_= $'; }
				}

				if(/^\s*N0*([0-9]+)/){
					modal_shori(4114,$1);
					$_= $';
				}
				if(/\(/){ $_= kakko_print($_); }
				shikaku_kakko_kensa($_);

				if(/IF/){ $i= bunki_shori($_, $i, @prog); }
				elsif(/GOTO/){ $i= idou_shori($_, @prog); }
				elsif(/WHILE/){ $i= kurikaeshi_shori($_, $i, $parent_prog_No, @prog); }
				elsif(/DO/){ $i= kurikaeshi_shori2($_, $i, $parent_prog_No, @prog); }
				elsif(/^\s*G65/){
					$i= macro_G65($_, $i);
					modal_shori(4115, $parent_prog_No);
				}
				elsif(/^\s*N?[0-9]*\s*G66/){ $i= macro_G66($_, $i, $parent_prog_No, @prog); }
				elsif(/^\s*N?[0-9]*\s*M98/){
					$i= sub_M98($_, $i);
					modal_shori(4115,$parent_prog_No);
				}
				else{
					$_= main_henkan($_);
					if(/M99/){
						$_= $`.$';
						if(/[A-Z]/){ extra_print($_); }
						return "M99";
					}
					elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
					else{ extra_print($_); }
				}
				#2018.02.23
				#if($i > $while_end){ return $i; }
				if( $i < $while_start or $i >= $while_end){ return $i; }
				elsif($i eq "M99" or $i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
			}
			#無限ループ対策
			if($loopCount > $loop_max){
				print OUT "(---ループ回数が上限数$loop_maxを超えたので、処理を中止しました。---)\n";
				close(OUT);
				exit;
			}
		}
	}
	else{
		print OUT '(---WHILE構文が正しくありません---)'."\n";
		return $while_start;
	}
}

sub jouken_handan{
	($line)= @_;
	my ($pre_line,$post_line,$pre_pre_line,$post_post_line,$copy_pre_line,$reverse_post_line);
	my ($sahen,$jouken,$uhen,$flag);
	my ($hiraki_kakko,$toji_kakko,$length,$char,$i);

	if($line =~ /(==|=|<>|<=|>=|>|<)/){
		print OUT "(---条件式に $1 は使えません。---)\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
	
	$line= '['.$line.']';
	while($line =~ /\s*(EQ)\s*/ or $line =~ /\s*(NE)\s*/ or $line =~ /\s*(GT)\s*/ or $line =~ /\s*(LT)\s*/ or $line =~ /\s*(GE)\s*/ or $line =~ /\s*(LE)\s*/){
		$jouken= $1;
		($pre_line,$copy_pre_line,$post_line)= ($`,$`,$');
		$reverse_post_line= reverse($post_line);
		($hiraki_kakko,$toji_kakko)= (0,0);

		$length= length($pre_line);
		for($i=1;$i<=$length;$i++){
			$char= chop($copy_pre_line);
			if($char eq '['){ $hiraki_kakko++; }
			if($char eq ']'){ $hiraki_kakko--; }
			if($hiraki_kakko == 1){
				$sahen= substr($pre_line,-$i);
				$pre_pre_line= substr($pre_line,0,-$i);
				last;
			}
		}

		$length= length($post_line);
		for($i=1;$i<=$length;$i++){
			$char= chop($reverse_post_line);
			if($char eq ']'){ $toji_kakko++; }
			if($char eq '['){ $toji_kakko--; }
			if($toji_kakko == 1){ 
				$uhen= substr($post_line,0,$i);
				$post_post_line= substr($post_line,$i);
				last;
			}
		}
		$flag= kobetsu_jouken_handan($sahen,$jouken,$uhen);
		$line= $pre_pre_line.$flag.$post_post_line;
	}
	
	$line= main_henkan_NoCheck($line);
	
	#$line= main_henkan($line);
	return $line;
}

sub kobetsu_jouken_handan{
	my ($sahen,$jouken,$uhen)= @_;
	my ($flag);

	$sahen= substr($sahen,1);
	$uhen= substr($uhen,0,-1);

	if($uhen =~ /^\s*\#[0\.]+\s*$/ and $sahen =~ /^\s*\#([0-9\.]+)\s*$/){
		if($jouken eq "EQ" or $jouken eq "NE"){
			$flag = compare_null($1,$jouken);
			return $flag;
		}
	}
	
	$sahen= joukennai_henkan($sahen,$jouken);
	$uhen= joukennai_henkan($uhen,$jouken);

	if($jouken eq "EQ"){
		if($sahen eq '(undefined)'){
			if($uhen eq '(undefined)'){ $flag= 1; }
			else{ $flag= 0; }
		}
		elsif($uhen eq '(undefined)'){ $flag= 0; }
		elsif($sahen == $uhen){ $flag= 1; }
		else{ $flag= 0; }
	}
	elsif($jouken eq "NE"){
		if($sahen eq '(undefined)'){
			if($uhen ne '(undefined)'){ $flag= 1; }
			else{ $flag= 0; }
		}
		elsif($uhen eq '(undefined)'){ $flag= 1; }
		elsif($sahen != $uhen){ $flag= 1; }
		else{ $flag= 0; }
	}
	elsif($jouken eq "GT"){
		if($sahen > $uhen){ $flag= 1; }
		else{ $flag= 0; }
	}
	elsif($jouken eq "LT"){
		if($sahen < $uhen){ $flag= 1; }
		else{ $flag= 0; }
	}
	elsif($jouken eq "GE"){
		if($sahen >= $uhen){ $flag= 1; }
		else{ $flag= 0; }
	}
	elsif($jouken eq "LE"){
		if($sahen <= $uhen){ $flag= 1; }
		else{ $flag= 0; }
	}
	return $flag;
}

sub compare_null{
	my ($hensuu_No,$jouken)= @_;
	my ($flag);
	
	$flag = 0;
	
	if($jouken eq "EQ"){
		if($hensuu_No <= 33){
			if(! defined($local_value[$macro_level][$hensuu_No])){ $flag= 1; }
		}
		else{
			if(! defined($value[$1])){ $flag= 1; }
		}
	}
	elsif($jouken eq "NE"){
		if($hensuu_No <= 33){
			if(defined($local_value[$macro_level][$hensuu_No])){ $flag= 1; }
		}
		else{
			if(defined($value[$1])){ $flag= 1; }
		}
	}	
	return $flag;
}

#2019.09.09 main_henkan_NoCheckを追加
#2020.03.30 main_henkan_NoCheckを削除
#2020.04.16 main_henkan_NoCheckを追加
sub joukennai_henkan{
	($_,$jouken)= @_;

	##
	$_= main_henkan_NoCheck($_);
	while(/\#[0-9\.]+/){
		($pre_line,$post_line)= ($`,$');
		if($jouken eq "EQ" or $jouken eq "NE"){
			if(/^\s*\#([0-9\.]+)\s*$/){
				if($1 <= 33){
					if(! defined($local_value[$macro_level][$1])){ $_= '(undefined)'; }
					else{ $_= $pre_line.$local_value[$macro_level][$1].$post_line; }
				}
				else{
					if(! defined($value[$1])){ $_= '(undefined)'; }
					else{ $_= $pre_line.$value[$1].$post_line; }
				}
			}
			else{
				$_= $pre_line."0".$post_line;
				
				##
				$_= main_henkan_NoCheck($_);
			}
		}
		else{
			$_= $pre_line."0".$post_line;
			##
			$_= main_henkan_NoCheck($_);
		}
	}
	
	return $_;
}

sub kurikaeshi_shori2{
	my ($line,$do_start,$parent_prog_No,@prog)= @_;
	my ($i,$do_end,$joukenshiki,$shikibetsu_bangou);
	
	$_= $line;
	if(/DO\s*([123])/){
		$shikibetsu_bangou= $1;

		for($i=$do_start+1;$i<=$#prog;$i++){
			$_= $prog[$i];
			if(/^\s*N?[0-9]*\s*END\s*$shikibetsu_bangou/){
				$do_end= $i;
				last;
			}
		}
		if(! defined($do_end)){
			print OUT '(---END'.$shikibetsu_bangou.'がありません---)'."\n";
			print OUT "(---処理を中止しました---)\n";
			close(OUT);
			exit;
		}

		my $loopCount= 0;
		for(;;){
			$loopCount++;
			for($i=$do_start+1;$i<=$do_end-1;$i++){
				$_= $prog[$i];
				original_print($_);

				if(/^\s*\//){
					if($OBS_switch == 1){
						OBS_skip_print();
						next;
					}
					else{ $_= $'; }
				}

				if(/^\s*N0*([0-9]+)/){
					modal_shori(4114,$1);
					$_= $';
				}
				if(/\(/){ $_= kakko_print($_); }
				shikaku_kakko_kensa($_);

				if(/IF/){ $i= bunki_shori($_,$i,@prog); }
				elsif(/GOTO/){ $i = idou_shori($_,@prog); }
				elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$parent_prog_No,@prog); }
				elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$parent_prog_No,@prog); }
				elsif(/^\s*G65/){
					$i= macro_G65($_,$i);
					modal_shori(4115,$parent_prog_No);
				}
				elsif(/^\s*G66/){ $i= macro_G66($_,$i,$parent_prog_No,@prog); }
				elsif(/^\s*M98/){
					$i= sub_M98($_,$i);
					modal_shori(4115,$parent_prog_No);
				}
				else{
					$_= main_henkan($_);

					if(/M99/){
						$_= $`.$';
						if(/[A-Z]/){ extra_print($_); }
						return "M99";
					}
					elsif(/(M30)/ or /(M0?2)[A-Z\s]/){ return $1; }
					else{ extra_print($_); }
				}

				#2018.02.23
				#if($i > $do_end){ return $i; }
				if($i < $do_start or $i >= $do_end){ return $i; }
				elsif($i eq "M99" or $i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
			}
			#無限ループ対策
			if($loopCount > $loop_max){
				print OUT "(---ループ回数が上限数$loop_maxを超えたので、処理を中止しました。---)\n";
				close(OUT);
				exit;
			}
		}
	}
	else{ return $do_start; }
}

sub main_henkan{
	($_)= @_;
	my $i;
	
	if($break_flag == 1){
		$_ = bunpouCheck($_);
	}
	
	for($i=1;$i<=6;$i++){
		$_= hensuu_henkan($_);
		$_= shisoku_enzan($_);
		$_= kansuu_henkan($_);
		$_= kakko_jokyo($_);
		$_= bit_enzan($_);
	}
	$_= toushiki_shori($_);
	$_= miteigi_shori($_);
	return $_;
}

sub main_henkan_NoCheck{
	($_)= @_;
	my $i;
	
	for($i=1;$i<=6;$i++){
		$_= hensuu_henkan($_);
		$_= shisoku_enzan($_);
		$_= kansuu_henkan($_);
		$_= kakko_jokyo($_);
		$_= bit_enzan($_);
	}
	$_= toushiki_shori($_);
	$_= miteigi_shori($_);
	
	return $_;
}

sub bunpouCheck{
	my ($line) = @_;
	
	my $errMsg = "";
	$_ = $line;
	#2019.05.23 文法チェックを強化
	#アドレス直後の数字に対して四則演算 X-10.0 - 20.0 , X-10.0 + #1 , X-10.0 + [ , X-10.0 + COS[180]
	while(/(?<![A-Z])([A-Z])\-?(\d+\.?\d*|\.\d+)\s*[\+\-\*\/]\s*([\d\.\#\[]|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR)/g){
		$errMsg .= "(// アドレス$1直後の計算式を[ ]で囲んでください。 //)\n";
	}
	
	#アドレス直後の数字に対して四則演算 X#1 + 10.0
	while(/(?<![A-Z])([A-Z])\#\d+\.?\d*\s*[\+\-\*\/]\s*([\d\.\#\[]|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR)/g){
		$errMsg .= "(// アドレス$1直後の計算式を[ ]で囲んでください。 //)\n";
	}
	
	#アドレスの直前にマイナス -X10.0
	while(/\-\s*([A-Z])\-?\d+\.?\d*/g){
		$errMsg .= "(// アドレス$1の直前にマイナスがあります。文法ミスです。 //)\n";
	}
	
	#アドレス直後に関数 X ACOS[ ]  X-SIN[ ] 
	#while(/(?<![A-Z])([A-Z])\s*\-?\s*((ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR))/g){
	#while(/(?<![A-Z])(([A-Z])\s*\-?\s*((ABS|SQRT|SQR|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR))|([B-Z])\s*\-?\s*((SIN|COS|TAN))|[A-WY-Z](XOR))/g){
	while(/(?<![A-Z])([A-Z])\s*\-?\s*(ABS|SQRT|SQR|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/g){
		$errMsg .= "(// アドレス$1直後の関数$2を[ ]で囲んでください。 //)\n";
	}
	#アドレス直後に関数  XCOS[ ]  X-SIN[ ] (A以外)
	while(/(?<![A-Z])([B-Z])\s*\-?\s*(SIN|COS|TAN)/g){
		$errMsg .= "(// アドレス$1直後の関数$2を[ ]で囲んでください。 //)\n";
	}
	
	#アドレス直後に AND XOR
	while(/(?<![A-Z])([A-Z])\s*\-?\s*(AND|XOR)/g){
		$errMsg .= "(// アドレス$1直後に$2があります。 //)\n";
	}	
	#アドレス直後にOR (X以外) YOR   
	while(/(?<![A-Z])([A-WY-Z])\s*\-?\s*(OR)/g){
		$errMsg .= "(// アドレス$1直後に$2があります。 //)\n";
	}
	
	#アドレスに数値なし XY10.0
	my $tmp= $_;
	s/(IF|WHILE|DO\s*\d*|END\s*\d*|GOTO\s*\d*|(EQ|NE|GT|LT|GE|LE)\s*\-?\d*\.*\d*|(ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR))//g;
	while(/(?<![A-Z])([A-Z])[A-Z\s]/g){ 
		$errMsg .= "(// アドレス$1に数値がありません。 //)\n";
	}
	$_= $tmp;
	
	#関数の後に [ なし
	while(/(?<![A-Z])((IF|WHILE|ABS|SQRT|SQR(?!T)|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR))(?!\s*\[)/g){
		$errMsg .= "(// $1の直後に [ が必要です。 //)\n";
	}
	
	#数値のみのブロック
	if(/^[\d\.]+\s*$/){
		$errMsg .= "(// 数値のみです。(アドレスがありません。) //)\n";
	}
	#数値のみのブロック
	if(/^(ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		$errMsg .= "(// 関数の前にアドレスが必要です。 //)\n";
	}
	#数値の直後に関数や#1、[など
	if(/(\-?[\d\.]+)\s*(\[|\#|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		$errMsg .= "(// 数値$1の直後に $2 があります。アドレスか演算子が必要です。 //)\n";
	}
	# ]の直後に数値や関数など
	if(/\]\s*([\d\.]+|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		$errMsg .= "(// ] の直後に$1があります。アドレスか演算子が必要です。 //)\n";
	}
	# [の直前に数値
	if(/(\-?[\d\.]+)\s*\[/){
		$errMsg .= "(// 数値$1の直後に [ があります。アドレスか演算子が必要です。 //)\n";
	}
	
	if ($errMsg ne ""){
		#if($debug_flag == 0){
			s/\s*$//;
			print OUT '(// '.$_.' //)'."\n";
		#}
		print OUT $errMsg;
		print OUT "(// 文法エラーを検出したので処理を中止しました //)\n";
		close(OUT);
		exit;
	}
	return $line;
}

sub hensuu_henkan{
	($line)= @_;
	my $new_line= "";

	if($line =~ /\s*\=\s*/){
		$new_line= $`.$&;
		$line= $';
	}
	while($line =~ /\#([0-9]+)/){
		($pre_line, $apply_line, $line, $hensuu_No)= ($`, $&, $', $1);
		$new_line= $new_line.$pre_line;
		if($pre_line =~ /.$/){ $last_char= $&; }
		else{ $last_char= ''; }

		if($hensuu_No <= 33){
			if(defined($local_value[$macro_level][$hensuu_No])){
				if($last_char =~ /[GMSTPDH]/){ 
					$new_line= $new_line.round($local_value[$macro_level][$hensuu_No]);
				}
				else{
					$new_line= $new_line.$local_value[$macro_level][$hensuu_No];
				}
			}
			else{ $new_line= $new_line.$apply_line; }
		}
		else{
			if(defined($value[$hensuu_No])){
				if($last_char =~ /[GMSTPDH]/){
					$new_line= $new_line.round($value[$hensuu_No]);
				}
				else{
					$new_line= $new_line.$value[$hensuu_No];
				}
			}
			else{ $new_line= $new_line.$apply_line; }
		}
		
	}
	$new_line= $new_line.$line;
	
	return $new_line;
}

sub shisoku_enzan{
	($_)= @_;
	my $jozan_flag,$fugou;
	
	while(/\#\s*(\-?)\s*\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`."\#".$1.$2.$'; }
	while(/\-\s*\-/g){
		($pre_line,$post_line)= ($`,$');
		if($pre_line =~ /[0-9\.\]]\s*$/){ $_= $pre_line."\+".$post_line; }
		else{ $_= $pre_line.$post_line; }
	}
#	while(/(\-?[0-9\.]+)\s*\*\s*(\-?[0-9\.]+)/g){
#	20200416
	while(/(?<!\#)([0-9\.]+)\s*\*\s*(\-?[0-9\.]+)/g){
	#while(/([0-9\.]+)\s*\*\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$num2)= ($`,$',$1,$2);
		if($pre_line =~ /\/\s*$/){ $jozan_flag= 1; }
		elsif($pre_line !~ /\#\-?$/){ $_= $pre_line.naibu_marume($num1*$num2).$post_line; }
	}
#	while(/(\-?[0-9\.]+)\s*\/\s*(\-?[0-9\.]+)/g){
#	20200416
	while(/(?<!\#)([0-9\.]+)\s*\/\s*(\-?[0-9\.]+)/g){
#	while(/([0-9\.]+)\s*\/\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$num2)= ($`,$',$1,$2);
		if($pre_line !~ /\#\-?$/){ $_= $pre_line.naibu_marume($num1/$num2).$post_line; }
	}
	if($jozan_flag == 1){
		while(/([0-9\.]+)\s*\*\s*(\-?[0-9\.]+)/g){
			($pre_line,$post_line,$num1,$num2)= ($`,$',$1,$2);
			if($pre_line !~ /\#\-?$/ and $pre_line !~ /\/\s*$/){ $_= $pre_line.naibu_marume($num1*$num2).$post_line; }
		}
	}
#	while(/((\-?)[0-9\.]+)\s*\-\s*(\-?[0-9\.]+)/g){
#		($pre_line,$post_line,$num1,$num2)= ($`,$',$1,$2);
#		if($pre_line !~ /\#$/ and $post_line !~ /^\s*[\*\/]/){ $_= $pre_line.kagenzan($num1,$num2,'-').$post_line; }
#	}
#	while(/(\-?[0-9\.]+)\s*\+\s*(\-?[0-9\.]+)/g){
#		($pre_line,$post_line,$num1,$num2)= ($`,$',$1,$2);
#		if($pre_line !~ /\#$/ and $post_line !~ /^\s*[\*\/]/){ $_= $pre_line.kagenzan($num1,$num2).$post_line; }
#	}

	while(/((\-?)[0-9\.]+)\s*\+\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$fugou,$num2)= ($`,$',$1,$2,$3);
		#2018.05.30
		if($fugou eq '-' and $pre_line =~ /[\d\.\]]\s*$/){ $fugou = '+'; }
		else{ $fugou = ''; }
		if($pre_line !~ /\#$/ and $post_line !~ /^\s*[\*\/]/){ $_= $pre_line.$fugou.kagenzan($num1,$num2).$post_line; }
	}
	while(/((\-?)[0-9\.]+)\s*\-\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$fugou,$num2)= ($`,$',$1,$2,$3);
		#2018.05.30
		if($fugou eq '-' and $pre_line =~ /[\d\.\]]\s*$/){ $fugou = '+'; }
		else{ $fugou = ''; }
		if($pre_line !~ /\#$/ and $post_line !~ /^\s*[\*\/]/){ $_= $pre_line.$fugou.kagenzan($num1,$num2,'-').$post_line; }
	}

	while(/\+\-/g){
		$_ = $`.'-'.$';
	}
	
	return $_;
}

sub kansuu_henkan{
	($_)= @_;
	while(/ABS\[\s*\-?([0-9\.]+)\s*\]/g){ $_= $`.naibu_marume($1).$'; }
	while(/(SQRT|SQR)\[\s*([0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(sqrt($2)).$'; }
	while(/ASIN\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(asin($1)*$RAD).$'; }
	while(/SIN\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(sin($1/$RAD)).$'; }
	while(/ACOS\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(acos($1)*$RAD).$'; }
	while(/COS\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(cos($1/$RAD)).$'; }
	while(/(ATAN|ATN)\[\s*(\-?[0-9\.]+)\s*\]\/\[\s*(\-?[0-9\.]+)\s*\]/g){
		$_= $`.naibu_marume(atan2($2,$3)*$RAD).$';
	}
	while(/(ATAN|ATN)\[\s*(\-?[0-9\.]+)\s*\,\s*(\-?[0-9\.]+)\s*\]/g){
		$_= $`.naibu_marume(atan2($2,$3)*$RAD).$';
	}
	while(/(ATAN|ATN)\[\s*(\-?[0-9\.]+)\s*\]/g){
		$_= $`.naibu_marume(atan($2)*$RAD).$';
	}
	while(/TAN\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(sin($1/$RAD)/cos($1/$RAD)).$'; }
	while(/(ROUND|RND)\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(round($2)).$'; }
	while(/FUP\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(fup($1)).$'; }
	while(/FIX\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(int($1)).$'; }
	while(/BCD\[\s*(\[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(bcd_shori($1)).$'; }
	while(/BIN\[\s*(\[0-9\.]+)\s*\]/g){ $_= $`.naibu_marume(bin_shori($1)).$'; }
	return $_;
}

sub kakko_jokyo{
	($_)= @_;
	my ($line,$new_line)= ($_,"");
	while($line =~ /(\-?)\s*\[\s*(\-?[0-9\.]+)\s*\]/){
		($_,$num1,$num2,$line)= ($`,$1,$2,$');
		$apply_line= $&;
		$new_line= $new_line.$_;
		if(/.$/){ $char= $&; }
		if(!/SIN$/ and !/COS$/ and !/TAN$/ and !/(ATAN|ATN)\[\s*\-?[0-9\.]+\s*\]\/$/ and !/(ATAN|ATN)\[\s*\-?[0-9\.]+\s*\,\s*\-?[0-9\.]+\s*\]$/ and !/ABS$/ and !/(SQRT|SQR)$/ and !/(ROUND|RND)$/ and !/FIX$/ and !/FUP$/ and !/BCD$/ and !/BIN$/){
			if($char =~ /[GMSTPDH]/){
				if($num1 =~ /\-/){
					if($num2 =~ /^\-(.+)/){ $new_line= $new_line.round($1); }
					else{ $new_line= $new_line.round($num2); }
				}
				else{ $new_line= $new_line.round($num2); }
			}
			else{ $new_line= $new_line.$num1.$num2; }
		}
		else{ $new_line= $new_line.$apply_line; }
	}
	$new_line= $new_line.$line;
	return $new_line;
}

sub bit_enzan{
	($_)= @_;
	while(/(.?)\s*([0-9\.]+)\s*AND\s*([0-9\.]+)/g){
		if($1 ne '#'){ $_= $`.$1.naibu_marume(and_shori($2,$3)).$'; }
	}
	while(/(.?)\s*([0-9\.]+)\s*OR\s*([0-9\.]+)/g){
		if($1 ne '#'){ $_= $`.$1.naibu_marume(or_shori($2,$3)).$'; }
	}
	while(/(.?)\s*([0-9\.]+)\s*XOR\s*([0-9\.]+)/g){
		if($1 ne '#'){ $_= $`.$1.naibu_marume(xor_shori($2,$3)).$'; }
	}
	return $_;
}

sub toushiki_shori{
	($_)= @_;
	my ($hensuu_No1,$hensuu_No2,$uhen);
	if(/^\s*N?[0-9]*\s*\#([0-9\.]+)\s*\=\s*/){
		($hensuu_No1,$uhen)= ($1,$');
		
		if($uhen =~ /^\s*(\-?[0-9\.]+)\s*$/){
		#if($uhen =~ /^\s*\+?(\-?[0-9\.]+)\s*$/){
			if($hensuu_No1 <= 33){
				$local_value[$macro_level][$hensuu_No1]= $1;
				if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= '.$1.'---)'."\n"; }
			}
			else{
				if($hensuu_No1 == 3000){
					$alerm_No= 3000+$1;
					print OUT '(---アラーム番号 '.$alerm_No.'---)'."\n";
					print OUT "(---処理を中止しました---)\n";
					close(OUT);
					exit;
				}
				else{
					$value[$hensuu_No1]= $1;
					if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= '.$1.'---)'."\n"; }
				}
			}
			$_= "";
		}
		elsif($uhen =~ /^\s*\#([0-9\.]+)\s*$/){
			$hensuu_No2 = $1;
			if($hensuu_No2 <= 33){
				if(! defined($local_value[$macro_level][$hensuu_No2])){
					if($hensuu_No1 <= 33){
						undef($local_value[$macro_level][$hensuu_No1]);
						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
					else{
						undef($value[$hensuu_No1]);
						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
				}
			}
			else{
				if(! defined($value[$hensuu_No2])){
					if($hensuu_No1 <= 33){
						undef($local_value[$macro_level][$hensuu_No1]);
						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
					else{
						undef($value[$hensuu_No1]);
						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
				}
			}
			($_,$uhen)= ("","");
		}
		else{
			while($uhen =~ /\#([0-9\.]+)/g){
				($pre_line, $hensuu_No2, $post_line)= ($`, $1, $');
				$uhen= $pre_line.'0'.$post_line;
			}
			$_= "\#".$hensuu_No1."\=".$uhen;
			$_= main_henkan($_);
		}
	}
	return $_;
}

sub miteigi_shori{
	($_)= @_;
	my $new_line= "";

#2018.02.20 $es追加
#	while(/[A-Z]\#([0-9\.]+)\s*([A-Z]?)/){
#		($pre_line, $post_line, $hensuu_No, $last_char)= ($`, $', $1, $2);
	while(/[A-Z]\#([0-9\.]+)(\s*)([A-Z]?)/){
		($pre_line, $post_line, $hensuu_No, $es, $last_char)= ($`, $', $1, $2, $3);

		if($hensuu_No <= 33){
			if(! defined($local_value[$macro_level][$hensuu_No])){
				$_= $pre_line.$last_char.$post_line;
			}
		}
		else{
			if(! defined($value[$hensuu_No])){
				$_= $pre_line.$last_char.$post_line;
			}
		}
#
		if($post_line eq ''){ $_ .= $es; }
	}

	if(/\#([0-9\.]+)/){
		while(/\#([0-9\.]+)/){
			($pre_line, $post_line, $hensuu_No)= ($`, $', $1);
			$_= $pre_line. '0'. $post_line;
		}
		$_= main_henkan($_);
	}

	return $_;
}

sub kagenzan{
	my ($num1,$num2,$enzanshi)= @_;
	my $num;
	$num1= naibu_marume($num1);
	$num2= naibu_marume($num2);
	if($enzanshi eq '-'){ $num= $num1 - $num2; }
	else{ $num= $num1 + $num2; }
	#if($num !~ /\./ and $num != 0){ $num= $num.'.'; }
	return $num;
}

sub modal_shori{
	my ($No,$num)= @_;
	$value[$No]= $num;
	$value[$No+200]= $num;
	if($modal_flag == 1){ print OUT '(----#'.$No.'= '.$num.'----)'."\n"; }
}

#sub original_print{
#	my ($line)= @_;
#	$line =~ s/\s*$//;
#	if($line ne ""){
#		if($debug_flag == 1){ print OUT '(^^ '.$line.' ^^)'."\n"; }
#	}
#}

sub original_print{
	($_)= @_;
	my $original= $_;

	$_ =~ s/\s*$//;
	if($_ ne "" and $debug_flag == 1){
		if( (!/^N?[0-9]*\s*\(/) or (!/\)$/) ){
			#if(/[\[\#\=\*\/]/ or /DO/ or /GOTO/ or /G65/ or /G66/ or /M98/){
			if(/[\[\#\=\*\/]/ or /DO/ or /GOTO/ or /G65/ or /G66/ or /M98/ or /N[0-9]+/){
				print OUT '(^^ '.$_.' ^^)'."\n";
			}
		}
	}
	$_= $original;
}

#sub OBS_skip_print{
#	if($debug_flag == 1){
#		s/\s*$//;
#		print OUT '(---skip '.$_.'---)'."\n";
#	}
#}

sub OBS_skip_print{
	s/\s*$//;
	print OUT '(---skip '.$_.'---)'."\n";
}

sub shikaku_kakko_kensa{
	my ($line)= @_;
	my $kakko_suu= 0;

	while($line =~ /([\[\]])/g){
		if($1 eq '['){ $kakko_suu++; }
		else{
			$kakko_suu--;
			if($kakko_suu < 0){ last; }
		}
	}
	if($kakko_suu != 0){
		print OUT '(---括弧が閉じていません---)'."\n";
		print OUT "(---処理を中止しました---)\n";
		close(OUT);
		exit;
	}
}

sub kakko_print{
	($_)= @_;
	while(/\(.*?\)/){
		($pre_line,$post_line)= ($`,$');
		print OUT $&;
		while($post_line =~ /\)/g){
			($post_pre_line,$post_post_line)= ($`,$');
			if($post_pre_line !~ /\(/){
				print OUT $post_pre_line.')';
				$post_line= $post_post_line;
			}
		}
		print OUT "\n";
		$_= $pre_line.$post_line;
	}
	if($_ =~ /^\s*N?\d*\s*$/){ $_= ""; }
	return $_;
}

sub extra_print{
	($line)= @_;
#	my ($new_line,$char,$str,$num,@modal);
	# 2018.03.28
	my ($new_line,$char,$str,$num,$G66_modal_flag,@modal);

	$G66_modal_flag= 0;
	$_= $line;
	while(/([A-MO-Z])(\-?)([0-9\.]+)/){
		$_= $';
		($char,$str,$num)= ($1,$2,$3);
		$num= $str.shutsuryoku_marume($char,$num);
		$new_line= $new_line.$char.$num;

		if($char eq "G"){
			$value[4000 + $G_group{$num+0}]= $num;
			$value[4200 + $G_group{$num+0}]= $num;
			push(@modal,'(----#'.(4000+$G_group{$num}).'= '.$num.'----)'."\n");
		}
		elsif($char =~ /[BFHMST]/){
			$value[$system_value_modal{$char}]= $num;
			$value[$system_value_modal{$char}+200]= $num;
			push(@modal,'(----#'.$system_value_modal{$char}.'= '.$num.'----)'."\n");
		}
	}
	if(/\s+$/){ $new_line= $new_line."\n"; }
	print OUT $new_line;
	if($modal_flag == 1){
		foreach (@modal){ print OUT; }
	}

	kotei_cycle($line);
	
	if($G66_modal_tajuudo > 0){
		if($G66_yobidashi_tajuudo < $G66_modal_tajuudo){
			$_= $line;
			#2018.03.02
			if(!/G92/ and !/G0*4[A-Z\s]/ and !/G28/ and $kotei_cycle == 0){
			#if(!/G92/ and $kotei_cycle == 0){
				if(/X\-*[0-9\.]+/ or /Y\-*[0-9\.]+/ or /Z\-*[0-9\.]+/){
					$G66_modal_flag= 1;
				}
			}
		}
	}


# H30.03.23 #5001 #5002 #5003 に対応

# #4003 → グループ3 → 90 or 91
# $value[4003] → 90 or 91
# #4009 → グループ9 → 固定サイクル(80,73,74,81,82,83,84,85,86,87,88,89)
# #4010 → グループ10 → 固定サイクル復帰レベル(98,99)


#原点復帰、G92、早送り、直線補間、円弧補間、ドウェル、固定サイクル

#G91G28Z0	(--,--,0)
#G91G28Z10.0	(--,--,0)

#G90
#G00X30.0Y40.0	(30,40,--)
#G01Z-10.0F100	(--,--,-10.0)
#X-30.0	(-30.0,--,--)
#G02X30.0Y40.0Z-3.0R100.0F200	(30,40,-3)
#G00Z100.0	(--,--,100)


#G91
#G00X30.0Y40.0	(+30,+40,--)
#G01Z-10.0F100	(--,--,--10)
#X-60.0	(--60,--,--)
#G02X60.0Y0R100.0F200	(+60,+0,--)
#G00Z100.0	(--,--,+100)

# G04X1000

# G65X10.0Y30.0 ←　出力段階では変換されてるはずだが()つき

# G90
# G98G81X100.0Y50.0Z-30.0R10.0F100	(100,50,--)
# X200.0Z-50.0	(200,--,--)
# G80

# G90
# G99G81X100.0Y50.0Z-30.0R10.0F100 	(100,50,10)
# X200.0		(200,--,--)
# G80

# G91
# G98G81X100.0Y50.0Z-30.0R10.0F100	(+100,+50,--)
# X200.0	(+200,--,--)
# G80

# G91
# G99G81X100.0Y50.0Z-30.0R10.0F100 	(+100,+50,+10)
# X200.0	(+200,--,--)
# G80

# G92X0Y0Z0
	
	$_ = $new_line;
	
	if(!/G0*4[A-Z\s]/){
		if(/G(28|30)[A-Z\s]/){
			if(/X\-*[0-9\.]+/){ $value[5001] = 0; if($debug_flag2 == 1){ print OUT '(----#5001= 0----)'."\n"; } }
			if(/Y\-*[0-9\.]+/){ $value[5002] = 0; if($debug_flag2 == 1){ print OUT '(----#5002= 0----)'."\n"; } }
			if(/Z\-*[0-9\.]+/){ $value[5003] = 0; if($debug_flag2 == 1){ print OUT '(----#5003= 0----)'."\n"; } }
		}
		elsif(/G92[A-Z\s]/){
			if(/X(\-*[0-9\.]+)/){ $value[5001] = $1; if($debug_flag2 == 1){ print OUT '(----#5001= '. $1. '----)'."\n"; } }
			if(/Y(\-*[0-9\.]+)/){ $value[5002] = $1; if($debug_flag2 == 1){ print OUT '(----#5002= '. $1. '----)'."\n"; } }
			if(/Z(\-*[0-9\.]+)/){ $value[5003] = $1; if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; } }
		}
		elsif($value[4003] == 90){
			if($kotei_cycle == 0){
				if(/X(\-*[0-9\.]+)/){ $value[5001] = $1; if($debug_flag2 == 1){ print OUT '(----#5001= '. $1. '----)'."\n"; } }
				if(/Y(\-*[0-9\.]+)/){ $value[5002] = $1; if($debug_flag2 == 1){ print OUT '(----#5002= '. $1. '----)'."\n"; } }
				if(/Z(\-*[0-9\.]+)/){ $value[5003] = $1; if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; } }
			}
			else{
				if(/X(\-*[0-9\.]+)/){ $value[5001] = $1; if($debug_flag2 == 1){ print OUT '(----#5001= '. $1. '----)'."\n"; } }
				if(/Y(\-*[0-9\.]+)/){ $value[5002] = $1; if($debug_flag2 == 1){ print OUT '(----#5002= '. $1. '----)'."\n"; } }
				if($value[4010] == 99){
					if(/R(\-*[0-9\.]+)/){ $value[5003] = $1; if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; } }
				}
			}
		}
		elsif($value[4003] == 91){
			if($kotei_cycle == 0){
				if(/X(\-*[0-9\.]+)/){ $value[5001] = kagenzan($value[5001],$1); if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; } }
				if(/Y(\-*[0-9\.]+)/){ $value[5002] = kagenzan($value[5002],$1); if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; } }
				if(/Z(\-*[0-9\.]+)/){ $value[5003] = kagenzan($value[5003],$1); if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; } }
#				if(/X(\-*[0-9\.]+)/){ $value[5001] += $1; if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; } }
#				if(/Y(\-*[0-9\.]+)/){ $value[5002] += $1; if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; } }
#				if(/Z(\-*[0-9\.]+)/){ $value[5003] += $1; if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; } }
			}
			else{
				if(/X(\-*[0-9\.]+)/){ $value[5001] = kagenzan($value[5001],$1); if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; } }
				if(/Y(\-*[0-9\.]+)/){ $value[5002] = kagenzan($value[5002],$1); if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; } }
#				if(/X(\-*[0-9\.]+)/){ $value[5001] += $1; if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; } }
#				if(/Y(\-*[0-9\.]+)/){ $value[5002] += $1; if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; } }
				if($value[4010] == 99){
					if(/R(\-*[0-9\.]+)/){ $value[5003] = kagenzan($value[5003],$1); if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; } }
#					if(/R(\-*[0-9\.]+)/){ $value[5003] += $1; if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; } }
				}
			}
		}
		
		if($G66_modal_flag == 1){
			G66_modal_yobidashi($G66_modal_tajuudo - $G66_yobidashi_tajuudo);
		}
	}
# H30.03.23 ここまで
	
}

sub kotei_cycle{
	($_) = @_;
	if(/G7[346]/ or /G8[1-9]/){ $kotei_cycle= 1; }
	elsif(/G80/ or /G0*[0123][A-Z\s]/ or /G33/){ $kotei_cycle= 0; }
}

sub naibu_marume{
	my ($num)= @_;
	my ($num1,$num2,$num3,$reverse_num,$num_length,$yuukou_num_length,$char,$i);
	my ($minus_flag,$seisuu_keta,$offset_shousuu_keta)= (0,0,0);
	my ($seisuu_bu,$shousuu_bu)= ("","");

	if(abs($num) < 1/(10**10)){ $num= 0; }
	$reverse_num= reverse($num);
	if($reverse_num =~ /\-$/){
		$minus_flag= 1;
		chop($reverse_num);
	}
	$char= chop($reverse_num);
	if($char ne "0"){
		$seisuu_bu= $char;
		$num_length= length($reverse_num);
		for($i=1;$i<=$num_length;$i++){
			$seisuu_keta++;
			$char= chop($reverse_num);
			if($char eq '.'){ last; }
			else{ $seisuu_bu= $seisuu_bu.$char; }
		}
	}
	else{ chop($reverse_num); }
	$shousuu_bu= reverse($reverse_num);

	if($seisuu_bu eq ""){
		$num_length= length($reverse_num);
		for($i=1;$i<=$num_length;$i++){
			$char= chop($reverse_num);
			if($char ne "0"){ last; }
			else{ $offset_shousuu_keta++; }
		}
	}

	$num1= $seisuu_bu.$shousuu_bu;
	$yuukou_num_length= length($num1);
	$yuukou_num_length -= $offset_shousuu_keta;

	if($yuukou_num_length > 8){
		$num2= substr($num1,0,8+$offset_shousuu_keta);
		$num3= '0.'.substr($num1,8+$offset_shousuu_keta,1);
		$num2= $num2 + round($num3);

		if($seisuu_keta > 8){
			$num= $num2;
			while($seisuu_keta > 8){
				$num= $num.'0';
				$seisuu_keta--;
			}
		}
		elsif($seisuu_keta != 0){
			if(length($num2) > 8){ $seisuu_keta++; }
			$num= substr($num2,0,$seisuu_keta).'.'.substr($num2,$seisuu_keta,8-$seisuu_keta);
		}
		else{
			$offset_shousuu_keta -= (length($num2) - 8);
			if($offset_shousuu_keta < 0){
				$num= substr($num2,0,-$offset_shousuu_keta).'.'.substr($num2,-$offset_shousuu_keta,7);
			}
			else{ $num= '0.'.'0'x$offset_shousuu_keta.substr($num2,0,8+$offset_shousuu_keta); }
		}
		if($minus_flag == 1){ $num= '-'.$num; }
	}
	return $num;
}


sub shutsuryoku_marume{
	my ($char,$num)= @_;
	my $num1;

	if($num =~ /(0*)([0-9\.]+)/){
		($num1,$num)= ($1,$2);
		if($num =~ /^\./){
			chop($num1);
			$num= '0'.$num;
		}
	}

	$num= $num * 1000;
	$num= round($num);
	$num= $num / 1000;

	if($num !~ /\./ and $num != 0){ $num= $num.'.'; }

	if($char =~ /[GMSTPDH]/ and $num =~ /\.$/){ $num= round($num); }
	elsif($char eq 'F'){
		if($F_flag == 0 and $num =~ /\.0*$/){ $num = round($num); }
	}
	$num= $num1.$num;
	return $num;
}

sub round{
	my ($num)= @_;
	if($num >= 0){ $num= int($num + 0.5); }
	else{ $num= int($num - 0.5); }
	return $num;
}

sub fup{
	my ($num)= @_;
	my $num2;
	$num2= int($num);
 	if($num != $num2){
		if($num > 0){ $num2++; }
		else{ $num2--; }
	}
	return $num2;
}

sub bcd_shori{
	my ($num)= @_;
	$num= hex($num);
	return $num;
}

sub bin_shori{
	my ($num)= @_;
	$num= sprintf("%x",$num);
	return $num;
}

sub ten_to_two{
	my ($num)= @_;
	$num= sprintf("%d",unpack("B32",pack("n",$num)));
	return $num;
}

sub two_to_ten{
	my ($num)= @_;
	$num= unpack("N",pack("B32",substr("0"x32 . $num,-32)));
	return $num;
}

sub and_shori{
	my ($num1,$num2)= @_;
	$num1= ten_to_two($num1);
	$num2= ten_to_two($num2);

	$num1= $num1 & $num2;
	$num1= two_to_ten($num1);
	return $num1;
}

sub or_shori{
	my ($num1,$num2)= @_;
	$num1= ten_to_two($num1);
	$num2= ten_to_two($num2);

	$num1= $num1 | $num2;
	$num1= two_to_ten($num1);
	return $num1;
}

sub xor_shori{
	my ($num1,$num2)= @_;
	$num1= ten_to_two($num1);
	$num2= ten_to_two($num2);

	$num1= $num1 ^ $num2;
	$num1= two_to_ten($num1);
	return $num1;
}
