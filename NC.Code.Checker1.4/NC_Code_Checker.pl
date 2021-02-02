#! /usr/bin/perl

### NC_Code_Checker.pl
##  Version1.4 (2020.03.31)
##  Version1.3 (2019.09.11)
##  Version1.2 (2019.07.26)
##  Version1.1 (2019.06.25)
##  Version1.0 (2019.05.24)

#
# マシニングセンタ(FANUC,MELDAS,MAPPS系)用のNCプログラムの誤りを
# チェックするPerlスクリプトです。
# 主に手書きで作成したNCプログラムのチェックを想定しています。
# 使い方、検出できる誤り等については
# [NC_Code_Checkerについて.pdf]を参照してください。
#
# 本スクリプトは、2019年度科学研究費助成事業(科学研究費補助金)
# 奨励研究(課題番号:19H00247)の助成を受けて作成されたものです。
#
#                           舞鶴工業高等専門学校　技術職員　石井貴弘

### 設定項目 #########################################################
# チェック後の結果ファイルとは別に、ログファイル(追記型)が
# ユーザードキュメントフォルダに、以下のファイル名で生成されます。
$log_file = "NC_Code_Checker_log.txt";

# Oコード(プログラム番号)が指令されていない場合に
# 警告する場合は 0、しない場合は 1 を設定してください。
$O_warn_flag = 0;

# X,Y,Z,I,J,K,R,Qコードの数値に小数点が入っていない場合に
# 警告する場合は 0、しない場合は 1 を設定してください。
$DP_warn_flag = 0;

# Sコードの数値に小数点がついているとエラーになる機種の場合は 0、
# 小数点がついていてもエラーにならない機種の場合は 1 を設定してください。
$S_DP_flag = 0;

# 固定サイクルのPコードの数値に小数点がついている場合に
# 警告する場合は 0、しない場合は 1 を設定してください。
$P_DP_flag = 0;

# 工具長補正番号Hが工具番号Tと違う場合に
# 警告する場合は 0、しない場合は 1 を設定してください。
$H_warn_flag = 0;

# 工具径補正番号Dが工具番号Tと違う場合に
# 警告する場合は 0、しない場合は 1 を設定してください。
$D_warn_flag = 0;

# 工具交換前に実行すべきコード(原点復帰等)を入力してください。
# 特に必要ない場合は "" としてください。(複数ブロックには未対応)
# このコードを実行後であっても工具交換する前に原点復帰以外の移動が
# 指令された場合、警告します。
$pre_TC_code = "G91G28Z0";

# TコードとM06(工具交換)を同じブロックに入れると
# M06の動作が先で、その後にT番号の工具が交換待機位置に呼び出される機種の場合は 0、
# T番号の工具呼び出しが先で、その後M06が動作する機種の場合は 1 を設定してください。
$TC_flag = 0;

# TコードとM06が同じブロックにないと工具交換されない機種の場合は 1、
# そうでない場合は 0 を設定してください。
$TC_flag2 = 0;

# 基本的には同じブロックにあると不具合の元となるので、
# TコードとM06が同じブロックにある場合、
# 警告する場合は 1、警告しない場合は 0 を設定してください。
$TC_warn_flag = 1;

# 初期状態で主軸についている工具の工具番号を設定する場合、入力してください。
# 特に必要なければ 1 のままにしておいてください。
$present_T = 1;

# 工具交換が指令されていない状態で、上の $present_T の工具番号を
# T番号とH番号が違う場合等の判定に使用する場合は 1 を
# 使用しない場合は 0 を設定してください。
$present_T_flag = 0;

# 主軸回転数を指令せずに主軸正転(M03)すると警告しますが、
# (リジッド(同期式)タッピングサイクルのときは除く)
# 工具交換後に改めてSコードを指令し直して主軸正転しないと
# エラーになる機種の場合は 0、エラーにならない機種の場合は 1 を設定してください。
$S_flag = 0;

# 早送り以外でZを下降させるとき(G01Z_や固定サイクル)に
# クーラントON(M08)状態でない場合、
# 警告する場合は 1、警告しない場合は 0 を設定してください。
$M08_warn_flag = 1;

# コメント文中に全角文字(全角スペースを含む)が入っている場合、
# 警告する場合は 0 、しない場合は 1 を設定してください。
$ComZen_warn_flag = 0;

# 1ブロック中でMコードを1つだけ指令できる機種の場合は 0、
# 1ブロック中でMコードを複数指令できる機種の場合は 1 を設定してください。
$multi_M = 0;

# G74、G84コードの前のブロックにM29S_がないとき警告する場合は 1、
# 必要ない、またはフロート(非同期式)サイクルを使用する場合は 0 を設定してください。
$G84_flag = 1;

# 上の $84_flag が 0 の場合で、
# G74、G84コードの前のブロックがM29S_でなくても
# G98(G99)G84X_Y_Z_R_F_S_;
# の構文で同期式タッピングサイクルが実行される機種(舞鶴高専には存在する)の場合で
# Fコード、SコードがG74、G84のブロックにないときに警告する場合は 1、
# 警告しない、あるいはそういう仕様ではない場合は 0 を設定してください。
$G84_flag2 = 0;

# 工具径補正で先読みできるブロック数を設定してください。
# 工具径補正モード中、XYの移動がないブロックがそれを超えた場合、警告します。
$foresee_block = 2;

# 固定サイクルのモーダル中に他の移動命令(G00等)があれば
# 一般的には固定サイクルはキャンセルされますが、
# 固定サイクルキャンセル命令(G80)でキャンセルしていない場合に
# 警告する場合は 0、しない場合は 1 を設定してください。
$G80_flag = 0;

# Sコードで指令する主軸回転数の上限値と下限値を設定してください。
# 範囲外の値の場合、警告します。
$S_max = 10000;
$S_min = 200;

# Fコードで指令する送り速度の上限値と下限値を設定してください。
# 範囲外の値の場合、警告します。
# (Fでタップのピッチを設定する機種もあるので
#   G74,G84と同じブロックのとき、下限値は無視します。)
$F_max = 600;
$F_min = 30;

# G73,G81,G82,G83で穴をあけるサイクルがある場合で
# 同一のプログラム内で
# そのサイクルで指令したXY座標にあけた穴に対して
# G74,G84,G85,G86,G88,G89で追加加工するサイクルがある場合、
# すでに開けられた穴のZ座標に対して
# この値以上高い位置(単位:ミリ)で止まっていない場合、警告します。
# 警告が必要ない場合は 0 を設定してください。
$Z_prepare_gap = 4;

# G74,G84,G85,G86,G88,G89で加工するサイクルがある場合、
# そのサイクルで指令しているXY座標に対して
# 同一のプログラム内の前工程に
# G73,G81,G82,G83で穴をあけるサイクルがない場合に
# 警告する場合は 1、警告しない場合 0 を設定してください。
# (何ヵ所かタップ加工等する場合で、1ヵ所だけ下穴と座標が違うミスなども検出できます。
# タッピングやボーリング加工等のみのプログラムの場合は 0 を設定してください。)
$prepared_hole_flag = 0;

# 主軸をZ軸マイナス方向に早送りした場合で
# その高さでXY方向に直線補間、または円弧補間している場合に
# 警告する場合は 1、警告しない場合は 0 を設定してください。
$Z_G00_warn_flag = 1;

# 主軸をZ軸プラス方向に逃がす場合(Z軸単独の移動)に
# 直線補間で移動させている量が
# この値を超えている場合、警告します(単位:ミリ)。
# (早送りの方がふさわしい場合です)
# 必要ない場合は 0 を設定してください。
$Z_G01escape_max = 30;

# Z軸マイナス方向へ直線補間で移動する量(１ブロックの命令で)が
# この値を超えている場合、警告します(単位:ミリ)。
# 正の値で設定し、必要ない場合は 0 を設定してください。
$Z_G01_max = 50;

# サブプログラムはメインプログラムと同じファイル中に
# メインプログラムの下方に記述されていれば認識します。
# サブプログラムを別のファイルに記述する場合は、
# O[プログラム番号]で始まるファイル名のファイル(例: O100.ncd)を
# メインプログラムのファイルと同じフォルダに入れるか、
# 以下に設定するパスのフォルダにサブプログラムのファイルを入れてください。
$sub_folder= 'C:\Program Files\NCVC\subpro';

# NCVC等のCAMソフトで出力されたプログラムに手動で工具交換命令を追加するとき、
# G90G54G00X0Y0も追加する場合がありますが(少なくとも舞鶴高専では)、
# 次の移動先が工具交換前のXY座標の片方もしくは両方と一致しているとき
# 出力されたプログラムには移動のない軸のコードは記述されていないことがありますが、
# その場合、次の移動先がX0かY0で書き換えられていることになります。
# その可能性がある時、警告する場合は 1、警告しない場合は 0 を設定してください。
# (1.工具交換、2.G00X0Y0、3.XまたはY軸のみの移動か、XY移動のない固定サイクル
#  の条件を満たした場合、警告します)
$after_TC_warn_flag = 0;

# オプショナルブロックスキップを有効(ON)にしたい場合は 1、
# 無効(OFF)にしたい場合は 0 を設定してください。
$OBS_switch = 0;

# M98の繰り返し数の指定方法について、
# M98P○○○○L○○○○のLで指定する方式の場合は 0、
# M98P○○○○○○○○の前4桁で指定する方式の場合は 1 を設定してください。
$M98_houshiki = 0;

# WHILEやDOループ内でのループ数の上限数を設定してください。
# 条件式などでループが終わらない場合に無限ループを防ぎます。
$loop_max = 300;

# プログラム全体でのGOTO命令の上限数を設定してください。
# GOTO処理での無限ループを防ぎます。
$GOTO_exe_max = 500;

# システム変数を使用する場合で、初期値が必要なものは値を登録してください。
# 初期状態のGコードのモーダル情報が違う場合も同様(スクリプト中の %initial_G 参照)。
#%system_value = (,);

# Windows環境でない場合で、実行エラーになる場合は
# 以下の行頭に # を付けてください。
use Win32::OLE;
########################################################################

%c= ("A","1","B","2","C","3","D","7","E","8","F","9","H","11","I","4","J","5","K","6","M","13","Q","17","R","18","S","19","T","20","U","21","V","22","W","23","X","24","Y","25","Z","26");

%G_group= (0,1,1,1,2,1,3,1,15,17,16,17,17,2,18,2,19,2,20,6,21,6,22,4,23,4,33,1,40,7,41,7,42,7,40.1,19,150,19,41.1,19,151,19,42.1,19,152,19,43,8,44,8,49,8,50,11,51,11,50.1,18,51.1,18,54,14,54.1,14,55,14,56,14,57,14,58,14,59,14,61,15,62,15,63,15,64,15,66,12,67,12,68,16,19,16,73,9,74,9,75,1,76,9,77,1,78,1,79,1,80,9,81,9,82,9,83,9,84,9,85,9,86,9,87,9,88,9,89,9,90,3,91,3,94,5,95,5,96,13,97,13,98,10,99,10,160,20,161,20);
%initial_G= (1,00,17,15,2,17,4,22,7,40,19,40.1,8,49,11,50,18,50.1,14,54,15,64,12,67,16,69,9,80,3,90,5,94,13,97,10,98,20,160);

%system_value_modal= ("B",4102,"D",4107,"F",4109,"H",4111,"M",4113,"S",4119,"T",4120);
#"N" 4114, "O" 4115

@G_groupList = ([0,1,2,3,33],[17,18,19],[20,21],[40,41,42],[43,44,49],[50,51],[54,55,56,57,58,59],[61,62,63,64],[65,66,67],[68,69],[73,74,76,80,81,82,83,84,85,86,87,88,89],[90,91],[94,95],[96,97],[98,99]);

%jouken_hash= ("==","EQ","=","EQ","<>","NE",">=","GE","<=","LE","GT",">","LT","<");

use Math::Trig;

$RAD = 180/pi;
#$PI= 3.1415926535897932;
#$RAD= 180/$PI;

use File::Basename;
$scriptName = basename($0, '');

if (substr($sub_folder, -1) ne "\\"){
	$sub_folder= $sub_folder . "\\";
}

($pre_file, $out_file)= ($ARGV[0], $ARGV[1]);

if($pre_file eq ""){
	if($^O =~ /Win/){ print "\n入力ファイルが指定されていません。\n\n"; }
	else{ print encode('UTF-8', decode('Shift_JIS', "\n入力ファイルが指定されていません。\n\n")); }
	exit;
}

open(IN,$pre_file);
while(<IN>){
	push(@main,$_);
}
close(IN);

if($main[0] =~ /\[.*\.pl実行結果\]/){
	if($out_file ne ""){
		open(OUT,">$out_file");
		print OUT "(実行結果のファイルに対してさらに$scriptNameが実行されたので処理を中止しました)";
		close(OUT);
	}
	else{
		if($^O =~ /Win/){
			print "\n(実行結果のファイルに対してさらに$scriptNameが実行されたので処理を中止しました)\n\n";
		}
		else{
			print encode('UTF-8', decode('Shift_JIS', "\n(実行結果のファイルに対してさらに$scriptNameが実行されたので処理を中止しました)\n\n"));
		}
	}
	exit;
}

$pre_folder= $pre_file;
$pre_folder =~ s/\\[^\\]+?$/\\/;

opendir(DIR,$pre_folder);
@sub_files2= readdir(DIR);
closedir(DIR);

opendir(DIR,$sub_folder);
@sub_files= readdir(DIR);
closedir(DIR);

if($^O =~ /Win/){
	my $wsh= new Win32::OLE 'WScript.Shell';
	$log_file= $wsh->SpecialFolders('MyDocuments')."\\$log_file";
	$pre_file_sjis= "[使用スクリプト: $scriptName]\n[対象ファイル: $pre_file]\n";
}
#elsif($^O =~ /Mac/ or $^O =~ /darwin/){
else{
	$log_file= $ENV{"HOME"}."/$log_file";
	use Encode 'decode';
	use Encode 'encode';
	$pre_file_sjis= "[使用スクリプト: $scriptName]\n[対象ファイル: ".encode('Shift_JIS', decode('UTF-8', $pre_file))."]\n";
}

open(LOG,">>$log_file");
my ($sec, $min, $hour, $mday, $mon, $year) = (localtime(time))[0..5];
printf(LOG "<%d/%02d/%02d %02d:%02d:%02d>\n", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print LOG $pre_file_sjis;

if($out_file ne ""){
	open(OUT,">$out_file");
	print OUT "[$scriptName実行結果]\n";
}
else{
	if($^O =~ /Win/){
		print "\n[$scriptName実行結果]\n\n";
	}
	else{
		print encode('UTF-8', decode('Shift_JIS',"\n[$scriptName実行結果]\n\n"));
	}
}
main();
if($error_flag == 0){ write_log2("誤りは見つかりませんでした。", "警告なし"); }
close(OUT);
close(LOG);
if($out_file eq ""){ print "\n\n"; }


### 廃止した設定 #################################################
# カスタムマクロを使うコードの場合は 1、
# 使わない場合は 0 を設定してください。
# 1 の場合はアドレスの後に数値がないエラーのチェックは行われません。
#$macro_flag = 0;

# # 内部処理及び、変換前の原文をコメント出力する場合は1、
# # しない場合は0を設定してください。
# # ただし、最低限の内部処理は0を設定しても出力されます。
# $debug_flag= 0;
# # モーダル情報をコメント出力する場合は1、
# # しない場合は0を設定してください。
# $modal_flag= 0;

# # Fコードで指定する数値の小数点以下が0のとき、
# # 小数点を出力しない場合は0、
# # 小数点を出力する場合は1を設定してください。
# $F_flag= 0;

# # システム変数 #5001,#5002,#5003の変化をコメント出力する場合は1、
# # しない場合は0を設定してください。
# #$debug_flag2= 0;
##################################################################

sub main{
	my ($i,$j);
	$error_flag= 0;
	$O_exist= 0;
	$M30_exist= 0;
	$S_exist= 0;
	$G92_exist= 0;
	$G54_exist= 0;
	$G54_warned= 0;
	$G43_exist= 0;
	$G43_warned= 0;
	$keihosei_mode= 0;
	$nonKeihoseiLine= 0;
	$keihosei_warned= 0;
	$spindle_ON= 0;
	$coolant_ON= 0;
	$M29S_flag= 0;
	$Z_up= 0;
	$Z_kirikomi= 0;
	$Z_G00_down= 0;
	$M06_exe= 0;
	$M06_count= 0;
	$manual_origin_X= 0;
	$manual_origin_Y= 0;
	$tap_tool_flag= 0;
	$GOTO_count= 0;
	$progKaisou= "";
	
	if($pre_TC_code eq ""){ $pre_TC_flag= 1; }
#	else{ $pre_TC_code .= "\n"; }
	
	$macro_level= 0;
	$G66_modal_tajuudo= 0;
	$yobidashi_tajuudo= 0;
	$proto_prog_No= 0;
	
	@initial_G_key= keys(%initial_G);
	@initial_G_key= sort{$a <=> $b} @initial_G_key;
#	if($modal_flag == 1){ print OUT '(----Gコード各グループのモーダル初期化開始----)'."\n"; }
	foreach $key(@initial_G_key){
		modal_shori($key+4000,$initial_G{$key});
	}
#	if($modal_flag == 1){ print OUT '(----Gコード各グループのモーダル初期化終了----)'."\n"; }
	
	@system_value_key= keys(%system_value);
	
	$value[5001] = 0;
	$value[5002] = 0;
	$value[5003] = 0;
	$value[4115] = 0;
	
	if(@system_value_key != 0){
		@system_value_key= sort{$a <=> $b} @system_value_key;
#		if($debug_flag == 1){ print OUT '(---システム変数登録開始---)'."\n"; }
		foreach $key(@system_value_key){
			$value[$key]= $system_value{$key};
#			print OUT '(---#'.$key.'= '.$system_value{$key}.'---)'."\n";
		}
#		if($debug_flag == 1){ print OUT '(---システム変数登録終了---)'."\n"; }
	}
	
	for($i=0;$i<=$#main;$i++){
		$_= $main[$i];
#		original_print($_);
		
		#コメント除去されたものが戻る
#		$_ = bunpou_check($_, $i, 0, @main);
		$_ = bunpou_check($_, $i, @main);
		
		if(/^\s*\/\d?/){
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
		
#		shikaku_kakko_kensa($_);
		shikaku_kakko_kensa($_, $i);
		if(/IF/){ $i= bunki_shori($_, $i, @main); }
#		elsif(/GOTO/){ $i= idou_shori($_, @main); }
		elsif(/GOTO/){ $i= idou_shori($_, $i, @main); }
		elsif(/WHILE/){ $i= kurikaeshi_shori($_, $i, $proto_prog_No, @main); }
		elsif(/DO/){ $i= kurikaeshi_shori2($_, $i, $proto_prog_No, @main); }
		elsif(/^\s*G65/){
#$progKaisou= "/O$proto_prog_No L".($i+1);
$progKaisou= "/MAIN L".($i+1);
			$i= macro_G65($_, $i);
			modal_shori(4115, $proto_prog_No);
$progKaisou= "";
		}
		elsif(/^\s*G66/){
			$i= macro_G66($_, $i, $proto_prog_No, @main); }
		elsif(/^\s*M98/){
$progKaisou= "/MAIN L".($i+1);
			$i= sub_M98($_, $i);
			modal_shori(4115, $proto_prog_No);
$progKaisou= "";
		}
		else{
			$_= main_henkan($_);
			if(/(?<![A-Z])M30(?!\d)/ or /(?<![A-Z])M0?2(?!\d)/){
#				print OUT $1."\n\%\n";
				$M30_exist = 1;
				
				if($spindle_ON == 1){
					write_log($i+1, $_, "主軸正転がプログラム停止命令で停止しました。", "M30で主軸停止");
					$spindle_ON= 0;
				}
				if($coolant_ON == 1){
					write_log($i+1, $_, "クーラントがプログラム停止命令で停止しました。", "M30でクーラント停止");
					$coolant_ON= 0;
				}
				last;
			}
			if(/(?<![A-Z])M99(?!\d)/){
#				print OUT;
				last;
			}
			extra_print($_, $i);
		}
		
		if($i eq "M30" or $i eq "M02" or $i eq "M2" or $i eq "M99"){
#			print OUT $i."\n\%\n";
			if($i =~ /M(30|0?2)/){
				$M30_exist = 1;
				
				if($spindle_ON == 1){
					write_log2("主軸正転がプログラム停止命令で停止しました。", "$iで主軸停止");
					$spindle_ON= 0;
				}
				if($coolant_ON == 1){
					write_log2("クーラントがプログラム停止命令で停止しました。", "$iでクーラント停止");
					$coolant_ON= 0;
				}
			}
			last;
		}
	}
	
	if($O_warn_flag == 0 and $O_exist == 0){
		write_log2("Oコードが指令されていません。", "Oコードがない");
	}
	if($M30_exist == 0){
		write_log2("プログラム終了コード(M30)がありません。", "M30がない");
	}
	if($T_yobidashi_flag== 1){
		write_log2("呼び出した工具T$value[4120]に交換せずにプログラムが終了しました。", "呼び出したTに交換せずにプログラム終了");
	}
	if($keihosei_mode == 1){
		write_log2("工具径補正キャンセルしないままプログラムが終了しました。", "工具径補正キャンセルせずにプログラム終了");
	}
	if($koteiCycle_mode == 1 and $G80_flag == 0){
		write_log2("固定サイクルキャンセルしないままプログラムが終了しました。", "固定サイクルキャンセルせずにプログラム終了");
	}
	if($spindle_ON == 1){
		write_log2("主軸を停止させないままプログラムが終了しました", "主軸停止せずににプログラム終了");
	}
	if($spindle_ON == 1){
		write_log2("クーラントを停止させないままプログラムが終了しました", "クーラント停止せずににプログラム終了");
	}
}

sub write_log{
	my ($lineNum, $line, $message, $logComment) = @_;
#	my ($lineNum, $progNum, $line, $message, $logComment) = @_;
	my $progNum= $value[4115];
	
	$line =~ s/\s*$//;
	if($progNum == 0 or $progNum == $proto_prog_No){
		if($out_file ne ""){
			print OUT "$lineNum行目: $line ← $message\n";
		}
		else{
			if($^O =~ /Win/){
				print "$lineNum行目: $line ← $message\n";
			}
			else{
				print encode('UTF-8', decode('Shift_JIS', "$lineNum行目: $line ← $message\n"));
				#print "$lineNum行目: $line ← $message\n";
			}
		}
	}
	else{
		if($out_file ne ""){
			print OUT "$lineNum行目(O$progNum中$progKaisou): $line ← $message\n";
#			print OUT "$lineNum行目(O$progNum中): $line ← $message\n";
		}
		else{
			if($^O =~ /Win/){
				print "$lineNum行目(O$progNum中$progKaisou): $line ← $message\n";
#				print "$lineNum行目(O$progNum中): $line ← $message\n";
			}
			else{
				print encode('UTF-8', decode('Shift_JIS', "$lineNum行目(O$progNum中$progKaisou): $line ← $message\n"));
#				print encode('UTF-8', decode('Shift_JIS', "$lineNum行目(O$progNum中): $line ← $message\n"));
				#print "$lineNum行目(O$progNum中): $line ← $message\n";
			}
		}
	}
	print LOG "  $logComment\n";
	$error_flag= 1;
}

sub write_log2{
	my ($message, $logComment) = @_;
	
	if($out_file ne ""){
		print OUT "  ($message)\n";
	}
	else{
		if($^O =~ /Win/){
			print "  ($message)\n";
		}
		else{
			print encode('UTF-8', decode('Shift_JIS', "  ($message)\n"));
		}
	}
	print LOG "  $logComment\n";
	$error_flag= 1;
}

sub exit_shori{
	close(OUT);
	close(LOG);
	if($out_file eq ""){ print "\n"; }
	exit;
}

sub bunpou_check{
#	my ($line, $i, $progNum, @prog)= @_;
	#メインプログラムのとき、$progNumは 0
	my ($line, $i, @prog)= @_;
	my ($c,$tmp,$sub_gyou);
	
	$_ = $line;
	
	if(/;\s*$/){
		write_log($i+1, $line, ";<EOB>は必要ありません。改行がその意味を持ちます", ";<EOB>がついている");
		s/;\s*$//;
	}
	
	if(/^\s*(\%)/){
		#print OUT $1.$';
		if($'=~ /\S/){
#			$_= $prog[$i];
			write_log($i+1, $line, "% は単独のブロックにしてください。", "% が単独でない");
			s/^\s*\%//;
		}
	}
	
	# 括弧(コメント)を除去
	if(/\(/){
		#$_= kakko_print($_);
		($_, $zenkakuComment) = comment_jokyo($_, $i);
		if($zenkakuComment == 1 and $ComZen_warn_flag == 0){
			write_log($i+1, $line, "コメント文に全角文字を含んでいます。", "コメント文に全角文字を含む");
		}
	}
	if(/（.*）/){
		write_log($i+1, $line, "コメントの () が全角です。半角にしてください。","コメントの () が全角");
		s/（.*）//;
	}
	elsif(/（.*\)/){
		write_log($i+1, $line, "コメントの ( が全角です。半角にしてください。","コメントの ( が全角");
		s/（.*\)//;
	}
	elsif(/\(.*）/){
		write_log($i+1, $line, "コメントの ) が全角です。半角にしてください。","コメントの ) が全角");
		s/\(.*）//;
	}
	
	#これ以降は$_のコメントが除去されている
	
	# Oと0の誤り判定
	if(/^\s*0([0-9]+)/){
		write_log($i+1, $line, "頭文字が0<ゼロ>です。O<おー>番号の誤りでは。", "プログラム番号Oと0の間違い");
	}
	# 0とOの誤り判定
	elsif(/(?<![A-Z])[A-Z]\-?\d*[Oo]+\d*\.?[Oo\d]*/ or /(?<![A-Z])[A-Z]\-?\d*\.?\d*[Oo]+[Oo\d]*/){
		if(!/DO/ and !/GOTO/ and !/COS/ and !/ROUND/ and !/XOR/){
			write_log($i+1, $line, "数字の0<ゼロ>がアルファベットO<おー>になっています。", "数値にアルファベットのO<おー>");
			s/(?<![A-Z])[A-Z]\-?\d*[Oo]+\d*\.?[Oo\d]*//g;
			s/(?<![A-Z])[A-Z]\-?\d*\.?\d*[Oo]+[Oo\d]*//g;
		}
	}
	#if(/^\s*O([0-9]+)/){
	elsif(/(?<![A-Z])O([0-9]+)/){
		$tmpProgNum = $1;
		$tmp= $_;
#		if($O_exist == 0 and $progNum == 0){
		if($O_exist == 0 and $value[4115] == 0){
			if(before_O_other_code_check(@prog[0..$i]) == 1){
				write_log($i+1, $line, "Oコードはプログラムの最初に記述してください。", "Oより前に他アドレス");
			}
			
#			if($progNum == 0){
			if($value[4115] == 0){
				$proto_prog_No= $tmpProgNum;
#				print OUT $_;
				modal_shori(4115,$proto_prog_No);
				$O_exist= 1;
			}
		}
		else{
			#サブプログラム中の最初のＯは無視
			if(multi_O_check(@prog[0..$i]) == 1){
				write_log($i+1, $line, "Oコードが2回以上指令されています。", "Oコードが2回以上");
			}
		}
		$_ = $tmp;
	}
	
	# 小文字アドレスa-z判定
	#if(/[a-z]\-?\d+\.?\d*/){
	#(?<!\x82)がないと、全角Ａ-Ｚに引っかかる
	if(/(?<!\x82)[\x61-\x7A]\-?\d+\.?\d*/){
		$c= () = $_ =~ m/(?<!\x82)[\x61-\x7A]\-?\d+\.?\d*/g;
		write_log($i+1, $line, "小文字のアドレスを$c個含んでいます。大文字に直してください。", "小文字アドレス×$c");
	}
	
	# 20190618
	# 小文字a-z不正な位置
	#if(/[a-z]\-?\d+\.?\d*/){
	#(?<!\x82)がないと、全角Ａ-Ｚに引っかかる
	if(/((?<!\x82)[\x61-\x7A])+/){
		write_log($i+1, $line, "小文字の文字列 $& が不正です。", "小文字の文字列 $&");
	}
	
	# 全角アドレスＡ-Ｚ判定
	#if(/[Ａ-Ｚ]\-?\d+\.?\d*/){
	if(/\x82[\x60-\x79]\-?\d+\.?\d*/){
		$c= () = $_ =~ m/\x82[\x60-\x79]\-?\d+\.?\d*/g;
		write_log($i+1, $line, "全角アドレスを$c個含んでいます。半角に直してください。", "全角アドレス×$c");
		$error_flag= 2;
	}
	# 小文字全角アドレスａ-ｚ判定
	#if(/[ａ-ｚ]\-?\d+\.?\d*/){
	if(/\x82[\x81-\x9A]\-?\d+\.?\d*/){
		$c= () = $_ =~ m/\x82[\x81-\x9A]\-?\d+\.?\d*/g;
		write_log($i+1, $line, "全角でさらに小文字のアドレスを$c個含んでいます。半角の大文字に直してください。", "全角で小文字アドレス×$c");
		$error_flag= 2;
	}
	# 全角ハイフン判定
	# 没 [\ー\―\‐\－] -> (\x81\[|\x81\\|\x81\]|\x81\|)
	# if(/[A-Z](\x81\[|\x81\\|\x81\]|\x81\|)\d+\.?\d*/){
	# [\ー\―\‐\－\─\─] -> \x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]
	if(/(?<![A-Z])[A-Z]\x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]\d+\.?\d*/){
		$c= () = $_ =~ m/(?<![A-Z])[A-Z]\x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]\d+\.?\d*/g;
		write_log($i+1, $line, "全角ハイフンを$c個含んでいます。半角に直してください。", "全角ハイフン×$c");
		s/\x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]/\x81\x5c/g;
		$error_flag= 2;
	}
	#それ以外の全角文字チェック
	if(zenkaku_check($_)== 1 and $error_flag != 2){
		write_log($i+1, $line, "全角文字を含んでいます。半角に直してください。", "その他全角文字");
		$error_flag= 2;
	}
	#不正小数点チェック
	while(/(?<![A-Z])([A-Z])\-?(\d+\.\d*\.|\.{2,}\d+)/g){
		write_log($i+1, $line, "アドレス$1の数値に複数の小数点が含まれています。", "アドレス$1の数値に複数の小数点");
	}
	
	#小数点とコンマの誤りチェック
	$tmp= $_;
	#G74,G84のオプション ,R01,S_ を除外
	if(/(?<![A-Z])G[78]4(?!\d)/){
		s/\,\s*(R*0[01]|S\d+\.?\*)//g;
	}
	while(/(?<![A-Z])([A-Z])\-?\d+\,\d*/g){
		write_log($i+1, $line, "アドレス$1の数値の小数点がコンマになっています。", "アドレス$1の数値の小数点がコンマ");
		s/(?<![A-Z])[A-Z]\-?\d+\,\d*//g;
	}
	
	#アドレス直後のマイナスと数字の間にスペース X- 10.0
	while(/(?<![A-Z])([A-Z])\-\s+\d+\.?\d*/g){
		write_log($i+1, $line, "アドレス$1直後のマイナスと数字の間にスペースがあります。文法ミスです。", "アドレス$1直後のマイナスと数字の間にスペース");
	}
	
	# #の直後に数字か [ 以外  #G01
	if(/\#[^\d\[\-]/){
		write_log($i+1, $line, "#の直後に数字か [ 以外が記入されています。", "#の直後に数字か [ 以外");
	}
	
	# 先頭の数値にアドレスなし
	if(/^\s*(\d+\.?\d*|\.\d*)/){
		write_log($i+1, $line, "ブロック先頭の数値 $& にアドレスがありません。", "ブロック先頭の数値$&にアドレスがない");
	}
	
	# 先頭の関数にアドレスなし
	if(/^\s*-?\[?(ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		write_log($i+1, $line, "ブロック先頭の関数 $& にアドレスがありません。", "ブロック先頭の関数$&にアドレスがない");
	}
	
	# 数値にアドレスがない　X10.\s100.0
	while(/(?<![A-Z])[A-Z]\-?(\d+\.?\d*|\.\d+)\s+(\d+\.?\d*|\.\d+)/g){
		write_log($i+1, $line, "数値$2にアドレスがありません", "数値$2にアドレスがない");
	}
	
	# 関数、変数前にアドレスか演算子がない　X10.0\s*COS , X10.0\s*#
#	while(/(?<![A-Z])-?(\d+\.?\d*|.\d+)\s+((\d+\.?\d*|\.\d+))/){
	while(/[\d\.]\s*((ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|\#(\d+|\[)))/g){
		write_log($i+1, $line, "$1の前にアドレスか演算子が必要です。", "$1に前にアドレスか演算子がない");
	}
	
	# ]の直後に関数や変数　]COS[
	while(/\]\s*((ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|\#(\d+|\[)))/g){
		write_log($i+1, $line, "$1の前にアドレスか演算子が必要です。", "$1に前にアドレスか演算子がない");
	}
	
	# #100 = 
	if(/^\s*\#/ and !/\=/){
		write_log($i+1, $line, "# で始まるブロックに = がありません。または、# の前にアドレスがありません。", "#で始まるブロックに=がない、または#の前にアドレスがない");
	}
	
	#アドレス直後の数字に対して四則演算 X-10.0 - 20.0 , X-10.0 + #1 , X-10.0 + [ , X-10.0 + COS[180]
	while(/(?<![A-Z])([A-Z])\-?(\d+\.?\d*|\.\d+)\s*[\+\-\*\/]\s*([\d\.\#\[]|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR)/g){
		write_log($i+1, $line, "アドレス$1直後の計算式を[ ]で囲んでください。", "アドレス$1直後の計算式に[ ]がない");
	}
	
	#アドレス直後の変数に対して四則演算 X#1 + 10.0
	while(/(?<![A-Z])([A-Z])\#\d+\.?\d*\s*[\+\-\*\/]\s*([\d\.\#\[]|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR)/g){
		write_log($i+1, $line, "アドレス$1直後の計算式を[ ]で囲んでください。", "アドレス$1直後の計算式に[ ]がない");
	}
	
	#アドレスの直前にマイナス -X10.0
#	if(/\-\s*[A-Z]/ and $macro_flag == 0){
#	while(/\-\s*([A-Z])/g){
	while(/\-\s*([A-Z])\-?\d+\.?\d*/g){
		write_log($i+1, $line, "アドレス$1の直前にマイナスがあります。文法ミスです。", "アドレス$1の直前にマイナス");
	}
	
	#アドレス直後に関数 X ACOS[ ]  X-SIN[ ] 
	while(/(?<![A-Z])([A-Z])\s*\-?\s*(ABS|SQRT|SQR|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/g){
		write_log($i+1, $line, "アドレス$1直後の関数$2を[ ]で囲んでください。", "アドレス$1直後に[ ]で囲んでない関数$2");
	}
	#アドレス直後に関数 A COS[ ]  X-SIN[ ] 
	while(/(?<![A-Z])([B-Z])\s*\-?\s*(SIN|COS|TAN)/g){
		write_log($i+1, $line, "アドレス$1直後の関数$2を[ ]で囲んでください。", "アドレス$1直後に[ ]で囲んでない関数$2");
	}
	#アドレス直後に AND XOR
	while(/(?<![A-Z])([A-Z])\s*\-?\s*(AND|XOR)/g){
		write_log($i+1, $line, "アドレス$1直後に$2があります。", "アドレス$1直後に$2");
	}	
	#アドレス直後にOR (X以外) YOR   
	while(/(?<![A-Z])([A-WY-Z])\s*\-?\s*(OR)/g){
		write_log($i+1, $line, "アドレス$1直後に$2があります。", "アドレス$1直後に$2");
	}
	
	$tmp= $_;
	s/(IF|WHILE|THEN|DO\s*\d*|END\s*\d*|GOTO\s*\d*|(EQ|NE|GT|LT|GE|LE)\s*\-?\d*\.*\d*|ABS|SQRT|SIN|COS|ATAN|TAN|ROUND|FUP|FIX|BSC|BIN|AND|XOR|OR)//g;
	#アドレスに数値なし XY10.0
#	if(/(?<![A-Z])[A-Z][A-Z\s]/ and $error_flag != 2){
	if($error_flag != 2){
		while(/(?<![A-Z])([A-Z])[A-Z\s]/g){ 
			write_log($i+1, $line, "アドレス$1に数値がありません。","アドレス$1に数値がない");
		}
	}
	$_= $tmp;
	
	#関数の後に [ なし
	while(/(?<![A-Z])((IF|WHILE|ABS|SQRT|SQR(?!T)|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR))(?!\s*\[)/g){
		write_log($i+1, $line, "$1の直後に [ が必要です。","$1直後に [ がない");
	}
	
	#数値の直後に関数や#1、[など
	if(/(\-?[\d\.]+)\s*(\[|\#|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		write_log($i+1, $line, "数値$1の直後に$2があります。アドレスか演算子が必要です。","数値$1の直後に$2");
	}
	# ]の直後に数値や関数など
	if(/\]\s*(\d+|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		write_log($i+1, $line, "] の直後に数値$1があります。アドレスか演算子が必要です。","] の直後に数値$1");
	}
	# [の直前に数値
	if(/(\-?[\d\.]+)\s*\[/){
		write_log($i+1, $line, "数値$1の直後に [ があります。アドレスか演算子が必要です。","数値$1の直後に [");
	}


# カスタムマクロ対応のため
#	#アドレスに数値なし
#	if(/(?<![A-Z])[A-Z][A-Z\s]/ and $macro_flag == 0 and $error_flag != 2){
#		write_log($i+1, $line, "アドレスに数値がありません。","アドレスに数値がない");
#	}
#	#アドレスの直前にマイナス
#	if(/\-\s*[A-Z]/ and $macro_flag == 0){
#		write_log($i+1, $line, "アドレスの直前にマイナスがあります。文法ミスです。", "アドレスの直前にマイナス");
#	}
#	#マイナスと数字の間にスペース
#	if(/(?<![A-Z])[A-Z]\-\s+\d+\.?\d*/ and $macro_flag == 0){
#		write_log($i+1, $line, "マイナスと数字の間にスペースがあります。文法ミスです。", "マイナスと数字の間にスペース");
#	}
	
	#長さアドレスに小数点なし
#	if($DP_warn_flag == 0 and $macro_flag == 0){
	
	#マクロ呼び出しの引数には小数点いらない
	if($DP_warn_flag == 0 and !/(?<![A-Z])G6[56](?!\d)/){
		while(/(?<![A-Z])([XYZIJKRQ])\-?(\d+\.?\d*|\.\d+)/g){
			my ($address, $post_line)= ($1, $');
			if ($2 ne "0" and $2 !~ /\./){
				#四則演算の場合は小数点いらない
				if($post_line !~ /^\s*[\+\-\*\/]/){
					write_log($i+1, $line, "長さのアドレス$addressの数値に小数点がありません。", "アドレス$addressの数値に小数点がない");
				}
			};
		
		}
		#if(check_DP($_)== 1 and !/(?<![A-Z])G6[56](?!\d)/){
		#	write_log($i+1, $line, "長さのアドレスに小数点がありません。", "XYZIJKRに小数点がない");
		#}
	}
	#Sコードに小数点あり
	if($S_DP_flag == 0){
		if(/(?<![A-Z])S\d+\.\d*/ and !/(?<![A-Z])G6[56](?!\d)/){
			if($' !~ /\s*[\+\-\*\/]/){
				write_log($i+1, $line, "Sコードの数値に小数点がついています。", "Sコードに小数点");
			}
		}
	}
	if($error_flag == 2){ $error_flag= 1; }
	
	return $_;
}

sub before_O_other_code_check{
	my (@prog)= @_;
	my $i, $flag = 0;
	
	for($i=0;$i<=$#prog-1;$i++){
		$_= $prog[$i];
		s/\(.*?\)//;	#コメント除去
		if(/(?<![A-Z])[A-NP-Z]\-?\d+\.?\d*/){ $flag = 1; }
	}
	$_= $prog[$#prog];
	if(/(?<![A-Z])O[0-9]+/){
		if($`=~ /(?<![A-Z])[A-Z][\-\d\.]/){ $flag = 1; }
	}
	return $flag;
}

sub multi_O_check{
	my (@prog)= @_;
	my $i, $n = 0;
	
	for($i=0;$i<=$#prog-1;$i++){
		$_= $prog[$i];
		s/\(.*?\)//;	#コメント除去
		if(/(?<![A-Z])O\d+/){ $n++; }
	}
	if($n == 0){ return 0; }
	else{ return 1; }
}

#sub check_DP{
#	($_)= @_;
#	my $DP= 0;
#	my $post_line;
#	
#	while(/(?<![A-Z])[XYZIJKRQ]\-?(\d+\.?\d*|\.\d+)/g){
#		$post_line= $';
#		if ($1 ne "0" and $1 !~ /\./){
#			#四則演算の場合は小数点いらない
#			if($post_line !~ /^\s*[\+\-\*\/]/){ $DP=1; }
#		};
#	}
#	return $DP;
#}

sub hikisuu_watashi{
	($_)= @_;
	my ($mode_J,$mode_K,$IJK);
	$IJK= 0;
	while(/(?<![A-Z])([ABCDEFIJKHMQRSTUVWXYZ])([0-9\.\-]+)/g){
		($char,$num)= ($1,$2);
		if($char=~ /[ABCDEFHMQRSTUVWXYZ]/){
			$local_value[$macro_level][$c{$char}]= $num;
#			if($debug_flag == 1){ print OUT '(---#'.$c{$char}.'= '.$num.'---)'."\n"; }
		}
		elsif($char =~ /I/){
			$IJK++;
			($mode_J,$mode_K)= (0,0);
			$local_value[$macro_level][3*$IJK+1]= $num;
#			if($debug_flag == 1){ print OUT '(---#'.(3*$IJK+1).'= '.$num.'---)'."\n"; }
		}
		elsif($char =~ /J/){
			if($IJK == 0 or $mode_J == 1 or $mode_K == 1){
				$IJK++;
				$mode_K= 0;
			}
			$mode_J= 1;
			$local_value[$macro_level][3*$IJK+2]= $num;
#			if($debug_flag == 1){ print OUT '(---#'.(3*$IJK+2).'= '.$num.'---)'."\n"; }
		}
		elsif($char =~ /K/){
			if($IJK == 0 or $mode_K == 1){
				$IJK++;
			}
			$mode_K= 1;
			$local_value[$macro_level][3*$IJK+3]= $num;
#			if($debug_flag == 1){ print OUT '(---#'.(3*$IJK+3).'= '.$num.'---)'."\n"; }
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
	
	#最初に読み込んだファイル中にサブプログラムがあるか
	for($i=0;$i<=$#main;$i++){
		$_= $main[$i];
		#ターゲットのプログラム番号が出てきたら読み込み開始
		if(/^\s*O0*$prog_No/){ ($prog_flag1,$prog_flag2)= (1,1); }
		#違うプログラム番号が出てきたら読み込みやめ
		elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }
		
		if($prog_flag2 == 1){ push(@prog,$_); }
	}
	#サブプログラム等を読み込んだ先のファイル中で別のサブプログラムを探す
	if($prog_flag1 == 0){
		for($i=0;$i<=$#present_prog;$i++){
			$_= $present_prog[$i];
			if(/^\s*O0*$prog_No/){ ($prog_flag1,$prog_flag2)= (1,1); }
			elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }
			
			if($prog_flag2 == 1){ push(@prog,$_); }
		}
	}
	#読み込みファイルと同じフォルダ中でサブプログラムのファイルを探す
	if($prog_flag1 == 0){
		foreach(@sub_files2){
			if(/O0*$prog_No(?!\d)/){
				$prog_file= $pre_folder.$_;
				last;
			}
		}
		#設定したサブプログラムのフォルダでサブプログラムのファイルを探す
		if(! defined($prog_file)){
			foreach(@sub_files){
				if(/O0*$prog_No(?!\d)/){
					$prog_file= $sub_folder.$_;
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
	$M99_exist= 0;
	
	$line= main_henkan($line);
	if($line =~ /(?<![A-Z])P0*([0-9]+)/){
		$macro_No= $1;
		if($line =~ /(?<![A-Z])L([0-9]+)/){ $kurikaeshi_suu= $1; }
		else{ $kurikaeshi_suu= 1; }
		
		@macro= prog_yomikomi($macro_No);
		if(! @macro){
#			print OUT $line;
#			print OUT '(---O'.$macro_No.'が見つかりません---)'."\n";
			write_log($gyou+1, $line, "マクロプログラム O$macro_No が見つかりません。", "G65で O$macro_No が見つからない。");
			return $gyou;
		}
		
		$macro_level++;
		$yobidashi_tajuudo++;
		if($macro_level == 5){
#			print OUT '(---マクロ多重度が限度を超えました---)'."\n";
			write_log( $gyou, $line, "マクロ多重度が限度を超えました", "G65でマクロ多重度が限度を超えた");
			exit_shori();
		}
		if($yobidashi_tajuudo == 9){
#			print OUT '(---呼び出し多重度が限度を超えました---)'."\n";
			write_log( $gyou, $line, "呼び出し多重度が限度を超えました", "G65で呼び出し多重度が限度を超えた");
			exit_shori();
		}
		
#		print OUT '(---G65 start---)'."\n";
		
		for($j=1;$j<=$kurikaeshi_suu;$j++){
#			print OUT '(---O'.$macro_No.' start---)'."\n";
			modal_shori(4115,$macro_No);
			hensuu_haki();
			hikisuu_watashi($line);
			for($i=0;$i<=$#macro;$i++){
				$_= $macro[$i];
#			 	original_print($_);
				
				#コメント除去されたものが戻る
#				$_ = bunpou_check($_, $i, $value[4115], @macro);
				$_ = bunpou_check($_, $i, @macro);
				
				if(/^\s*\/\d?/){
					if($OBS_switch == 1){
						OBS_skip_print();
						next;
					}
					else{ $_= $'; }
				}
				
#				if(!/^\s*\%/){
#					if(/^\s*(O[0-9]+)/){
#						print OUT '('.$1.')'.$';
#					}
#					else{
						if(/^\s*N0*([0-9]+)/){
							modal_shori(4114,$1);
							$_= $';
						}
						
#						shikaku_kakko_kensa($_);
						shikaku_kakko_kensa($_, $i);
						
						if(/IF/){ $i= bunki_shori($_,$i,@macro); }
#						elsif(/GOTO/){ $i= idou_shori($_,@macro); }
						elsif(/GOTO/){ $i= idou_shori($_, $i, @macro); }
						elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$macro_No,@macro); }
						elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$macro_No,@macro); }
						elsif(/^\s*G65/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
							$i= macro_G65($_,$i);
							modal_shori(4115,$macro_No);
$progKaisou =~ s/^\/[^\/]*//;
						}
						elsif(/^\s*G66/){ $i= macro_G66($_,$i,$macro_No,@macro); }
						elsif(/^\s*M98/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
							$i= sub_M98($_,$i);
							modal_shori(4115,$macro_No);
$progKaisou =~ s/^\/[^\/]*//;
						}
						else{
							$_= main_henkan($_);
							
							if(/(?<![A-Z])M99(?!\d)/){
								$_= $`.$';
								if(/(?<![A-Z])[A-MO-Z]/){ extra_print($_, $i); }
#								print OUT '(---O'.$macro_No.' end---)'."\n";
								$M99_exist= 1;
								last;
							}
							elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
							else{ extra_print($_, $i); }
						}
						
						if($i eq "M99"){
#							print OUT '(---O'.$macro_No.' end---)'."\n";
							$M99_exist= 1;
							last;
						}
						elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
#					}
#				}
			}
		}
		$macro_level--;
		$yobidashi_tajuudo--;
#		print OUT '(---G65 end---)'."\n";
		if($M99_exist == 0){
			$line =~ s/\s*$//;
			write_log2("$line ← O$macro_No にM99がありません。","G65で使用する O$macro_No にM99がない");
		}
		return $gyou;
	}
	
	else{
#		print OUT $line;
#		print OUT '(---プログラム番号が指定されていません---)'."\n";
		write_log($gyou+1, $line, "G65で呼び出すプログラム番号をPコードで指令してください。", "M65にPコードがない");
		exit_shori();
	}
}

sub macro_G66{
	my ($line,$G66_start,$parent_prog_No,@prog)= @_;
	my ($i,$j,$macro_No,$G66_end,$G66_flag,$kurikaeshi_suu,$idou_sequence,@macro);
	my $M99_exist= 0;
	
	$line= main_henkan($line);
	if($line =~ /(?<![A-Z])P0*([0-9]+)/){
		$macro_No= $1;
		
		if($line =~ /(?<![A-Z])L([0-9]+)/){ $kurikaeshi_suu= $1; }
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
#			print OUT '(---G67がありません---)'."\n";
			write_log($G66_start+1, $line, "対応するG67がありません。", "G66に対応するG67がない");
			exit_shori();
		}
		
		@macro= prog_yomikomi($macro_No);
		if(! @macro){
			for($i=$G66_start; $i<=$G66_end; $i++){
				$_= $prog[$i];
#				print OUT;
			}
#			print OUT '(---O'.$macro_No.'が見つかりません---)'."\n";
			write_log($G66_start+1, $line, "マクロプログラム O$macro_No が見つかりません。", "G66で O$macro_No が見つからない。");
			return $G66_end;
		}
		
#		print OUT '(---G66 modal mode --O'.$macro_No.'-- start---)'."\n";
		$G66_modal_tajuudo++;
		if($G66_modal_tajuudo == 1){ modal_shori(4012,66); }
		G66_modal_touroku($G66_modal_tajuudo,$line,$macro_No,$kurikaeshi_suu,@macro);
		
		$macro_level++;
		hensuu_haki();
		hikisuu_watashi($line);
		$macro_level--;
		
		# H30.03.27,28
		#G66_modal_yobidashi($G66_modal_tajuudo - $G66_yobidashi_tajuudo);

		for($i=$G66_start+1; $i<=$G66_end-1; $i++){
			$_= $prog[$i];
			
#$G66_lineNumList[$G66_modal_tajuudo] = $i;
#if($G66_modal_tajuudo == 1){ $tmpLineNum = $i; }
#if($G66_modal_tajuudo - $G66_yobidashi_tajuudo == 1){ $tmpLineNum = $i; }
#if($G66_yobidashi_tajuudo == 0){ $tmpLineNum = $i; }
$G66_lineNumList[$G66_yobidashi_tajuudo] = $i;
 #			original_print($_);
			
			#コメント除去されたものが戻る
#			$_ = bunpou_check($_, $i, $value[4115], @prog);
			$_ = bunpou_check($_, $i, @prog);
			
			if(/^\s*\/\d?/){
				if($OBS_switch == 1){
					OBS_skip_print();
					next;
				}
				else{ $_= $'; }
			}
			
#			if(!/^\s*\%/){
				if(/^\s*N0*([0-9]+)/){
					modal_shori(4114,$1);
					$_= $';
				}
#				if(/\(/){
#					$_= kakko_print($_);
#				}

#				shikaku_kakko_kensa($_);
				shikaku_kakko_kensa($_, $i);
				
				if(/IF/){ $i= bunki_shori($_,$i,@prog); }
#				elsif(/GOTO/){ $i= idou_shori($_,@prog); }
				elsif(/GOTO/){ $i= idou_shori($_, $i, @prog); }
				elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$parent_prog_No,@prog); }
				elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$parent_prog_No,@prog); }
				elsif(/^\s*N?[0-9]*\s*G65/){ 
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
					$i= macro_G65($_,$i);
					modal_shori(4115,$parent_prog_No);
$progKaisou =~ s/^\/[^\/]*//;
				}
				elsif(/^\s*N?[0-9]*\s*G66/){
					$i= macro_G66($_,$i,$parent_prog_No,@prog);
				}
				elsif(/^\s*N?[0-9]*\s*M98/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
					$i= sub_M98($_,$i);
					modal_shori(4115,$parent_prog_No);
$progKaisou =~ s/^\/[^\/]*//;
				}
				else{
					$_= main_henkan($_);
					
					if(/(?<![A-Z])M99(?!\d)/){
						$_= $`.$';
						if(/(?<![A-Z])[A-MO-Z]/){ extra_print($_, $i); }
						last;
					}
					elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
					else{ extra_print($_, $i); }
				}
				
				if($i eq "M99"){
#					print OUT '(---O'.$prog_No.' end---)'."\n";
					return $i;
				}
				elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
#			}
		}
#		print OUT '(---G66 modal mode --O'.$macro_No.'-- end---)'."\n";
		$G66_modal_tajuudo--;
		if($G66_modal_tajuudo == 0){ modal_shori(4012,67); }
		return $G66_end;
	}
	else{
#		print OUT $line;
#		print OUT '(---プログラム番号が指定されていません---)'."\n";
		write_log($G66_start+1, $line, "モーダル呼び出しを行うプログラム番号が指令されていません。Pコードで指令してください。", "G66でPコードがない");
		exit_shori();
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
	my $M99_exist = 0;
	
	$parent_prog_No= $value[4115];
	$G66_yobidashi_tajuudo++;
	
#	print OUT '(---G66 modal --O'.$macro_No.'-- start---)'."\n";
	for($j=1;$j<=$kurikaeshi_suu;$j++){
		$macro_level++;
		$yobidashi_tajuudo++;
		if($macro_level == 5){
#			print OUT '(---マクロ多重度が限度を超えました---)'."\n";
			write_log2("マクロ多重度が限度を超えました","G66でマクロ多重度が限度を超えた");
			exit_shori();
		}
		if($yobidashi_tajuudo == 9){
#			print OUT '(---呼び出し多重度が限度を超えました---)'."\n";
			write_log2("呼び出し多重度が限度を超えました","G66で呼び出し多重度が限度を超えた");
			exit_shori();
		}

#		print OUT '(---O'.$macro_No.' start---)'."\n";
		modal_shori(4115,$macro_No);
		
#		hensuu_haki();
#		hikisuu_watashi($line);
		
		for($i=0;$i<=$#macro;$i++){
			$_= $macro[$i];
#			original_print($_);
$G66_lineNumList[$G66_yobidashi_tajuudo] = $i;

			#コメント除去されたものが戻る
#			$_ = bunpou_check($_, $i, $value[4115], @macro);
			$_ = bunpou_check($_, $i, @macro);
			
			if(/^\s*\/\d?/){
				if($OBS_switch == 1){
					OBS_skip_print();
					next;
				}
				else{ $_= $'; }
			}
			
#			if(!/^\s*\%/){
#				if(/^\s*(O[0-9]+)/){ print OUT '('.$1.')'.$'; }
#				else{
					if(/^\s*N0*([0-9]+)/){
						modal_shori(4114,$1);
						$_= $';
					}
#					if(/\(/){
#						$_= kakko_print($_);
#					}
					
#					shikaku_kakko_kensa($_);
					shikaku_kakko_kensa($_, $i);
					
					if(/IF/){ $i= bunki_shori($_,$i,@macro); }
#					elsif(/GOTO/){ $i= idou_shori($_,@macro); }
					elsif(/GOTO/){ $i= idou_shori($_, $i, @macro); }
					elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$macro_No,@macro); }
					elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,@macro); }
					elsif(/^\s*G65/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
						$i= macro_G65($_,$i);
						modal_shori(4115,$macro_No);
$progKaisou =~ s/^\/[^\/]*//;
					}
					elsif(/^\s*G66/){ $i= macro_G66($_,$i,$macro_No,@macro); }
					elsif(/^\s*M98/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
						$i= sub_M98($_,$i);
						modal_shori(4115,$macro_No);
$progKaisou =~ s/^\/[^\/]*//;
					}
					else{
						$_= main_henkan($_);
						if(/(?<![A-Z])M99(?!\d)/){
							$_= $`.$';
							if(/[A-MO-Z]/){ extra_print($_, $i); }
#							print OUT '(---O'.$macro_No.' end---)'."\n";
							$M99_exist= 1;
							last;
						}
						elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
						else{ extra_print($_, $i); }
					}
					
					if($i eq "M99"){
#						print OUT '(---O'.$macro_No.' end---)'."\n";
						$M99_exist= 1;
						last;
					}
					elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
#				}
#			}
		}
		$macro_level--;
		$yobidashi_tajuudo--;
	}
	if($M99_exist == 0){
		$line =~ s/\s*$//;
		write_log2("$line ← O$macro_No にM99がありません。","G66で使用する O$macro_No にM99がない");
	}
#	print OUT '(---G66 modal --O'.$macro_No.'-- end---)'."\n";
	$G66_yobidashi_tajuudo--;
	modal_shori(4115,$parent_prog_No);
}

sub sub_M98{
	my ($line,$gyou)= @_;
	my ($i,$j,$k,$kurikaeshi_suu,$prog_No,$jikkou_bun,@sub);
	my $M99_exist= 0;
	
	$_= main_henkan($line);
	if(/(?<![A-Z])M98\s*P([0-9]+)\s*/){
		$jikkou_bun= $`.$';
		if($M98_houshiki == 0){
			$prog_No= $1;
			
			if($jikkou_bun =~ /(?<![A-Z])L([0-9]+)/){
				$jikkou_bun= $`.$';
				$kurikaeshi_suu= $1;
			}
			else{ $kurikaeshi_suu= 1; }
		}
		else{
			if(length($1) <= 4){
				$prog_No= $1;
				if($jikkou_bun =~ /(?<![A-Z])L([0-9]+)/){
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
		if($jikkou_bun =~ /(?<![A-Z])[A-KMO-Z]/){
			$jikkou_bun= main_henkan($jikkou_bun);
			extra_print($jikkou_bun, $i);
		}
		
		@sub= prog_yomikomi($prog_No);
		if(! @sub){
#			print OUT $line;
#			print OUT '(---O'.$prog_No.'が見つかりません---)'."\n";
			write_log($gyou+1, $line, "Pで指令しているプログラム O$prog_No が見つかりません", "サブプロ O$prog_No が見つからない。");
			return $gyou;
		}
		
		$yobidashi_tajuudo++;
		if($yobidashi_tajuudo == 9){
#			print OUT '(---呼び出し多重度が限度を超えました---)'."\n";
			write_log($gyou+1, $line, "呼び出し多重度が限度を超えました。","サブプロで呼び出し多重度オーバー");
			exit_shori();
		}
		
#		print OUT '(---M98 start---)'."\n";
		for($j=1;$j<=$kurikaeshi_suu;$j++){;
#			print OUT '(---O'.$prog_No.' start---)'."\n";
			modal_shori(4115,$prog_No);
			for($i=0;$i<=$#sub;$i++){
				$_= $sub[$i];
#				original_print($_);
				
				#コメント除去されたものが戻る
#				$_ = bunpou_check($_, $i, $prog_No, @sub);
				$_ = bunpou_check($_, $i, @sub);
				
				if(/^\s*\/\d?/){
					if($OBS_switch == 1){
					OBS_skip_print();
					next;
					}
					else{ $_= $'; }
				}
				
#				if(!/^\s*\%/){
#					if(/^\s*(O[0-9]+)/){
#						print OUT '('.$1.')'.$';
#					}
#					else{
						if(/^\s*N0*([0-9]+)/){
							modal_shori(4114,$1);
							$_= $';
						}
#						if(/\(/){
#							$_= kakko_print($_);
#						}
						
#						shikaku_kakko_kensa($_);
						shikaku_kakko_kensa($_, $i);
						
						if(/IF/){ $i= bunki_shori($_,$i,@sub); }
#						elsif(/GOTO/){ $i= idou_shori($_,@sub); }
						elsif(/GOTO/){ $i= idou_shori($_, $i, @sub); }
						elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$prog_No,@sub); }
						elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$prog_No,@sub); }
						elsif(/^\s*G65/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
							$i= macro_G65($_,$i);
							modal_shori(4115,$prog_No);
$progKaisou =~ s/^\/[^\/]*//;
						}
						elsif(/^\s*G66/){ $i= macro_G66($_,$i,$prog_No,@sub); }
						elsif(/^\s*M98/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
							$i= sub_M98($_,$i);
							modal_shori(4115,$prog_No);
$progKaisou =~ s/^\/[^\/]*//;
						}
						else{
							$_= main_henkan($_);
							if(/(?<![A-Z])M99(?!\d)/){
								$_= $`.$';
								if(/(?<![A-Z])[A-MO-Z]/){ extra_print($_, $i); }
#								print OUT '(---O'.$prog_No.' end---)'."\n";
								$M99_exist= 1;
								last;
							}
							elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
							else{ extra_print($_, $i); }
						}
						
						if($i eq "M99"){
#							print OUT '(---O'.$prog_No.' end---)'."\n";
							$M99_exist= 1;
							last;
						}
						elsif($i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
#					}
#				}
			}
		}
		if ($M99_exist == 0){
			$line =~ s/\s*$//;
			write_log2("$line ← O$prog_No にM99がありません。","M98で使用する O$prog_No にM99がない");
		}
#		print OUT '(---M98 end---)'."\n";
		$yobidashi_tajuudo--;
		return $gyou;
	}
	else{
#		print OUT $line;
#		print OUT '(---プログラム番号が指定されていません---)'."\n";
		write_log($gyou+1, $_, "M98で呼び出すプログラム番号をPコードで指令してください。", "M98にPコードがない。");
		exit_shori();
	}
}

sub idou_shori{
#	my ($line,@prog)= @_;
	my ($line,$gyou,@prog)= @_;
	my ($i,$idou_sequence);
	
	$_= main_henkan($line);
	if(/GOTO\s*0*([0-9]+)/){
		$idou_sequence= $1;
		$GOTO_count++;
		if($GOTO_count > $GOTO_exe_max){
			write_log($gyou+1, $line, "GOTO実行回数が上限値$GOTO_exe_maxを超えました。", "GOTO実行回数が上限値$GOTO_exe_maxを超えた");
			exit_shori();
		}
		
		for($i=0;$i<=$#prog;$i++){
			if($prog[$i] =~ /^\s*N0*([0-9]+)/){
				if($1 == $idou_sequence){
#					if($debug_flag == 1){ print OUT '(---move to N' . $idou_sequence .'---)'."\n"; }
					return ($i - 1);
				}
			}
		}
		
#		print OUT '(---N'.$idou_sequence.'がありません---)'."\n";
		write_log($gyou+1, $line, "移動先の N$idou_sequence がありません。", "GOTOに対するN$idou_sequenceがない");
		exit_shori();
	}
	else{
#		print OUT '(---GOTO文が正しくありません---'."\n";
		write_log($gyou+1, $line, "GOTO文が正しくありません。", "GOTO文が正しくない");
		exit_shori();
	}
}

sub bunki_shori{
	my ($line,$gyou,@prog)= @_;
	my ($joukenshiki,$jikkoubun,$flag);
	
	$_= $line;
	if(/IF\s*\[\s*(.+)\s*\]\s*(GOTO\s*)/){
		($joukenshiki,$jikkoubun)= ($1,$2.$');
		
		while($joukenshiki =~ /(==|=|<>|>=|<=|>|<)/g){
			write_log($gyou+1, $line, "条件式に $1 は使えません。$jouken_hash{$1} に書き換えてください", "条件式に $1");
		}
		$flag= jouken_handan($joukenshiki);
		if($flag == 1){
#			if($debug_flag == 1){ print OUT '(---true---)'."\n"; }
			#2020.03.30
			#$gyou= idou_shori($jikkoubun,$gyou,@prog);
			$gyou= idou_shori($line,$gyou,@prog);
			return $gyou;
		}
		else{
#			if($debug_flag == 1){ print OUT '(---false---)'."\n"; }
			return $gyou;
		}
	}
	elsif(/IF\s*\[\s*(.+)\s*\]\s*THEN\s*/){
		($joukenshiki,$jikkoubun)= ($1,$');
		
		while($joukenshiki =~ /(==|=|<>|<=|>=|>|<)/g){
			write_log($gyou+1, $line, "条件式に $1 は使えません。$jouken_hash{$1} に書き換えてください", "条件式に $1");
		}
		$flag= jouken_handan($joukenshiki);
		if($flag == 1){
#			if($debug_flag == 1){ print OUT '(---true---)'."\n"; }
			$_= main_henkan($jikkoubun); 
			if(/(?<![A-Z])M99(?!\d)/){
				$_= $`.$';
				if(/(?<![A-Z])[A-Z]/){ extra_print($_, $gyou); }
				return "M99";
			}
			elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
			else{ extra_print($_, $gyou); }
			return $gyou;
		}
		else{
#			if($debug_flag == 1){ print OUT '(---false---)'."\n";}
			return $gyou;
		}
	}
	else{
#		print OUT '(---IF文が正しくありません---'."\n";
		write_log($gyou+1, $line, "IF文が正しくありません", "IF文が正しくない");
		return $gyou;
	}
}

sub kurikaeshi_shori{
	my ($line, $while_start, $parent_prog_No, @prog)= @_;
	my ($i, $while_end, $joukenshiki, $shikibetsu_bangou);
	
	$_= $line;
	if(/WHILE\s*\[\s*(.+)\s*\]\s*DO\s*([123])/){
		($joukenshiki, $shikibetsu_bangou)= ($1, $2);
		
		while($joukenshiki =~ /(==|=|<>|<=|>=|>|<)/g){
			write_log($while_start+1, $line, "条件式に $1 は使えません。$jouken_hash{$1} に書き換えてください", "条件式に $1");
		}
		
		for($i=$while_start+1; $i<=$#prog; $i++){
			$_= $prog[$i];
			if(/^\s*N?[0-9]*\s*END\s*$shikibetsu_bangou/){
				$while_end= $i;
				last;
			}
		}
		if(! defined($while_end)){
#			print OUT '(---END'.$shikibetsu_bangou.'がありません---)'."\n";
			write_log( $i+1, $line, "END$shikibetsu_bangouがありません", "DO$shikibetsu_bangouに対応するEND$shikibetsu_bangouがない");
			exit_shori();
		}
		
		my $loopCount= 0;
		for(;;){
			$loopCount++;
			$flag= jouken_handan($joukenshiki);
			
			if($flag == 0){
#				if($debug_flag == 1){ print OUT '(---DO'.$shikibetsu_bangou.' false---)'."\n"; }
				return $while_end;
			}
#			if($debug_flag == 1){ print OUT '(---DO'.$shikibetsu_bangou.' true---)'."\n"; }
			for($i=$while_start+1;$i<=$while_end-1;$i++){
				$_= $prog[$i];
#				original_print($_);
				
				if(/^\s*\/\d?/){
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
				if(/\(/){
#					$_= kakko_print($_);
					($_,$zenkakuComment) = comment_jokyo($_,$i);
					if($zenkakuComment == 1 and $ComZen_warn_flag == 0){
						write_log($i+1, $prog[$i], "コメント文に全角文字を含んでいます。", "コメント文に全角文字を含む");
					}
				}
				
#				shikaku_kakko_kensa($_);
				shikaku_kakko_kensa($_, $i);
				
				if(/IF/){ $i= bunki_shori($_, $i, @prog); }
#				elsif(/GOTO/){ $i= idou_shori($_, @prog); }
				elsif(/GOTO/){ $i= idou_shori($_, $i, @prog); }
				elsif(/WHILE/){ $i= kurikaeshi_shori($_, $i, $parent_prog_No, @prog); }
				elsif(/DO/){ $i= kurikaeshi_shori2($_, $i, $parent_prog_No, @prog); }
				elsif(/^\s*G65/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
					$i= macro_G65($_, $i);
					modal_shori(4115, $parent_prog_No);
$progKaisou =~ s/^\/[^\/]*//;
				}
				elsif(/^\s*N?[0-9]*\s*G66/){ $i= macro_G66($_, $i, $parent_prog_No, @prog); }
				elsif(/^\s*N?[0-9]*\s*M98/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
					$i= sub_M98($_, $i);
					modal_shori(4115,$parent_prog_No);
$progKaisou =~ s/^\/[^\/]*//;
				}
				else{
					$_= main_henkan($_);
					if(/(?<![A-Z])M99(?!\d)/){
						$_= $`.$';
						if(/(?<![A-Z])[A-Z]/){ extra_print($_, $i); }
						return "M99";
					}
					elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
					else{ extra_print($_, $i); }
				}
				#2018.02.23
				#if($i > $while_end){ return $i; }
				if( $i < $while_start or $i >= $while_end){ return $i; }
				elsif($i eq "M99" or $i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
			}
			
			if($loopCount > $loop_max){
				write_log($while_start+1, $line, "ループ回数が上限数$loop_maxを超えました。","ループ回数が上限数$loop_maxを超えた");
				exit_shori();
			}
		}
	}
	else{
#		print OUT '(---WHILE構文が正しくありません---)'."\n";
		write_log($while_start+1, $line, "WHILE文が正しくありません", "WHILE文が正しくない");
		return $while_start;
	}
}

sub jouken_handan{
	($line)= @_;
	my ($pre_line,$post_line,$pre_pre_line,$post_post_line,$copy_pre_line,$reverse_post_line);
	my ($sahen,$jouken,$uhen,$flag);
	my ($hiraki_kakko,$toji_kakko,$length,$char,$i);
	
	$line= '['.$line.']';
	while($line =~ /\s*(EQ|NE|GT|LT|GE|LE)\s*/){
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
	$line= main_henkan($line);
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

sub joukennai_henkan{
	($_,$jouken)= @_;
	
	$_= main_henkan($_);
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
				$_= main_henkan($_);
			}
		}
		else{
			$_= $pre_line."0".$post_line;
			$_= main_henkan($_);
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
#			print OUT '(---END'.$shikibetsu_bangou.'がありません---)'."\n";
			write_log($do_start+1, $line, "END$shikibetsu_bangouがありません","DO$shikibetsu_bangouに対応するEND$shikibetsu_bangouがない");
			exit_shori();
		}
		
		my $loopCount=0;
		for(;;){
			$loopCount++;
			for($i=$do_start+1;$i<=$do_end-1;$i++){
				$_= $prog[$i];
#				original_print($_);
				
				if(/^\s*\/\d?/){
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
				if(/\(/){
#					$_= kakko_print($_);
					($_,$zenkakuComment) = comment_jokyo($_,$i);
					if($zenkakuComment == 1 and $ComZen_warn_flag == 0){
						write_log($i+1, $prog[$i], "コメント文に全角文字を含んでいます。", "コメント文に全角文字を含む");
					}
				}
				
#				shikaku_kakko_kensa($_);
				shikaku_kakko_kensa($_, $i);
				
				if(/IF/){ $i= bunki_shori($_,$i,@prog); }
#				elsif(/GOTO/){ $i = idou_shori($_,@prog); }
				elsif(/GOTO/){ $i = idou_shori($_,$i,@prog); }
				elsif(/WHILE/){ $i= kurikaeshi_shori($_,$i,$parent_prog_No,@prog); }
				elsif(/DO/){ $i= kurikaeshi_shori2($_,$i,$parent_prog_No,@prog); }
				elsif(/^\s*G65/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
					$i= macro_G65($_,$i);
					modal_shori(4115,$parent_prog_No);
$progKaisou =~ s/^\/[^\/]*//;
				}
				elsif(/^\s*G66/){ $i= macro_G66($_,$i,$parent_prog_No,@prog); }
				elsif(/^\s*M98/){
$progKaisou= "/O$value[4115] L" . ($i+1) . $progKaisou;
					$i= sub_M98($_,$i);
					modal_shori(4115,$parent_prog_No);
$progKaisou =~ s/^\/[^\/]*//;
				}
				else{
					$_= main_henkan($_);
					
					if(/(?<![A-Z])M99(?!\d)/){
						$_= $`.$';
						if(/(?<![A-Z])[A-Z]/){ extra_print($_, $i); }
						return "M99";
					}
					elsif(/(?<![A-Z])(M30)(?!\d)/ or /(?<![A-Z])(M0?2)(?!\d)/){ return $1; }
					else{ extra_print($_, $i); }
				}
				
				#2018.02.23
				#if($i > $do_end){ return $i; }
				if($i < $do_start or $i >= $do_end){ return $i; }
				elsif($i eq "M99" or $i eq "M30" or $i eq "M02" or $i eq "M2"){ return $i; }
			}
			#無限ループ対策
			if($loopCount > $loop_max){
				write_log($do_start+1, $line, "ループ回数が上限数$loop_maxを超えました。","ループ回数が上限数$loop_maxを超えた");
				exit_shori();
			}
		}
	}
	else{ return $do_start; }
}

sub main_henkan{
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
	my $jozan_flag;
	
	while(/\#\s*(\-?)\s*\[\s*(\-?[0-9\.]+)\s*\]/g){ $_= $`."\#".$1.$2.$'; }
	while(/\-\s*\-/g){
		($pre_line,$post_line)= ($`,$');
		if($pre_line =~ /[0-9\.\]]\s*$/){ $_= $pre_line."\+".$post_line; }
		else{ $_= $pre_line.$post_line; }
	}
#	while(/(\-?[0-9\.]+)\s*\*\s*(\-?[0-9\.]+)/g){
	while(/([0-9\.]+)\s*\*\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$num2)= ($`,$',$1,$2);
		if($pre_line =~ /\/\s*$/){ $jozan_flag= 1; }
		elsif($pre_line !~ /\#\-?$/){ $_= $pre_line.naibu_marume($num1*$num2).$post_line; }
	}
#	while(/(\-?[0-9\.]+)\s*\/\s*(\-?[0-9\.]+)/g){
	while(/([0-9\.]+)\s*\/\s*(\-?[0-9\.]+)/g){
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
	while(/((\-?)[0-9\.]+)\s*\-\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$fugou,$num2)= ($`,$',$1,$2,$3);
		if($fugou ne ''){ $fugou = '+'; }
		else{ $fugou = ''; }
		
		if($pre_line !~ /\#$/ and $post_line !~ /^\s*[\*\/]/){ $_= $pre_line.$fugou.kagenzan($num1,$num2,'-').$post_line; }
	}
	while(/((\-?)[0-9\.]+)\s*\+\s*(\-?[0-9\.]+)/g){
		($pre_line,$post_line,$num1,$fugou,$num2)= ($`,$',$1,$2,$3);
		if($fugou ne ''){ $fugou = '+'; }
		else{ $fugou = ''; }
		
		if($pre_line !~ /\#$/ and $post_line !~ /^\s*[\*\/]/){ $_= $pre_line.$fugou.kagenzan($num1,$num2).$post_line; }
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
	while(/SIN\[\s*(\-?[0-9\.]+)\s*\]/g){$_= $`.naibu_marume(sin($1/$RAD)).$';}
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
			if($hensuu_No1 <= 33){
				$local_value[$macro_level][$hensuu_No1]= $1;
#				if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= '.$1.'---)'."\n"; }
			}
			else{
				if($hensuu_No1 == 3000){
					$alerm_No= 3000+$1;
#					print OUT '(---アラーム番号 '.$alerm_No.'---)'."\n";
					write_log2("システム変数3000番(アラーム番号)に $alerm_No が設定されました。","アラーム番号(システム変数3000)に$alerm_No");
					exit_shori();
				}
				else{
					$value[$hensuu_No1]= $1;
#					if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= '.$1.'---)'."\n"; }
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
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
					else{
						undef($value[$hensuu_No1]);
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
				}
			}
			else{
				if(! defined($value[$hensuu_No2])){
					if($hensuu_No1 <= 33){
						undef($local_value[$macro_level][$hensuu_No1]);
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
					}
					else{
						undef($value[$hensuu_No1]);
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <空>---)'."\n"; }
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
	if($modal_flag == 1){
#		print OUT '(----#'.$No.'= '.$num.'----)'."\n";
	}
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
#				print OUT '(^^ '.$_.' ^^)'."\n";
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
	my ($line, $gyou)= @_;
	my $kakko_suu= 0;
	
	while($line =~ /([\[\]])/g){
		if($1 eq '['){ $kakko_suu++; }
		else{
			$kakko_suu--;
			if($kakko_suu < 0){ last; }
		}
	}
	if($kakko_suu != 0){
#		print OUT '(---括弧が閉じていません---)'."\n";
		write_log($gyou+1, $line, "\[ \]が閉じていません。スクリプトを中止します。", "\[ \]が閉じていない。スクリプト中止");
		exit_shori();
	}
}

sub comment_jokyo{
	my ($comment, $gyou)= @_;
	my $zenkaku_flag= 0;
	
	$_= $comment;
	while(/\(.*?\)/){
		($pre_line,$post_line)= ($`,$');
		
		if(zenkaku_check($&)== 1){ $zenkaku_flag= 1; }
		#print OUT $&;
		
		NCVC_comment_check($&, $gyou);
		
		while($post_line =~ /\)/g){
			($post_pre_line,$post_post_line)= ($`,$');
			if($post_pre_line !~ /\(/){
				if(zenkaku_check($post_pre_line)== 1){ $zenkaku_flag= 1; }
#				print OUT $post_pre_line.')';
				$post_line= $post_post_line;
			}
		}
#		print OUT "\n";
		$_= $pre_line.$post_line;
	}

	if($_=~ /^\s*(N\d+)?\s*$/){ $_= ""; }
	return ($_, $zenkaku_flag);
}

sub NCVC_comment_check{
	my ($comment, $gyou)= @_;
	
	$_= $comment;
	if(/Work R.*\=/i){
		write_log($gyou+1, $_, "WorkとRectはスペースで区切りません。", "NCVC用コメント");
	}
	elsif(/Work C.*\=/i){
		write_log($gyou+1, $_, "WorkとCylinderはスペースで区切りません。", "NCVC用コメント");
	}
	elsif(/WorkR(?!ect).*\s*\=/i or /WarkRect\s*\=/i){
		write_log($gyou+1, $_, "WorkRectの誤り。", "NCVC用コメント");
	}
	elsif(/WorkC(?!ylinder).*\s*\=/i or /WarkCylinder\s*\=/i){
		write_log($gyou+1, $_, "WorkCylinderの誤り。", "NCVC用コメント");
	}
#	elsif(/\(\s*WorkRect\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){5}\s*\-?\d+\.?\d*\s*\))/i){
	elsif(/\(\s*WorkRect\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){5}\s*\-?\d+\.?\d*\s*\))/i and /\(\s*WorkRect\s*\=(?!(\s*\-?\d+\.?\d*\s*)x(\s*\-?\d+\.?\d*\s*)t(\s*\-?\d+\.?\d*\s*)\))/i){
		write_log($gyou+1, $_, "WorkRect=以降は、コンマで区切った6つの数値、または[X方向の大きさ]x[Y方向の大きさ]t[Z方向の大きさ]です。", "NCVC用コメント");
	}
#	elsif(/\(\s*WorkCylinder\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){4}\s*\-?\d+\.?\d*\s*\))/i){
	elsif(/\(\s*WorkCylinder\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){4}\s*\-?\d+\.?\d*\s*\))/i and /\(\s*WorkCylinder\s*\=(?!(\s*\-?\d+\.?\d*\s*)h(\s*\-?\d+\.?\d*\s*)\))/i){
		write_log($gyou+1, $_, "WorkCylinder=以降は、コンマで区切った5つの数値、または[直径]h[高さ]です。", "NCVC用コメント");
	}
	
	if(/\(\s*Endmil\s*\=/i or /\(\s*Endomil.*\s*\=/i or /\(\s*Emdo?mil.*\s*\=/i){
		write_log($gyou+1, $_, "Endmill の誤り。", "NCVC用コメント");
	}
	elsif(/\(\s*Do[rl]i(ll?|ru)\s*\=/i or /\(\s*Dril\s*\=/i or /\(\s*Dli(ll?|ru).*\s*\=/i){
		write_log($gyou+1, $_, "Drill の誤り。", "NCVC用コメント");
	}
	elsif(/\(\s*(Tapu|Tapp|Tappu)\s*\=/i){
		write_log($gyou+1, $_, "Tap の誤り。", "NCVC用コメント");
	}
	elsif(/\(\s*(R[ea]m[ea]r|Reamar|R(ea|[ea]|)n[ea]r)\s*\=/i){
		write_log($gyou+1, $_, "Reamer の誤り。", "NCVC用コメント");
	}
	
	if(/\(\s*Tap\s*\=/i){
		$tap_tool_flag= 1;
	}
	elsif(/\(\s*(Endmill|Drill|Reamer)\s*\=/i){
		$tap_tool_flag= 0;
	}
}

sub zenkaku_check{
	($_)= @_;
	
	if(/\P{ascii}+/){ return 1; }
	else{ return 0; }
}

#sub kakko_print{
#	($_)= @_;
#	while(/\(.*?\)/){
#		($pre_line,$post_line)= ($`,$');
#		print OUT $&;
#		while($post_line =~ /\)/g){
#			($post_pre_line,$post_post_line)= ($`,$');
#			if($post_pre_line !~ /\(/){
#				print OUT $post_pre_line.')';
#				$post_line= $post_post_line;
#			}
#		}
#		print OUT "\n";
#		$_= $pre_line.$post_line;
#	}
#	if($_ =~ /^\s*N?\d*\s*$/){ $_= ""; }
#	return $_;
#}

sub extra_print{
#	($line)= @_;
	($line, $gyou)= @_;

#	my ($new_line,$char,$str,$num,@modal);
# 2018.03.28
	my ($new_line,$char,$str,$num,$G66_modal_flag,@modal);
	my ($tmp);

	$G66_modal_flag= 0;
	$_= $line;
	while(/(?<![A-Z])([A-MO-Z])(\-?)([0-9\.]+)/){
		$_= $';
		($char,$str,$num)= ($1,$2,$3);
		$num= $str.shutsuryoku_marume($char,$num);
		$new_line= $new_line.$char.$num;
		
		if($char eq "G"){
			$value[4000 + $G_group{$num+0}]= $num;
			$value[4200 + $G_group{$num+0}]= $num;
#			push(@modal,'(----#'.(4000+$G_group{$num}).'= '.$num.'----)'."\n");
		}
		elsif($char =~ /[BDFHMST]/){
			$value[$system_value_modal{$char}]= $num;
			$value[$system_value_modal{$char}+200]= $num;
#			push(@modal,'(----#'.$system_value_modal{$char}.'= '.$num.'----)'."\n");
		}
	}
	if(/\s+$/){ $new_line= $new_line."\n"; }
#	print OUT $new_line;
#	if($modal_flag == 1){
#		foreach (@modal){ print OUT; }
#	}

	#固定サイクル中か
	$_ = $new_line;
	if(/(?<![A-Z])G(7[346]|8[1-9])(?!\d)/){
		
		#if( ( () = $new_line =~ /(?<![A-Z])G(7[346]|8[1-9])(?!\d)/g ) > 1){
		$tmp = "";
		my $kn = 0;
		while(/(?<![A-Z])G(7[346]|8[1-9])(?!\d)/g){
			$tmp .= $&.",";
			$kn ++ ;
		}
		if($kn > 1){
			$tmp =~ s/\,$//;
			write_log($gyou+1, $line, "1ブロック中で固定サイクルのコードが複数指令されています($tmp)。", "1ブロック中で複数の固定サイクル($tmp)");
		}
		
		#主軸が回転していない場合
		if($spindle_ON == 0 and not($M29_flag == 0 and /(?<![A-Z])G[78]4(?!\d)/)){
			if(/(?<![A-Z])G74(?!\d)/){
				write_log($gyou+1, $line, "主軸を回転させずに固定サイクル命令しています。", "主軸を回転させずに固定サイクル");
			}
			else{
				write_log($gyou+1, $line, "主軸を正転させずに固定サイクル命令しています。", "主軸を正転させずに固定サイクル");
			}
		}
		
		#クーラントが出ていないとき 20190613追加
		if($M08_warn_flag == 1 and $coolant_ON == 0){
			write_log($gyou+1, $line, "クーラント(切削油)を出さずに固定サイクル命令しています。", "クーラントを出さずに固定サイクル");
		}
		
		if($tap_tool_flag == 1 and /(?<![A-Z])G(7[36]|8[1-35-9])(?!\d)/){
			write_log($gyou+1, $line, "タップでタッピングサイクル以外の固定サイクルが指令されています。", "タップでタッピングサイクル以外の固定サイクル");
		}
		
		$koteiCycle_mode= 1;
		$R_level= 0;
		$Z_kirikomi= 0;
	}
	
	if($koteiCycle_mode == 1){
		if(/(?<![A-Z])G80(?!\d)/){
			$koteiCycle_mode= 0;
		}
		elsif(/(?<![A-Z])G(0*[0123]|28|30|33)(?!\d)/ and !/(?<![A-Z])G(7[346]|8[1-9])(?!\d)/){
			if($G80_flag == 0){
				write_log($gyou+1, $line, "固定サイクルがキャンセルされていません。", "固定サイクルがキャンセルされていない");
			}
			$koteiCycle_mode= 0;
		}
	}
	
	if($G66_modal_tajuudo > 0){
		if($G66_yobidashi_tajuudo < $G66_modal_tajuudo){
			$_= $line;
			#2018.03.02
			if(!/(?<![A-Z])G92/ and !/(?<![A-Z])G0*4(?!\d)/ and !/(?<![A-Z])G(28|30)(?!\d)/ and $koteiCycle_mode == 0){
			#if(!/G92/ and $koteiCycle_mode == 0){
#				if(/X\-*[0-9\.]+/ or /Y\-*[0-9\.]+/ or /Z\-*[0-9\.]+/){
				if(/(?<![A-Z])[XYZ]\-?\d+\.?\d*/){
					$G66_modal_flag= 1;
				}
			}
		}
	}
	
	$_ = $new_line;
	
	#送り速度の範囲判定
	if(/(?<![A-Z])F(\-?\d+\.?\d*)/){
		if($1 > $F_max){
			write_log($gyou+1, $line, "送り速度が設定された上限値$F_maxを超えています。", "送り速度が上限値を超えている");
		}
		elsif($1 < $F_min){
			$tmp= $1;
			if(!/(?<![A-Z])G[78]4(?!\d)/){
				write_log($gyou+1, $line, "送り速度が設定された下限値$F_minを下回っています。", "送り速度が下限値を下回っている");
			}
			#タッピングサイクルの場合、下限値判定はしないが、ゼロとマイナスはチェック
			elsif($tmp == 0){
				write_log($gyou+1, $line, "送り速度に0が設定されています。", "送り速度に0");
			}
			elsif($tmp == 0){
				write_log($gyou+1, $line, "送り速度にマイナスの値が設定されています。", "送り速度にマイナスの値");
			}
		}
	}
	
	#Fコードなしで速度指令タイプの補間をしているか
	if(/(?<![A-Z])G(0*[123]|7[356]|8[1-9])(?!\d)/){
		if($value[4109] == 0){
			write_log($gyou+1, $line, "$&の送り速度(F)が設定されていません。", "$&の送り速度が設定されていない");
		}
	}
	
	#同一のGグループ内の複数Gコードがあるか
	foreach my $G_list(@G_groupList){
		my $Gcount = 0;
		my $multi_G_str = "";
		foreach my $G_num(@{$G_list}){
			if($new_line =~ /(?<![A-Z])G0*$G_num(?!\d)/){
				$Gcount++;
				$multi_G_str .=  $& . ",";
			}
		}
		if($Gcount > 1){
			$multi_G_str =~ s/\,$//;
			write_log($gyou+1, $line, "同一グループのGコードが複数指令されています($multi_G_str)。", "同一グループのGコードが複数指令されている($multiG_str)");
		}
	}
	
	#固定サイクルとG00,G01,G02,G03が同じブロック(ブロックは違うが不正)
	if(/(?<![A-Z])G0*[0123](?!\d)/ and /(?<![A-Z])G(7[346]|8[1-9])(?!\d)/){
		$tmp = "";
		while(/(?<![A-Z])G(0*[0123]|7[346]|8[1-9])(?!\d)/g){
			$tmp .= $& . ",";
		}
		$tmp =~ s/\,$//;
		write_log($gyou+1, $line, "1ブロック中で移動命令と固定サイクルが指令されています($tmp)。", "1ブロックで移動命令と固定サイクルを指令($tmp)");
	}
	
	#複数Mコードチェック
	if( ( () = $new_line =~ /(?<![A-Z])M\d+\.?\d*/g ) > 1 and $multi_M == 0){
		write_log($gyou+1, $line, "1ブロック中で複数のMコードが指令されています。", "1ブロックでMコードが複数");
	}
	
	#工具交換前に実行すべきコード判定
	if($pre_TC_code ne ""){
		$tmp= $line;
		$tmp =~ s/\s//g;
		if($tmp =~ $pre_TC_code){ $pre_TC_flag= 1; }
		elsif(!/(?<![A-Z])G0*4(?!\d)/ and !/(?<![A-Z])G(28|30)/ and !/(?<![A-Z])G92(?!\d)/){
			if(/(?<![A-Z])[XYZ]\-?\d+\.?\d*/){ $pre_TC_flag= 0; }
		}
	}
	#工具呼び出しと工具交換が同じブロック
	if(/(?<![A-Z])M0*6(?!\d)/ and /(?<![A-Z])T\d+/){
		if($pre_TC_flag == 0){ #工具交換前に実行すべきコードが実行されていない
			write_log($gyou+1, $line, "設定されている工具交換前のコード<$pre_TC_code>を実行せずに工具交換しようとしています。", "交換前に実行すべきコード未実行で工具交換");
		}
		if($TC_warn_flag == 1){ #TとM06を同じブロックに入れると警告
			write_log($gyou+1, $line, "TコードとM06は同じブロックに入れないでください。", "TコードとM06が同じブロックにある");
		}
		if($TC_flag == 0){ #M06実行が先のとき
			$tmp= $present_T;
			$present_T = $value[4120];
			$value[4120]= $tmp;
			$T_yobidashi_flag= 1;
		}
		else{ #Tの実行が先のとき
			$present_T = $value[4120];
			$T_yobidashi_flag= 0;
		}
		
		$G92_exist= 0;
		$G43_exist= 0;
		$M06_count++;
		$M06_exe= 1;
		
		#主軸が回っているとき
		if($spindle_ON == 1){
			write_log($gyou+1, $line, "工具交換前に主軸を停止してください。", "主軸正転のまま工具交換");
		}
		#クーラントが出ているとき
		if($coolant_ON == 1){
			write_log($gyou+1, $line, "工具交換前にクーラントをOFFしてください。", "クーラントONのまま工具交換");
		}
		#工具径補正がキャンセルされていないとき
		if($keihosei_mode == 1){
			write_log($gyou+1, $line, "工具交換前に工具径補正をキャンセルしてください。", "工具径補正のまま工具交換");
		}
		#固定サイクルがキャンセルされていないとき
		if($koteiCycle_mode == 1){
			if($G80_flag == 0){
				write_log($gyou+1, $line, "工具交換前に固定サイクルをキャンセルしてください。", "固定サイクルキャンセルせずに工具交換");
			}
			$koteiCycle_mode= 0;
		}
		
	}
	#工具呼び出し時のチェック
	elsif(/(?<![A-Z])T\d+/){
		if($T_yobidashi_flag== 1){
			write_log($gyou+1, $line, "前回呼び出した工具を交換せずに新しい工具を呼び出しています。", "交換しないまま別の工具呼び出し");
		}
		if($TC_flag2 == 1){ #TとM06が同じブロックの機種
			write_log($gyou+1, $line, "TコードとM06が同じブロックにないと工具交換できない機種でTが単独で実行されています。", "TコードとM06が同じブロックにないと交換できない設定でTを単独実行");
		}
		$T_yobidashi_flag= 1;
	}
	#工具交換時のチェック
	elsif(/(?<![A-Z])M0*6(?!\d)/){
		if($pre_TC_flag == 0){ #工具交換前に実行すべきコードが実行されていない
			write_log($gyou+1, $line, "設定されている工具交換前のコード<$pre_TC_code>を実行せずに工具交換しようとしています。", "交換前に実行すべきコード未実行で工具交換");
		}
		if($T_yobidashi_flag== 0){
			write_log($gyou+1, $line, "工具を呼び出さずに交換しようとしています。", "Tを呼び出さずにM06している");
		}
		if($TC_flag2 == 1){  #TとM06が同じブロックの機種
			write_log($gyou+1, $line, "TコードとM06が同じブロックにないと工具交換できない機種でM06が単独で実行されています。", "TコードとM06が同じブロックにないと交換できない設定でM06を単独実行");
		}
		$present_T= $value[4120];
		$T_yobidashi_flag= 0;
		$G92_exist= 0;
		$G43_exist= 0;
		$M06_count++;
		$M06_exe= 1;
		
		#主軸が回っているとき
		if($spindle_ON == 1){
			write_log($gyou+1, $line, "工具交換前に主軸を停止してください。", "主軸正転のまま工具交換");
		}
		#クーラントが出ているとき
		if($coolant_ON == 1){
			write_log($gyou+1, $line, "工具交換前にクーラントをOFFしてください。", "クーラントONのまま工具交換");
		}
		#工具径補正がキャンセルされていないとき
		if($keihosei_mode == 1){
			write_log($gyou+1, $line, "工具交換前に工具径補正をキャンセルしてください。", "工具径補正のまま工具交換");
		}
		#固定サイクルがキャンセルされていないとき
		if($koteiCycle_mode == 1){
			if($G80_flag == 0){
				write_log($gyou+1, $line, "工具交換前に固定サイクルをキャンセルしてください。", "固定サイクルキャンセルせずに工具交換");
			}
			$koteiCycle_mode= 0;
		}
	}
	
	#回転数が設定されているか
	if(/(?<![A-Z])S(\-?\d+\.?\d*)/){
		if($1 > $S_max){
			write_log($gyou+1, $line, "主軸回転数が設定された上限値$S_maxを超えています。", "Sが上限値を超えている");
		}
		elsif($1 < $S_min){
			write_log($gyou+1, $line, "主軸回転数が設定された下限値$S_minを下回っています。", "Sが下限値を下回っている");
		}
		$S_exist = 1;
	}
	
	if($S_flag == 0){
		if(/(?<![A-Z])M0*6(?!\d)/){ $S_exist = 0; }
	}
	
	if($new_line =~ /(?<![A-Z])M0*3(?!\d)/){
		#主軸正転時に回転数が設定されているか
		if($S_exist == 0){
			write_log($gyou+1, $line, "主軸回転数が設定されていない状態で主軸正転命令(M03)されています。", "回転数なしでM03");
		}
		$spindle_ON= 1;
	}
	if(/(?<![A-Z])M0*5(?!\d)/){
		#Zを上げずに主軸停止している場合
		if($Z_up == 0){
			write_log($gyou+1, $line, "主軸を上に逃がさない状態で主軸停止命令(M05)されています。", "主軸を上に逃がさずにM05");
		}
		$spindle_ON= 0;
	}
	
	#クーラントが止まっているか
	if(/(?<![A-Z])M0*8(?!\d)/){ $coolant_ON = 1; }
	if(/(?<![A-Z])M0*9(?!\d)/){ $coolant_ON = 0; }
	
	if(/(?<![A-Z])G5[4-9]/){ $G54_exist= 1; }
	#ワーク座標系が呼び出されていない状態でXY移動
	if(/(?<![A-Z])[XY]\-?\d+\.?\d*/ and !/(?<![A-Z])G(0*4|28|30|92)(?!\d)/ and $value[4003] != 91
							and $G92_exist == 0 and $G54_exist == 0 and $G54_warned == 0){
		write_log($gyou+1, $line, "ワーク座標系が呼び出されていません。", "ワーク座標系が呼び出されていない");
		$G54_warned= 1;
	}
	
	#工具長補正G43呼び出し時にHコードが指令されていない
	if(/(?<![A-Z])G43(?!\d)/){
		if($value[4111] == 0){
			write_log($gyou+1, $line, "工具長補正G43でHコードが指令されてません。", "G43指令時にHコードなし");
		}
		#工具長補正番号が工具番号と違う
		elsif($H_warn_flag == 0 and $value[4111] != $present_T){
			if($M06_count != 0 or $present_T_flag == 1){
				write_log($gyou+1, $line, "補正されるH番号とT番号が異なります。", "H番号とT番号が違う状態でG43");
			}
		}
		$G43_exist= 1;
	}
	#工具長補正をせずにZ移動
	if(/(?<![A-Z])Z\-?\d+\.?\d*/ and !/(?<![A-Z])G(0*4|28|30|92)(?!\d)/ and $G92_exist == 0 and $G43_exist == 0 and $G43_warned == 0){
		if($M06_count == 0){
			write_log($gyou+1, $line, "工具長補正されていません。", "工具長補正されていない");
		}
		else{
			write_log($gyou+1, $line, "T$present_T が工具長補正されていません。", "T$present_Tが工具長補正されていない");
		}
		$G43_warned= 1;
	}
	if(/(?<![A-Z])G49(?!\d)/){ $G43_exist= 0; }
	if(/(?<![A-Z])G40(?!\d)/){
		$keihosei_mode= 0;
		$keihosei_warned= 0;
	}
	
	#径補正の先読みできる行数判定
	if($keihosei_mode == 1){
		if(/(?<![A-Z])[XY]\-?\d+\.?\d*/){
			if(not(/(?<![A-Z])G0*4(?!\d)/ and /(?<![A-Z])X\-?\d+\.?\d*/) and !/(?<![A-Z])G(28|30|92)(?!\d)/){
				$nonKeihoseiLine= 0;
				$keihosei_warned= 0;
			}
			else{ $nonKeihoseiLine++ ; }
		}
		else{ $nonKeihoseiLine++ ; }
		
		if($nonKeihoseiLine > $foresee_block and $keihosei_warned == 0){
			write_log($gyou+1, $line,
				 "工具長補正モード中にXYの移動がないブロックが先読みできるブロック数を超えました。", "工具長補正モードでXYの移動がないブロックが先読みできるブロック数を超えた");
			$keihosei_warned= 1;
		}
	}
	
	if(/(?<![A-Z])G4[12](?!\d)/){
		#工具径補正G41またはG42呼び出し時にDコードが指令されていない
		if($value[4107] == 0){
			write_log($gyou+1, $line, "工具長補正$&でDコードが指令されてません。", "$&指令時にDコードなし");
		}
		#工具径補正番号が工具番号と違う
		elsif($D_warn_flag == 0 and $value[4107] != $present_T){
			if($M06_count != 0 or $present_T_flag == 1){
				write_log($gyou+1, $line, "補正されるD番号とT番号が異なります。", "D番号とT番号が違う状態で径補正");
			}
		}
		$keihosei_mode= 1;
		$nonKeiHoseiLine= 0;
	}
	
	if(/(?<![A-Z])G[78]4(?!\d)/){
		if($G84_flag == 1){
			if($M29S_flag == 0){
				write_log($gyou+1, $line, "$&の前のブロックにM29S_がありません。", "$&の前にM29S_がない");
			}
		}
		else{
			if($M29S_flag2 == 1){
				if($M29S_flag == 1){
					write_log($gyou+1, $line, "$&の前のブロックにM29S_は必要ありません。", "$&の前にM29S_が必要ない機種でG84の前に実行");
				}
				if(!/(?<![A-Z])F\-?\d+\.?\d*/ and !/(?<![A-Z])S\-?\d+\.?\d*/){
					write_log($gyou+1, $line, "FコードとSコードがありません。", "$1にFコードとSコードがない(F,Sが必要な機種)");
				}
				elsif(!/(?<![A-Z])F\-?\d+\.?\d*/){
					write_log($gyou+1, $line, "Fコードがありません。", "$1にFコードがない(F,Sが必要な機種)");
				}
				elsif(!/(?<![A-Z])S\-?\d+\.?\d*/){
					write_log($gyou+1, $line, "Sコードがありません。", "$1にSコードがない(F,Sが必要な機種)");
				}
			}
		}
	}
	
	#M29S_の行判定
	elsif(/(?<![A-Z])M29S\d+/){ $M29S_flag= 1; }
	else{ $M29S_flag= 0; }

	#G00、G01と同じブロックにR,I,J(,K)がある場合に警告
	#G02、G03が同じブロックにある場合は警告しないが、他のチェックに引っかかってるはず
	if(/(?<![A-Z])G0*[01](?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])G0*[23](?!\d)/){
			while(/(?<![A-Z])([RIJK])\-?\d+\.?\d*/g){
				write_log($gyou+1, $line, "$tmpのブロックに$1コードが指令されています。", "$tmpのブロックに$1コードがある");
			}
		}
	}
	
	#02、G03と同じブロックにIJコードもRコードもない場合に警告
	if(/(?<![A-Z])G0*[23](?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])[RIJ]\-?\d+\.?\d*/ and $value[4002] == 17){
			write_log($gyou+1, $line, "$tmpにはRコードまたはI・Jコードが必要です。", "$tmpのブロックにRコードもI・Jコードもない");
		}
		elsif(!/(?<![A-Z])[RIK]\-?\d+\.?\d*/ and $value[4002] == 18){
			write_log($gyou+1, $line, "G18のときの$tmpにはRコードまたはI・Kコードが必要です。", "G18のときの$tmpのブロックにRコードもI・Kコードもない");
		}
		elsif(!/(?<![A-Z])[RJK]\-?\d+\.?\d*/ and $value[4002] == 19){
			write_log($gyou+1, $line, "G19のときの$tmpにはRコードまたはJ・Kコードが必要です。", "G19のときの$tmpのブロックにRコードもJ・Kコードもない");
		}
	}
	
	#Gグループ1が2か3(円弧補間時)
	if($value[4001] =~ /0*[23](?!\d)/){
		if(/(?<![A-Z])R(\-?\d+\.?\d*)/){
			if($1 == 0){
				write_log($gyou+1, $line, "円弧補間のRに0はありえません。", "円弧補間のRに0");
			}
			if(/(?<![A-Z])[IJ]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "円弧補間はR指令かIJ指令どちらかで指令してください。", "円弧補間にRとIJ両方ある");
			}
			elsif(/(?<![A-Z])[IK]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "G18のときの円弧補間はR指令かIK指令どちらかで指令してください。", "G18のときの円弧補間にRとIK両方ある");
			}
			elsif(/(?<![A-Z])[JK]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "G19のときの円弧補間はR指令かJK指令どちらかで指令してください。", "G19のときの円弧補間にRとJK両方ある");
			}
			if(!/(?<![A-Z])[XY]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "XYの移動がなく、Rコードのみでは円弧が成立しません。", "円弧補間にRコードがあるがXYコードがない");
			}
			elsif(!/(?<![A-Z])[XZ]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "G18のとき、XZの移動がなく、Rコードのみでは円弧が成立しません。", "G18のときの円弧補間にRコードがあるがXZコードがない");
			}
			elsif(!/(?<![A-Z])[YZ]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "G19のとき、YZの移動がなく、Rコードのみでは円弧が成立しません。", "G19のときの円弧補間にRコードがあるがYZコードがない");
			}
		}
		#2020.03.30
		if(/G4[12](?!\d)/){
			if(/(?<!A-Z])[XYRIJ]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "工具径補正のスタートアップブロックでは円弧補間は使えません。", "工具径補正のスタートアップブロックで円弧補間");
			}
			if(/(?<!A-Z])[XZRIK]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "工具径補正のスタートアップブロックでは円弧補間は使えません。", "G18のときの工具径補正のスタートアップブロックで円弧補間");
			}
			if(/(?<!A-Z])[YZRJK]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "工具径補正のスタートアップブロックでは円弧補間は使えません。", "G19のときの工具径補正のスタートアップブロックで円弧補間");
			}
		}
		if(/G40(?!\d)/){
			if(/(?<!A-Z])[XYRIJ]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "工具径補正のキャンセルブロックでは円弧補間は使えません。", "工具径補正のキャンセルブロックで円弧補間");
			}
			if(/(?<!A-Z])[XZRIK]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "工具径補正のキャンセルブロックでは円弧補間は使えません。", "G18のときの工具径補正のキャンセルブロックで円弧補間");
			}
			if(/(?<!A-Z])[YZRJK]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "工具径補正のキャンセルブロックでは円弧補間は使えません。", "G19のときの工具径補正のキャンセルブロックで円弧補間");
			}
		}
	}

# 固定サイクル判定方針
#
# 固定サイクルコードと同じブロック内に
# 「絶対入れる」がない場合と、「絶対入れない」がある場合、警告
#
#コード 標準      省略可   絶対入れる　絶対入れない 
##	G73 XYZQR(P)F   XYRPF       ZQ
##	G74 XYZRPF      XYRP        ZF         Q
##	G76 XYZQ(IJ)RF  XYRF      Z(Q or IJ)
##	G81 XYZRF       XYRF        Z          PQ
##	G82 XYZRPF      XYRF        ZP         Q
##	G83 XYZQRPF     XYRPF       ZQ
##	G84 XYZRPF      XYRP        ZF         Q
##	G85 XYZRF       XYRF        Z          PQ
##	G86 XYZRPF      XYRPF       ZP         Q
##	G87 XYZQ(IJ)RF  XYRF      Z(Q or IJ)
##	G88 XYZRPF      XYRF        ZP         Q
##	G89 XYZRPF      XYRF        ZP         Q

	#Zがない場合に警告(G73,74,76,81,82,83,84,85,86,87,88,89)
	if(/(?<![A-Z])G(7[346]|8[1-9])(?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])(Z)\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmpにZコードが指令されていません。", "$tmpにZコードがない");
		}
	}
	#Pがない場合に警告(G82,86,88,89)
	if(/(?<![A-Z])G8[2689](?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])P\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmpにPコードが指令されていません。", "$tmpにPコードがない");
		}
		elsif(/(?<![A-Z])P(\-?\d+\.?\d*)/){
			if($1 == 0){
				write_log($gyou+1, $line, "固定サイクルのPに0はありえません。", "固定サイクルのPに0");
			}
		}
	}
	#Qがない場合に警告(G73,76,83,87 ただしG76,87はIJでも可)
	if(/(?<![A-Z])G(7[36]|8[37])(?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])Q\-?\d+\.?\d*/ and not (/(?<![A-Z])G(76|87)(?!\d)/ and /(?<![A-Z])[IJ]\-?\d+\.?\d*/)){
			write_log($gyou+1, $line, "$tmpにQコードが指令されていません。", "$tmpにQコードがない");
		}
		elsif(/(?<![A-Z])Q(\-?\d+\.?\d*)/){
			if($1 == 0){
				write_log($gyou+1, $line, "固定サイクルのQに0はありえません。", "固定サイクルのQに0");
			}
		}
	}
	#Pがある場合に警告(G81,85)
	if($new_line =~ /(?<![A-Z])G8[15](?!\d)/){
		$tmp = $&;
		if($new_line =~ /(?<![A-Z])(P)\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmpに$1コードが指令されています。", "$tmpに$1コードがある");
		}
	}
	#Pに小数点がある場合に警告
	elsif($new_line =~ /(?<![A-Z])G(7[346]|8[2-46-9])(?!\d)/){
		$tmp = $&;
		if($line =~ /(?<![A-Z])P\-?\d+\.\d*/ and $P_DP_flag == 0){
			write_log($gyou+1, $line, "Pには通常、小数点はつけません(つけると秒、つけないとミリ秒)。", "$tmpのPに小数点");
		}
	}
	
	#Qがある場合に警告(G74,81,82,84,85,86,88,89)
	if($new_line =~ /(?<![A-Z])G(74|8[1245689])(?!\d)/){
		$tmp = $&;
		if($new_line =~ /(?<![A-Z])(Q)\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmpに$1コードが指令されています。", "$tmpに$1コードがある");
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
# G80z

# G91
# G98G81X100.0Y50.0Z-30.0R10.0F100	(+100,+50,--)
# X200.0	(+200,--,--)
# G80

# G91
# G99G81X100.0Y50.0Z-30.0R10.0F100 	(+100,+50,+10)
# X200.0	(+200,--,--)
# G80

# G92X0Y0Z0

	my ($start_X,$start_Y,$start_Z,$end_X,$end_Y,$end_Z,$center_X,$center_Y,$center_Z,$R1,$R2);

	if(!/(?<![A-Z])G0*4(?!\d)/){
		if(/(?<![A-Z])G(28|30)(?!\d)/){
			if($value[4003] == 90){
				write_log($gyou+1, $line, "G90指令で原点復帰されています。", "G90指令で原点復帰");
			}
			
			if(/(?<![A-Z])[XY]\-*[0-9\.]+/ and ($Z_G00_down == 1 or $Z_kirikomi == 1) ){
				write_log($gyou+1, $line, "Z軸を上方に逃がさずにXY方向に原点復帰しています。", "Zを上方に逃がさずにXY方向に原点復帰");
			}
			
			if(/(?<![A-Z])X\-*[0-9\.]+/){ $value[5001] = 0; #if($debug_flag2 == 1){ print OUT '(----#5001= 0----)'."\n"; }
			}
			if(/(?<![A-Z])Y\-*[0-9\.]+/){ $value[5002] = 0; #if($debug_flag2 == 1){ print OUT '(----#5002= 0----)'."\n"; }
			}
			if(/(?<![A-Z])Z\-*[0-9\.]+/){
				$Z_up= 1;
				$Z_kirikomi= 0;
				$Z_G00_down= 0;
				$value[5003] = 0; #if($debug_flag2 == 1){ print OUT '(----#5003= 0----)'."\n"; }
			}
			
			$M06_exe= 0;
		}
		elsif(/(?<![A-Z])G92(?!\d)/){
			if(/(?<![A-Z])X(\-*[0-9\.]+)/){ $value[5001] = $1; #if($debug_flag2 == 1){ print OUT '(----#5001= '. $1. '----)'."\n"; }
			}
			if(/(?<![A-Z])Y(\-*[0-9\.]+)/){ $value[5002] = $1; #if($debug_flag2 == 1){ print OUT '(----#5002= '. $1. '----)'."\n"; }
			}
			if(/(?<![A-Z])Z(\-*[0-9\.]+)/){ $value[5003] = $1; #if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; }
			}
			
			$G92_exist= 1;
			$M06_exe= 0;
		}
		elsif($value[4003] == 90){
			if($koteiCycle_mode == 0){
				
				if(/(?<![A-Z])[XY]\-?\d+\.?\d*/){
					if($value[4001] == 0 and $Z_kirikomi == 1 and !/(?<![A-Z])G40(?!\d)/){
				 		#切り込み状態でXY早送り(G40のとき以外)
				 		write_log($gyou+1, $line, "直線補間等でZを切り込んだ状態でXY方向に早送りしています。", "直線補間等でZを切り込んだ状態でXY早送り");
					}
					if($value[4001] =~ /0*[123]/ and $Z_G00_down == 1 and $Z_G00_warn_flag == 1){
						#Zマイナスに早送りした高さのまま直線、または円弧補間(オプション)
						write_log($gyou+1, $line, "Zマイナス方向に早送りした高さでXY方向に直線、または円弧補間しています。", "Zマイナス方向に早送りした高さでXY方向に直線、または円弧補間");
					}
				}
				#円弧補間が成立するか検査
				if($value[4001] =~ /0*[23]/){
					$start_X = $value[5001];
					$start_Y = $value[5002];
					$start_Z = $value[5003];
					
					$end_X = $start_X;
					$end_Y = $start_Y;
					$end_Z = $start_Z;
					
					if(/(?<![A-Z])X(\-?\d+\.?\d*)/){ $end_X = $1; }
					if(/(?<![A-Z])Y(\-?\d+\.?\d*)/){ $end_Y = $1; }
					if(/(?<![A-Z])Z(\-?\d+\.?\d*)/){ $end_Z = $1; }
					
					if(/(?<![A-Z])R(\-?\d+\.?\d*)/){
						$R1 = $1;
						
						if($value[4002] == 17){
							#始点から終点までの距離
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 );
						}
						elsif($value[4002] == 18){
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						elsif($value[4002] == 19){
							$R2 = sqrt( ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						
						#許容量0.002
						if($R2 > 2 * abs($R1) + 0.002){
							write_log($gyou+1, $line, "指令されている半径値では終点への円弧が成立しません。", "指令されている半径値では終点への円弧が成立しない");
						}
#						$R_value = $1;
#						if( ($value[4002] == 17 and ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 18 and ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 19 and ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) ){
#							write_log($gyou+1, $line, "指令されている半径値では終点への円弧が成立しません。", "指令されている半径値では終点への円弧が成立しない");
#						}
					}
					elsif(/(?<![A-Z])[IJK](\-?\d+\.?\d*)/){
						$center_X = $start_X;
						$center_Y = $start_Y;
						$center_Z = $start_X;
						
						if(/(?<![A-Z])I(\-?\d+\.?\d*)/){ $center_X += $1; }
						if(/(?<![A-Z])J(\-?\d+\.?\d*)/){ $center_Y += $1; }
						if(/(?<![A-Z])K(\-?\d+\.?\d*)/){ $center_Z += $1; }
						
						if($value[4002] == 17){
							$R1 = sqrt( ($start_X - $center_X) ** 2 + ($start_Y - $center_Y) ** 2 ) ;
							$R2 = sqrt( ($end_X - $center_X) ** 2 + ($end_Y - $center_Y) ** 2 ) ;
						}
						elsif($value[4002] == 18){
							$R1 = sqrt( ($start_X - $center_X) ** 2 + ($start_Z - $center_Z) ** 2 ) ;
							$R2 = sqrt( ($end_X - $center_X) ** 2 + ($end_Z - $center_Z) ** 2 ) ;
						}
						elsif($value[4002] == 19){
							$R1 = sqrt( ($start_Y - $center_Y) ** 2 + ($start_Z - $center_Z) ** 2 ) ;
							$R2 = sqrt( ($end_Y - $center_Y) ** 2 + ($end_Z - $center_Z) ** 2 ) ;
						}
						
						#許容量0.02
						if( abs($R1 - $R2) > 0.002){
							write_log($gyou+1, $line, "指令されている中心点では終点への円弧が成立しません。", "指令されている中心点では終点への円弧が成立しない");
						}
						
					}
				}
				
				if(/(?<![A-Z])X(\-*[0-9\.]+)/){
					$value[5001] = $1; #if($debug_flag2 == 1){ print OUT '(----#5001= '. $1. '----)'."\n"; }
					$manual_origin_X= 0;
				}
				if(/(?<![A-Z])Y(\-*[0-9\.]+)/){
					$value[5002] = $1; #if($debug_flag2 == 1){ print OUT '(----#5002= '. $1. '----)'."\n"; }
					$manual_origin_Y= 0;
				}
				
				if($after_TC_warn_flag == 1){
					if(($manual_origin_X == 0 and $manual_origin_Y == 1) or ($manual_origin_X == 1 and $manual_origin_Y == 0)){
						write_log($gyou+1, $line, "手動で工具交換のコードを追加している場合、XY座標を確認してください。(この警告が必要ない場合はスクリプト冒頭にある設定を変更してください。)", "手動で工具交換のコード追加後のXY座標確認");
						$manual_origin_X= 0;
						$manual_origin_Y= 0;
					}
				}
				
				if(/(?<![A-Z])Z(\-*[0-9\.]+)/){ 
					if($1 > $value[5003]){
						$Z_up= 1;
						$Z_kirikomi= 0;
						$Z_G00_down= 0;
						
						if($Z_G01escape_max != 0){
							if($1 - $value[5003] > $Z_G01escape_max and $value[4001] == 1 and !/(?<![A-Z])[XY]\-?\d+\.?\d*/){
								write_log($gyou+1, $line, "設定された移動距離の上限値$Z_G01escape_maxミリ(1ブロックで)を超えて、直線補間でZを逃がしています。", "上限値$Z_G01escape_max以上、直線補間でZを逃がしている");
							}
						}
					}
					elsif($1 < $value[5003]){
						$Z_up= 0;
						
						#早送りでなくZを下げているとき
						if($value[4001] != 0){
							#主軸が回転していない場合
							if($spindle_ON == 0){
								write_log($gyou+1, $line, "主軸を正転させずにZを切り込んでいます。", "主軸を正転させずにZ切り込み");
							}
							#クーラントが出ていないとき
							if($M08_warn_flag == 1 and $coolant_ON == 0){
								write_log($gyou+1, $line, "クーラント(切削油)を出さずにZを切り込んでいます。", "クーラントを出さずにZ切り込み");
							}
							$Z_kirikomi= 1;
							$Z_G00_down= 0;
						}
						#早送りでZを下げているとき
						else{ $Z_G00_down= 1; }
						
						if($Z_G01_max != 0){
							if($value[5003] - $1 > $Z_G01_max and $value[4001] == 1 and !/(?<![A-Z])[XY]\-?\d+\.?\d*/){
								write_log($gyou+1, $line, "設定された移動距離の上限値$Z_G01_maxミリ(1ブロックで)を超えて、Zマイナス方向に直線補間しています。", "上限値$Z_G01_maxを超えて、Zマイナス方向に直線補間");
							}
						}
					}
					$value[5003] = $1; #if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; }
				}
			}
			#固定サイクルのとき
			else{
				if(/(?<![A-Z])X(\-*[0-9\.]+)/){
					$value[5001] = $1; #if($debug_flag2 == 1){ print OUT '(----#5001= '. $1. '----)'."\n"; }
					$manual_origin_X= 0;
				}
				if(/(?<![A-Z])Y(\-*[0-9\.]+)/){
					$value[5002] = $1; #if($debug_flag2 == 1){ print OUT '(----#5002= '. $1. '----)'."\n"; }
					$manual_origin_Y= 0;
				}
				if($after_TC_warn_flag == 1){
					if($manual_origin_X == 1 or $manual_origin_Y == 1){
						write_log($gyou+1, $line, "手動で工具交換のコードを追加している場合、XY座標を確認してください。(この警告が必要ない場合はスクリプト冒頭にある設定を変更してください。)", "手動で工具交換のコード追加後のXY座標確認");
						$manual_origin_X= 0;
						$manual_origin_Y= 0;
					}
				}
				#固定サイクルのときのZ深さ
				if(/(?<![A-Z])Z(\-?\d+\.?\d*)/){
					$fukasa= $1;
					#Z座標がイニシャルレベルより高いとき
					if($fukasa >= $value[5003]){
						write_log($gyou+1, $line, "指令されているZ座標がイニシャル点レベル以上に高い位置です。", "固定サイクルのZがイニシャル点レベル以上");
					}
				}
				
				if(/(?<![A-Z])R(\-*[0-9\.]+)/){
					$R_level= $1;
					if($value[4010] == 99){
						 $value[5003] = $R_level; #if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; }
					}
					#Z座標がイニシャルレベルよりは低いがR点レベルよりも高いとき
					if($fukasa >= $R_level){
						if($fukasa < $value[5003]){
							write_log($gyou+1, $line, "指令されているZ座標がR点レベル以上に高い位置です。", "固定サイクルのZがR点レベル以上");
						}
					}
				}
				$Z_up= 1;
				$Z_G00_down= 0;
				
				if(/(?<![A-Z])[XYZ]\-?\d+\.?\d*/){
					if($value[4009] =~ /(73|8[123])/){
						push(@hole_list, [$value[5001], $value[5002], $fukasa]);
					}
					elsif($value[4009] =~ /8[45689]/){
						my $pre_hole = 999;
						foreach my $ref(@hole_list){
   						@hole_XYZ = @$ref;
							# $hole_XYZ [0]:X座標、[1]Y座標、[2]Z深さ
							if($hole_XYZ[0] == $value[5001] and $hole_XYZ[1] == $value[5002]){
								if($pre_hole > $hole_XYZ[2]){ $pre_hole= $hole_XYZ[2]; }
							}
						}
						if($prepared_hole_flag == 1 and $pre_hole == 999){
							write_log($gyou+1, $line, "G$value[4009]の前の下穴の工程がありません。(この警告が必要ない場合はスクリプト冒頭にある設定を変更してください。)", "G$value[4009]の前に下穴の工程がない");
						}
						if($pre_hole != 999 and $Z_prepare_gap != 0 and $fukasa < $pre_hole + $Z_prepare_gap){
							write_log($gyou+1, $line, "すでに加工された穴に対して切り込みすぎです。", "すでに加工された穴に対して切り込みすぎ");
						}
					}
				}
			}
			
			#工具交換後にマニュアルでワーク座標XY原点に戻しているか
			if($M06_count >= 2 and $M06_exe == 1 and /(?<![A-Z])X0\.?0*(?!\d)/ and /(?<![A-Z])Y0\.?0*(?!\d)/){
				$manual_origin_X= 1;
				$manual_origin_Y= 1;
				$M06_exe= 0;
			}
		}
		elsif($value[4003] == 91){
			if($koteiCycle_mode == 0){
				
				if(/(?<![A-Z])[XY]\-?\d+\.?\d*/){
			 		if($Z_kirikomi == 1 and $value[4001] == 0 and !/(?<![A-Z])G40(?!\d)/ ){
						#切り込み状態でXY早送り(G40のときを除く)
						write_log($gyou+1, $line, "直線補間等でZを切り込んだ状態でXY方向に早送りしています。", "直線補間等でZを切り込んだ状態でXY早送り");
					}
					if($value[4001] =~ /0*[123]/ and $Z_G00_down == 1 and $Z_G00_warn_flag == 1){
						#Zマイナスに早送りした高さのまま直線、または円弧補間(オプション)
						write_log($gyou+1, $line, "Zマイナス方向に早送りした高さでXY方向に直線、または円弧補間しています。", "Zマイナス方向に早送りした高さでXY方向に直線、または円弧補間");
					}
				}
				
				#円弧補間が成立するか検査
				if($value[4001] =~ /0*[23]/){
					$start_X = $value[5001];
					$start_Y = $value[5002];
					$start_Z = $value[5003];
					
					$end_X = $start_X;
					$end_Y = $start_Y;
					$end_Z = $start_Z;
					
					if(/(?<![A-Z])X(\-?\d+\.?\d*)/){ $end_X += $1; }
					if(/(?<![A-Z])Y(\-?\d+\.?\d*)/){ $end_Y += $1; }
					if(/(?<![A-Z])Z(\-?\d+\.?\d*)/){ $end_Z += $1; }
					
					if(/(?<![A-Z])R(\-?\d+\.?\d*)/){
						
						$R1 = $1;
						
						if($value[4002] == 17){
							#始点から終点までの距離
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 );
						}
						elsif($value[4002] == 18){
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						elsif($value[4002] == 19){
							$R2 = sqrt( ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						
						#許容量0.002
						if($R2 > 2 * abs($R1) + 0.002){
							write_log($gyou+1, $line, "指令されている半径値では終点への円弧が成立しません。", "指令されている半径値では終点への円弧が成立しない");
						}

#						$R_value = $1;
#						if( ($value[4002] == 17 and ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 18 and ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 19 and ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) ){
#							write_log($gyou+1, $line, "指令されている半径値では終点への円弧が成立しません。", "指令されている半径値では終点への円弧が成立しない");
#						}
					}
					elsif(/(?<![A-Z])[IJK](\-?\d+\.?\d*)/){
						$center_X = $start_X;
						$center_Y = $start_Y;
						$center_Z = $start_X;
						
						if(/(?<![A-Z])I(\-?\d+\.?\d*)/){ $center_X += $1; }
						if(/(?<![A-Z])J(\-?\d+\.?\d*)/){ $center_Y += $1; }
						if(/(?<![A-Z])K(\-?\d+\.?\d*)/){ $center_Z += $1; }
												
						if($value[4002] == 17){
							$R1 = sqrt( ($start_X - $center_X) ** 2 + ($start_Y - $center_Y) ** 2 ) ;
							$R2 = sqrt( ($end_X - $center_X) ** 2 + ($end_Y - $center_Y) ** 2 ) ;
						}
						elsif($value[4002] == 18){
							$R1 = sqrt( ($start_X - $center_X) ** 2 + ($start_Z - $center_Z) ** 2 ) ;
							$R2 = sqrt( ($end_X - $center_X) ** 2 + ($end_Z - $center_Z) ** 2 ) ;
						}
						elsif($value[4002] == 19){
							$R1 = sqrt( ($start_Y - $center_Y) ** 2 + ($start_Z - $center_Z) ** 2 ) ;
							$R2 = sqrt( ($end_Y - $center_Y) ** 2 + ($end_Z - $center_Z) ** 2 ) ;
						}
						
						#許容量0.02
						if( abs($R1 - $R2) > 0.002){
							write_log($gyou+1, $line, "指令されている中心点では終点への円弧が成立しません。", "指令されている中心点では終点への円弧が成立しない");
						}
					}
				}
				
				if(/(?<![A-Z])X(\-*[0-9\.]+)/){ $value[5001] = kagenzan($value[5001],$1); #if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; }
				}
				if(/(?<![A-Z])Y(\-*[0-9\.]+)/){ $value[5002] = kagenzan($value[5002],$1); #if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; }
				}
				if(/(?<![A-Z])Z(\-*[0-9\.]+)/){
					if($1 > 0){
						$Z_up= 1;
						$Z_kirikomi= 0;
						$Z_G00_down= 0;
						
						if($Z_G01escape_max != 0){
							if($1 > $Z_G01escape_max and $value[4001] == 1 and !/(?<![A-Z])[XY]\-?\d+\.?\d*/){
								write_log($gyou+1, $line, "設定された上限値$Z_G01escape_maxミリを超えて、直線補間でZを逃がしています。", "上限値$Z_G01escape_max以上、直線補間でZを逃がしている");
							}
						}
					}
					elsif($1 < 0){
						$Z_up= 0;
						
						#早送りでなくZを下げているとき
						if($value[4001] != 0){
							#主軸が回転していない場合
							if($spindle_ON == 0){
								write_log($gyou+1, $line, "主軸を正転させずにZを切り込んでいます。", "主軸を正転させずにZ切り込み");
							}
							#クーラントが出ていないとき
							if($M08_warn_flag == 1 and $coolant_ON == 0){
								write_log($gyou+1, $line, "クーラント(切削油)を出さずにZを切り込んでいます。", "クーラントを出さずにZ切り込み");
							}
							$Z_kirikomi= 1;
							$Z_G00_down= 0;
						}
						#早送りでZを下げているとき
						else{ $Z_G00_down= 1; }
						
						if($Z_G01_max != 0){
							if($1 + $Z_G01_max > 0 and $value[4001] == 1 and !/(?<![A-Z])[XY]\-?\d+\.?\d*/){
								write_log($gyou+1, $line, "設定された上限値$Z_G01_maxミリを超えて、Zマイナス方向に直線補間しています。", "上限値$Z_G01_max以上、Zマイナス方向に直線補間");
							}
						}
					}
					$value[5003] = kagenzan($value[5003],$1); #if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; }
				}
			}
			#G91で固定サイクル
			else{
				if(/(?<![A-Z])X(\-*[0-9\.]+)/){ $value[5001] = kagenzan($value[5001],$1); #if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; }
				}
				if(/(?<![A-Z])Y(\-*[0-9\.]+)/){ $value[5002] = kagenzan($value[5002],$1); #if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; }
				}
				if(/(?<![A-Z])Z(\-?\d+\.?\d*)/){
					$fukasa= $value[5003] + $1;
					
					if($1 >= 0){ 
						if(/(?<![A-Z])R\-?\d+\.?\d*/){
							write_log($gyou+1, $line, "指令されているZ座標がR点レベル以上に高い位置です。", "固定サイクルのZがR点レベル以上");
						}
						else{
							write_log($gyou+1, $line, "指令されているZ座標がイニシャル点レベル以上に高い位置です。", "固定サイクルのZがイニシャル点レベル以上");
						}
					}
					
					if(/(?<![A-Z])R(\-?\d+\.?\d*)/){
						$fukasa= fukasa + $1;
					}
					
					if($value[4009] =~ /(73|8[123])/){
						push(@hole_list, [$value[5001], $value[5002], $fukasa]);
					}
					elsif($value[4009] =~ /8[45689]/){
						my $pre_hole = 999;
						foreach my $ref(@hole_list){
   						@hole_XYZ = @$ref;
							# $hole_XYZ [0]:X座標、[1]Y座標、[2]Z深さ
							if($hole_XYZ[0] == $value[5001] and $hole_XYZ[1] == $value[5002]){
								if($pre_hole > $hole_XYZ[2]){ $pre_hole= $hole_XYZ[2]; }
							}
						}
						if($prepared_hole_flag == 1 and $pre_hole == 999){
							write_log($gyou+1, $line, "G$value[4009]の前の下穴のサイクルがありません。(この警告が必要ない場合はスクリプト冒頭にある設定を変更してください。)", "G$value[4009]の前に下穴サイクルがない");
						}
						if($pre_hole != 999 and $Z_prepare_gap != 0 and $fukasa < $pre_hole + $Z_prepare_gap){
							write_log($gyou+1, $line, "すでに加工された穴に対して切り込みすぎです。", "すでに加工された穴に対して切り込みすぎ");
						}
					}
				}
				
				if($value[4010] == 99){
					if(/(?<![A-Z])R(\-*[0-9\.]+)/){ $value[5003] = kagenzan($value[5003],$1); #if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; }
					}
				}
				$Z_up= 1;
				$Z_G00_down= 0;
			}
		}
		if($G66_modal_flag == 1){

if($progKaisou eq ""){$progKaisou= "/MAIN L" . ($G66_lineNumList[$G66_yobidashi_tajuudo] + 1); }
else{ $progKaisou= "/O$value[4115] L" . ($G66_lineNumList[$G66_yobidashi_tajuudo] + 1) . $progKaisou; }
			G66_modal_yobidashi($G66_modal_tajuudo - $G66_yobidashi_tajuudo);
$progKaisou =~ s/^\/[^\/]*//;
		}
	}
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
		if($num =~ /^\./){ #小数点以左の0がない場合
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
