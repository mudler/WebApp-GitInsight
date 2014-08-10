package WebApp::GitInsight::Controller::Predict;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw/ encode decode spurt slurp /;
use JSON;

sub insight {
    my $self     = shift;
    my $username = $self->param("username");
    my ($left_cutoff,$right_cutoff) =split(/,/,$self->param("cutoff")|| "0,0");
    $right_cutoff=$right_cutoff-$left_cutoff;
    my $wd       = 0;
    $wd = 1 if $self->param("no_weekdays");
    my $Insight = $self->app->insight(
        $username, $wd,
        $left_cutoff,
        $right_cutoff
    );

    my $user_data = decode_json $self->ua->get(
        "https://api.github.com/users/" . $username )->res->body;

    $self->stash(
        username         => $username,
        from             => $Insight->start_day,
        to               => $Insight->last_day,
        profile_page     => $user_data->{html_url},
        avatar           => $user_data->{avatar_url},
        stats            => $Insight->{stats},
        labels           => $Insight->{steps},
        predictions => $Insight->{result},
        prediction_start => $Insight->prediction_start_day,
        no_weekdays      => $wd
    );

    $self->render("prediction");
}

sub get {
    my $self     = shift;
    my $username = $self->param("username");
    return $self->render(
        data   => slurp 'public/pred/' . $username . ".png",
        format => 'png'
    ) if ( -e 'public/pred/' . $username . ".png" );
    $self->render_not_found and return;
}

1;
