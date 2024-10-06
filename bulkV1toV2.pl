use strict;
use warnings;
use Image::PNG::Libpng qw(read_png_file);
use JSON::PP;
use MIME::Base64;
use File::Spec;

my $count;

sub read_def_from_png {
    my $png = shift // $_;
    my $card = read_png_file($png) or die $!;
    my $chunks = $card->get_text();
    my ($chunk) = (grep { $_->{key} eq 'chara'} @$chunks);
    warn "No text found in file '$png'" unless $chunk;
    $chunk ? decode_json decode_base64($chunk->{text}) : undef;
}

sub update {
    my $v1_card = shift // $_;
    my $v2_card = {
        spec => 'chara_card_v2',
        spec_version => '2.0',
        data => {
            name                         => $v1_card->{name},
            description                  => $v1_card->{description},
            personality                  => $v1_card->{personality},
            scenario                     => $v1_card->{scenario},
            first_mes                    => $v1_card->{first_mes},
            mes_example                  => $v1_card->{mes_example},
            creator_notes                => "",
            system_prompt                => "",
            post_history_instructions    => "",
            alternate_greetings          => [],
            tags                         => [],
            creator                      => "",
            character_version            => "",
            extensions                   => {}
        }
    };

    $v2_card;
}

sub write_card {
    my ($src, $defs, $dest) = @_;
    my $card = read_png_file($src)->copy_png() or die $!;
    $defs = encode_base64 encode_json($defs);
    $card->set_text([{
        key => 'chara',
        text => $defs
    }]);

    $card -> write_png_file($dest) or die "Failed to write to destination: $!";
    $count++;
}

sub is_v2 { exists $_[0]->{spec} }

my ($src, $dest) = @ARGV;
$src = '.' unless $src;

my @files = glob "$src/*.png";
my %cards = map { 
    my $defs = read_def_from_png;
    $defs ? ($_ => $defs) : ();
    } @files;

my %v1_cards = map { $_ => $cards{$_} } grep { !is_v2($cards{$_}) } keys %cards;

for (keys %v1_cards) {
    my $srcfile = $_;
    my $defs = update $v1_cards{$_};
    my $destfile;
    if ($dest) { $destfile = File::Spec->catfile($dest, (File::Spec->splitdir($_))[-1]); }
    else { $destfile = $srcfile; }
    write_card($srcfile, $defs, $destfile);
}

print "$count card(s) updated\n"