use strict;
use warnings;

use Device::BusPirate;
use Time::HiRes qw( sleep time );
use POSIX qw( strftime );

my $pirate = Device::BusPirate->new;
my $max = $pirate->mount_chip( "MAX7219" )->get;

$max->mode->configure( open_drain => 0 )->get;
$max->power(1)->get;
END {
   $max and $max->power(0)->get;
   $pirate and $pirate->stop
}

$SIG{TERM} = $SIG{INT} = sub { exit };

$max->intensity( 2 )->get;
$max->limit( 8 )->get;
$max->set_decode( 0xff )->get;
$max->write_bcd( $_, " " )->get for 0 .. 7;

$max->shutdown( 0 )->get;

while(1) {
   my $now = time;
   my $str = strftime "%H %M %S", localtime int $now;

   foreach my $d ( 0 .. 7 ) {
      my $val = substr $str, 7 - $d, 1;
      $max->write_bcd( $d, $val )->get;
   }

   sleep( int( $now + 1 ) - $now );
}
