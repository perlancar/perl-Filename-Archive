#!perl

use 5.010;
use strict;
use warnings;

use Filename::Archive qw(check_archive_filename);
use Test::More 0.98;

is_deeply(check_archive_filename(filename=>"foo.txt"), 0);
is_deeply(check_archive_filename(filename=>"foo.rar"),
          {
              archive_name=>'RAR',
              archive_suffix=>'.rar',
          });
is_deeply(check_archive_filename(filename=>"foo.tar.gz"),
          {
              archive_name=>'tar',
              archive_suffix=>'.tar',
              compressor_info=>[
                  {
                      compressor_name => 'Gzip',
                      compressor_suffix => '.gz',
                      uncompressed_filename => 'foo.tar',
                  },
              ],
          });
# double-compressed, ci=1
is_deeply(check_archive_filename(filename=>"foo.ZIP.gz.XZ"),
          {
              archive_name=>'Zip',
              archive_suffix=>'.ZIP',
              compressor_info=>[
                  {
                      compressor_name => 'XZ',
                      compressor_suffix => '.XZ',
                      uncompressed_filename => 'foo.ZIP.gz',
                  },
                  {
                      compressor_name => 'Gzip',
                      compressor_suffix => '.gz',
                      uncompressed_filename => 'foo.ZIP',
                  },
              ],
          });

# XXX test double-archive?

DONE_TESTING:
done_testing;
