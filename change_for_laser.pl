#! /usr/bin/perl

#  NCVC�ŏo�͂���NC�R�[�h�����[�U�[���H�@�p�ɕϊ�����X�N���v�g  #
#   G01��Z���}�C�i�X�����ɐ؂荞�ރR�[�h��$ON_Code�A             #
#   G00�܂���G01��Z���v���X�����ɑҔ�����R�[�h��$OFF_Code       #
#  �ɕϊ�����                                                    #
#  �܂��AS�R�[�h����������                                       #
#  G90�̃R�[�h�̂ݑΉ�                                           #

#  �g�����̃R�c                                                  #
#  (1)NC�����I�v�V�����̐؍팴�_(G92)��Z�l��R�_��                #
#     ��(�v���X)�̓����l�ɂ���(�����[���ł��n�j)                 #
#  (2)�؂荞�݂��}�C�i�X�l�ɂ���                                 #
#  (3)�W���J�X�^���w�b�_�[�����[�U�p�ɃJ�X�^��                   #
#     {G90orG91}G54{G92_Initial} �� {G90orG91}G92{G92X}{G92Y}    #
#     {Spindle}M3                �� �폜                         #
#     (�K�v�ɉ����� T���� F�~�~�Ȃ�)                             #
#  (4)�J�X�^���t�b�^�[���J�X�^��                                 #
#     M30                                                        #
#     %                                                          #
#     �Ȃ�                                                       #
#  ���̐؍�����Ő�������NC�R�[�h���A���̃X�N���v�g�ŕϊ������  #
#  Z�l�̏㉺�ɍ��킹�ă��[�U�o�͂�ON/OFF������ł��܂�           #
#  
#  Ver. 2.0


#######################

#���[�U�[���I���ɂ���R�[�h
$ON_Code = 'M04';

#���[�U�[���I�t�ɂ���R�[�h
$OFF_Code = 'M05';

#######################


$pre_file= $ARGV[0];
$out_file= $ARGV[1];
open(IN,$pre_file);
open(OUT,">$out_file");


$G0X = -1;
$Zn=1000;
$Zp=1000;
$GCF = 0;
$preG0X = -1;

while(<IN>){

	if(!/^N?[0-9\s]*[\(\%]/){

		s/(S[\d\.]+)//;
		
		if(/G0*?([0123])[A-Z\s]/){
			$G0X= $1;
			$GCF = 0;
		}

		if($GCF == 1 && $G0X == $preG0X && /[XYZ]/){ print OUT "G0" . $G0X; }

		if($G0X != -1){
			if(/Z([0-9\-\.]+)/){ $Zn = $1; }
		}

		if($G0X == 1 && $Zn < $Zp){
			$_ = $ON_Code . "\n";
			$Zp = $Zn;
			$GCF = 1;
			$preG0X = $G0X;
		}
		elsif(($G0X == 0 or $G0X == 1) && $Zn > $Zp){
			$_ = $OFF_Code . "\n";
			$Zp = $Zn;
			$GCF = 1;
			$preG0X = $G0X;
		}
	}

	print OUT;

}