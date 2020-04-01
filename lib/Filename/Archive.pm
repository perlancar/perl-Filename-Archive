package Filename::Archive;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(check_archive_filename);
#list_archive_suffixes

# XXX multi-part archive?

our %SUFFIXES = (
    '.7z'  => {name=>'7-zip'},
    '.zip' => {name=>'Zip'},
    '.rar' => {name=>'RAR'},
    '.tar' => {name=>'tar'},
    '.tgz' => {name=>'tar+gzip'},
    '.tbz' => {name=>'tar+bzip2'},
    '.arj' => {name=>'arj'},
    # XXX other older/less popular: lha, zoo
    # XXX windows: cab
    # XXX zip-based archives: war, etc
    # XXX tar-based archives: linux packages
);

our %ARCHIVES = (
    'arj' => {
    },
    '7-zip' => {
    },
    Zip => {
        # all programs mentioned here must accept filename(s) as arguments.
        # preferably CLI. XXX specify capabilities (password-protection, unix
        # permission, etc). XXX specify how to create (with password, etc). XXX
        # specify how to extract.
        archiver_programs => [
            {name => 'zip', opts => ''},
        ],
        extractor_programs => [
            {name => 'zip', opts => ''},
            {name => 'unzip', opts => ''},
        ],
    },
    RAR => {
    },
    tar => {
    },
    'tar+gzip' => {
    },
    'tar+bzip2' => {
    },
);

our %SPEC;

$SPEC{check_archive_filename} = {
    v => 1.1,
    summary => 'Check whether filename indicates being an archive file',
    description => <<'_',


_
    args => {
        filename => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        # XXX recurse?
        ci => {
            summary => 'Whether to match case-insensitively',
            schema  => 'bool',
            default => 1,
        },
    },
    result_naked => 1,
    result => {
        schema => ['any*', of=>['bool*', 'hash*']],
        description => <<'_',

Return false if no archive suffixes detected. Otherwise return a hash of
information, which contains these keys: `archive_name`, `archive_suffix`,
`compressor_info`.

_
    },
};
sub check_archive_filename {
    require Filename::Compressed;

    my %args = @_;

    my $filename = $args{filename};
    my $ci = $args{ci} // 1;

    my @compressor_info;
    while (1) {
        my $res = Filename::Compressed::check_compressed_filename(
            filename => $filename, ci => $ci);
        if ($res) {
            push @compressor_info, $res;
            $filename = $res->{uncompressed_filename};
            next;
        } else {
            last;
        }
    }

    $filename =~ /(\.\w+)\z/ or return 0;
    my $suffix = $1;

    my $spec;
    if ($ci) {
        my $suffix_lc = lc($suffix);
        for (keys %SUFFIXES) {
            if (lc($_) eq $suffix_lc) {
                $spec = $SUFFIXES{$_};
                last;
            }
        }
    } else {
        $spec = $SUFFIXES{$suffix};
    }
    return 0 unless $spec;

    return {
        archive_name       => $spec->{name},
        archive_suffix     => $suffix,
        (compressor_info    => \@compressor_info) x !!@compressor_info,
    };
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Filename::Archive qw(check_archive_filename);
 my $res = check_archive_filename(filename => "foo.tar.gz");
 if ($res) {
     printf "File is an archive (type: %s, compressed: %s)\n",
         $res->{archive_name},
         $res->{compressor_info} ? "yes":"no";
 } else {
     print "File is not an archive\n";
 }

=head1 DESCRIPTION


=head1 SEE ALSO

L<Filename::Compressed>

=cut
