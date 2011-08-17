package Pinto::Logger;

# ABSTRACT: A simple logger

use Moose;
use MooseX::Types::Moose qw(Int);

use Readonly;

use namespace::autoclean;

#-----------------------------------------------------------------------------

# VERSION

#-----------------------------------------------------------------------------
# Moose attributes

has log_level => (
    is         => 'ro',
    isa        => Int,
    lazy_build => 1,
);


#-----------------------------------------------------------------------------
# Moose roles

with qw(Pinto::Role::Configurable);

#-----------------------------------------------------------------------------

Readonly my $LOG_LEVEL_QUIET => -2;
Readonly my $LOG_LEVEL_WARN  => -1;
Readonly my $LOG_LEVEL_INFO  =>  0;
Readonly my $LOG_LEVEL_DEBUG =>  1;

#-----------------------------------------------------------------------------
# Builders

sub _build_log_level {
    my ($self) = @_;

    return $LOG_LEVEL_QUIET if $self->config->quiet();
    return $self->config->verbose();
}

#-----------------------------------------------------------------------------
# Private functions

sub _logit {
    my ($message) = @_;

    return print "$message\n";
}

#-----------------------------------------------------------------------------
# Public methods

=method debug( $message )

Logs a message to C<STDOUT> if the C<log_level> is 1 or higher.

=cut

sub debug {
    my ($self, $message) = @_;

    _logit($message) if $self->log_level() >= $LOG_LEVEL_DEBUG;

    return 1;
}

#-----------------------------------------------------------------------------

=method info( $message )

Logs a message to C<STDOUT> if the C<log_level> is 0 or higher.

=cut

sub info {
    my ($self, $message) = @_;

    _logit($message) if $self->log_level() >= $LOG_LEVEL_INFO;

    return 1;
}

#-----------------------------------------------------------------------------

=method whine( $message )

Logs a message to C<STDERR> if the C<log_level> is -1 or higher.

=cut

sub whine {
    my ($self, $message) = @_;

    warn "$message\n" if $self->log_level() >= $LOG_LEVEL_WARN;

    return 1;
}

#-----------------------------------------------------------------------------

=method fatal( $message )

Dies with the given message.

=cut

sub fatal {
    my ($self, $message) = @_;

    die "$message\n";  ## no critic (RequireCarping)
}

#-----------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable();

#-----------------------------------------------------------------------------

1;

__END__
