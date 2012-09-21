#!perl
# The JSX compiler must not crash with any options!
use strict;
use warnings;

use IPC::Open3 qw(open3);
use Symbol qw(gensym);
use Data::Dumper ();
use Test::More;

sub dumper {
    local $Data::Dumper::Terse  = 1;
    local $Data::Dumper::Indent = 0;

    return Data::Dumper->new([\@_], ['*argv'])->Dump();
}

sub jsx {
    my @cmd = ("bin/jsx", @_);

    my($wtr, $rdr) = (gensym(), gensym());
    my $pid = open3($wtr, $rdr, undef, @cmd);
    close $wtr;
    my $out = do {
        local $/;
        <$rdr>;
    };
    waitpid($pid, 0);

    return $out;
}

sub not_crash {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    unlike(jsx(@_), qr/^\s+ \b at \b \s+ \b Module \b/xms, dumper("jsx", @_));
}

not_crash "no such file";
{
    local $TODO = "todo";
    not_crash "--complete", "1:1", "no such file";
}
done_testing;
