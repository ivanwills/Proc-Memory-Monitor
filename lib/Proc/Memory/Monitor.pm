package Proc::Memory::Monitor;

# Created on: 2009-07-16 05:46:13
# Create by:  Ivan Wills
# $Id$
# $Revision$, $HeadURL$, $Date$
# $Revision$, $Source$, $Date$

use Moose;
use warnings;
use version;
use Carp;
use Data::Dumper qw/Dumper/;
use English qw/ -no_match_vars /;
use Proc::ProcessTable;
use Log::Deep;

our $VERSION     = version->new('0.0.1');
our @EXPORT_OK   = qw//;
our %EXPORT_TAGS = ();

has parent => (
	is  => 'rw',
	isa => 'Int',
);
has max => (
	is      => 'rw',
	isa     => 'Num',
	default => 10,
);
has pause => (
	is      => 'rw',
	isa     => 'Int',
	default => 10,
);
has verbose => (
	is  => 'rw',
	isa => 'Bool',
);

sub monitor {
	my ($self, $action) = @_;
	my $count = 0;
	my $zero_mem = 0;
	my $log = Log::Deep->new( -level => 'debug' );

	$self->parent($$);

	# return the parent process
	my $child = fork;
	return $child if $child;

	# start to monitor the parent process
	while (1) {
		my $pid_tree = $self->_pid_tree();

		my $mem_usage = $self->_pid_branch_memory($pid_tree->{$self->parent});
		$log->debug({ parent_pid => $self->parent }, $mem_usage);
		warn "\n\nMemory Usage = $mem_usage\%\n\n\n" if $count++ % 2 == 0;

		if ( $mem_usage > $self->max ) {
			# check if there is a action to be performed or if we should kill the parent
			if ( $action && ref $action eq 'CODE' ) {
				my $ans = $action->($mem_usage, $self);

				# exit monitoring unless asked to keep monitoring.
				last if !$ans;
			}
			else {
				$self->_pid_branch_kill($pid_tree->{$self->parent});
			}
		}
		elsif ( $mem_usage eq 0 ) {
			if ( $zero_mem++ > 10 * 60 / $self->pause ) {
				$self->_pid_branch_kill($pid_tree->{$self->parent});
				return;
			}
		}
		else {
			$zero_mem = 0;
		}

		# check if everything has finished
		if ( $pid_tree->{$self->parent}{children}
			&& @{ $pid_tree->{$self->parent}{children} } == 1
			&& !defined $pid_tree->{$self->parent}{mem}
		) {
			# we appear to have stopped
			warn "No processes appear to be running!\n" if $self->verbose;
			last;
		}

		sleep $self->pause;
	}

	# exit here rather than returning as returning would probably not be what is expected
	exit 0;
}

# builds a tree of processes and their children
sub _pid_tree {
	my $procs = Proc::ProcessTable->new;
	my %tree;

	PROC:
	for my $proc ( @{$procs->table} ) {
		$tree{$proc->pid} ||= { pid => $proc->pid, children => [] };
		$tree{$proc->pid}{mem} = $proc->pctmem;

		# append this process to its parent (if it has one)
		if ( $proc->pid != $proc->pgrp ) {
			$tree{$proc->pgrp} ||= { pid => $proc->pgrp, children => [] };
			push @{ $tree{$proc->pgrp}{children} }, $tree{$proc->pid};
		}
	}

	return \%tree;
}

# kills all child processes of $pid (but not $pid itself)
sub _pid_branch_kill {
	my ($self, $tree) = @_;

	confess Dumper $tree if !ref $tree || !ref $tree->{children};

	for my $child ( @{ $tree->{children} } ) {
		# kill any children
		$self->_pid_branch_kill($child);
	}

	# kill the process (unless it is this process)
	kill $tree->{pid} if $tree->{pid} != $$;

	return;
}

# counts the percentage memory usage of pid and it's children
sub _pid_branch_memory {
	my ($self, $tree) = @_;
	my $total = 0;

	for my $child ( @{ $tree->{children} } ) {
		# Count the childs memory
		$total += $self->_pid_branch_memory($child);
	}

	$total += $tree->{mem} || 0;

	return $total;
}

1;

__END__

=head1 NAME

Proc::Memory::Monitor - Monitors a processes memory usage and tries to kill
it if it starts to use too much memory.

=head1 VERSION

This documentation refers to Proc::Memory::Monitor version 0.1.

=head1 SYNOPSIS

   use Proc::Memory::Monitor;

   my $child = Proc::Memory::Monitor->new()->monitor();

   # do potentially large memory opperations

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 C<monitor ( [$action] )>

Param: C<$action> - code ref - Optional sub to run when the maximum memory is reached

Return: The child pid of the monitor.

Description: This forks the process monitoring code and return the child
pid to parent process. While the child process continues running monitoring
the parent process.

When the $action sub is run it is passed two parameters, the first is the
current memory usage of the process (and it's children) and the second
parameter is a reference to the calling C<Proc::Memory::Monitor> object.
If the return value is false then the memory monitor will stop exit, stopping
further monitoring.

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.

Please report problems to Ivan Wills (ivan.wills@gmail.com).

Patches are welcome.

=head1 AUTHOR

Ivan Wills - (ivan.wills@gmail.com)

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2009 Ivan Wills (14 Mullion Close, Hornsby Heights, NSW Australia 2077).
All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.  This program is
distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

=cut
