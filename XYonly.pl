###ActivePerl���܂��C���X�g�[�����ĉ������B�t���[�\�t�g�ł��B###
###http://www.activestate.com/Products/ActivePerl/?psbx=1###
###Perl�ɂ��Ă͂����ȃz�[���y�[�W�ŉ������Ă��܂��B�������ĉ������B###
###���̃X�N���v�g�t�@�C�����A�ϊ��������m�b�t�@�C���Ɠ����t�H���_�ɓ����###
###�_�u���N���b�N�����"anaExcel.ncd"�Ƃ����t�@�C�����ł��܂��B###
###���ӁI�I�ϊ��������t�@�C������"ana.ncd"�ɂ��Ă�����s���Ă�������###
######�m�b�u�b�̐ݒ�́A�������f�t�H���g�ł�����Ǝv���܂���###
###�y�l�i�[���j�Ƃq�_�Ƃe�l�͐����ŁB�����_�͕K�{�B###
###�X�N���v�g�͊�{�I�ɁA��̍s���珇�ԂɎ��s���Ă����̂Œ���###

open(IN,"ana.ncd")||die"error:$!\n";###"ana.ncd"���ϊ��������t�@�C�����ł�###
open(OUT,">anaExcel.ncd")||die"error:$!\n";###anaExcel.ncd"���ϊ���ɂł���t�@�C�����ł�###
@SABU=<IN>;  
    foreach $line(@SABU)  {
       $line=~ s/G\d+//g;###/�`/�a/�ł`���a�ɒu��������Ƃ����Ӗ��ł�###
       $line=~ s/Z\d+\.//g;###Z\d+\.�Ƃ�Z4.�Ƃ�Z23.�̂��Ƃł��h���K�\���h�Ō������ĉ�����###
       $line=~ s/Z\d+\.\d+//g;###�u������폜�͂��̍\�����g���ΊȒP�ł�###
       $line=~ s/Z-\d+\.R\d+\.\d+//g;###�y�Ƃq�������Ȃ�s�v###
       $line=~ s/Z-\d+\.\d+R\d+\.\d+//g;###����###
       $line=~ s/Z-\d+\.R\d+\.//g;
       $line=~ s/Z-\d+\.\d+R\d+\.//g;
       $line=~ s/Z\d+//g;
       $line=~ s/F\d+\.//g;
       $line=~ s/\(End of CircleData\)//g;
       $line=~ s/^\n//g;###�s���̉��s��u������###
     }
print OUT @SABU;
close(IN);
close(OUT);
