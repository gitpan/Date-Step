# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Date-Step.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 4;
BEGIN { use_ok('Date::Step') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $step = Date::Step->new();
isa_ok($step,'Date::Step');

$step->set_start(2000022818);  # start date
$step->set_end('6h');          # end date
$step->set_increment('3h');    # date increment length
$step->set_format('%Y %m %d'); # format of returned date string

my $date;
do {
  $date = $step->get_current();
} while ($step->next());

ok($date eq '2000 02 29','leap year');

$step->set_start(2001022818);  # start date
$step->set_end('6h');          # end date
$step->set_increment('3h');    # date increment length
$step->set_format('%Y %m %d'); # format of returned date string

do {
  $date = $step->get_current();
} while ($step->next());

ok($date eq '2001 03 01','non-leap year');
