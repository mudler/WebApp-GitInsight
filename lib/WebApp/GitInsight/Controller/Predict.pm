package WebApp::GitInsight::Controller::Predict;

use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw/ encode decode spurt slurp /;

sub insight {
    my $self     = shift;
    my $username = $self->param("username");
    my $wd       = 0;
    $wd = 1 if $self->param("no_weekdays");
    my $Insight = $self->app->insight(
        $username, $wd,
        $self->param("left_cutoff"),
        $self->param("cutoff_offset")
    );
    $self->stash(
        username         => $username,
        from             => $Insight->start_day,
        to               => $Insight->last_day,
        stats            => $Insight->{stats},
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
