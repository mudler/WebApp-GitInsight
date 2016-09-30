package WebApp::GitInsight;
use strict;
use 5.008_005;
our $VERSION = '0.01';
use Mojo::Base 'Mojolicious';
use Mojo::Loader;
use IO::Compress::Gzip 'gzip';
use Mojolicious::Plugin::BootstrapAlerts;
use Mojolicious::Plugin::StaticCompressor;
use Mojolicious::Plugin::AssetPack;

sub startup {
    my $app = shift;

    ################# Basic plugin loading
    $app->plugin('config');
    $app->plugin('StaticCompressor');
    $app->plugin('AssetPack');
    $app->plugin("BootstrapAlerts");

    my $insight_dir
        = $app->config('insight_dir')
        || $ENV{INSIGHT_DIR}
        || '/tmp/gitinsight';
    -d $insight_dir
        or File::Path::mkpath($insight_dir)
        or die "mkpath $insight_dir: $!";

    ################# Assets definitions
    # script.js and extern.js are bundled in the app.js asset
    
 
  $app->asset->process(
    "bootstrap.css" => "http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
  );
  $app->asset->process(
    "bootstrap.js" => "http://maxcdn.bootstrapcdn.com/bootstrap/3.3.4/js/bootstrap.min.js");
  );
  
    $app->asset(
        'libs.js' => 'http://d3js.org/d3.v3.min.js',
        'http://code.jquery.com/jquery-2.1.1.min.js',
        '/js/slider.js',
        '/js/progressbar.js'
    );
    $app->asset( 'scripts.js' => '/js/script.js' );
    $app->asset(
        'style.css' => '/css/style.css',
        'http://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css',
        '/css/slider.css',
        '/css/progressbar.css'
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

1;
__END__

=encoding utf-8

=head1 NAME

WebApp::GitInsight - GitInsight web application

=head1 SYNOPSIS

  hypnotoad script/gitinsight
  morbo script/gitinsight #for debugging

=head1 DESCRIPTION

GitInsight is the website powering L<http://gitinsight.mudler.pm>, uses L<GitInsight> as engine for the prediction computations

=head1 INSTALLATION

    cpanm --installdeps .

you will also need: ruby-sass ruby-compass (those are the debian packages)

=head1 AUTHOR

mudler E<lt>mudler@dark-lab.netE<gt>

=head1 COPYRIGHT

Copyright 2014- mudler

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://gitinsight.mudler.pm>, L<GitInsight>

=cut
