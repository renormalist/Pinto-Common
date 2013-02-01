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

{

  my @cases = qw( A/AU/AUTHOR/Dist-1.0.tar.gz
                  A/AU/AUTHOR/subdir/Dist-1.0.tar.gz
                  whatever/authors/id/A/AU/AUTHOR/subdir/Dist-1.0.tar.gz
                  http://foo.com/whatever/authors/id/A/AU/AUTHOR/subdir/Dist-1.0.tar.gz );

  my $expect_auth    = 'AUTHOR';
  my $expect_archive = 'Dist-1.0.tar.gz';

  for my $case (@cases) {
    my ($got_auth, $got_archive) = Pinto::Util::parse_dist_path($case);
    is($got_auth, $expect_auth, "Parsed author from $case");
    is($got_archive, $expect_archive, "Parsed archive from $case");
  }

}

#-----------------------------------------------------------------------------

done_testing;

