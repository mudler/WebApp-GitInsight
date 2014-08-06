package WebApp;

use strict;
use 5.008_005;
our $VERSION = '0.01';
use Mojo::Base 'Mojolicious';
use Mojo::Loader;
use IO::Compress::Gzip 'gzip';
use Mojolicious::Plugin::BootstrapAlerts;
use Mojolicious::Plugin::StaticCompressor;
use Mojolicious::Plugin::Bootstrap3;
use Mojolicious::Plugin::AssetPack;

sub startup {
    my $app = shift;

    ################# Basic plugin loading
    $app->plugin('config');
    $app->plugin('StaticCompressor');
    $app->plugin('AssetPack');
    $app->plugin("BootstrapAlerts");
    $app->plugin("bootstrap3");

    my $insight_dir
        = $app->config('insight_dir')
        || $ENV{INSIGHT_DIR}
        || '/tmp/gitinsight';
    -d $insight_dir
        or File::Path::mkpath($insight_dir)
        or die "mkpath $insight_dir: $!";

    ################# Assets definitions
    # script.js and extern.js are bundled in the app.js asset
    $app->asset(
        'app.js' => 'http://d3js.org/d3.v3.min.js',
        'https://raw.githubusercontent.com/pguso/jquery-plugin-circliful/master/js/jquery.circliful.min.js',
        '/js/script.js'
    );
    $app->asset(
        'style.css' => '/css/style.css',
        'http://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css',
        'https://raw.githubusercontent.com/pguso/jquery-plugin-circliful/master/css/jquery.circliful.css'

    );

    ################# Load plugin namespace
    push @{ $app->plugins->namespaces }, 'WebApp::GitInsight::Plugin';
    $app->plugin("GitInsight");

    ################# GZip Compression
    $app->hook(
        after_render => sub {
            my ( $c, $output, $format ) = @_;

            # Check if "gzip => 1" has been set in the stash
            return if ( exists $c->stash->{gzip} and $c->stash->{gzip} == 0 );

            # Check if user agent accepts GZip compression
            return
                unless ( $c->req->headers->accept_encoding // '' ) =~ /gzip/i;
            $c->res->headers->append( Vary => 'Accept-Encoding' );

            # Compress content with GZip
            $c->res->headers->content_encoding('gzip');
            gzip $output, \my $compressed;
            $$output = $compressed;
        }
    );

    ################# Routes
    my $r = $app->routes;
    $r->namespaces( ['WebApp::GitInsight::Controller'] );

    # Index
    $r->any('/')->to('index#index');
    $r->any('/index')->to('index#index');
    $r->post('/predict')->to('predict#insight');
    $r->get('/predict/:username')->to('predict#insight');
    $r->get('/predict/img/:username')->to('predict#get');

}

!!42;
1;
__END__

=encoding utf-8

=head1 NAME

MojoMonster - Blah blah blah

=head1 SYNOPSIS

  use MojoMonster;

=head1 DESCRIPTION

MojoMonster is

=head1 AUTHOR

mudler E<lt>mudler@dark-lab.netE<gt>

=head1 COPYRIGHT

Copyright 2014- mudler

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
