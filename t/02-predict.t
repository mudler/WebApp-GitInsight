use Test::More;
use Test::Mojo;
my $t = Test::Mojo->new('WebApp::GitInsight');
# HTML/XML
$t->get_ok('/')->status_is(200);
$t->get_ok('/index')->status_is(200);
$t->post_ok('/predict')->status_is(200);
$t->get_ok('/predict/mudler')->status_is(200);
$t->get_ok('/predict/img/mudler')->status_is(200);
done_testing();