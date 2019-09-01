#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'Music::ToRoman';

throws_ok {
    Music::ToRoman->new( scale_note => 'X' )
} qr/Invalid note/, 'invalid note';

throws_ok {
    Music::ToRoman->new( scale_name => 'foo' )
} qr/Invalid scale/, 'invalid scale';

throws_ok {
    Music::ToRoman->new( chords => 123 )
} qr/Invalid boolean/, 'invalid boolean';

my $mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'minor',
);
isa_ok $mtr, 'Music::ToRoman';

throws_ok {
    $mtr->parse
} qr/No chord/, 'no chord to parse';

is $mtr->parse('Am'), 'i', 'i';
is $mtr->parse('Bb'), 'bII', 'bII';
is $mtr->parse('B'), 'II', 'II';
is $mtr->parse('Bo'), 'iio', 'iio';
is $mtr->parse('Bdim'), 'iio', 'iio';
is $mtr->parse('B dim'), 'ii o', 'ii o';
is $mtr->parse('Bmsus4'), 'iisus4', 'iisus4';
is $mtr->parse('Bm sus4'), 'ii sus4', 'ii sus4';
is $mtr->parse('CM'), 'III', 'III';
is $mtr->parse('Cm9/G'), 'iii9/VII', 'iii9/VII';
is $mtr->parse('Cm9/Bb'), 'iii9/bii', 'iii9/bii';
is $mtr->parse('DMaj7'), 'IVmaj7', 'IVmaj7';
is $mtr->parse('D Maj7'), 'IV maj7', 'IV maj7';
is $mtr->parse('E7'), 'V7', 'V7';
is $mtr->parse('Em7'), 'v7', 'v7';
is $mtr->parse('Emin7'), 'vmin7', 'vmin7';
is $mtr->parse('E min7'), 'v min7', 'v min7';
is $mtr->parse('F+'), 'VI+', 'VI+';
is $mtr->parse('Gadd9'), 'VIIadd9', 'VIIadd9';
is $mtr->parse('G add9'), 'VII add9', 'VII add9';
is $mtr->parse('G xyz'), 'VII xyz', 'VII xyz';
is $mtr->parse('Am5'), 'i5', 'i5';
is $mtr->parse('Am64'), 'i64', 'i64';

$mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'dorian',
    chords     => 0,
);
is $mtr->parse('A'), 'i', 'i';
is $mtr->parse('B'), 'ii', 'ii';
is $mtr->parse('C'), 'III', 'III';
is $mtr->parse('D'), 'IV', 'IV';
is $mtr->parse('E'), 'v', 'v';
is $mtr->parse('F#'), 'vi', 'vi';
is $mtr->parse('G'), 'VII', 'VII';

is $mtr->parse('A7'), 'i7', 'i7';
is $mtr->parse('B+'), 'ii+', 'ii+'; # Bogus chord
is $mtr->parse('Co'), 'IIIo', 'IIIo'; # Bogus chord
is $mtr->parse('Dmin7'), 'IVmin7', 'IVmin7'; # Bogus chord
is $mtr->parse('EMaj7'), 'vmaj7', 'vmaj7'; # Bogus chord
is $mtr->parse('Em'), 'v', 'v';
is $mtr->parse('F#/G'), 'vi/VII', 'vi/VII';
is $mtr->parse('Gb'), 'bVII', 'bVII';

$mtr = Music::ToRoman->new( scale_note => 'C#' );
isa_ok $mtr, 'Music::ToRoman';

is $mtr->parse('C#m'), 'i', 'i';
is $mtr->parse('D'), 'bII', 'bII';
is $mtr->parse('D#'), 'II', 'II';
is $mtr->parse('D#o'), 'iio', 'iio';
is $mtr->parse('D#dim'), 'iio', 'iio';
is $mtr->parse('D# dim'), 'ii o', 'ii o';
is $mtr->parse('D#msus4'), 'iisus4', 'iisus4';
is $mtr->parse('D#m sus4'), 'ii sus4', 'ii sus4';
is $mtr->parse('E#M'), 'III', 'III';
is $mtr->parse('E#m9/B#'), 'iii9/VII', 'iii9/VII';
is $mtr->parse('E#m9/D'), 'iii9/bii', 'iii9/bii';
is $mtr->parse('F#Maj7'), 'IVmaj7', 'IVmaj7';
is $mtr->parse('F# Maj7'), 'IV maj7', 'IV maj7';
is $mtr->parse('G#7'), 'V7', 'V7';
is $mtr->parse('G#m7'), 'v7', 'v7';
is $mtr->parse('G#min7'), 'vmin7', 'vmin7';
is $mtr->parse('G# min7'), 'v min7', 'v min7';
is $mtr->parse('A#+'), 'VI+', 'VI+';
is $mtr->parse('B#add9'), 'VIIadd9', 'VIIadd9';
is $mtr->parse('B# add9'), 'VII add9', 'VII add9';
is $mtr->parse('B# xyz'), 'VII xyz', 'VII xyz';
is $mtr->parse('C#5'), 'I5', 'I5';
is $mtr->parse('C#64'), 'I64', 'I64';

$mtr = Music::ToRoman->new( scale_note => 'Db' );
isa_ok $mtr, 'Music::ToRoman';

is $mtr->parse('Dbm'), 'i', 'i';
is $mtr->parse('D'), 'bII', 'bII';
is $mtr->parse('Eb'), 'II', 'II';
is $mtr->parse('Ebo'), 'iio', 'iio';
is $mtr->parse('Ebdim'), 'iio', 'iio';
is $mtr->parse('Eb dim'), 'ii o', 'ii o';
is $mtr->parse('Ebmsus4'), 'iisus4', 'iisus4';
is $mtr->parse('Ebm sus4'), 'ii sus4', 'ii sus4';
is $mtr->parse('FM'), 'III', 'III';
is $mtr->parse('Fm9/C'), 'iii9/VII', 'iii9/VII';
is $mtr->parse('Fm9/D'), 'iii9/bii', 'iii9/bii';
is $mtr->parse('GbMaj7'), 'IVmaj7', 'IVmaj7';
is $mtr->parse('Gb Maj7'), 'IV maj7', 'IV maj7';
is $mtr->parse('Ab7'), 'V7', 'V7';
is $mtr->parse('Abm7'), 'v7', 'v7';
is $mtr->parse('Abmin7'), 'vmin7', 'vmin7';
is $mtr->parse('Ab min7'), 'v min7', 'v min7';
is $mtr->parse('Bb+'), 'VI+', 'VI+';
is $mtr->parse('Cadd9'), 'VIIadd9', 'VIIadd9';
is $mtr->parse('C add9'), 'VII add9', 'VII add9';
is $mtr->parse('C xyz'), 'VII xyz', 'VII xyz';
is $mtr->parse('Dbm5'), 'i5', 'i5';
is $mtr->parse('Dbm64'), 'i64', 'i64';

done_testing();
