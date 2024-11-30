#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'Music::ToRoman';

subtest throws => sub {
    throws_ok {
        Music::ToRoman->new( scale_note => 'X' )
    } qr/Invalid note/, 'invalid note';

    throws_ok {
        Music::ToRoman->new( major_tonic => 'X' )
    } qr/Invalid note/, 'invalid note';

    throws_ok {
        Music::ToRoman->new( scale_name => 'foo' )
    } qr/Invalid scale/, 'invalid scale';

    throws_ok {
        Music::ToRoman->new( chords => 123 )
    } qr/Invalid boolean/, 'invalid boolean';

    my $mtr = Music::ToRoman->new;
    isa_ok $mtr, 'Music::ToRoman';

    throws_ok {
        $mtr->parse
    } qr/No chord/, 'no chord to parse';
};

subtest degree_type => sub {
    my $mtr = Music::ToRoman->new;

    my $expect = 'major';
    my ($degree, $type) = $mtr->get_scale_nums('I');
    is $degree, 1, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('II');
    is $degree, 2, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('III');
    is $degree, 3, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('IV');
    is $degree, 4, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('V');
    is $degree, 5, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('VI');
    is $degree, 6, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('VII');
    is $degree, 7, 'degree';
    is $type, $expect, 'type';

    $expect = 'minor';
    ($degree, $type) = $mtr->get_scale_nums('i');
    is $degree, 1, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('ii');
    is $degree, 2, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('iii');
    is $degree, 3, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('iv');
    is $degree, 4, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('v');
    is $degree, 5, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('vi');
    is $degree, 6, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('vii');
    is $degree, 7, 'degree';
    is $type, $expect, 'type';

    $expect = 'diminished';
    ($degree, $type) = $mtr->get_scale_nums('io');
    is $degree, 1, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('iio');
    is $degree, 2, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('iiio');
    is $degree, 3, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('ivo');
    is $degree, 4, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('vo');
    is $degree, 5, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('vio');
    is $degree, 6, 'degree';
    is $type, $expect, 'type';
    ($degree, $type) = $mtr->get_scale_nums('viio');
    is $degree, 7, 'degree';
    is $type, $expect, 'type';
};

done_testing();
