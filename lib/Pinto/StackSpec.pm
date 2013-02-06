# ABSTRACT: Specifies a package by name and version

package Pinto::PackageSpec;

use Moose;

use Pinto::Types qw(StackName StackDefault CommitID CommitHead);

use overload ('""' => 'to_string');

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

has name => (
    is       => 'ro',
    isa      => StackName | StackDefault,
    default  => undef,
);


has commit => (
    is      => 'ro',
    isa     => CommitID | CommitHead,
    default => undef,
    coerce  => 1,
);

#------------------------------------------------------------------------------

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;

    my @args = @_;
    if (@args == 1 and not ref $args[0]) {

        my ($name, $commit) =   $args[0] =~ m/@/
                              ? split m{@}x, $_[0], 2
                              : ($args[0], undef);

        @args = (name => $name || undef, commit => $commit || undef);
    }

    return $class->$orig(@args);
};

#------------------------------------------------------------------------------

=method to_string()

Serializes this StackSpec to its string form.  This method is called
whenever the StackSpec is evaluated in string context.

=cut

sub to_string {
    my ($self) = @_;

    my $name   = $self->name   || 'DEFAULT';
    my $commit = $self->commit || 'HEAD';

    return sprintf '%s@%s', $name, $commit;
}

#------------------------------------------------------------------------------

__PACKAGE__->meta->make_immutable;

#------------------------------------------------------------------------------
1;

__END__

