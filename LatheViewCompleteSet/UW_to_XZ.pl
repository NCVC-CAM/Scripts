#! /usr/bin/perl

#  ‘•ª’l‚t,‚v‚ðâ‘Î’l‚wC‚y‚É•ÏŠ·‚·‚éƒXƒNƒŠƒvƒg  #



%UW= ("U","X","W","Z");
%XZ= ("X",0,"Z",1);
$pre_file= $ARGV[0];
$out_file= $ARGV[1];

open(IN,$pre_file);
open(OUT,">$out_file");
while(<IN>){
 	if($_ !~ /^N?[0-9\s]*[\(\%]/){
 if( $_ !~ /G28|G0??4\D/){
        if(/[XZUW]/){
			       $new_line= "";
            if(/[UW]/){
              while($_ =~ /([UW])([0-9\-\.]+)/){
 		               $kiso[$XZ{$UW{$1}}]= $kiso[$XZ{$UW{$1}}]+$2 ;
		                $kiso[$XZ{$UW{$1}}]=$kiso[$XZ{$UW{$1}}]*1000;
			              $kiso[$XZ{$UW{$1}}]=int($kiso[$XZ{$UW{$1}}]);
		                 $kiso[$XZ{$UW{$1}}]=$kiso[$XZ{$UW{$1}}]/1000;

   
		               	$new_line= $new_line.$`.$UW{$1}.$kiso[$XZ{$UW{$1}}];
		                $_=$';
  
               } 
								

              }
							$_= $new_line.$_;
             if(/[XZ]/){
											$new_line= "";
		          while($_ =~ /([XZ])([0-9\-\.]+)/){
			              $kiso[$XZ{$1}]=$2;
		               $kiso[$XZ{$1}]=$kiso[$XZ{$1}]*1000;
		                $kiso[$XZ{$1}]=int($kiso[$XZ{$1}]);
		                $kiso[$XZ{$1}]=$kiso[$XZ{$1}]/1000;

              			$new_line= $new_line.$`.$1.$kiso[$XZ{$1}] ;
										$_=$';

                }
  
								}
 								
        
$_= $new_line.$_;

         }

   } 
}
	if(!/^N?[0-9\s]*[\(\%]/){
		$new_line= "";
		while(/([XZIKRCUVWF])([\-\d\.]+)/){
			($pre_line,$char,$num,$_)= ($`,$1,$2,$');

			if($num !~ /\./ and $num != 0){ $num= $num."\."; }
			$new_line= $new_line.$pre_line.$char.$num;
		}
		$_= $new_line.$_;
	}
	print OUT;}
close(OUT);
close(IN);
