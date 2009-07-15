#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Proc::Memory::Monitor' );
}

diag( "Testing Proc::Memory::Monitor $Proc::Memory::Monitor::VERSION, Perl $], $^X" );
