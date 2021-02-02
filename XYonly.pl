###ActivePerlをまずインストールして下さい。フリーソフトです。###
###http://www.activestate.com/Products/ActivePerl/?psbx=1###
###Perlについてはいろんなホームページで解説されています。検索して下さい。###
###このスクリプトファイルを、変換したいＮＣファイルと同じフォルダに入れて###
###ダブルクリックすると"anaExcel.ncd"というファイルができます。###
###注意！！変換したいファイル名を"ana.ncd"にしてから実行してください###
######ＮＣＶＣの設定は、穴あけデフォルトでいけると思いますが###
###Ｚ値（深さ）とＲ点とＦ値は整数で。小数点は必須。###
###スクリプトは基本的に、上の行から順番に実行していくので注意###

open(IN,"ana.ncd")||die"error:$!\n";###"ana.ncd"が変換したいファイル名です###
open(OUT,">anaExcel.ncd")||die"error:$!\n";###anaExcel.ncd"が変換後にできるファイル名です###
@SABU=<IN>;  
    foreach $line(@SABU)  {
       $line=~ s/G\d+//g;###/Ａ/Ｂ/でＡをＢに置き換えるという意味です###
       $line=~ s/Z\d+\.//g;###Z\d+\.とはZ4.とかZ23.のことです”正規表現”で検索して下さい###
       $line=~ s/Z\d+\.\d+//g;###置換えや削除はこの構文を使えば簡単です###
       $line=~ s/Z-\d+\.R\d+\.\d+//g;###ＺとＲが整数なら不要###
       $line=~ s/Z-\d+\.\d+R\d+\.\d+//g;###同上###
       $line=~ s/Z-\d+\.R\d+\.//g;
       $line=~ s/Z-\d+\.\d+R\d+\.//g;
       $line=~ s/Z\d+//g;
       $line=~ s/F\d+\.//g;
       $line=~ s/\(End of CircleData\)//g;
       $line=~ s/^\n//g;###行頭の改行を置き換え###
     }
print OUT @SABU;
close(IN);
close(OUT);
