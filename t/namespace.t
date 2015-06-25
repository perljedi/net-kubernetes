use strict;
use warnings;
use Test::Spec;
use HTTP::Request;
use HTTP::Response;
use Test::Deep;
use Test::Fatal qw(lives_ok dies_ok);
use Net::Kubernetes;
use Net::Kubernetes::Namespace;
use MIME::Base64;
use Test::Mock::Wrapper;
use vars qw($lwpMock $sut);


describe "Net::Kubernetes - Namespace" => sub {
	before sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		lives_ok {
			$sut = Net::Kubernetes::Namespace->new(base_path=>'/api/v1beta3/namespaces/default');
		};
	};
	it "can be instantiated" => sub {
		ok($sut);
		isa_ok($sut, 'Net::Kubernetes::Namespace');
	};
	spec_helper "resource_lister_examples.pl";
	it_should_behave_like "Pod Lister";
	it_should_behave_like "Replication Controller Lister";
	it_should_behave_like "Service Lister";
	it_should_behave_like "Secret Lister";
	
	#describe "username and password" => sub {
	#	my $kube;
	#	before sub {
	#		$kube = Net::Kubernetes->new(username=>'Marti', password=>'McFly');
	#	};
	#	it "includes header Authorization: Basic with created requests" => sub {
	#		my $req = $kube->create_request(GET => '/pods');
	#		ok(defined $req->header('Authorization'));
	#		is($req->header('Authorization'), "Basic ".encode_base64('Marti:McFly'));
	#	};
	#};
};

runtests;
