#!perl

use strict;
use warnings;

use Test::More;
use Pinto::Util qw(:all);

#-----------------------------------------------------------------------------

{

  isnt(current_username, '__ME__', 'Actual user');
  local $Pinto::Globals::current_username = '__ME__';
  is(current_username, '__ME__', 'Override user');

  isnt(current_time, -9, 'Actual time');
  local $Pinto::Globals::current_time = -9;
  is(current_time, -9, 'Override time');

  isnt(is_interactive, -9, 'Actual interactive state');
  local $Pinto::Globals::is_interactive = -9;
  is(is_interactive, -9, 'Override interactive state');

}

#-----------------------------------------------------------------------------

done_testing;
