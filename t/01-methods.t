#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Music::ToRoman';

my $mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'minor',
);
isa_ok $mtr, 'Music::ToRoman';

my $roman = $mtr->parse('Am');
is $roman, 'i', 'i';
$roman = $mtr->parse('Bo');
is $roman, 'iio', 'iio';
$roman = $mtr->parse('CM');
is $roman, 'III', 'III';
SKIP: {
    skip 'note in bass not yet implemented', 1;
    $roman = $mtr->parse('Cm9/G');
    is $roman, 'iii9/vii', 'iii9/vii';
}
$roman = $mtr->parse('Em7');
is $roman, 'v7', 'v7';
$roman = $mtr->parse('A+');
is $roman, 'I+', 'I+';
$roman = $mtr->parse('BbM');
is $roman, 'bII', 'bII';
$roman = $mtr->parse('Bm add4');
is $roman, 'ii add4', 'ii add4';

done_testing();
