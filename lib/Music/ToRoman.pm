package Music::ToRoman;

# ABSTRACT: Convert notes and chords to Roman numeral notation

our $VERSION = '0.1000';

use Carp;
use List::MoreUtils qw/ any first_index /;
use Moo;
use Music::Scales;

use strictures 2;
use namespace::clean;

=head1 SYNOPSIS

  use Music::ToRoman;

  my $mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'minor',
  );

  my $roman = $mtr->parse('Am');  # i (minor)
  $roman = $mtr->parse('Bo');     # iio (diminished)
  $roman = $mtr->parse('Bdim');   # iio (diminished)
  $roman = $mtr->parse('Bb');     # bII (flat-two major)
  $roman = $mtr->parse('CM');     # III (major)
  $roman = $mtr->parse('C');      # III (major)
  $roman = $mtr->parse('Cm9/G');  # iii9/VII (minor ninth with seven bass)
  $roman = $mtr->parse('Cm9/Bb'); # iii9/bii (minor ninth with flat-two bass)
  $roman = $mtr->parse('D sus4'); # IV sus4
  $roman = $mtr->parse('DMaj7');  # IV maj7 (major seventh)
  $roman = $mtr->parse('E7');     # V7 (dominant seventh)
  $roman = $mtr->parse('Em7');    # v7 (minor seventh)
  $roman = $mtr->parse('Fmin7');  # vi min7 (minor seventh)
  $roman = $mtr->parse('G+');     # VII+ (augmented)

  $mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'dorian',
    chords     => 0,
  );

  $roman = $mtr->parse('A');      # i
  $roman = $mtr->parse('B');      # ii
  $roman = $mtr->parse('C');      # III
  $roman = $mtr->parse('D');      # IV
  $roman = $mtr->parse('E');      # v
  $roman = $mtr->parse('F#');     # vi
  $roman = $mtr->parse('G');      # VII
  $roman = $mtr->parse('Amin7');  # i min7
  $roman = $mtr->parse('Bo');     # iio
  $roman = $mtr->parse('CMaj7');  # III maj7
  $roman = $mtr->parse('D7');     # IV7
  $roman = $mtr->parse('Em');     # v

=head1 DESCRIPTION

C<Music::ToRoman> converts named chords to Roman numeral notation.
Also individual "chordless" notes may be converted given a diatonic
mode B<scale_name>.

=head1 ATTRIBUTES

=head2 scale_note

Note on which the scale is based.  Default: C<C>

* Must be an uppercase letter either alone or followed by C<#> or C<b>.
Double-sharp and double-flat keys are not allowed.

=cut

has scale_note => (
    is      => 'ro',
    isa     => sub { die 'Invalid note' unless _valid_note( $_[0] ) },
    default => sub { 'C' },
);

=head2 scale_name

Name of the scale.  Default: C<major>

* Must be one of the lowercase names shown below.

The diatonic mode names supported are:

  ionian / major
  dorian
  phrygian
  lydian
  mixolydian
  aeolian / minor
  locrian

=cut

has scale_name => (
    is      => 'ro',
    isa     => sub { die 'Invalid scale' unless _valid_scale( $_[0] ) },
    default => sub { 'major' },
);

=head2 chords

Are we given chords to B<parse> with major (C<M>) and minor (C<m>)
designations?

Default: C<1>

* Must be a Boolean value.

If this is set to C<0>, single notes can be used to return the
major/minor Roman numeral for the given diatonic mode B<scale_name>.

=cut

has chords => (
    is      => 'ro',
    isa     => sub { die 'Invalid boolean' unless $_[0] == 0 || $_[0] == 1 },
    default => sub { 1 },
);

=head1 METHODS

=head2 new

  $mtr = Music::ToRoman->new(
    scale_note => $note,
    scale_name => $name,
  );

Create a new C<Music::ToRoman> object.

=head2 parse

  $roman = $mtr->parse($chord);

Parse a note or chord name into a Roman numeral representation.

For instance, the Roman numeral representation for the C<aeolian> (or
minor) mode is: C<i ii III iv v VI VII> - where the case indicates the
major/minor status of the given chord.

This can be overridden by parsing say, C<BM7> (B dominant seventh),
thus producing C<II7>.

If a major/minor chord designation is not provided, C<M> major is
assumed.

If the B<chords> attribute is off and a single note is given, the
diatonic mode of the B<scale_name> is used to find the correct Roman
numeral representation.

A diminished chord may be given as either C<o> or C<dim>, and both are
rendered as C<o>.

=cut

sub parse {
    my ( $self, $chord ) = @_;

    die 'No chord to parse'
        unless $chord;

    # Literal diatonic modes when chords attribute is zero
    my @roman = qw( I ii iii IV V vi vii ); # Default to major/ionian
    if ( $self->scale_name eq 'dorian' ) {
        @roman = qw( i ii III IV v vi VII );
    }
    elsif ( $self->scale_name eq 'phrygian' ) {
        @roman = qw( i II III iv v VI vii );
    }
    elsif ( $self->scale_name eq 'lydian' ) {
        @roman = qw( I II iii iv V vi vii );
    }
    elsif ( $self->scale_name eq 'mixolydian' ) {
        @roman = qw( I ii iii IV v vi VII );
    }
    elsif ( $self->scale_name eq 'minor' || $self->scale_name eq 'aeolian' ) {
        @roman = qw( i ii III iv v VI VII );
    }
    elsif ( $self->scale_name eq 'locrian' ) {
        @roman = qw( i II iii iv V VI vii );
    }

    # Get the scale notes
    my @notes = get_scale_notes( $self->scale_note, $self->scale_name );

    # Convert a diminished chord
    $chord =~ s/dim/o/;

    # Get just the note part of the chord name
    ( my $note = $chord ) =~ s/^([A-G][#b]?).*$/$1/;

    # Get the roman representation based on the scale position
    my $position = first_index { $_ eq $note } @notes;
    # If the note is not in the scale find a new position and accidental
    my $accidental;
    if ( $position == -1 ) {
        ( $position, $accidental ) = _pos_acc( $note, $position, \@notes );
    }
    my $roman = $roman[$position];

    # Get everything but the note part
    ( my $decorator = $chord ) =~ s/^(?:[A-G][#b]?)(.*)$/$1/;

    # Are we minor or diminished?
    my $minor = $decorator =~ /[mo]/ ? 1 : 0;

    # Convert the case of the roman representation based on minor or major
    if ( $self->chords ) {
        $roman = $minor ? lc($roman) : uc($roman);
    }

    # Add any accidental found in a non-scale note
    $roman = $accidental . $roman if $accidental;

    if ( $decorator =~ /maj/i || $decorator =~ /min/i ) {
        $decorator = lc $decorator;
    }
    else {
        # Drop the minor and major part of the chord name
        $decorator =~ s/M//i;
    }

    # A remaining note name is a bass decorator
    if ( $decorator =~ /([A-G][#b]?)/ ) {
        my $name = $1;
        $position = first_index { $_ eq $name } @notes;
        if ( $position >= 0 ) {
            $decorator =~ s/[A-G][#b]?/$roman[$position]/;
        }
        else {
            ( $position, $accidental ) = _pos_acc( $name, $position, \@notes );
            my $bass = $accidental . $roman[$position];
            $decorator =~ s/[A-G][#b]?/$bass/;
        }
    }

    # Append the remaining decorator to the roman representation
    $roman .= $decorator;

    return $roman;
}

sub _pos_acc {
    my ( $note, $position, $notes ) = @_;

    my $accidental;

    # If the note has no accidental...
    if ( length($note) == 1 ) {
        # Find the scale position of the closest note
        $position = first_index { $_ =~ /$note/ } @$notes;
        # Get the accidental of the scale note
        ( $accidental = $notes->[$position] ) =~ s/^[A-G](.)$/$1/;
        # TODO: Why?
        $accidental = $accidental eq '#' ? 'b' : '#';
    }
    else {
        # Get the accidental of the given note
        ( my $letter, $accidental ) = $note =~ /^([A-G])(.)$/;
        # Get the scale position of the closest note
        $position = first_index { $_ eq $letter } @$notes;
    }

    return $position, $accidental;
}

sub _valid_note {
    my ($note) = @_;

    my @valid = ();

    my @notes = 'A' .. 'G';

    push @valid, @notes;
    push @valid, map { $_ . '#' } @notes;
    push @valid, map { $_ . 'b' } @notes;

    return any { $_ eq $note } @valid;
}

sub _valid_scale {
    my ($name) = @_;

    my @valid = qw(
        ionian
        major
        dorian
        phrygian
        lydian
        mixolydian
        aeolian
        minor
        locrian
    );

    return any { $_ eq $name } @valid;
}

1;
__END__

=head1 SEE ALSO

L<List::MoreUtils>

L<Moo>

L<Music::Scales>

L<https://en.wikipedia.org/wiki/Roman_numeral_analysis>

For example usage, check out the files F<eg/roman> and F<eg/basslines>
in L<Music::BachChoralHarmony>.

=cut
