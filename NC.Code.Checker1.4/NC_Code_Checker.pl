#! /usr/bin/perl

### NC_Code_Checker.pl
##  Version1.4 (2020.03.31)
##  Version1.3 (2019.09.11)
##  Version1.2 (2019.07.26)
##  Version1.1 (2019.06.25)
##  Version1.0 (2019.05.24)

#
# �}�V�j���O�Z���^(FANUC,MELDAS,MAPPS�n)�p��NC�v���O�����̌���
# �`�F�b�N����Perl�X�N���v�g�ł��B
# ��Ɏ菑���ō쐬����NC�v���O�����̃`�F�b�N��z�肵�Ă��܂��B
# �g�����A���o�ł����蓙�ɂ��Ă�
# [NC_Code_Checker�ɂ���.pdf]���Q�Ƃ��Ă��������B
#
# �{�X�N���v�g�́A2019�N�x�Ȋw�����������(�Ȋw������⏕��)
# ���㌤��(�ۑ�ԍ�:19H00247)�̏������󂯂č쐬���ꂽ���̂ł��B
#
#                           ���ߍH�ƍ������w�Z�@�Z�p�E���@�Έ�M�O

### �ݒ荀�� #########################################################
# �`�F�b�N��̌��ʃt�@�C���Ƃ͕ʂɁA���O�t�@�C��(�ǋL�^)��
# ���[�U�[�h�L�������g�t�H���_�ɁA�ȉ��̃t�@�C�����Ő�������܂��B
$log_file = "NC_Code_Checker_log.txt";

# O�R�[�h(�v���O�����ԍ�)���w�߂���Ă��Ȃ��ꍇ��
# �x������ꍇ�� 0�A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$O_warn_flag = 0;

# X,Y,Z,I,J,K,R,Q�R�[�h�̐��l�ɏ����_�������Ă��Ȃ��ꍇ��
# �x������ꍇ�� 0�A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$DP_warn_flag = 0;

# S�R�[�h�̐��l�ɏ����_�����Ă���ƃG���[�ɂȂ�@��̏ꍇ�� 0�A
# �����_�����Ă��Ă��G���[�ɂȂ�Ȃ��@��̏ꍇ�� 1 ��ݒ肵�Ă��������B
$S_DP_flag = 0;

# �Œ�T�C�N����P�R�[�h�̐��l�ɏ����_�����Ă���ꍇ��
# �x������ꍇ�� 0�A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$P_DP_flag = 0;

# �H��␳�ԍ�H���H��ԍ�T�ƈႤ�ꍇ��
# �x������ꍇ�� 0�A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$H_warn_flag = 0;

# �H��a�␳�ԍ�D���H��ԍ�T�ƈႤ�ꍇ��
# �x������ꍇ�� 0�A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$D_warn_flag = 0;

# �H������O�Ɏ��s���ׂ��R�[�h(���_���A��)����͂��Ă��������B
# ���ɕK�v�Ȃ��ꍇ�� "" �Ƃ��Ă��������B(�����u���b�N�ɂ͖��Ή�)
# ���̃R�[�h�����s��ł����Ă��H���������O�Ɍ��_���A�ȊO�̈ړ���
# �w�߂��ꂽ�ꍇ�A�x�����܂��B
$pre_TC_code = "G91G28Z0";

# T�R�[�h��M06(�H�����)�𓯂��u���b�N�ɓ�����
# M06�̓��삪��ŁA���̌��T�ԍ��̍H������ҋ@�ʒu�ɌĂяo�����@��̏ꍇ�� 0�A
# T�ԍ��̍H��Ăяo������ŁA���̌�M06�����삷��@��̏ꍇ�� 1 ��ݒ肵�Ă��������B
$TC_flag = 0;

# T�R�[�h��M06�������u���b�N�ɂȂ��ƍH���������Ȃ��@��̏ꍇ�� 1�A
# �����łȂ��ꍇ�� 0 ��ݒ肵�Ă��������B
$TC_flag2 = 0;

# ��{�I�ɂ͓����u���b�N�ɂ���ƕs��̌��ƂȂ�̂ŁA
# T�R�[�h��M06�������u���b�N�ɂ���ꍇ�A
# �x������ꍇ�� 1�A�x�����Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$TC_warn_flag = 1;

# ������ԂŎ厲�ɂ��Ă���H��̍H��ԍ���ݒ肷��ꍇ�A���͂��Ă��������B
# ���ɕK�v�Ȃ���� 1 �̂܂܂ɂ��Ă����Ă��������B
$present_T = 1;

# �H��������w�߂���Ă��Ȃ���ԂŁA��� $present_T �̍H��ԍ���
# T�ԍ���H�ԍ����Ⴄ�ꍇ���̔���Ɏg�p����ꍇ�� 1 ��
# �g�p���Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$present_T_flag = 0;

# �厲��]�����w�߂����Ɏ厲���](M03)����ƌx�����܂����A
# (���W�b�h(������)�^�b�s���O�T�C�N���̂Ƃ��͏���)
# �H�������ɉ��߂�S�R�[�h���w�߂������Ď厲���]���Ȃ���
# �G���[�ɂȂ�@��̏ꍇ�� 0�A�G���[�ɂȂ�Ȃ��@��̏ꍇ�� 1 ��ݒ肵�Ă��������B
$S_flag = 0;

# ������ȊO��Z�����~������Ƃ�(G01Z_��Œ�T�C�N��)��
# �N�[�����gON(M08)��ԂłȂ��ꍇ�A
# �x������ꍇ�� 1�A�x�����Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$M08_warn_flag = 1;

# �R�����g�����ɑS�p����(�S�p�X�y�[�X���܂�)�������Ă���ꍇ�A
# �x������ꍇ�� 0 �A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$ComZen_warn_flag = 0;

# 1�u���b�N����M�R�[�h��1�����w�߂ł���@��̏ꍇ�� 0�A
# 1�u���b�N����M�R�[�h�𕡐��w�߂ł���@��̏ꍇ�� 1 ��ݒ肵�Ă��������B
$multi_M = 0;

# G74�AG84�R�[�h�̑O�̃u���b�N��M29S_���Ȃ��Ƃ��x������ꍇ�� 1�A
# �K�v�Ȃ��A�܂��̓t���[�g(�񓯊���)�T�C�N�����g�p����ꍇ�� 0 ��ݒ肵�Ă��������B
$G84_flag = 1;

# ��� $84_flag �� 0 �̏ꍇ�ŁA
# G74�AG84�R�[�h�̑O�̃u���b�N��M29S_�łȂ��Ă�
# G98(G99)G84X_Y_Z_R_F_S_;
# �̍\���œ������^�b�s���O�T�C�N�������s�����@��(���ߍ���ɂ͑��݂���)�̏ꍇ��
# F�R�[�h�AS�R�[�h��G74�AG84�̃u���b�N�ɂȂ��Ƃ��Ɍx������ꍇ�� 1�A
# �x�����Ȃ��A���邢�͂��������d�l�ł͂Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$G84_flag2 = 0;

# �H��a�␳�Ő�ǂ݂ł���u���b�N����ݒ肵�Ă��������B
# �H��a�␳���[�h���AXY�̈ړ����Ȃ��u���b�N������𒴂����ꍇ�A�x�����܂��B
$foresee_block = 2;

# �Œ�T�C�N���̃��[�_�����ɑ��̈ړ�����(G00��)�������
# ��ʓI�ɂ͌Œ�T�C�N���̓L�����Z������܂����A
# �Œ�T�C�N���L�����Z������(G80)�ŃL�����Z�����Ă��Ȃ��ꍇ��
# �x������ꍇ�� 0�A���Ȃ��ꍇ�� 1 ��ݒ肵�Ă��������B
$G80_flag = 0;

# S�R�[�h�Ŏw�߂���厲��]���̏���l�Ɖ����l��ݒ肵�Ă��������B
# �͈͊O�̒l�̏ꍇ�A�x�����܂��B
$S_max = 10000;
$S_min = 200;

# F�R�[�h�Ŏw�߂��鑗�葬�x�̏���l�Ɖ����l��ݒ肵�Ă��������B
# �͈͊O�̒l�̏ꍇ�A�x�����܂��B
# (F�Ń^�b�v�̃s�b�`��ݒ肷��@�������̂�
#   G74,G84�Ɠ����u���b�N�̂Ƃ��A�����l�͖������܂��B)
$F_max = 600;
$F_min = 30;

# G73,G81,G82,G83�Ō���������T�C�N��������ꍇ��
# ����̃v���O��������
# ���̃T�C�N���Ŏw�߂���XY���W�ɂ��������ɑ΂���
# G74,G84,G85,G86,G88,G89�Œǉ����H����T�C�N��������ꍇ�A
# ���łɊJ����ꂽ����Z���W�ɑ΂���
# ���̒l�ȏ㍂���ʒu(�P��:�~��)�Ŏ~�܂��Ă��Ȃ��ꍇ�A�x�����܂��B
# �x�����K�v�Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$Z_prepare_gap = 4;

# G74,G84,G85,G86,G88,G89�ŉ��H����T�C�N��������ꍇ�A
# ���̃T�C�N���Ŏw�߂��Ă���XY���W�ɑ΂���
# ����̃v���O�������̑O�H����
# G73,G81,G82,G83�Ō���������T�C�N�����Ȃ��ꍇ��
# �x������ꍇ�� 1�A�x�����Ȃ��ꍇ 0 ��ݒ肵�Ă��������B
# (���������^�b�v���H������ꍇ�ŁA1�������������ƍ��W���Ⴄ�~�X�Ȃǂ����o�ł��܂��B
# �^�b�s���O��{�[�����O���H���݂̂̃v���O�����̏ꍇ�� 0 ��ݒ肵�Ă��������B)
$prepared_hole_flag = 0;

# �厲��Z���}�C�i�X�����ɑ����肵���ꍇ��
# ���̍�����XY�����ɒ�����ԁA�܂��͉~�ʕ�Ԃ��Ă���ꍇ��
# �x������ꍇ�� 1�A�x�����Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$Z_G00_warn_flag = 1;

# �厲��Z���v���X�����ɓ������ꍇ(Z���P�Ƃ̈ړ�)��
# ������Ԃňړ������Ă���ʂ�
# ���̒l�𒴂��Ă���ꍇ�A�x�����܂�(�P��:�~��)�B
# (������̕����ӂ��킵���ꍇ�ł�)
# �K�v�Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$Z_G01escape_max = 30;

# Z���}�C�i�X�����֒�����Ԃňړ������(�P�u���b�N�̖��߂�)��
# ���̒l�𒴂��Ă���ꍇ�A�x�����܂�(�P��:�~��)�B
# ���̒l�Őݒ肵�A�K�v�Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
$Z_G01_max = 50;

# �T�u�v���O�����̓��C���v���O�����Ɠ����t�@�C������
# ���C���v���O�����̉����ɋL�q����Ă���ΔF�����܂��B
# �T�u�v���O������ʂ̃t�@�C���ɋL�q����ꍇ�́A
# O[�v���O�����ԍ�]�Ŏn�܂�t�@�C�����̃t�@�C��(��: O100.ncd)��
# ���C���v���O�����̃t�@�C���Ɠ����t�H���_�ɓ���邩�A
# �ȉ��ɐݒ肷��p�X�̃t�H���_�ɃT�u�v���O�����̃t�@�C�������Ă��������B
$sub_folder= 'C:\Program Files\NCVC\subpro';

# NCVC����CAM�\�t�g�ŏo�͂��ꂽ�v���O�����Ɏ蓮�ōH��������߂�ǉ�����Ƃ��A
# G90G54G00X0Y0���ǉ�����ꍇ������܂���(���Ȃ��Ƃ����ߍ���ł�)�A
# ���̈ړ��悪�H������O��XY���W�̕Е��������͗����ƈ�v���Ă���Ƃ�
# �o�͂��ꂽ�v���O�����ɂ͈ړ��̂Ȃ����̃R�[�h�͋L�q����Ă��Ȃ����Ƃ�����܂����A
# ���̏ꍇ�A���̈ړ��悪X0��Y0�ŏ����������Ă��邱�ƂɂȂ�܂��B
# ���̉\�������鎞�A�x������ꍇ�� 1�A�x�����Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
# (1.�H������A2.G00X0Y0�A3.X�܂���Y���݂̂̈ړ����AXY�ړ��̂Ȃ��Œ�T�C�N��
#  �̏����𖞂������ꍇ�A�x�����܂�)
$after_TC_warn_flag = 0;

# �I�v�V���i���u���b�N�X�L�b�v��L��(ON)�ɂ������ꍇ�� 1�A
# ����(OFF)�ɂ������ꍇ�� 0 ��ݒ肵�Ă��������B
$OBS_switch = 0;

# M98�̌J��Ԃ����̎w����@�ɂ��āA
# M98P��������L����������L�Ŏw�肷������̏ꍇ�� 0�A
# M98P�����������������̑O4���Ŏw�肷������̏ꍇ�� 1 ��ݒ肵�Ă��������B
$M98_houshiki = 0;

# WHILE��DO���[�v���ł̃��[�v���̏������ݒ肵�Ă��������B
# �������ȂǂŃ��[�v���I���Ȃ��ꍇ�ɖ������[�v��h���܂��B
$loop_max = 300;

# �v���O�����S�̂ł�GOTO���߂̏������ݒ肵�Ă��������B
# GOTO�����ł̖������[�v��h���܂��B
$GOTO_exe_max = 500;

# �V�X�e���ϐ����g�p����ꍇ�ŁA�����l���K�v�Ȃ��̂͒l��o�^���Ă��������B
# ������Ԃ�G�R�[�h�̃��[�_����񂪈Ⴄ�ꍇ�����l(�X�N���v�g���� %initial_G �Q��)�B
#%system_value = (,);

# Windows���łȂ��ꍇ�ŁA���s�G���[�ɂȂ�ꍇ��
# �ȉ��̍s���� # ��t���Ă��������B
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
	if($^O =~ /Win/){ print "\n���̓t�@�C�����w�肳��Ă��܂���B\n\n"; }
	else{ print encode('UTF-8', decode('Shift_JIS', "\n���̓t�@�C�����w�肳��Ă��܂���B\n\n")); }
	exit;
}

open(IN,$pre_file);
while(<IN>){
	push(@main,$_);
}
close(IN);

if($main[0] =~ /\[.*\.pl���s����\]/){
	if($out_file ne ""){
		open(OUT,">$out_file");
		print OUT "(���s���ʂ̃t�@�C���ɑ΂��Ă����$scriptName�����s���ꂽ�̂ŏ����𒆎~���܂���)";
		close(OUT);
	}
	else{
		if($^O =~ /Win/){
			print "\n(���s���ʂ̃t�@�C���ɑ΂��Ă����$scriptName�����s���ꂽ�̂ŏ����𒆎~���܂���)\n\n";
		}
		else{
			print encode('UTF-8', decode('Shift_JIS', "\n(���s���ʂ̃t�@�C���ɑ΂��Ă����$scriptName�����s���ꂽ�̂ŏ����𒆎~���܂���)\n\n"));
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
	$pre_file_sjis= "[�g�p�X�N���v�g: $scriptName]\n[�Ώۃt�@�C��: $pre_file]\n";
}
#elsif($^O =~ /Mac/ or $^O =~ /darwin/){
else{
	$log_file= $ENV{"HOME"}."/$log_file";
	use Encode 'decode';
	use Encode 'encode';
	$pre_file_sjis= "[�g�p�X�N���v�g: $scriptName]\n[�Ώۃt�@�C��: ".encode('Shift_JIS', decode('UTF-8', $pre_file))."]\n";
}

open(LOG,">>$log_file");
my ($sec, $min, $hour, $mday, $mon, $year) = (localtime(time))[0..5];
printf(LOG "<%d/%02d/%02d %02d:%02d:%02d>\n", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
print LOG $pre_file_sjis;

if($out_file ne ""){
	open(OUT,">$out_file");
	print OUT "[$scriptName���s����]\n";
}
else{
	if($^O =~ /Win/){
		print "\n[$scriptName���s����]\n\n";
	}
	else{
		print encode('UTF-8', decode('Shift_JIS',"\n[$scriptName���s����]\n\n"));
	}
}
main();
if($error_flag == 0){ write_log2("���͌�����܂���ł����B", "�x���Ȃ�"); }
close(OUT);
close(LOG);
if($out_file eq ""){ print "\n\n"; }


### �p�~�����ݒ� #################################################
# �J�X�^���}�N�����g���R�[�h�̏ꍇ�� 1�A
# �g��Ȃ��ꍇ�� 0 ��ݒ肵�Ă��������B
# 1 �̏ꍇ�̓A�h���X�̌�ɐ��l���Ȃ��G���[�̃`�F�b�N�͍s���܂���B
#$macro_flag = 0;

# # ���������y�сA�ϊ��O�̌������R�����g�o�͂���ꍇ��1�A
# # ���Ȃ��ꍇ��0��ݒ肵�Ă��������B
# # �������A�Œ���̓���������0��ݒ肵�Ă��o�͂���܂��B
# $debug_flag= 0;
# # ���[�_�������R�����g�o�͂���ꍇ��1�A
# # ���Ȃ��ꍇ��0��ݒ肵�Ă��������B
# $modal_flag= 0;

# # F�R�[�h�Ŏw�肷�鐔�l�̏����_�ȉ���0�̂Ƃ��A
# # �����_���o�͂��Ȃ��ꍇ��0�A
# # �����_���o�͂���ꍇ��1��ݒ肵�Ă��������B
# $F_flag= 0;

# # �V�X�e���ϐ� #5001,#5002,#5003�̕ω����R�����g�o�͂���ꍇ��1�A
# # ���Ȃ��ꍇ��0��ݒ肵�Ă��������B
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
#	if($modal_flag == 1){ print OUT '(----G�R�[�h�e�O���[�v�̃��[�_���������J�n----)'."\n"; }
	foreach $key(@initial_G_key){
		modal_shori($key+4000,$initial_G{$key});
	}
#	if($modal_flag == 1){ print OUT '(----G�R�[�h�e�O���[�v�̃��[�_���������I��----)'."\n"; }
	
	@system_value_key= keys(%system_value);
	
	$value[5001] = 0;
	$value[5002] = 0;
	$value[5003] = 0;
	$value[4115] = 0;
	
	if(@system_value_key != 0){
		@system_value_key= sort{$a <=> $b} @system_value_key;
#		if($debug_flag == 1){ print OUT '(---�V�X�e���ϐ��o�^�J�n---)'."\n"; }
		foreach $key(@system_value_key){
			$value[$key]= $system_value{$key};
#			print OUT '(---#'.$key.'= '.$system_value{$key}.'---)'."\n";
		}
#		if($debug_flag == 1){ print OUT '(---�V�X�e���ϐ��o�^�I��---)'."\n"; }
	}
	
	for($i=0;$i<=$#main;$i++){
		$_= $main[$i];
#		original_print($_);
		
		#�R�����g�������ꂽ���̂��߂�
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
					write_log($i+1, $_, "�厲���]���v���O������~���߂Œ�~���܂����B", "M30�Ŏ厲��~");
					$spindle_ON= 0;
				}
				if($coolant_ON == 1){
					write_log($i+1, $_, "�N�[�����g���v���O������~���߂Œ�~���܂����B", "M30�ŃN�[�����g��~");
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
					write_log2("�厲���]���v���O������~���߂Œ�~���܂����B", "$i�Ŏ厲��~");
					$spindle_ON= 0;
				}
				if($coolant_ON == 1){
					write_log2("�N�[�����g���v���O������~���߂Œ�~���܂����B", "$i�ŃN�[�����g��~");
					$coolant_ON= 0;
				}
			}
			last;
		}
	}
	
	if($O_warn_flag == 0 and $O_exist == 0){
		write_log2("O�R�[�h���w�߂���Ă��܂���B", "O�R�[�h���Ȃ�");
	}
	if($M30_exist == 0){
		write_log2("�v���O�����I���R�[�h(M30)������܂���B", "M30���Ȃ�");
	}
	if($T_yobidashi_flag== 1){
		write_log2("�Ăяo�����H��T$value[4120]�Ɍ��������Ƀv���O�������I�����܂����B", "�Ăяo����T�Ɍ��������Ƀv���O�����I��");
	}
	if($keihosei_mode == 1){
		write_log2("�H��a�␳�L�����Z�����Ȃ��܂܃v���O�������I�����܂����B", "�H��a�␳�L�����Z�������Ƀv���O�����I��");
	}
	if($koteiCycle_mode == 1 and $G80_flag == 0){
		write_log2("�Œ�T�C�N���L�����Z�����Ȃ��܂܃v���O�������I�����܂����B", "�Œ�T�C�N���L�����Z�������Ƀv���O�����I��");
	}
	if($spindle_ON == 1){
		write_log2("�厲���~�����Ȃ��܂܃v���O�������I�����܂���", "�厲��~�����ɂɃv���O�����I��");
	}
	if($spindle_ON == 1){
		write_log2("�N�[�����g���~�����Ȃ��܂܃v���O�������I�����܂���", "�N�[�����g��~�����ɂɃv���O�����I��");
	}
}

sub write_log{
	my ($lineNum, $line, $message, $logComment) = @_;
#	my ($lineNum, $progNum, $line, $message, $logComment) = @_;
	my $progNum= $value[4115];
	
	$line =~ s/\s*$//;
	if($progNum == 0 or $progNum == $proto_prog_No){
		if($out_file ne ""){
			print OUT "$lineNum�s��: $line �� $message\n";
		}
		else{
			if($^O =~ /Win/){
				print "$lineNum�s��: $line �� $message\n";
			}
			else{
				print encode('UTF-8', decode('Shift_JIS', "$lineNum�s��: $line �� $message\n"));
				#print "$lineNum�s��: $line �� $message\n";
			}
		}
	}
	else{
		if($out_file ne ""){
			print OUT "$lineNum�s��(O$progNum��$progKaisou): $line �� $message\n";
#			print OUT "$lineNum�s��(O$progNum��): $line �� $message\n";
		}
		else{
			if($^O =~ /Win/){
				print "$lineNum�s��(O$progNum��$progKaisou): $line �� $message\n";
#				print "$lineNum�s��(O$progNum��): $line �� $message\n";
			}
			else{
				print encode('UTF-8', decode('Shift_JIS', "$lineNum�s��(O$progNum��$progKaisou): $line �� $message\n"));
#				print encode('UTF-8', decode('Shift_JIS', "$lineNum�s��(O$progNum��): $line �� $message\n"));
				#print "$lineNum�s��(O$progNum��): $line �� $message\n";
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
	#���C���v���O�����̂Ƃ��A$progNum�� 0
	my ($line, $i, @prog)= @_;
	my ($c,$tmp,$sub_gyou);
	
	$_ = $line;
	
	if(/;\s*$/){
		write_log($i+1, $line, ";<EOB>�͕K�v����܂���B���s�����̈Ӗ��������܂�", ";<EOB>�����Ă���");
		s/;\s*$//;
	}
	
	if(/^\s*(\%)/){
		#print OUT $1.$';
		if($'=~ /\S/){
#			$_= $prog[$i];
			write_log($i+1, $line, "% �͒P�Ƃ̃u���b�N�ɂ��Ă��������B", "% ���P�ƂłȂ�");
			s/^\s*\%//;
		}
	}
	
	# ����(�R�����g)������
	if(/\(/){
		#$_= kakko_print($_);
		($_, $zenkakuComment) = comment_jokyo($_, $i);
		if($zenkakuComment == 1 and $ComZen_warn_flag == 0){
			write_log($i+1, $line, "�R�����g���ɑS�p�������܂�ł��܂��B", "�R�����g���ɑS�p�������܂�");
		}
	}
	if(/�i.*�j/){
		write_log($i+1, $line, "�R�����g�� () ���S�p�ł��B���p�ɂ��Ă��������B","�R�����g�� () ���S�p");
		s/�i.*�j//;
	}
	elsif(/�i.*\)/){
		write_log($i+1, $line, "�R�����g�� ( ���S�p�ł��B���p�ɂ��Ă��������B","�R�����g�� ( ���S�p");
		s/�i.*\)//;
	}
	elsif(/\(.*�j/){
		write_log($i+1, $line, "�R�����g�� ) ���S�p�ł��B���p�ɂ��Ă��������B","�R�����g�� ) ���S�p");
		s/\(.*�j//;
	}
	
	#����ȍ~��$_�̃R�����g����������Ă���
	
	# O��0�̌�蔻��
	if(/^\s*0([0-9]+)/){
		write_log($i+1, $line, "��������0<�[��>�ł��BO<���[>�ԍ��̌��ł́B", "�v���O�����ԍ�O��0�̊ԈႢ");
	}
	# 0��O�̌�蔻��
	elsif(/(?<![A-Z])[A-Z]\-?\d*[Oo]+\d*\.?[Oo\d]*/ or /(?<![A-Z])[A-Z]\-?\d*\.?\d*[Oo]+[Oo\d]*/){
		if(!/DO/ and !/GOTO/ and !/COS/ and !/ROUND/ and !/XOR/){
			write_log($i+1, $line, "������0<�[��>���A���t�@�x�b�gO<���[>�ɂȂ��Ă��܂��B", "���l�ɃA���t�@�x�b�g��O<���[>");
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
				write_log($i+1, $line, "O�R�[�h�̓v���O�����̍ŏ��ɋL�q���Ă��������B", "O���O�ɑ��A�h���X");
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
			#�T�u�v���O�������̍ŏ��̂n�͖���
			if(multi_O_check(@prog[0..$i]) == 1){
				write_log($i+1, $line, "O�R�[�h��2��ȏ�w�߂���Ă��܂��B", "O�R�[�h��2��ȏ�");
			}
		}
		$_ = $tmp;
	}
	
	# �������A�h���Xa-z����
	#if(/[a-z]\-?\d+\.?\d*/){
	#(?<!\x82)���Ȃ��ƁA�S�p�`-�y�Ɉ���������
	if(/(?<!\x82)[\x61-\x7A]\-?\d+\.?\d*/){
		$c= () = $_ =~ m/(?<!\x82)[\x61-\x7A]\-?\d+\.?\d*/g;
		write_log($i+1, $line, "�������̃A�h���X��$c�܂�ł��܂��B�啶���ɒ����Ă��������B", "�������A�h���X�~$c");
	}
	
	# 20190618
	# ������a-z�s���Ȉʒu
	#if(/[a-z]\-?\d+\.?\d*/){
	#(?<!\x82)���Ȃ��ƁA�S�p�`-�y�Ɉ���������
	if(/((?<!\x82)[\x61-\x7A])+/){
		write_log($i+1, $line, "�������̕����� $& ���s���ł��B", "�������̕����� $&");
	}
	
	# �S�p�A�h���X�`-�y����
	#if(/[�`-�y]\-?\d+\.?\d*/){
	if(/\x82[\x60-\x79]\-?\d+\.?\d*/){
		$c= () = $_ =~ m/\x82[\x60-\x79]\-?\d+\.?\d*/g;
		write_log($i+1, $line, "�S�p�A�h���X��$c�܂�ł��܂��B���p�ɒ����Ă��������B", "�S�p�A�h���X�~$c");
		$error_flag= 2;
	}
	# �������S�p�A�h���X��-������
	#if(/[��-��]\-?\d+\.?\d*/){
	if(/\x82[\x81-\x9A]\-?\d+\.?\d*/){
		$c= () = $_ =~ m/\x82[\x81-\x9A]\-?\d+\.?\d*/g;
		write_log($i+1, $line, "�S�p�ł���ɏ������̃A�h���X��$c�܂�ł��܂��B���p�̑啶���ɒ����Ă��������B", "�S�p�ŏ������A�h���X�~$c");
		$error_flag= 2;
	}
	# �S�p�n�C�t������
	# �v [\�[\�\\�]\�|] -> (\x81\[|\x81\\|\x81\]|\x81\|)
	# if(/[A-Z](\x81\[|\x81\\|\x81\]|\x81\|)\d+\.?\d*/){
	# [\�[\�\\�]\�|\��\��] -> \x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]
	if(/(?<![A-Z])[A-Z]\x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]\d+\.?\d*/){
		$c= () = $_ =~ m/(?<![A-Z])[A-Z]\x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]\d+\.?\d*/g;
		write_log($i+1, $line, "�S�p�n�C�t����$c�܂�ł��܂��B���p�ɒ����Ă��������B", "�S�p�n�C�t���~$c");
		s/\x81[\x5b|\x5c|\x5d|\x7c|\x9f|\xaa]/\x81\x5c/g;
		$error_flag= 2;
	}
	#����ȊO�̑S�p�����`�F�b�N
	if(zenkaku_check($_)== 1 and $error_flag != 2){
		write_log($i+1, $line, "�S�p�������܂�ł��܂��B���p�ɒ����Ă��������B", "���̑��S�p����");
		$error_flag= 2;
	}
	#�s�������_�`�F�b�N
	while(/(?<![A-Z])([A-Z])\-?(\d+\.\d*\.|\.{2,}\d+)/g){
		write_log($i+1, $line, "�A�h���X$1�̐��l�ɕ����̏����_���܂܂�Ă��܂��B", "�A�h���X$1�̐��l�ɕ����̏����_");
	}
	
	#�����_�ƃR���}�̌��`�F�b�N
	$tmp= $_;
	#G74,G84�̃I�v�V���� ,R01,S_ �����O
	if(/(?<![A-Z])G[78]4(?!\d)/){
		s/\,\s*(R*0[01]|S\d+\.?\*)//g;
	}
	while(/(?<![A-Z])([A-Z])\-?\d+\,\d*/g){
		write_log($i+1, $line, "�A�h���X$1�̐��l�̏����_���R���}�ɂȂ��Ă��܂��B", "�A�h���X$1�̐��l�̏����_���R���}");
		s/(?<![A-Z])[A-Z]\-?\d+\,\d*//g;
	}
	
	#�A�h���X����̃}�C�i�X�Ɛ����̊ԂɃX�y�[�X X- 10.0
	while(/(?<![A-Z])([A-Z])\-\s+\d+\.?\d*/g){
		write_log($i+1, $line, "�A�h���X$1����̃}�C�i�X�Ɛ����̊ԂɃX�y�[�X������܂��B���@�~�X�ł��B", "�A�h���X$1����̃}�C�i�X�Ɛ����̊ԂɃX�y�[�X");
	}
	
	# #�̒���ɐ����� [ �ȊO  #G01
	if(/\#[^\d\[\-]/){
		write_log($i+1, $line, "#�̒���ɐ����� [ �ȊO���L������Ă��܂��B", "#�̒���ɐ����� [ �ȊO");
	}
	
	# �擪�̐��l�ɃA�h���X�Ȃ�
	if(/^\s*(\d+\.?\d*|\.\d*)/){
		write_log($i+1, $line, "�u���b�N�擪�̐��l $& �ɃA�h���X������܂���B", "�u���b�N�擪�̐��l$&�ɃA�h���X���Ȃ�");
	}
	
	# �擪�̊֐��ɃA�h���X�Ȃ�
	if(/^\s*-?\[?(ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		write_log($i+1, $line, "�u���b�N�擪�̊֐� $& �ɃA�h���X������܂���B", "�u���b�N�擪�̊֐�$&�ɃA�h���X���Ȃ�");
	}
	
	# ���l�ɃA�h���X���Ȃ��@X10.\s100.0
	while(/(?<![A-Z])[A-Z]\-?(\d+\.?\d*|\.\d+)\s+(\d+\.?\d*|\.\d+)/g){
		write_log($i+1, $line, "���l$2�ɃA�h���X������܂���", "���l$2�ɃA�h���X���Ȃ�");
	}
	
	# �֐��A�ϐ��O�ɃA�h���X�����Z�q���Ȃ��@X10.0\s*COS , X10.0\s*#
#	while(/(?<![A-Z])-?(\d+\.?\d*|.\d+)\s+((\d+\.?\d*|\.\d+))/){
	while(/[\d\.]\s*((ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|\#(\d+|\[)))/g){
		write_log($i+1, $line, "$1�̑O�ɃA�h���X�����Z�q���K�v�ł��B", "$1�ɑO�ɃA�h���X�����Z�q���Ȃ�");
	}
	
	# ]�̒���Ɋ֐���ϐ��@]COS[
	while(/\]\s*((ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|\#(\d+|\[)))/g){
		write_log($i+1, $line, "$1�̑O�ɃA�h���X�����Z�q���K�v�ł��B", "$1�ɑO�ɃA�h���X�����Z�q���Ȃ�");
	}
	
	# #100 = 
	if(/^\s*\#/ and !/\=/){
		write_log($i+1, $line, "# �Ŏn�܂�u���b�N�� = ������܂���B�܂��́A# �̑O�ɃA�h���X������܂���B", "#�Ŏn�܂�u���b�N��=���Ȃ��A�܂���#�̑O�ɃA�h���X���Ȃ�");
	}
	
	#�A�h���X����̐����ɑ΂��Ďl�����Z X-10.0 - 20.0 , X-10.0 + #1 , X-10.0 + [ , X-10.0 + COS[180]
	while(/(?<![A-Z])([A-Z])\-?(\d+\.?\d*|\.\d+)\s*[\+\-\*\/]\s*([\d\.\#\[]|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR)/g){
		write_log($i+1, $line, "�A�h���X$1����̌v�Z����[ ]�ň͂�ł��������B", "�A�h���X$1����̌v�Z����[ ]���Ȃ�");
	}
	
	#�A�h���X����̕ϐ��ɑ΂��Ďl�����Z X#1 + 10.0
	while(/(?<![A-Z])([A-Z])\#\d+\.?\d*\s*[\+\-\*\/]\s*([\d\.\#\[]|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR)/g){
		write_log($i+1, $line, "�A�h���X$1����̌v�Z����[ ]�ň͂�ł��������B", "�A�h���X$1����̌v�Z����[ ]���Ȃ�");
	}
	
	#�A�h���X�̒��O�Ƀ}�C�i�X -X10.0
#	if(/\-\s*[A-Z]/ and $macro_flag == 0){
#	while(/\-\s*([A-Z])/g){
	while(/\-\s*([A-Z])\-?\d+\.?\d*/g){
		write_log($i+1, $line, "�A�h���X$1�̒��O�Ƀ}�C�i�X������܂��B���@�~�X�ł��B", "�A�h���X$1�̒��O�Ƀ}�C�i�X");
	}
	
	#�A�h���X����Ɋ֐� X ACOS[ ]  X-SIN[ ] 
	while(/(?<![A-Z])([A-Z])\s*\-?\s*(ABS|SQRT|SQR|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/g){
		write_log($i+1, $line, "�A�h���X$1����̊֐�$2��[ ]�ň͂�ł��������B", "�A�h���X$1�����[ ]�ň͂�łȂ��֐�$2");
	}
	#�A�h���X����Ɋ֐� A COS[ ]  X-SIN[ ] 
	while(/(?<![A-Z])([B-Z])\s*\-?\s*(SIN|COS|TAN)/g){
		write_log($i+1, $line, "�A�h���X$1����̊֐�$2��[ ]�ň͂�ł��������B", "�A�h���X$1�����[ ]�ň͂�łȂ��֐�$2");
	}
	#�A�h���X����� AND XOR
	while(/(?<![A-Z])([A-Z])\s*\-?\s*(AND|XOR)/g){
		write_log($i+1, $line, "�A�h���X$1�����$2������܂��B", "�A�h���X$1�����$2");
	}	
	#�A�h���X�����OR (X�ȊO) YOR   
	while(/(?<![A-Z])([A-WY-Z])\s*\-?\s*(OR)/g){
		write_log($i+1, $line, "�A�h���X$1�����$2������܂��B", "�A�h���X$1�����$2");
	}
	
	$tmp= $_;
	s/(IF|WHILE|THEN|DO\s*\d*|END\s*\d*|GOTO\s*\d*|(EQ|NE|GT|LT|GE|LE)\s*\-?\d*\.*\d*|ABS|SQRT|SIN|COS|ATAN|TAN|ROUND|FUP|FIX|BSC|BIN|AND|XOR|OR)//g;
	#�A�h���X�ɐ��l�Ȃ� XY10.0
#	if(/(?<![A-Z])[A-Z][A-Z\s]/ and $error_flag != 2){
	if($error_flag != 2){
		while(/(?<![A-Z])([A-Z])[A-Z\s]/g){ 
			write_log($i+1, $line, "�A�h���X$1�ɐ��l������܂���B","�A�h���X$1�ɐ��l���Ȃ�");
		}
	}
	$_= $tmp;
	
	#�֐��̌�� [ �Ȃ�
	while(/(?<![A-Z])((IF|WHILE|ABS|SQRT|SQR(?!T)|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN|AND|OR|XOR))(?!\s*\[)/g){
		write_log($i+1, $line, "$1�̒���� [ ���K�v�ł��B","$1����� [ ���Ȃ�");
	}
	
	#���l�̒���Ɋ֐���#1�A[�Ȃ�
	if(/(\-?[\d\.]+)\s*(\[|\#|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		write_log($i+1, $line, "���l$1�̒����$2������܂��B�A�h���X�����Z�q���K�v�ł��B","���l$1�̒����$2");
	}
	# ]�̒���ɐ��l��֐��Ȃ�
	if(/\]\s*(\d+|ABS|SQRT|SQR|SIN|COS|TAN|ASIN|ACOS|ATAN|ATN|ROUND|RND|FUP|FIX|BSC|BIN)/){
		write_log($i+1, $line, "] �̒���ɐ��l$1������܂��B�A�h���X�����Z�q���K�v�ł��B","] �̒���ɐ��l$1");
	}
	# [�̒��O�ɐ��l
	if(/(\-?[\d\.]+)\s*\[/){
		write_log($i+1, $line, "���l$1�̒���� [ ������܂��B�A�h���X�����Z�q���K�v�ł��B","���l$1�̒���� [");
	}


# �J�X�^���}�N���Ή��̂���
#	#�A�h���X�ɐ��l�Ȃ�
#	if(/(?<![A-Z])[A-Z][A-Z\s]/ and $macro_flag == 0 and $error_flag != 2){
#		write_log($i+1, $line, "�A�h���X�ɐ��l������܂���B","�A�h���X�ɐ��l���Ȃ�");
#	}
#	#�A�h���X�̒��O�Ƀ}�C�i�X
#	if(/\-\s*[A-Z]/ and $macro_flag == 0){
#		write_log($i+1, $line, "�A�h���X�̒��O�Ƀ}�C�i�X������܂��B���@�~�X�ł��B", "�A�h���X�̒��O�Ƀ}�C�i�X");
#	}
#	#�}�C�i�X�Ɛ����̊ԂɃX�y�[�X
#	if(/(?<![A-Z])[A-Z]\-\s+\d+\.?\d*/ and $macro_flag == 0){
#		write_log($i+1, $line, "�}�C�i�X�Ɛ����̊ԂɃX�y�[�X������܂��B���@�~�X�ł��B", "�}�C�i�X�Ɛ����̊ԂɃX�y�[�X");
#	}
	
	#�����A�h���X�ɏ����_�Ȃ�
#	if($DP_warn_flag == 0 and $macro_flag == 0){
	
	#�}�N���Ăяo���̈����ɂ͏����_����Ȃ�
	if($DP_warn_flag == 0 and !/(?<![A-Z])G6[56](?!\d)/){
		while(/(?<![A-Z])([XYZIJKRQ])\-?(\d+\.?\d*|\.\d+)/g){
			my ($address, $post_line)= ($1, $');
			if ($2 ne "0" and $2 !~ /\./){
				#�l�����Z�̏ꍇ�͏����_����Ȃ�
				if($post_line !~ /^\s*[\+\-\*\/]/){
					write_log($i+1, $line, "�����̃A�h���X$address�̐��l�ɏ����_������܂���B", "�A�h���X$address�̐��l�ɏ����_���Ȃ�");
				}
			};
		
		}
		#if(check_DP($_)== 1 and !/(?<![A-Z])G6[56](?!\d)/){
		#	write_log($i+1, $line, "�����̃A�h���X�ɏ����_������܂���B", "XYZIJKR�ɏ����_���Ȃ�");
		#}
	}
	#S�R�[�h�ɏ����_����
	if($S_DP_flag == 0){
		if(/(?<![A-Z])S\d+\.\d*/ and !/(?<![A-Z])G6[56](?!\d)/){
			if($' !~ /\s*[\+\-\*\/]/){
				write_log($i+1, $line, "S�R�[�h�̐��l�ɏ����_�����Ă��܂��B", "S�R�[�h�ɏ����_");
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
		s/\(.*?\)//;	#�R�����g����
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
		s/\(.*?\)//;	#�R�����g����
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
#			#�l�����Z�̏ꍇ�͏����_����Ȃ�
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
	
	#�ŏ��ɓǂݍ��񂾃t�@�C�����ɃT�u�v���O���������邩
	for($i=0;$i<=$#main;$i++){
		$_= $main[$i];
		#�^�[�Q�b�g�̃v���O�����ԍ����o�Ă�����ǂݍ��݊J�n
		if(/^\s*O0*$prog_No/){ ($prog_flag1,$prog_flag2)= (1,1); }
		#�Ⴄ�v���O�����ԍ����o�Ă�����ǂݍ��݂��
		elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }
		
		if($prog_flag2 == 1){ push(@prog,$_); }
	}
	#�T�u�v���O��������ǂݍ��񂾐�̃t�@�C�����ŕʂ̃T�u�v���O������T��
	if($prog_flag1 == 0){
		for($i=0;$i<=$#present_prog;$i++){
			$_= $present_prog[$i];
			if(/^\s*O0*$prog_No/){ ($prog_flag1,$prog_flag2)= (1,1); }
			elsif(/^\s*O[0-9]+/){ $prog_flag2= 0; }
			
			if($prog_flag2 == 1){ push(@prog,$_); }
		}
	}
	#�ǂݍ��݃t�@�C���Ɠ����t�H���_���ŃT�u�v���O�����̃t�@�C����T��
	if($prog_flag1 == 0){
		foreach(@sub_files2){
			if(/O0*$prog_No(?!\d)/){
				$prog_file= $pre_folder.$_;
				last;
			}
		}
		#�ݒ肵���T�u�v���O�����̃t�H���_�ŃT�u�v���O�����̃t�@�C����T��
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
#			print OUT '(---O'.$macro_No.'��������܂���---)'."\n";
			write_log($gyou+1, $line, "�}�N���v���O���� O$macro_No ��������܂���B", "G65�� O$macro_No ��������Ȃ��B");
			return $gyou;
		}
		
		$macro_level++;
		$yobidashi_tajuudo++;
		if($macro_level == 5){
#			print OUT '(---�}�N�����d�x�����x�𒴂��܂���---)'."\n";
			write_log( $gyou, $line, "�}�N�����d�x�����x�𒴂��܂���", "G65�Ń}�N�����d�x�����x�𒴂���");
			exit_shori();
		}
		if($yobidashi_tajuudo == 9){
#			print OUT '(---�Ăяo�����d�x�����x�𒴂��܂���---)'."\n";
			write_log( $gyou, $line, "�Ăяo�����d�x�����x�𒴂��܂���", "G65�ŌĂяo�����d�x�����x�𒴂���");
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
				
				#�R�����g�������ꂽ���̂��߂�
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
			write_log2("$line �� O$macro_No ��M99������܂���B","G65�Ŏg�p���� O$macro_No ��M99���Ȃ�");
		}
		return $gyou;
	}
	
	else{
#		print OUT $line;
#		print OUT '(---�v���O�����ԍ����w�肳��Ă��܂���---)'."\n";
		write_log($gyou+1, $line, "G65�ŌĂяo���v���O�����ԍ���P�R�[�h�Ŏw�߂��Ă��������B", "M65��P�R�[�h���Ȃ�");
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
#			print OUT '(---G67������܂���---)'."\n";
			write_log($G66_start+1, $line, "�Ή�����G67������܂���B", "G66�ɑΉ�����G67���Ȃ�");
			exit_shori();
		}
		
		@macro= prog_yomikomi($macro_No);
		if(! @macro){
			for($i=$G66_start; $i<=$G66_end; $i++){
				$_= $prog[$i];
#				print OUT;
			}
#			print OUT '(---O'.$macro_No.'��������܂���---)'."\n";
			write_log($G66_start+1, $line, "�}�N���v���O���� O$macro_No ��������܂���B", "G66�� O$macro_No ��������Ȃ��B");
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
			
			#�R�����g�������ꂽ���̂��߂�
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
#		print OUT '(---�v���O�����ԍ����w�肳��Ă��܂���---)'."\n";
		write_log($G66_start+1, $line, "���[�_���Ăяo�����s���v���O�����ԍ����w�߂���Ă��܂���BP�R�[�h�Ŏw�߂��Ă��������B", "G66��P�R�[�h���Ȃ�");
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
#			print OUT '(---�}�N�����d�x�����x�𒴂��܂���---)'."\n";
			write_log2("�}�N�����d�x�����x�𒴂��܂���","G66�Ń}�N�����d�x�����x�𒴂���");
			exit_shori();
		}
		if($yobidashi_tajuudo == 9){
#			print OUT '(---�Ăяo�����d�x�����x�𒴂��܂���---)'."\n";
			write_log2("�Ăяo�����d�x�����x�𒴂��܂���","G66�ŌĂяo�����d�x�����x�𒴂���");
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

			#�R�����g�������ꂽ���̂��߂�
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
		write_log2("$line �� O$macro_No ��M99������܂���B","G66�Ŏg�p���� O$macro_No ��M99���Ȃ�");
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
#			print OUT '(---O'.$prog_No.'��������܂���---)'."\n";
			write_log($gyou+1, $line, "P�Ŏw�߂��Ă���v���O���� O$prog_No ��������܂���", "�T�u�v�� O$prog_No ��������Ȃ��B");
			return $gyou;
		}
		
		$yobidashi_tajuudo++;
		if($yobidashi_tajuudo == 9){
#			print OUT '(---�Ăяo�����d�x�����x�𒴂��܂���---)'."\n";
			write_log($gyou+1, $line, "�Ăяo�����d�x�����x�𒴂��܂����B","�T�u�v���ŌĂяo�����d�x�I�[�o�[");
			exit_shori();
		}
		
#		print OUT '(---M98 start---)'."\n";
		for($j=1;$j<=$kurikaeshi_suu;$j++){;
#			print OUT '(---O'.$prog_No.' start---)'."\n";
			modal_shori(4115,$prog_No);
			for($i=0;$i<=$#sub;$i++){
				$_= $sub[$i];
#				original_print($_);
				
				#�R�����g�������ꂽ���̂��߂�
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
			write_log2("$line �� O$prog_No ��M99������܂���B","M98�Ŏg�p���� O$prog_No ��M99���Ȃ�");
		}
#		print OUT '(---M98 end---)'."\n";
		$yobidashi_tajuudo--;
		return $gyou;
	}
	else{
#		print OUT $line;
#		print OUT '(---�v���O�����ԍ����w�肳��Ă��܂���---)'."\n";
		write_log($gyou+1, $_, "M98�ŌĂяo���v���O�����ԍ���P�R�[�h�Ŏw�߂��Ă��������B", "M98��P�R�[�h���Ȃ��B");
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
			write_log($gyou+1, $line, "GOTO���s�񐔂�����l$GOTO_exe_max�𒴂��܂����B", "GOTO���s�񐔂�����l$GOTO_exe_max�𒴂���");
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
		
#		print OUT '(---N'.$idou_sequence.'������܂���---)'."\n";
		write_log($gyou+1, $line, "�ړ���� N$idou_sequence ������܂���B", "GOTO�ɑ΂���N$idou_sequence���Ȃ�");
		exit_shori();
	}
	else{
#		print OUT '(---GOTO��������������܂���---'."\n";
		write_log($gyou+1, $line, "GOTO��������������܂���B", "GOTO�����������Ȃ�");
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
			write_log($gyou+1, $line, "�������� $1 �͎g���܂���B$jouken_hash{$1} �ɏ��������Ă�������", "�������� $1");
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
			write_log($gyou+1, $line, "�������� $1 �͎g���܂���B$jouken_hash{$1} �ɏ��������Ă�������", "�������� $1");
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
#		print OUT '(---IF��������������܂���---'."\n";
		write_log($gyou+1, $line, "IF��������������܂���", "IF�����������Ȃ�");
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
			write_log($while_start+1, $line, "�������� $1 �͎g���܂���B$jouken_hash{$1} �ɏ��������Ă�������", "�������� $1");
		}
		
		for($i=$while_start+1; $i<=$#prog; $i++){
			$_= $prog[$i];
			if(/^\s*N?[0-9]*\s*END\s*$shikibetsu_bangou/){
				$while_end= $i;
				last;
			}
		}
		if(! defined($while_end)){
#			print OUT '(---END'.$shikibetsu_bangou.'������܂���---)'."\n";
			write_log( $i+1, $line, "END$shikibetsu_bangou������܂���", "DO$shikibetsu_bangou�ɑΉ�����END$shikibetsu_bangou���Ȃ�");
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
						write_log($i+1, $prog[$i], "�R�����g���ɑS�p�������܂�ł��܂��B", "�R�����g���ɑS�p�������܂�");
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
				write_log($while_start+1, $line, "���[�v�񐔂������$loop_max�𒴂��܂����B","���[�v�񐔂������$loop_max�𒴂���");
				exit_shori();
			}
		}
	}
	else{
#		print OUT '(---WHILE�\��������������܂���---)'."\n";
		write_log($while_start+1, $line, "WHILE��������������܂���", "WHILE�����������Ȃ�");
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
#			print OUT '(---END'.$shikibetsu_bangou.'������܂���---)'."\n";
			write_log($do_start+1, $line, "END$shikibetsu_bangou������܂���","DO$shikibetsu_bangou�ɑΉ�����END$shikibetsu_bangou���Ȃ�");
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
						write_log($i+1, $prog[$i], "�R�����g���ɑS�p�������܂�ł��܂��B", "�R�����g���ɑS�p�������܂�");
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
			#�������[�v�΍�
			if($loopCount > $loop_max){
				write_log($do_start+1, $line, "���[�v�񐔂������$loop_max�𒴂��܂����B","���[�v�񐔂������$loop_max�𒴂���");
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
#					print OUT '(---�A���[���ԍ� '.$alerm_No.'---)'."\n";
					write_log2("�V�X�e���ϐ�3000��(�A���[���ԍ�)�� $alerm_No ���ݒ肳��܂����B","�A���[���ԍ�(�V�X�e���ϐ�3000)��$alerm_No");
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
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <��>---)'."\n"; }
					}
					else{
						undef($value[$hensuu_No1]);
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <��>---)'."\n"; }
					}
				}
			}
			else{
				if(! defined($value[$hensuu_No2])){
					if($hensuu_No1 <= 33){
						undef($local_value[$macro_level][$hensuu_No1]);
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <��>---)'."\n"; }
					}
					else{
						undef($value[$hensuu_No1]);
#						if($debug_flag == 1){ print OUT '(---#'.$hensuu_No1.'= <��>---)'."\n"; }
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

#2018.02.20 $es�ǉ�
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
#		print OUT '(---���ʂ����Ă��܂���---)'."\n";
		write_log($gyou+1, $line, "\[ \]�����Ă��܂���B�X�N���v�g�𒆎~���܂��B", "\[ \]�����Ă��Ȃ��B�X�N���v�g���~");
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
		write_log($gyou+1, $_, "Work��Rect�̓X�y�[�X�ŋ�؂�܂���B", "NCVC�p�R�����g");
	}
	elsif(/Work C.*\=/i){
		write_log($gyou+1, $_, "Work��Cylinder�̓X�y�[�X�ŋ�؂�܂���B", "NCVC�p�R�����g");
	}
	elsif(/WorkR(?!ect).*\s*\=/i or /WarkRect\s*\=/i){
		write_log($gyou+1, $_, "WorkRect�̌��B", "NCVC�p�R�����g");
	}
	elsif(/WorkC(?!ylinder).*\s*\=/i or /WarkCylinder\s*\=/i){
		write_log($gyou+1, $_, "WorkCylinder�̌��B", "NCVC�p�R�����g");
	}
#	elsif(/\(\s*WorkRect\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){5}\s*\-?\d+\.?\d*\s*\))/i){
	elsif(/\(\s*WorkRect\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){5}\s*\-?\d+\.?\d*\s*\))/i and /\(\s*WorkRect\s*\=(?!(\s*\-?\d+\.?\d*\s*)x(\s*\-?\d+\.?\d*\s*)t(\s*\-?\d+\.?\d*\s*)\))/i){
		write_log($gyou+1, $_, "WorkRect=�ȍ~�́A�R���}�ŋ�؂���6�̐��l�A�܂���[X�����̑傫��]x[Y�����̑傫��]t[Z�����̑傫��]�ł��B", "NCVC�p�R�����g");
	}
#	elsif(/\(\s*WorkCylinder\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){4}\s*\-?\d+\.?\d*\s*\))/i){
	elsif(/\(\s*WorkCylinder\s*\=(?!(\s*\-?\d+\.?\d*\s*\,){4}\s*\-?\d+\.?\d*\s*\))/i and /\(\s*WorkCylinder\s*\=(?!(\s*\-?\d+\.?\d*\s*)h(\s*\-?\d+\.?\d*\s*)\))/i){
		write_log($gyou+1, $_, "WorkCylinder=�ȍ~�́A�R���}�ŋ�؂���5�̐��l�A�܂���[���a]h[����]�ł��B", "NCVC�p�R�����g");
	}
	
	if(/\(\s*Endmil\s*\=/i or /\(\s*Endomil.*\s*\=/i or /\(\s*Emdo?mil.*\s*\=/i){
		write_log($gyou+1, $_, "Endmill �̌��B", "NCVC�p�R�����g");
	}
	elsif(/\(\s*Do[rl]i(ll?|ru)\s*\=/i or /\(\s*Dril\s*\=/i or /\(\s*Dli(ll?|ru).*\s*\=/i){
		write_log($gyou+1, $_, "Drill �̌��B", "NCVC�p�R�����g");
	}
	elsif(/\(\s*(Tapu|Tapp|Tappu)\s*\=/i){
		write_log($gyou+1, $_, "Tap �̌��B", "NCVC�p�R�����g");
	}
	elsif(/\(\s*(R[ea]m[ea]r|Reamar|R(ea|[ea]|)n[ea]r)\s*\=/i){
		write_log($gyou+1, $_, "Reamer �̌��B", "NCVC�p�R�����g");
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

	#�Œ�T�C�N������
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
			write_log($gyou+1, $line, "1�u���b�N���ŌŒ�T�C�N���̃R�[�h�������w�߂���Ă��܂�($tmp)�B", "1�u���b�N���ŕ����̌Œ�T�C�N��($tmp)");
		}
		
		#�厲����]���Ă��Ȃ��ꍇ
		if($spindle_ON == 0 and not($M29_flag == 0 and /(?<![A-Z])G[78]4(?!\d)/)){
			if(/(?<![A-Z])G74(?!\d)/){
				write_log($gyou+1, $line, "�厲����]�������ɌŒ�T�C�N�����߂��Ă��܂��B", "�厲����]�������ɌŒ�T�C�N��");
			}
			else{
				write_log($gyou+1, $line, "�厲�𐳓]�������ɌŒ�T�C�N�����߂��Ă��܂��B", "�厲�𐳓]�������ɌŒ�T�C�N��");
			}
		}
		
		#�N�[�����g���o�Ă��Ȃ��Ƃ� 20190613�ǉ�
		if($M08_warn_flag == 1 and $coolant_ON == 0){
			write_log($gyou+1, $line, "�N�[�����g(�؍��)���o�����ɌŒ�T�C�N�����߂��Ă��܂��B", "�N�[�����g���o�����ɌŒ�T�C�N��");
		}
		
		if($tap_tool_flag == 1 and /(?<![A-Z])G(7[36]|8[1-35-9])(?!\d)/){
			write_log($gyou+1, $line, "�^�b�v�Ń^�b�s���O�T�C�N���ȊO�̌Œ�T�C�N�����w�߂���Ă��܂��B", "�^�b�v�Ń^�b�s���O�T�C�N���ȊO�̌Œ�T�C�N��");
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
				write_log($gyou+1, $line, "�Œ�T�C�N�����L�����Z������Ă��܂���B", "�Œ�T�C�N�����L�����Z������Ă��Ȃ�");
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
	
	#���葬�x�͈͔̔���
	if(/(?<![A-Z])F(\-?\d+\.?\d*)/){
		if($1 > $F_max){
			write_log($gyou+1, $line, "���葬�x���ݒ肳�ꂽ����l$F_max�𒴂��Ă��܂��B", "���葬�x������l�𒴂��Ă���");
		}
		elsif($1 < $F_min){
			$tmp= $1;
			if(!/(?<![A-Z])G[78]4(?!\d)/){
				write_log($gyou+1, $line, "���葬�x���ݒ肳�ꂽ�����l$F_min��������Ă��܂��B", "���葬�x�������l��������Ă���");
			}
			#�^�b�s���O�T�C�N���̏ꍇ�A�����l����͂��Ȃ����A�[���ƃ}�C�i�X�̓`�F�b�N
			elsif($tmp == 0){
				write_log($gyou+1, $line, "���葬�x��0���ݒ肳��Ă��܂��B", "���葬�x��0");
			}
			elsif($tmp == 0){
				write_log($gyou+1, $line, "���葬�x�Ƀ}�C�i�X�̒l���ݒ肳��Ă��܂��B", "���葬�x�Ƀ}�C�i�X�̒l");
			}
		}
	}
	
	#F�R�[�h�Ȃ��ő��x�w�߃^�C�v�̕�Ԃ����Ă��邩
	if(/(?<![A-Z])G(0*[123]|7[356]|8[1-9])(?!\d)/){
		if($value[4109] == 0){
			write_log($gyou+1, $line, "$&�̑��葬�x(F)���ݒ肳��Ă��܂���B", "$&�̑��葬�x���ݒ肳��Ă��Ȃ�");
		}
	}
	
	#�����G�O���[�v���̕���G�R�[�h�����邩
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
			write_log($gyou+1, $line, "����O���[�v��G�R�[�h�������w�߂���Ă��܂�($multi_G_str)�B", "����O���[�v��G�R�[�h�������w�߂���Ă���($multiG_str)");
		}
	}
	
	#�Œ�T�C�N����G00,G01,G02,G03�������u���b�N(�u���b�N�͈Ⴄ���s��)
	if(/(?<![A-Z])G0*[0123](?!\d)/ and /(?<![A-Z])G(7[346]|8[1-9])(?!\d)/){
		$tmp = "";
		while(/(?<![A-Z])G(0*[0123]|7[346]|8[1-9])(?!\d)/g){
			$tmp .= $& . ",";
		}
		$tmp =~ s/\,$//;
		write_log($gyou+1, $line, "1�u���b�N���ňړ����߂ƌŒ�T�C�N�����w�߂���Ă��܂�($tmp)�B", "1�u���b�N�ňړ����߂ƌŒ�T�C�N�����w��($tmp)");
	}
	
	#����M�R�[�h�`�F�b�N
	if( ( () = $new_line =~ /(?<![A-Z])M\d+\.?\d*/g ) > 1 and $multi_M == 0){
		write_log($gyou+1, $line, "1�u���b�N���ŕ�����M�R�[�h���w�߂���Ă��܂��B", "1�u���b�N��M�R�[�h������");
	}
	
	#�H������O�Ɏ��s���ׂ��R�[�h����
	if($pre_TC_code ne ""){
		$tmp= $line;
		$tmp =~ s/\s//g;
		if($tmp =~ $pre_TC_code){ $pre_TC_flag= 1; }
		elsif(!/(?<![A-Z])G0*4(?!\d)/ and !/(?<![A-Z])G(28|30)/ and !/(?<![A-Z])G92(?!\d)/){
			if(/(?<![A-Z])[XYZ]\-?\d+\.?\d*/){ $pre_TC_flag= 0; }
		}
	}
	#�H��Ăяo���ƍH������������u���b�N
	if(/(?<![A-Z])M0*6(?!\d)/ and /(?<![A-Z])T\d+/){
		if($pre_TC_flag == 0){ #�H������O�Ɏ��s���ׂ��R�[�h�����s����Ă��Ȃ�
			write_log($gyou+1, $line, "�ݒ肳��Ă���H������O�̃R�[�h<$pre_TC_code>�����s�����ɍH��������悤�Ƃ��Ă��܂��B", "�����O�Ɏ��s���ׂ��R�[�h�����s�ōH�����");
		}
		if($TC_warn_flag == 1){ #T��M06�𓯂��u���b�N�ɓ����ƌx��
			write_log($gyou+1, $line, "T�R�[�h��M06�͓����u���b�N�ɓ���Ȃ��ł��������B", "T�R�[�h��M06�������u���b�N�ɂ���");
		}
		if($TC_flag == 0){ #M06���s����̂Ƃ�
			$tmp= $present_T;
			$present_T = $value[4120];
			$value[4120]= $tmp;
			$T_yobidashi_flag= 1;
		}
		else{ #T�̎��s����̂Ƃ�
			$present_T = $value[4120];
			$T_yobidashi_flag= 0;
		}
		
		$G92_exist= 0;
		$G43_exist= 0;
		$M06_count++;
		$M06_exe= 1;
		
		#�厲������Ă���Ƃ�
		if($spindle_ON == 1){
			write_log($gyou+1, $line, "�H������O�Ɏ厲���~���Ă��������B", "�厲���]�̂܂܍H�����");
		}
		#�N�[�����g���o�Ă���Ƃ�
		if($coolant_ON == 1){
			write_log($gyou+1, $line, "�H������O�ɃN�[�����g��OFF���Ă��������B", "�N�[�����gON�̂܂܍H�����");
		}
		#�H��a�␳���L�����Z������Ă��Ȃ��Ƃ�
		if($keihosei_mode == 1){
			write_log($gyou+1, $line, "�H������O�ɍH��a�␳���L�����Z�����Ă��������B", "�H��a�␳�̂܂܍H�����");
		}
		#�Œ�T�C�N�����L�����Z������Ă��Ȃ��Ƃ�
		if($koteiCycle_mode == 1){
			if($G80_flag == 0){
				write_log($gyou+1, $line, "�H������O�ɌŒ�T�C�N�����L�����Z�����Ă��������B", "�Œ�T�C�N���L�����Z�������ɍH�����");
			}
			$koteiCycle_mode= 0;
		}
		
	}
	#�H��Ăяo�����̃`�F�b�N
	elsif(/(?<![A-Z])T\d+/){
		if($T_yobidashi_flag== 1){
			write_log($gyou+1, $line, "�O��Ăяo�����H������������ɐV�����H����Ăяo���Ă��܂��B", "�������Ȃ��܂ܕʂ̍H��Ăяo��");
		}
		if($TC_flag2 == 1){ #T��M06�������u���b�N�̋@��
			write_log($gyou+1, $line, "T�R�[�h��M06�������u���b�N�ɂȂ��ƍH������ł��Ȃ��@���T���P�ƂŎ��s����Ă��܂��B", "T�R�[�h��M06�������u���b�N�ɂȂ��ƌ����ł��Ȃ��ݒ��T��P�Ǝ��s");
		}
		$T_yobidashi_flag= 1;
	}
	#�H��������̃`�F�b�N
	elsif(/(?<![A-Z])M0*6(?!\d)/){
		if($pre_TC_flag == 0){ #�H������O�Ɏ��s���ׂ��R�[�h�����s����Ă��Ȃ�
			write_log($gyou+1, $line, "�ݒ肳��Ă���H������O�̃R�[�h<$pre_TC_code>�����s�����ɍH��������悤�Ƃ��Ă��܂��B", "�����O�Ɏ��s���ׂ��R�[�h�����s�ōH�����");
		}
		if($T_yobidashi_flag== 0){
			write_log($gyou+1, $line, "�H����Ăяo�����Ɍ������悤�Ƃ��Ă��܂��B", "T���Ăяo������M06���Ă���");
		}
		if($TC_flag2 == 1){  #T��M06�������u���b�N�̋@��
			write_log($gyou+1, $line, "T�R�[�h��M06�������u���b�N�ɂȂ��ƍH������ł��Ȃ��@���M06���P�ƂŎ��s����Ă��܂��B", "T�R�[�h��M06�������u���b�N�ɂȂ��ƌ����ł��Ȃ��ݒ��M06��P�Ǝ��s");
		}
		$present_T= $value[4120];
		$T_yobidashi_flag= 0;
		$G92_exist= 0;
		$G43_exist= 0;
		$M06_count++;
		$M06_exe= 1;
		
		#�厲������Ă���Ƃ�
		if($spindle_ON == 1){
			write_log($gyou+1, $line, "�H������O�Ɏ厲���~���Ă��������B", "�厲���]�̂܂܍H�����");
		}
		#�N�[�����g���o�Ă���Ƃ�
		if($coolant_ON == 1){
			write_log($gyou+1, $line, "�H������O�ɃN�[�����g��OFF���Ă��������B", "�N�[�����gON�̂܂܍H�����");
		}
		#�H��a�␳���L�����Z������Ă��Ȃ��Ƃ�
		if($keihosei_mode == 1){
			write_log($gyou+1, $line, "�H������O�ɍH��a�␳���L�����Z�����Ă��������B", "�H��a�␳�̂܂܍H�����");
		}
		#�Œ�T�C�N�����L�����Z������Ă��Ȃ��Ƃ�
		if($koteiCycle_mode == 1){
			if($G80_flag == 0){
				write_log($gyou+1, $line, "�H������O�ɌŒ�T�C�N�����L�����Z�����Ă��������B", "�Œ�T�C�N���L�����Z�������ɍH�����");
			}
			$koteiCycle_mode= 0;
		}
	}
	
	#��]�����ݒ肳��Ă��邩
	if(/(?<![A-Z])S(\-?\d+\.?\d*)/){
		if($1 > $S_max){
			write_log($gyou+1, $line, "�厲��]�����ݒ肳�ꂽ����l$S_max�𒴂��Ă��܂��B", "S������l�𒴂��Ă���");
		}
		elsif($1 < $S_min){
			write_log($gyou+1, $line, "�厲��]�����ݒ肳�ꂽ�����l$S_min��������Ă��܂��B", "S�������l��������Ă���");
		}
		$S_exist = 1;
	}
	
	if($S_flag == 0){
		if(/(?<![A-Z])M0*6(?!\d)/){ $S_exist = 0; }
	}
	
	if($new_line =~ /(?<![A-Z])M0*3(?!\d)/){
		#�厲���]���ɉ�]�����ݒ肳��Ă��邩
		if($S_exist == 0){
			write_log($gyou+1, $line, "�厲��]�����ݒ肳��Ă��Ȃ���ԂŎ厲���]����(M03)����Ă��܂��B", "��]���Ȃ���M03");
		}
		$spindle_ON= 1;
	}
	if(/(?<![A-Z])M0*5(?!\d)/){
		#Z���グ���Ɏ厲��~���Ă���ꍇ
		if($Z_up == 0){
			write_log($gyou+1, $line, "�厲����ɓ������Ȃ���ԂŎ厲��~����(M05)����Ă��܂��B", "�厲����ɓ���������M05");
		}
		$spindle_ON= 0;
	}
	
	#�N�[�����g���~�܂��Ă��邩
	if(/(?<![A-Z])M0*8(?!\d)/){ $coolant_ON = 1; }
	if(/(?<![A-Z])M0*9(?!\d)/){ $coolant_ON = 0; }
	
	if(/(?<![A-Z])G5[4-9]/){ $G54_exist= 1; }
	#���[�N���W�n���Ăяo����Ă��Ȃ���Ԃ�XY�ړ�
	if(/(?<![A-Z])[XY]\-?\d+\.?\d*/ and !/(?<![A-Z])G(0*4|28|30|92)(?!\d)/ and $value[4003] != 91
							and $G92_exist == 0 and $G54_exist == 0 and $G54_warned == 0){
		write_log($gyou+1, $line, "���[�N���W�n���Ăяo����Ă��܂���B", "���[�N���W�n���Ăяo����Ă��Ȃ�");
		$G54_warned= 1;
	}
	
	#�H��␳G43�Ăяo������H�R�[�h���w�߂���Ă��Ȃ�
	if(/(?<![A-Z])G43(?!\d)/){
		if($value[4111] == 0){
			write_log($gyou+1, $line, "�H��␳G43��H�R�[�h���w�߂���Ă܂���B", "G43�w�ߎ���H�R�[�h�Ȃ�");
		}
		#�H��␳�ԍ����H��ԍ��ƈႤ
		elsif($H_warn_flag == 0 and $value[4111] != $present_T){
			if($M06_count != 0 or $present_T_flag == 1){
				write_log($gyou+1, $line, "�␳�����H�ԍ���T�ԍ����قȂ�܂��B", "H�ԍ���T�ԍ����Ⴄ��Ԃ�G43");
			}
		}
		$G43_exist= 1;
	}
	#�H��␳��������Z�ړ�
	if(/(?<![A-Z])Z\-?\d+\.?\d*/ and !/(?<![A-Z])G(0*4|28|30|92)(?!\d)/ and $G92_exist == 0 and $G43_exist == 0 and $G43_warned == 0){
		if($M06_count == 0){
			write_log($gyou+1, $line, "�H��␳����Ă��܂���B", "�H��␳����Ă��Ȃ�");
		}
		else{
			write_log($gyou+1, $line, "T$present_T ���H��␳����Ă��܂���B", "T$present_T���H��␳����Ă��Ȃ�");
		}
		$G43_warned= 1;
	}
	if(/(?<![A-Z])G49(?!\d)/){ $G43_exist= 0; }
	if(/(?<![A-Z])G40(?!\d)/){
		$keihosei_mode= 0;
		$keihosei_warned= 0;
	}
	
	#�a�␳�̐�ǂ݂ł���s������
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
				 "�H��␳���[�h����XY�̈ړ����Ȃ��u���b�N����ǂ݂ł���u���b�N���𒴂��܂����B", "�H��␳���[�h��XY�̈ړ����Ȃ��u���b�N����ǂ݂ł���u���b�N���𒴂���");
			$keihosei_warned= 1;
		}
	}
	
	if(/(?<![A-Z])G4[12](?!\d)/){
		#�H��a�␳G41�܂���G42�Ăяo������D�R�[�h���w�߂���Ă��Ȃ�
		if($value[4107] == 0){
			write_log($gyou+1, $line, "�H��␳$&��D�R�[�h���w�߂���Ă܂���B", "$&�w�ߎ���D�R�[�h�Ȃ�");
		}
		#�H��a�␳�ԍ����H��ԍ��ƈႤ
		elsif($D_warn_flag == 0 and $value[4107] != $present_T){
			if($M06_count != 0 or $present_T_flag == 1){
				write_log($gyou+1, $line, "�␳�����D�ԍ���T�ԍ����قȂ�܂��B", "D�ԍ���T�ԍ����Ⴄ��ԂŌa�␳");
			}
		}
		$keihosei_mode= 1;
		$nonKeiHoseiLine= 0;
	}
	
	if(/(?<![A-Z])G[78]4(?!\d)/){
		if($G84_flag == 1){
			if($M29S_flag == 0){
				write_log($gyou+1, $line, "$&�̑O�̃u���b�N��M29S_������܂���B", "$&�̑O��M29S_���Ȃ�");
			}
		}
		else{
			if($M29S_flag2 == 1){
				if($M29S_flag == 1){
					write_log($gyou+1, $line, "$&�̑O�̃u���b�N��M29S_�͕K�v����܂���B", "$&�̑O��M29S_���K�v�Ȃ��@���G84�̑O�Ɏ��s");
				}
				if(!/(?<![A-Z])F\-?\d+\.?\d*/ and !/(?<![A-Z])S\-?\d+\.?\d*/){
					write_log($gyou+1, $line, "F�R�[�h��S�R�[�h������܂���B", "$1��F�R�[�h��S�R�[�h���Ȃ�(F,S���K�v�ȋ@��)");
				}
				elsif(!/(?<![A-Z])F\-?\d+\.?\d*/){
					write_log($gyou+1, $line, "F�R�[�h������܂���B", "$1��F�R�[�h���Ȃ�(F,S���K�v�ȋ@��)");
				}
				elsif(!/(?<![A-Z])S\-?\d+\.?\d*/){
					write_log($gyou+1, $line, "S�R�[�h������܂���B", "$1��S�R�[�h���Ȃ�(F,S���K�v�ȋ@��)");
				}
			}
		}
	}
	
	#M29S_�̍s����
	elsif(/(?<![A-Z])M29S\d+/){ $M29S_flag= 1; }
	else{ $M29S_flag= 0; }

	#G00�AG01�Ɠ����u���b�N��R,I,J(,K)������ꍇ�Ɍx��
	#G02�AG03�������u���b�N�ɂ���ꍇ�͌x�����Ȃ����A���̃`�F�b�N�Ɉ����������Ă�͂�
	if(/(?<![A-Z])G0*[01](?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])G0*[23](?!\d)/){
			while(/(?<![A-Z])([RIJK])\-?\d+\.?\d*/g){
				write_log($gyou+1, $line, "$tmp�̃u���b�N��$1�R�[�h���w�߂���Ă��܂��B", "$tmp�̃u���b�N��$1�R�[�h������");
			}
		}
	}
	
	#02�AG03�Ɠ����u���b�N��IJ�R�[�h��R�R�[�h���Ȃ��ꍇ�Ɍx��
	if(/(?<![A-Z])G0*[23](?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])[RIJ]\-?\d+\.?\d*/ and $value[4002] == 17){
			write_log($gyou+1, $line, "$tmp�ɂ�R�R�[�h�܂���I�EJ�R�[�h���K�v�ł��B", "$tmp�̃u���b�N��R�R�[�h��I�EJ�R�[�h���Ȃ�");
		}
		elsif(!/(?<![A-Z])[RIK]\-?\d+\.?\d*/ and $value[4002] == 18){
			write_log($gyou+1, $line, "G18�̂Ƃ���$tmp�ɂ�R�R�[�h�܂���I�EK�R�[�h���K�v�ł��B", "G18�̂Ƃ���$tmp�̃u���b�N��R�R�[�h��I�EK�R�[�h���Ȃ�");
		}
		elsif(!/(?<![A-Z])[RJK]\-?\d+\.?\d*/ and $value[4002] == 19){
			write_log($gyou+1, $line, "G19�̂Ƃ���$tmp�ɂ�R�R�[�h�܂���J�EK�R�[�h���K�v�ł��B", "G19�̂Ƃ���$tmp�̃u���b�N��R�R�[�h��J�EK�R�[�h���Ȃ�");
		}
	}
	
	#G�O���[�v1��2��3(�~�ʕ�Ԏ�)
	if($value[4001] =~ /0*[23](?!\d)/){
		if(/(?<![A-Z])R(\-?\d+\.?\d*)/){
			if($1 == 0){
				write_log($gyou+1, $line, "�~�ʕ�Ԃ�R��0�͂��肦�܂���B", "�~�ʕ�Ԃ�R��0");
			}
			if(/(?<![A-Z])[IJ]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "�~�ʕ�Ԃ�R�w�߂�IJ�w�߂ǂ��炩�Ŏw�߂��Ă��������B", "�~�ʕ�Ԃ�R��IJ��������");
			}
			elsif(/(?<![A-Z])[IK]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "G18�̂Ƃ��̉~�ʕ�Ԃ�R�w�߂�IK�w�߂ǂ��炩�Ŏw�߂��Ă��������B", "G18�̂Ƃ��̉~�ʕ�Ԃ�R��IK��������");
			}
			elsif(/(?<![A-Z])[JK]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "G19�̂Ƃ��̉~�ʕ�Ԃ�R�w�߂�JK�w�߂ǂ��炩�Ŏw�߂��Ă��������B", "G19�̂Ƃ��̉~�ʕ�Ԃ�R��JK��������");
			}
			if(!/(?<![A-Z])[XY]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "XY�̈ړ����Ȃ��AR�R�[�h�݂̂ł͉~�ʂ��������܂���B", "�~�ʕ�Ԃ�R�R�[�h�����邪XY�R�[�h���Ȃ�");
			}
			elsif(!/(?<![A-Z])[XZ]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "G18�̂Ƃ��AXZ�̈ړ����Ȃ��AR�R�[�h�݂̂ł͉~�ʂ��������܂���B", "G18�̂Ƃ��̉~�ʕ�Ԃ�R�R�[�h�����邪XZ�R�[�h���Ȃ�");
			}
			elsif(!/(?<![A-Z])[YZ]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "G19�̂Ƃ��AYZ�̈ړ����Ȃ��AR�R�[�h�݂̂ł͉~�ʂ��������܂���B", "G19�̂Ƃ��̉~�ʕ�Ԃ�R�R�[�h�����邪YZ�R�[�h���Ȃ�");
			}
		}
		#2020.03.30
		if(/G4[12](?!\d)/){
			if(/(?<!A-Z])[XYRIJ]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "�H��a�␳�̃X�^�[�g�A�b�v�u���b�N�ł͉~�ʕ�Ԃ͎g���܂���B", "�H��a�␳�̃X�^�[�g�A�b�v�u���b�N�ŉ~�ʕ��");
			}
			if(/(?<!A-Z])[XZRIK]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "�H��a�␳�̃X�^�[�g�A�b�v�u���b�N�ł͉~�ʕ�Ԃ͎g���܂���B", "G18�̂Ƃ��̍H��a�␳�̃X�^�[�g�A�b�v�u���b�N�ŉ~�ʕ��");
			}
			if(/(?<!A-Z])[YZRJK]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "�H��a�␳�̃X�^�[�g�A�b�v�u���b�N�ł͉~�ʕ�Ԃ͎g���܂���B", "G19�̂Ƃ��̍H��a�␳�̃X�^�[�g�A�b�v�u���b�N�ŉ~�ʕ��");
			}
		}
		if(/G40(?!\d)/){
			if(/(?<!A-Z])[XYRIJ]\-?\d+\.?\d*/ and $value[4002] == 17){
				write_log($gyou+1, $line, "�H��a�␳�̃L�����Z���u���b�N�ł͉~�ʕ�Ԃ͎g���܂���B", "�H��a�␳�̃L�����Z���u���b�N�ŉ~�ʕ��");
			}
			if(/(?<!A-Z])[XZRIK]\-?\d+\.?\d*/ and $value[4002] == 18){
				write_log($gyou+1, $line, "�H��a�␳�̃L�����Z���u���b�N�ł͉~�ʕ�Ԃ͎g���܂���B", "G18�̂Ƃ��̍H��a�␳�̃L�����Z���u���b�N�ŉ~�ʕ��");
			}
			if(/(?<!A-Z])[YZRJK]\-?\d+\.?\d*/ and $value[4002] == 19){
				write_log($gyou+1, $line, "�H��a�␳�̃L�����Z���u���b�N�ł͉~�ʕ�Ԃ͎g���܂���B", "G19�̂Ƃ��̍H��a�␳�̃L�����Z���u���b�N�ŉ~�ʕ��");
			}
		}
	}

# �Œ�T�C�N��������j
#
# �Œ�T�C�N���R�[�h�Ɠ����u���b�N����
# �u��Γ����v���Ȃ��ꍇ�ƁA�u��Γ���Ȃ��v������ꍇ�A�x��
#
#�R�[�h �W��      �ȗ���   ��Γ����@��Γ���Ȃ� 
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

	#Z���Ȃ��ꍇ�Ɍx��(G73,74,76,81,82,83,84,85,86,87,88,89)
	if(/(?<![A-Z])G(7[346]|8[1-9])(?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])(Z)\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmp��Z�R�[�h���w�߂���Ă��܂���B", "$tmp��Z�R�[�h���Ȃ�");
		}
	}
	#P���Ȃ��ꍇ�Ɍx��(G82,86,88,89)
	if(/(?<![A-Z])G8[2689](?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])P\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmp��P�R�[�h���w�߂���Ă��܂���B", "$tmp��P�R�[�h���Ȃ�");
		}
		elsif(/(?<![A-Z])P(\-?\d+\.?\d*)/){
			if($1 == 0){
				write_log($gyou+1, $line, "�Œ�T�C�N����P��0�͂��肦�܂���B", "�Œ�T�C�N����P��0");
			}
		}
	}
	#Q���Ȃ��ꍇ�Ɍx��(G73,76,83,87 ������G76,87��IJ�ł���)
	if(/(?<![A-Z])G(7[36]|8[37])(?!\d)/){
		$tmp = $&;
		if(!/(?<![A-Z])Q\-?\d+\.?\d*/ and not (/(?<![A-Z])G(76|87)(?!\d)/ and /(?<![A-Z])[IJ]\-?\d+\.?\d*/)){
			write_log($gyou+1, $line, "$tmp��Q�R�[�h���w�߂���Ă��܂���B", "$tmp��Q�R�[�h���Ȃ�");
		}
		elsif(/(?<![A-Z])Q(\-?\d+\.?\d*)/){
			if($1 == 0){
				write_log($gyou+1, $line, "�Œ�T�C�N����Q��0�͂��肦�܂���B", "�Œ�T�C�N����Q��0");
			}
		}
	}
	#P������ꍇ�Ɍx��(G81,85)
	if($new_line =~ /(?<![A-Z])G8[15](?!\d)/){
		$tmp = $&;
		if($new_line =~ /(?<![A-Z])(P)\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmp��$1�R�[�h���w�߂���Ă��܂��B", "$tmp��$1�R�[�h������");
		}
	}
	#P�ɏ����_������ꍇ�Ɍx��
	elsif($new_line =~ /(?<![A-Z])G(7[346]|8[2-46-9])(?!\d)/){
		$tmp = $&;
		if($line =~ /(?<![A-Z])P\-?\d+\.\d*/ and $P_DP_flag == 0){
			write_log($gyou+1, $line, "P�ɂ͒ʏ�A�����_�͂��܂���(����ƕb�A���Ȃ��ƃ~���b)�B", "$tmp��P�ɏ����_");
		}
	}
	
	#Q������ꍇ�Ɍx��(G74,81,82,84,85,86,88,89)
	if($new_line =~ /(?<![A-Z])G(74|8[1245689])(?!\d)/){
		$tmp = $&;
		if($new_line =~ /(?<![A-Z])(Q)\-?\d+\.?\d*/){
			write_log($gyou+1, $line, "$tmp��$1�R�[�h���w�߂���Ă��܂��B", "$tmp��$1�R�[�h������");
		}
	}

# H30.03.23 #5001 #5002 #5003 �ɑΉ�

# #4003 �� �O���[�v3 �� 90 or 91
# $value[4003] �� 90 or 91
# #4009 �� �O���[�v9 �� �Œ�T�C�N��(80,73,74,81,82,83,84,85,86,87,88,89)
# #4010 �� �O���[�v10 �� �Œ�T�C�N�����A���x��(98,99)


#���_���A�AG92�A������A������ԁA�~�ʕ�ԁA�h�E�F���A�Œ�T�C�N��

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

# G65X10.0Y30.0 ���@�o�͒i�K�ł͕ϊ�����Ă�͂�����()��

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
				write_log($gyou+1, $line, "G90�w�߂Ō��_���A����Ă��܂��B", "G90�w�߂Ō��_���A");
			}
			
			if(/(?<![A-Z])[XY]\-*[0-9\.]+/ and ($Z_G00_down == 1 or $Z_kirikomi == 1) ){
				write_log($gyou+1, $line, "Z��������ɓ���������XY�����Ɍ��_���A���Ă��܂��B", "Z������ɓ���������XY�����Ɍ��_���A");
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
				 		#�؂荞�ݏ�Ԃ�XY������(G40�̂Ƃ��ȊO)
				 		write_log($gyou+1, $line, "������ԓ���Z��؂荞�񂾏�Ԃ�XY�����ɑ����肵�Ă��܂��B", "������ԓ���Z��؂荞�񂾏�Ԃ�XY������");
					}
					if($value[4001] =~ /0*[123]/ and $Z_G00_down == 1 and $Z_G00_warn_flag == 1){
						#Z�}�C�i�X�ɑ����肵�������̂܂ܒ����A�܂��͉~�ʕ��(�I�v�V����)
						write_log($gyou+1, $line, "Z�}�C�i�X�����ɑ����肵��������XY�����ɒ����A�܂��͉~�ʕ�Ԃ��Ă��܂��B", "Z�}�C�i�X�����ɑ����肵��������XY�����ɒ����A�܂��͉~�ʕ��");
					}
				}
				#�~�ʕ�Ԃ��������邩����
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
							#�n�_����I�_�܂ł̋���
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 );
						}
						elsif($value[4002] == 18){
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						elsif($value[4002] == 19){
							$R2 = sqrt( ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						
						#���e��0.002
						if($R2 > 2 * abs($R1) + 0.002){
							write_log($gyou+1, $line, "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������܂���B", "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������Ȃ�");
						}
#						$R_value = $1;
#						if( ($value[4002] == 17 and ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 18 and ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 19 and ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) ){
#							write_log($gyou+1, $line, "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������܂���B", "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������Ȃ�");
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
						
						#���e��0.02
						if( abs($R1 - $R2) > 0.002){
							write_log($gyou+1, $line, "�w�߂���Ă��钆�S�_�ł͏I�_�ւ̉~�ʂ��������܂���B", "�w�߂���Ă��钆�S�_�ł͏I�_�ւ̉~�ʂ��������Ȃ�");
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
						write_log($gyou+1, $line, "�蓮�ōH������̃R�[�h��ǉ����Ă���ꍇ�AXY���W���m�F���Ă��������B(���̌x�����K�v�Ȃ��ꍇ�̓X�N���v�g�`���ɂ���ݒ��ύX���Ă��������B)", "�蓮�ōH������̃R�[�h�ǉ����XY���W�m�F");
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
								write_log($gyou+1, $line, "�ݒ肳�ꂽ�ړ������̏���l$Z_G01escape_max�~��(1�u���b�N��)�𒴂��āA������Ԃ�Z�𓦂����Ă��܂��B", "����l$Z_G01escape_max�ȏ�A������Ԃ�Z�𓦂����Ă���");
							}
						}
					}
					elsif($1 < $value[5003]){
						$Z_up= 0;
						
						#������łȂ�Z�������Ă���Ƃ�
						if($value[4001] != 0){
							#�厲����]���Ă��Ȃ��ꍇ
							if($spindle_ON == 0){
								write_log($gyou+1, $line, "�厲�𐳓]��������Z��؂荞��ł��܂��B", "�厲�𐳓]��������Z�؂荞��");
							}
							#�N�[�����g���o�Ă��Ȃ��Ƃ�
							if($M08_warn_flag == 1 and $coolant_ON == 0){
								write_log($gyou+1, $line, "�N�[�����g(�؍��)���o������Z��؂荞��ł��܂��B", "�N�[�����g���o������Z�؂荞��");
							}
							$Z_kirikomi= 1;
							$Z_G00_down= 0;
						}
						#�������Z�������Ă���Ƃ�
						else{ $Z_G00_down= 1; }
						
						if($Z_G01_max != 0){
							if($value[5003] - $1 > $Z_G01_max and $value[4001] == 1 and !/(?<![A-Z])[XY]\-?\d+\.?\d*/){
								write_log($gyou+1, $line, "�ݒ肳�ꂽ�ړ������̏���l$Z_G01_max�~��(1�u���b�N��)�𒴂��āAZ�}�C�i�X�����ɒ�����Ԃ��Ă��܂��B", "����l$Z_G01_max�𒴂��āAZ�}�C�i�X�����ɒ������");
							}
						}
					}
					$value[5003] = $1; #if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; }
				}
			}
			#�Œ�T�C�N���̂Ƃ�
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
						write_log($gyou+1, $line, "�蓮�ōH������̃R�[�h��ǉ����Ă���ꍇ�AXY���W���m�F���Ă��������B(���̌x�����K�v�Ȃ��ꍇ�̓X�N���v�g�`���ɂ���ݒ��ύX���Ă��������B)", "�蓮�ōH������̃R�[�h�ǉ����XY���W�m�F");
						$manual_origin_X= 0;
						$manual_origin_Y= 0;
					}
				}
				#�Œ�T�C�N���̂Ƃ���Z�[��
				if(/(?<![A-Z])Z(\-?\d+\.?\d*)/){
					$fukasa= $1;
					#Z���W���C�j�V�������x����荂���Ƃ�
					if($fukasa >= $value[5003]){
						write_log($gyou+1, $line, "�w�߂���Ă���Z���W���C�j�V�����_���x���ȏ�ɍ����ʒu�ł��B", "�Œ�T�C�N����Z���C�j�V�����_���x���ȏ�");
					}
				}
				
				if(/(?<![A-Z])R(\-*[0-9\.]+)/){
					$R_level= $1;
					if($value[4010] == 99){
						 $value[5003] = $R_level; #if($debug_flag2 == 1){ print OUT '(----#5003= '. $1. '----)'."\n"; }
					}
					#Z���W���C�j�V�������x�����͒Ⴂ��R�_���x�����������Ƃ�
					if($fukasa >= $R_level){
						if($fukasa < $value[5003]){
							write_log($gyou+1, $line, "�w�߂���Ă���Z���W��R�_���x���ȏ�ɍ����ʒu�ł��B", "�Œ�T�C�N����Z��R�_���x���ȏ�");
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
							# $hole_XYZ [0]:X���W�A[1]Y���W�A[2]Z�[��
							if($hole_XYZ[0] == $value[5001] and $hole_XYZ[1] == $value[5002]){
								if($pre_hole > $hole_XYZ[2]){ $pre_hole= $hole_XYZ[2]; }
							}
						}
						if($prepared_hole_flag == 1 and $pre_hole == 999){
							write_log($gyou+1, $line, "G$value[4009]�̑O�̉����̍H��������܂���B(���̌x�����K�v�Ȃ��ꍇ�̓X�N���v�g�`���ɂ���ݒ��ύX���Ă��������B)", "G$value[4009]�̑O�ɉ����̍H�����Ȃ�");
						}
						if($pre_hole != 999 and $Z_prepare_gap != 0 and $fukasa < $pre_hole + $Z_prepare_gap){
							write_log($gyou+1, $line, "���łɉ��H���ꂽ���ɑ΂��Đ؂荞�݂����ł��B", "���łɉ��H���ꂽ���ɑ΂��Đ؂荞�݂���");
						}
					}
				}
			}
			
			#�H�������Ƀ}�j���A���Ń��[�N���WXY���_�ɖ߂��Ă��邩
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
						#�؂荞�ݏ�Ԃ�XY������(G40�̂Ƃ�������)
						write_log($gyou+1, $line, "������ԓ���Z��؂荞�񂾏�Ԃ�XY�����ɑ����肵�Ă��܂��B", "������ԓ���Z��؂荞�񂾏�Ԃ�XY������");
					}
					if($value[4001] =~ /0*[123]/ and $Z_G00_down == 1 and $Z_G00_warn_flag == 1){
						#Z�}�C�i�X�ɑ����肵�������̂܂ܒ����A�܂��͉~�ʕ��(�I�v�V����)
						write_log($gyou+1, $line, "Z�}�C�i�X�����ɑ����肵��������XY�����ɒ����A�܂��͉~�ʕ�Ԃ��Ă��܂��B", "Z�}�C�i�X�����ɑ����肵��������XY�����ɒ����A�܂��͉~�ʕ��");
					}
				}
				
				#�~�ʕ�Ԃ��������邩����
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
							#�n�_����I�_�܂ł̋���
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 );
						}
						elsif($value[4002] == 18){
							$R2 = sqrt( ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						elsif($value[4002] == 19){
							$R2 = sqrt( ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 );
						}
						
						#���e��0.002
						if($R2 > 2 * abs($R1) + 0.002){
							write_log($gyou+1, $line, "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������܂���B", "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������Ȃ�");
						}

#						$R_value = $1;
#						if( ($value[4002] == 17 and ($end_X - $start_X) ** 2 + ($end_Y - $start_Y) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 18 and ($end_X - $start_X) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) or
#								($value[4002] == 19 and ($end_Y - $start_Y) ** 2 + ($end_Z - $start_Z) ** 2 > 4 * $R_value ** 2) ){
#							write_log($gyou+1, $line, "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������܂���B", "�w�߂���Ă��锼�a�l�ł͏I�_�ւ̉~�ʂ��������Ȃ�");
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
						
						#���e��0.02
						if( abs($R1 - $R2) > 0.002){
							write_log($gyou+1, $line, "�w�߂���Ă��钆�S�_�ł͏I�_�ւ̉~�ʂ��������܂���B", "�w�߂���Ă��钆�S�_�ł͏I�_�ւ̉~�ʂ��������Ȃ�");
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
								write_log($gyou+1, $line, "�ݒ肳�ꂽ����l$Z_G01escape_max�~���𒴂��āA������Ԃ�Z�𓦂����Ă��܂��B", "����l$Z_G01escape_max�ȏ�A������Ԃ�Z�𓦂����Ă���");
							}
						}
					}
					elsif($1 < 0){
						$Z_up= 0;
						
						#������łȂ�Z�������Ă���Ƃ�
						if($value[4001] != 0){
							#�厲����]���Ă��Ȃ��ꍇ
							if($spindle_ON == 0){
								write_log($gyou+1, $line, "�厲�𐳓]��������Z��؂荞��ł��܂��B", "�厲�𐳓]��������Z�؂荞��");
							}
							#�N�[�����g���o�Ă��Ȃ��Ƃ�
							if($M08_warn_flag == 1 and $coolant_ON == 0){
								write_log($gyou+1, $line, "�N�[�����g(�؍��)���o������Z��؂荞��ł��܂��B", "�N�[�����g���o������Z�؂荞��");
							}
							$Z_kirikomi= 1;
							$Z_G00_down= 0;
						}
						#�������Z�������Ă���Ƃ�
						else{ $Z_G00_down= 1; }
						
						if($Z_G01_max != 0){
							if($1 + $Z_G01_max > 0 and $value[4001] == 1 and !/(?<![A-Z])[XY]\-?\d+\.?\d*/){
								write_log($gyou+1, $line, "�ݒ肳�ꂽ����l$Z_G01_max�~���𒴂��āAZ�}�C�i�X�����ɒ�����Ԃ��Ă��܂��B", "����l$Z_G01_max�ȏ�AZ�}�C�i�X�����ɒ������");
							}
						}
					}
					$value[5003] = kagenzan($value[5003],$1); #if($debug_flag2 == 1){ print OUT '(----#5003= '. $value[5003]. '----)'."\n"; }
				}
			}
			#G91�ŌŒ�T�C�N��
			else{
				if(/(?<![A-Z])X(\-*[0-9\.]+)/){ $value[5001] = kagenzan($value[5001],$1); #if($debug_flag2 == 1){ print OUT '(----#5001= '. $value[5001]. '----)'."\n"; }
				}
				if(/(?<![A-Z])Y(\-*[0-9\.]+)/){ $value[5002] = kagenzan($value[5002],$1); #if($debug_flag2 == 1){ print OUT '(----#5002= '. $value[5002]. '----)'."\n"; }
				}
				if(/(?<![A-Z])Z(\-?\d+\.?\d*)/){
					$fukasa= $value[5003] + $1;
					
					if($1 >= 0){ 
						if(/(?<![A-Z])R\-?\d+\.?\d*/){
							write_log($gyou+1, $line, "�w�߂���Ă���Z���W��R�_���x���ȏ�ɍ����ʒu�ł��B", "�Œ�T�C�N����Z��R�_���x���ȏ�");
						}
						else{
							write_log($gyou+1, $line, "�w�߂���Ă���Z���W���C�j�V�����_���x���ȏ�ɍ����ʒu�ł��B", "�Œ�T�C�N����Z���C�j�V�����_���x���ȏ�");
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
							# $hole_XYZ [0]:X���W�A[1]Y���W�A[2]Z�[��
							if($hole_XYZ[0] == $value[5001] and $hole_XYZ[1] == $value[5002]){
								if($pre_hole > $hole_XYZ[2]){ $pre_hole= $hole_XYZ[2]; }
							}
						}
						if($prepared_hole_flag == 1 and $pre_hole == 999){
							write_log($gyou+1, $line, "G$value[4009]�̑O�̉����̃T�C�N��������܂���B(���̌x�����K�v�Ȃ��ꍇ�̓X�N���v�g�`���ɂ���ݒ��ύX���Ă��������B)", "G$value[4009]�̑O�ɉ����T�C�N�����Ȃ�");
						}
						if($pre_hole != 999 and $Z_prepare_gap != 0 and $fukasa < $pre_hole + $Z_prepare_gap){
							write_log($gyou+1, $line, "���łɉ��H���ꂽ���ɑ΂��Đ؂荞�݂����ł��B", "���łɉ��H���ꂽ���ɑ΂��Đ؂荞�݂���");
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
		if($num =~ /^\./){ #�����_�ȍ���0���Ȃ��ꍇ
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
