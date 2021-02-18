#!/bin/perl

# TCONS_00000001  XLOC_000001     DDX11L1|ENST00000456328 =       q1:DDX11L1|ENST00000456328|3|0.000000|0.000000|0.000000|1657    -       -       -       -       -       -       -       -       -       -       -       -       -
       -       -
# XLOC_000004     1[+]57598-64116      OR4G11P|ENST00000642116,OR4G11P|ENST00000492842 ENST00000642116,ENST00000492842

open (F, $ARGV[0]) or die;

while (<F>){
chomp;

my @s = split /\t/, $_;
my $xloc = $s[1];
my $geneid=$s[2];
my @t = split /\|/, $geneid;
$geneid = $t[1] . "_" . $t[0];

$xloc2geneid{$xloc} = $geneid . "_" . $xloc . "_" . $s[3];
# print $xloc . "\t" . $geneid . "\n";

}
close(F);

open (G, $ARGV[1]) or die;

while (<G>){
if (m/^#/ or m/^Geneid/){
print ;
next;
}
chomp;
my @v = split /\t/, $_;
if (defined ($xloc2geneid{$v[0]})){
$v[0] = $xloc2geneid{$v[0]};
}
print join "\t", @v;
print "\n";

}
close(G);
