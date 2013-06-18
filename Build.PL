use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Proc::Memory::Monitor',
    license             => 'perl',
    dist_author         => 'Ivan Wills <ivan.wills@gmail.com>',
    dist_version_from   => 'lib/Proc/Memory/Monitor.pm',
    requires          => {
        'perl'               => '5.006',
        'List::Util'         => 0,
        'Log::Deep'          => 0,
        'Moose'              => 0,
        'Proc::ProcessTable' => 0,
        'Scalar::Util'       => 0,
        'version'            => 0,
    },
    configure_requires => {
        'Module::Build' => 0.38,
    },
    build_requires => {
        'Test::More'         => 0,
        'Test::NoWarnings'   => 0,
    },
    add_to_cleanup     => [ 'Proc-Memory-Monitor-*' ],
    create_makefile_pl => 'traditional',
    create_license     => 1,
    meta_merge         => {
        resources => {
            repository => 'http://github.com/ivanwills/Proc-Memory-Monitor',
            bugtracker => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Proc-Memory-Monitor',
        },
    },
);

$builder->create_build_script();
