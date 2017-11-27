#!/usr/bin/perl

# Emblem to BMP Converter by Take

# v0.00	'00.03.12	����J�n
# v0.01	'00.03.14	DCI�t�H�[�}�b�g�̊��Ⴂ�����
# v0.02	'00.03.15	seek���g��Ȃ��悤�ɏ�������
# v0.02b'00.11.10   Changed back from DCI to use VMS files! Got rid of ugly
#                   's as well. It outputs the .BMP to STDOUT now...

$EMB_to_BMP_home = $ARGV[0];

#Emblem Format
#$EMB_ImageTop  = 0x02a0;
$EMB_ImageTop	= 0x0280;
$EMB_ImageLen  = 64*64*3/4;
#$EMB_PalletTop = 0x0ea0;
$EMB_PalletTop	= 0x0e80;
$EMB_PalletLen = 64*2;

#BMP Format (256�F���[�h)
$BMP_ImageTop  = 0x436;
$BMP_PalletTop = 0x36;
$BMP_FileLen   = 5174;
$Pallet = pack("A256");	# �p���b�g�o�͗p�o�b�t�@
$Image = pack("A4096");	# �C���[�W�o�͗p�o�b�t�@

$EMB_InFile  = $ARGV[1];              # �G���u�����t�@�C����
$BMP_InFile  = $EMB_to_BMP_home . "template.bmp";  # BMP�e���v���[�g�t�@�C����

open(EMB_IN,"<".$EMB_InFile) || die("can\'t open \'$EMB_InFile\'\n");
binmode(EMB_IN);
seek(EMB_IN,0,0);
read(EMB_IN,$EMB_Buffer,4128);
close(EMB_IN);

#�p���b�g�ǂݏo��
$buf = substr($EMB_Buffer,$EMB_PalletTop,$EMB_PalletLen);

# Goodbye DCI code -- Scott
#for($i=0; $i<$EMB_PalletLen/4; $i++){
#	($a,$b,$c,$d) = unpack("CCCC",substr($EMB_Buffer,$EMB_PalletTop+$i*4,4));
#	substr($buf,$i*4,4) = pack("CCCC",$d,$c,$b,$a);
#}

for($i=0; $i<64; $i++){
	($lo,$hi) = unpack("CC",substr($buf,$i*2,2));
	$pal = ($hi<<8)+$lo;
	$r = ($pal>>7) & 0xf8;	if ($r){$r += 0x7;}
	$g = ($pal>>2) & 0xf8;	if ($g){$g += 0x7;}
	$b = ($pal<<3) & 0xf8;	if ($b){$b += 0x7;}
	substr($Pallet,$i*4,4) = pack("CCCC",$b,$g,$r,0);
	# printf "%2x%2x%2x ",$r,$g,$b;
}

#�C���[�W�ǂݏo��
$buf = substr($EMB_Buffer,$EMB_ImageTop,$EMB_ImageLen);

# Goodbye DCI code -- Scott
#for($i=0; $i<$EMB_ImageLen/4; $i++){
#	($a,$b,$c,$d) = unpack("CCCC",substr($EMB_Buffer,$EMB_ImageTop+$i*4,4));
#	substr($buf,$i*4,4) = pack("CCCC",$d,$c,$b,$a);
#}

for($i=0; $i<$EMB_ImageLen/3; $i++){
	($hi,$mid,$lo) = unpack("CCC",substr($buf,$i*3,3));
	$buf2 = ($hi<<16)+($mid<<8)+$lo;
	$a = ($buf2>>18) & 0x3f;
	$b = ($buf2>>12) & 0x3f;
	$c = ($buf2>> 6) & 0x3f;
	$d = ($buf2    ) & 0x3f;
	substr($Image,$i*4,4) = pack("CCCC",$a,$b,$c,$d);
	# printf "%2x%2x%2x%2x ",$a,$b,$c,$d;
}

# �c�����ɔ��]
for($y=0; $y<32; $y++){
	for($x=0; $x<64; $x++){
		$buf = substr($Image,$y*64+$x,1);
		substr($Image,$y*64+$x,1) = substr($Image,(63-$y)*64+$x,1);
		substr($Image,(63-$y)*64+$x,1) = $buf;
	}
}

open(BMP_IN,"<".$BMP_InFile) || die("can\'t open \'$BMP_InFile\'\n");
binmode(BMP_IN);
seek(BMP_IN,0,0);
read(BMP_IN,$buf,$BMP_FileLen);
# print pack("A2",$buf);
close(BMP_IN);

# printf("%4x %4x\n",length($Pallet),length($Image));
substr($buf,$BMP_PalletTop,length($Pallet)) = $Pallet;
substr($buf,$BMP_ImageTop,length($Image)) = $Image;

print pack("A$BMP_FileLen",$buf);

exit();
