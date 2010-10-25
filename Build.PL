use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Proc::Memory::Monitor',
	license             => 'perl',
	dist_author         => 'Ivan Wills <ivan.wills@gmail.com>',
	dist_version_from   => 'lib/Proc/Memory/Monitor.pm',
	build_requires => {
		'Test::More' => 0,
	},
	add_to_cleanup     => [ 'Proc-Memory-Monitor-*' ],
	create_makefile_pl => 'traditional',
	create_license     => 1,
	meta_merge         => {
		resources => {
			#repository => 'http://github.com/ivanwills/Proc-Memory-Monitor',
			#bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Proc-Memory-Monitor',
		},
	},
);

$builder->create_build_script();
