#!perl

use strict;
use warnings;

use Test::More;
use Path::Class;
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

{

  my $author = 'joseph';
  my $expect = dir( qw(J JO JOSEPH) );

  is(Pinto::Util::author_dir($author), $expect, 'Author dir path for joseph');

}

#-----------------------------------------------------------------------------

{

  my $author = 'JO';
  my $expect = dir( qw(J JO JO) );

  is(Pinto::Util::author_dir($author), $expect, 'Author dir path for JO');

}

#-----------------------------------------------------------------------------

{

  my $author = 'Mike';
  my @base = qw(a b);
  my $expect = dir( qw(a b M MI MIKE) );


  is(Pinto::Util::author_dir(@base, $author), $expect, 'Author dir with base');

}

#-----------------------------------------------------------------------------

done_testing;

