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
$roman = $mtr->parse('Cm9/G');
is $roman, 'iii9/VII', 'iii9/VII';
SKIP: {
    skip "can't parse non-scale notes in the bass", 1;
    $roman = $mtr->parse('Cm9/Bb');
    is $roman, 'iii9/bii', 'iii9/bii';
}
$roman = $mtr->parse('Em7');
is $roman, 'v7', 'v7';
$roman = $mtr->parse('A+');
is $roman, 'I+', 'I+';
$roman = $mtr->parse('BbM');
is $roman, 'bII', 'bII';
$roman = $mtr->parse('Bm sus4');
is $roman, 'ii sus4', 'ii sus4';

$mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'dorian',
    chords     => 0,
);
$roman = $mtr->parse('A');
is $roman, 'i', 'i';
$roman = $mtr->parse('B');
is $roman, 'ii', 'ii';
$roman = $mtr->parse('C');
is $roman, 'III', 'III';
$roman = $mtr->parse('D');
is $roman, 'IV', 'IV';
$roman = $mtr->parse('E');
is $roman, 'v', 'v';
$roman = $mtr->parse('F#');
is $roman, 'vi', 'vi';
$roman = $mtr->parse('G');
is $roman, 'VII', 'VII';

done_testing();
