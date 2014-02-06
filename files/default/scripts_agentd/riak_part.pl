#!/usr/bin/perl

$first = 1;

print "{\n";
print "\t\"data\":[\n\n";

for (`ls /srv/sa_riak/shared/data/merge_index`)
{
    ($dirname) = m/(\S+)/;

    print "\t,\n" if not $first;
    $first = 0;

    print "\t{\n";
    print "\t\t\"{#RIAKPART}\":\"$dirname\",\n";
    print "\t}\n";
}

print "\n\t]\n";
print "}\n";
