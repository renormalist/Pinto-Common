# ABSTRACT: Static utility functions for Pinto

package Pinto::Util;

use strict;
use warnings;
use version;

use Carp;
use Try::Tiny;
use Path::Class;
use Digest::MD5;
use Digest::SHA;
use Scalar::Util;
use IO::Interactive;
use Readonly;

use Pinto::Globals;
use Pinto::Constants qw(:all);
use Pinto::Exception qw(throw);

use namespace::autoclean;

use base qw(Exporter);

#-------------------------------------------------------------------------------

# VERSION

#-------------------------------------------------------------------------------

Readonly our @EXPORT_OK => qw(
    author_dir
    current_time
    current_username
    decamelize
    interpolate
    is_interactive
    is_stack_all
    is_vcs_file
    isa_perl
    itis
    md5
    mksymlink
    mtime
    parse_dist_path
    sha256
    trim
);

Readonly our %EXPORT_TAGS => ( all => \@EXPORT_OK );

#-------------------------------------------------------------------------------

=func author_dir( @base, $author )

Given the name of an C<$author>, returns the directory where the
distributions for that author belong (as a L<Path::Class::Dir>).  The
optional C<@base> can be a series of L<Path::Class:Dir> or path parts
(as strings).  If C<@base> is given, it will be prepended to the
directory that is returned.

=cut

sub author_dir {                                  ## no critic (ArgUnpacking)
    my $author = uc pop;
    my @base =  @_;

    return dir(@base, substr($author, 0, 1), substr($author, 0, 2), $author);
}

#-------------------------------------------------------------------------------

=func itis( $var, $class )

Asserts whether var is a blessed reference and is an instance of the
C<$class>.

=cut

sub itis {
    my ($var, $class) = @_;

    return ref $var && Scalar::Util::blessed($var) && $var->isa($class);
}

#-------------------------------------------------------------------------------

=func parse_dist_path( $path )

Parses a path like the ones you would see in a full URL to a
distribution in a CPAN repository, or the URL fragment you would see
in a CPAN index.  Returns the author and file name of the
distribution.  Subdirectoires between the author name and the file
name are discarded.

=cut

sub parse_dist_path {
    my ($path) = @_;

    # eg: /yadda/authors/id/A/AU/AUTHOR/subdir1/subdir2/Foo-1.0.tar.gz
    # or: A/AU/AUTHOR/subdir/Foo-1.0.tar.gz

    if ( $path =~ s{^ (?:.*/authors/id/)? (.*) $}{$1}mx ) {

        # $path = 'A/AU/AUTHOR/subdir/Foo-1.0.tar.gz'
        my @path_parts = split m{ / }mx, $path;
        my $author  = $path_parts[2];  # AUTHOR
        my $archive = $path_parts[-1]; # Foo-1.0.tar.gz
        return ($author, $archive);
    }

    confess "Unable to parse path: $path";
}

#-------------------------------------------------------------------------------

=func isa_perl( $path_or_url )

Return true if C<$path_or_url> appears to point to a release of perl
itself.  This is based on some file naming patterns that I've seen in
the wild.  It may not be completely accurate.

=cut

sub isa_perl {
    my ($path_or_url) = @_;

    return $path_or_url =~ m{ / perl-[\d.]+ \.tar \.(?: gz|bz2 ) $ }mx;
}

#-------------------------------------------------------------------------------

=func is_vcs_file( $path );

Returns true if C<$path> appears to point to a file that is an
internal part of a VCS system.

=cut

Readonly my %VCS_FILES => (map {$_ => 1} qw(.svn .git .gitignore CVS));

sub is_vcs_file {
    my ($file) = @_;

    $file = file($file) unless eval { $file->isa('Path::Class::File') };

    return exists $VCS_FILES{ $file->basename() };
}

#-------------------------------------------------------------------------------

=func mtime( $file )

Returns the last modification time (in epoch seconds) for the C<file>.
The argument is required and the file must exist or an exception will
be thrown.

=cut

sub mtime {
    my ($file) = @_;

    confess 'Must supply a file' if not $file;
    confess "$file does not exist" if not -e $file;

    return (stat $file)[9];
}

#-------------------------------------------------------------------------------

=func md5( $file )

Returns the C<MD-5> digest (as a hex string) for the C<$file>.  The
argument is required and the file must exist on an exception will be
thrown.

=cut

sub md5 {
    my ($file) = @_;

    confess 'Must supply a file' if not $file;
    confess "$file does not exist" if not -e $file;

    my $fh = $file->openr();
    my $md5 = Digest::MD5->new->addfile($fh)->hexdigest();

    return $md5;
}

#-------------------------------------------------------------------------------

=func sha256( $file )

Returns the C<SHA-256> digest (as a hex string) for the C<$file>.  The
argument is required and the file must exist on an exception will be
thrown.

=cut

sub sha256 {
    my ($file) = @_;

    confess 'Must supply a file' if not $file;
    confess "$file does not exist" if not -e $file;

    my $fh = $file->openr();
    my $sha256 = Digest::SHA->new(256)->addfile($fh)->hexdigest();

    return $sha256;
}

#-------------------------------------------------------------------------------

=func validate_property_name( $prop_name )

Throws an exception if the property name is invalid.  Currently,
property names must be alphanumeric plus any underscores or hyphens.

=cut

sub validate_property_name {
    my ($prop_name) = @_;

    throw "Invalid property name $prop_name" if $prop_name !~ $PINTO_PROPERTY_NAME_REGEX;

    return $prop_name;
}

#-------------------------------------------------------------------------------

=func validate_stack_name( $stack_name )

Throws an exception if the stack name is invalid.  Currently, stack
names must be alphanumeric plus underscores or hyphens.

=cut

sub validate_stack_name {
    my ($stack_name) = @_;

    throw "Invalid stack name $stack_name" if $stack_name !~ $PINTO_STACK_NAME_REGEX;

    return $stack_name;
}

#-------------------------------------------------------------------------------

=func current_time()

Returns the current time (in epoch seconds) unless the current time has been
overridden by C<$Pinto::Globals::current_time>.

=cut

sub current_time {

    ## no critic qw(PackageVars)
    return $Pinto::Globals::current_time
      if defined $Pinto::Globals::current_time;

    return time;
}

#-------------------------------------------------------------------------------

=func current_username()

Returns the id of the current user unless it has been overridden by
C<$Pinto::Globals::current_username>.

=cut

sub current_username {

    ## no critic qw(PackageVars)
    return $Pinto::Globals::current_username
      if defined $Pinto::Globals::current_username;

    my $username =  $ENV{PINTO_USERNAME} || $ENV{USER} || $ENV{LOGIN} || $ENV{USERNAME} || $ENV{LOGNAME};

    die "Unable to determine your username.  Set PINTO_USERNAME." if not $username;

    return $username
}

#-------------------------------------------------------------------------------

=func is_interactive()

Returns true if the process is connected to an interactive terminal
(i.e.  a keyboard & screen) unless it has been overridden by
C<$Pinto::Globals::is_interactive>.

=cut

sub is_interactive {

    ## no critic qw(PackageVars)
    return $Pinto::Globals::is_interactive
      if defined $Pinto::Globals::is_interactive;

    return IO::Interactive::is_interactive;
}

#-------------------------------------------------------------------------------

=func interpolate($string)

Performs interpolation on a literal string.  The string should not
include anything that looks like a variable.  Only metacharacters
(like \n) will be interpolated correctly.

=cut

sub interpolate {
    my $string = shift;

    return eval qq{"$string"};  ## no critic qw(Eval)
}

#-------------------------------------------------------------------------------

=func trim($string)

Returns the string with all leading and trailing whitespace removed.

=cut

sub trim {
    my $string = shift;

    $string =~ s/^ \s+  //x;
    $string =~ s/  \s+ $//x;

    return $string;
}

#-------------------------------------------------------------------------------

=func decamelize($string)

Returns the string forced to lower case and words separated by underscores.
For example "FooBar" becomes "foo_bar".

=cut

sub decamelize {
    my $string = shift;

    return if not defined $string;

    $string =~ s/([a-z])([A-Z])/$1_$2/g;

    return lc $string;
}


#-------------------------------------------------------------------------------

=func mksymlink($from => $to)

Creates a symlink between the two files.  No checks are performed to see
if either path is valid or already exists.  Throws an exception if the
operation fails or is not supported.

=cut

sub mksymlink {
    my ($from, $to) = @_;

    # TODO: Try to add Win32 support here, somehow.
    symlink $to, $from or die "symlink to $to from $from failed: $!";

    return 1;
}

#-------------------------------------------------------------------------------

=func is_stack_all($stack_name)

Returns true if the given C<$stack_name> matches the name of the magical
C<STACK_ALL> which represents all stacks.

=cut

sub is_stack_all {
    my $stack_name = shift;

    return defined $stack_name && $stack_name eq $PINTO_STACK_NAME_ALL;
}

#-------------------------------------------------------------------------------
1;

__END__


=head1 DESCRIPTION

This is a private module for internal use only.  There is nothing for
you to see here (yet).  All API documentation is purely for my own
reference.

=cut
