#! /usr/bin/perl

#  change_axes.pl Version 1.2

#  ���W����ϊ�����X�N���v�g�B                    #

#  NC�v���O��������                                #
#  (INDEX -Y)�A(INDEX +Y)�A(INDEX -X)�A(INDEX +X)  #
#  �����ꂩ�̃R�����g������΁AXY�������ꂼ��      #
#  [-X]Z���AXZ���AYZ���A[-Y]Z���ɕϊ�����          #

# ������̃R�����g���Ȃ��ꍇ
####################################################
# XY����
#  [-X]Z���ɕϊ��������ꍇ�E�E�E  1
#  XZ���ɕϊ��������ꍇ�E�E�E     2
#  YZ���ɕϊ��������ꍇ�E�E�E     3
#  [-Y]Z���ɕϊ��������ꍇ�E�E�E  4
# �Ή����鐔����$mode= �̌�ɐݒ肵�Ă�������

$mode= 2;

# �Y������R�����g��NC�v���O�������ɂ���ꍇ��
# $mode= �ȉ��Őݒ肵�������͖�������܂�
####################################################


%puramai= ('-',1,'+',2);
%index_XY= ('X',1,'Y',0);
%axes_comment_hash= (1,'[-X]Z',2,'XZ',3,'YZ',4,'[-Y]Z');
%address_hash= ('X',0,'I',1,'Y',2,'J',3,'Z',4);
%heimen_hash= (1,18,2,18,3,19,4,19);
%kaiten_hash= (2,3,3,2);

@henkan_address= ('X','I','Z','K','Y',
'','','Z','K','Y',
'Y','J','Z','K','X',
'Y','J','Z','K','X');
@henkan_fugou= (1,1,0,0,0,
0,0,0,0,1,
0,0,0,0,0,
1,1,0,0,1);

($pre_file,$out_file)= ($ARGV[0],$ARGV[1]);
open(IN,$pre_file);
while(<IN>){
	push(@input,$_);
}
close(IN);

for(@input){
	if(/\(\s*INDEX\s*([\-\+])([XY])\s*\)/){
		$mode= $puramai{$1} + ($index_XY{$2} * 2);
		last;
	}
}

for(@input){
	if(/G17/){
		$G17_flag= 1;
		last;
	}
}

open(OUT,">$out_file");

print OUT '(change XY to ' . $axes_comment_hash{$mode} . ')' . "\n";

if($G17_flag != 1){ print OUT 'G'.$heimen_hash{$mode}."\n"; }
for(@input){
	if(/^\s*N?\d*\s*\(/){ print OUT; }
	else{
		if($mode == 2 or $mode == 4){
			if(/(G0*)([23])(\D)/g){ $_= $`.$1.$kaiten_hash{$2}.$3.$'; }
			if(/G41/){ $_= $`.G42.$'; }
			elsif(/G42/){ $_= $`.G41.$'; }
		}
		if(/G17/){ $_= $`.G.$heimen_hash{$mode}.$'; }

		while(/([XIYJZ])(\-?)(\d+\.?\d*)/g){
			print OUT $`;
			$_= $';

			$hyou_No= ($mode - 1)*5 + $address_hash{$1};
			$new_address= $henkan_address[$hyou_No];
			$address_fugou= $henkan_fugou[$hyou_No];

			if($new_address eq ''){ print OUT $&; }
			elsif($address_fugou == 0){ print OUT $new_address.$2.$3; }
			else{
				if(($2 eq '-') or ($3 == 0)){ print OUT $new_address.$3; }
				else{ print OUT $new_address.'-'.$3; }
			}
		}
		print OUT;
	}
}

close(OUT);

