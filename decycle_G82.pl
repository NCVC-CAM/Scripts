#! /usr/bin/perl

#  G82�𑼂�NC�R�[�h�ɕϊ�����X�N���v�g  #

$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");

$initZ= 0;
$kotei_flag= 0;
$G82_flag= 0;
$i= 0;		# �R�����g�p�ϐ�
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

			### 1 X�CY���W�����蓮��
			if(/[XY]/){
				$XY_move= "G00";
				while(/[XY][\-\d\.]+/g){ $XY_move= $XY_move.$&; }
				$XY_move= $XY_move."\n";
			}
			### 2 R�_�ڋߓ���
			if(/R([\-\d\.]+)/){
				$R= $1;	 #R�_���A�p�ϐ�
				$Z_move= "G00Z".$R."\n";
			}
			else{ undef($R); }
			### 3 ���J������
			if(/Z([\-\d\.]+)/){
				$kirikomiZ= $1;	 #�؂荞�ݐ[���p�ϐ�
				if(/F[\d\.]+/){ push(@G82cycle,"G01Z".$kirikomiZ.$&."\n"); }
				else{ push(@G82cycle,"G01Z".$kirikomiZ."\n"); }
			}
			### 4 �h�E�F������
			if(/P[\d\.]+/){	push(@G82cycle,"G04".$&."\n"); }
			### �T Z���W���A����
			## G90�̂Ƃ�
			## G98�Ȃ�C�j�V�����_�ɁAG99�Ȃ�R�_�ɖ߂�
			if($G90G91 eq "G90"){
				if($G98G99 eq "G98"){ push(@G82cycle,"G00Z".$initZ."\n"); }
				else{
					push(@G82cycle,"G00Z".$R."\n");
					$initZ= $R;
				}
			}
			## G91�̂Ƃ�
			## �O��Ƃ���$R�A$kirikomiZ�̓}�C�i�X�̒l�B2,3�̍s���Ŋi�[�ς�
			## G99�̂Ƃ���R�_�ɖ߂�̂ŁA�؂荞��Z�̈ړ��ʂ����㏸����΂悢
			## G98�̂Ƃ��̓C�j�V�����_�ɖ߂�̂ŁA�؂荞��Z�̈ړ��ʂƁA
			## R�_���������ꍇ�́AR�_�܂ł̈ړ��ʂ�������ɏ㏸
			else{
				$kirikomiZ =~ s/-//;
				## G98�̂Ƃ��̓C�j�V�����_�܂ŏ㏸
				if($G98G99 eq "G98"){
					if(/R/){
						if($R =~ /-/){ $return_R= $'; }
						$kirikomiZ= marume($kirikomiZ,$return_R);
					}
					push(@G82cycle,"G00Z".$kirikomiZ."\n");
				}
				## G99�̂Ƃ��͐؂荞�񂾕������㏸�AR�_���L��
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
				## G82���[�h�łȂ��ꍇ�A���̂܂܏o��
				print OUT;
				### �C�j�V�����_�L���p�̏���
				## G90�̂Ƃ�
				if($G90G91 eq "G90"){
					## G99�̂Ƃ���R�_�ɖ߂�
					if($G98G99 eq "G99"){
						if(/R([\-\d\.]+)/){ $initZ= $1; }
					}
					## G98������Ƃ���Z�̎��̐����͐؂荞�݂̐[���ł����āA���A������W�ł͂Ȃ�
					## G98�ł̓C�j�V�����_�A�܂肻��ȑO�Ɉړ�����Z���W�ɕ��A����̂�$initZ��ύX����K�v�͂Ȃ�
					## ����āA����ȊO�̎���Z�̈ړ����W���Ď�����
					else{
						if(/Z([\-\d\.]+)/){ $initZ= $1; }
					}
				}
				## G91�̂Ƃ��͂��̓s�x�̑��ΗʂőΏ��ł��邪�A�r����G91����G90�Ɉڍs�����ꍇ�A��΍��W��������Ȃ��Ȃ�B
				## �����ŁAZ�̐�΍��W���ړ��̑��ΗʂŔc�����Ă����K�v������
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
