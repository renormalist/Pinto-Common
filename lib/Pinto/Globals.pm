# ABSTRACT: Global variables used across the Pinto utilities

package Pinto::Globals;

use strict;
use warnings;

#------------------------------------------------------------------------------

# VERSION

#------------------------------------------------------------------------------

## no critic qw(PackageVars);
our $current_time    = undef;
our $current_user    = undef;
our $is_interactive  = undef;

#------------------------------------------------------------------------------
1;

__END__
