package Music::ToRoman;

# ABSTRACT: Convert notes and chords to Roman numeral notation

our $VERSION = '0.0501';

use Moo;
use strictures 2;
use namespace::clean;

use List::MoreUtils 'first_index';
use Music::Scales;

=head1 SYNOPSIS

  use Music::ToRoman;

  my $mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'minor',
  );
  my $roman = $mtr->parse('Am'); # i (minor)
  $roman = $mtr->parse('Bo');    # iio (diminished)
  $roman = $mtr->parse('CM');    # III (major)
  $roman = $mtr->parse('Em7');   # v7 (minor seventh)
  $roman = $mtr->parse('A+');    # I+ (augmented)
  $roman = $mtr->parse('BbM');   # bII (flat-two major)
  $roman = $mtr->parse('Cm9/G'); # iii9/VII

  # Also:
  $mtr = Music::ToRoman->new(
    scale_note => 'A',
    scale_name => 'dorian',
    chords     => 0,
  );
  $roman = $mtr->parse('A'); # i
  $roman = $mtr->parse('B'); # ii
  $roman = $mtr->parse('C'); # III

=head1 DESCRIPTION

C<Music::ToRoman> converts chords to Roman numeral notation.  Also individual
"chordless" notes may be converted given a diatonic mode B<scale_name>.

For example usage, check out the files F<eg/roman> and F<eg/basslines> in
L<Music::BachChoralHarmony>.

=head1 ATTRIBUTES

=head2 scale_note

Note on which the scale is based.  This can be one of C, Cb, C#, D, Db, D# ...

Default: C

=cut

has scale_note => (
    is      => 'ro',
    default => sub { 'C' },
);

=head2 scale_name

Name of the scale.  The diatonic mode names supported are:

  ionian / major
  dorian
  phrygian
  lydian
  mixolydian
  aeolian / minor
  locrian

Default: major

=cut

has scale_name => (
    is      => 'ro',
    default => sub { 'major' },
);

=head2 chords

Are we given chords to B<parse> with major ("M") and minor ("m") designations?

Default: 1

If this is set to 0, single notes may be used to return the major/minor Roman
numeral for the given diatonic mode B<scale_name>.

=cut

has chords => (
    is      => 'ro',
    default => sub { 1 },
);

=head1 METHODS

=head2 new()

  $mtr = Music::ToRoman->new(%arguments);

Create a new C<Music::ToRoman> object.

=head2 parse()

  $roman = $mtr->parse($chord);

Parse a given chord name into a Roman numeral representation.

=cut

sub parse {
    my ( $self, $chord ) = @_;

    # Literal diatonic modes when chords attribute is zero
    my @roman;
    if ( $self->scale_name eq 'major' || $self->scale_name eq 'ionian' ) {
        @roman = qw( I ii iii IV V vi vii );
    }
    elsif ( $self->scale_name eq 'dorian' ) {
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

    # Get just the note part of the chord name
    ( my $note = $chord ) =~ s/^(\w[#b]?).*$/$1/;

    # Get the roman representation based on the scale position
    my $position = first_index { $_ eq $note } @notes;
    my ( $roman, $accidental );
    if ( $position == -1 ) {
        if ( length($note) == 1 ) {
            $position = first_index { $_ =~ /$note/ } @notes;
            ( $accidental = $notes[$position] ) =~ s/^\w(.)$/$1/;
            $accidental = $accidental eq '#' ? 'b' : '#';
        }
        else {
            my $letter;
            ( $letter, $accidental ) = $note =~ /^(\w)(.)$/;
            $position = first_index { $_ eq $letter } @notes;
        }
    }
    $roman = $roman[$position];

    # Get everything but the note part
    ( my $decorator = $chord ) =~ s/^(?:\w[#b]?)(.*)$/$1/;

    # Are we minor or diminished?
    my $minor = $decorator =~ /[mo]/ ? 1 : 0;

    # Convert the case of the roman representation based on minor or major
    if ( $self->chords ) {
        $roman = $minor ? lc($roman) : uc($roman);
    }

    # Add any accidental found in a non-scale note
    $roman = $accidental . $roman if $accidental;

    # Drop the minor and major part of the chord name
    $decorator =~ s/M//i;

    if ( $decorator =~ /([A-G][#b]?)/ ) {
        my $letter = $1;
        $position = first_index { $_ eq $letter } @notes;
        $decorator =~ s/[A-G][#b]?/$roman[$position]/;
    }

    # Append the remaining decorator to the roman representation
    $roman .= $decorator;

    return $roman;
}

1;
__END__

=head1 SEE ALSO

L<Moo>

L<List::MoreUtils>

L<Music::Scales>

L<https://en.wikipedia.org/wiki/Roman_numeral_analysis>

=cut
