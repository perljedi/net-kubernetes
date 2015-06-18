#!/usr/local/bin/perl
use strict;
use lib qw(./lib);
use Net::Kubernetes;
use Data::Dumper;

my $kube = Net::Kubernetes->new(url=>'https://10.245.1.2', username=>'vagrant', password=>'vagrant');

my $ns = $kube->get_namespace('default');

print "Namespace $ns\n";

my $pod = $ns->get_pod('bootstrap-cass-cql');

#$pod->spec->{containers}[0]{image} = 'liquidweb/base-perl:latest';
$pod->metadata->{labels}{snarf} = 'blat';

print Dumper($pod)."\n";

if($pod->update){
    print "Updated, yay\n";
}else{
    print "Doh!\n";
}

#my $rc = $ns->get_rc('doppler-storage-pod-v1');
#
#$rc->spec->{replicas} = 1;
#
#print Dumper($rc)."\n";
#
#if($rc->update){
#    print "Updated, yay\n";
#}else{
#    print "Doh!\n";
#}

#my($junk) = grep({$_->{metadata}{name} eq 'junk'} $ns->list_secrets);
#
#$junk->delete;

#print $ns->create_from_file('/data/net-kubernetes/futz_with_me.yaml')."\n";
