package WebApp::GitInsight::Plugin::GitInsight;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw/ encode decode spurt slurp /;
use Scalar::Util qw(looks_like_number);
use GitInsight;
use JSON;

sub register {
    my ( $self, $app, $conf ) = @_;
    $app->helper(
        insight => sub {
            shift;
            $_[0] ||= "mudler";
            my $Insight = GitInsight->new(
                verbose      => 0,
                accuracy     => 1,
                file_output  => 'public/pred/' . $_[0],
                no_day_stats => $_[1] |=
                    0,
                left_cutoff => !looks_like_number( $_[2] ) ? 0
                : $_[2] >= 0 ? $_[2]
                : 0,
                cutoff_offset => !looks_like_number( $_[3] ) ? 0
                : $_[3] >= 0 ? $_[3]
                : 0,
                statistics => 1
            );
            $Insight->contrib_calendar( $_[0] );
            $Insight->process;
            spurt(
                encode_json $Insight->{treemap},
                'public/json/' . $_[0] . ".json"
            );
            return $Insight;
        }
    );
}

1;

