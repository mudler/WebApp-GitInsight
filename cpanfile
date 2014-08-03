requires 'Encode';
requires 'GitInsight';
requires 'IO::Compress::Gzip';
requires 'JSON';
requires 'List::Util';
requires 'Mojo::Base';
requires 'Mojo::Loader';
requires 'Mojo::Util';
requires 'Mojolicious::Plugin::BootstrapAlerts';
requires 'Scalar::Util';
requires 'perl', '5.008_005';

on test => sub {
    requires 'Test::More';
};
