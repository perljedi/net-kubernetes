package Doppler::Storage::Interface::REST::Test;
use strict;
use warnings;
use Test::Spec;
use Data::Dumper;
use HTTP::Request;
use HTTP::Response;
use JSON;
use Test::Fatal qw(lives_ok dies_ok);
use Net::Kubernetes;
use Test::Mock::Wrapper;

describe "Net::Kubernetes" => sub {
	my $lwpMock;
	before sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
	};
	it "can be instantiated" => sub {
		new_ok( 'Net::Kubernetes' )
	};
	describe "list_pods" => sub {
		my $kube;
		before sub {
			$kube = Net::Kubernetes->new;
		};
		it "can get a list of pods" => sub {
			can_ok($kube, 'list_pods');
		};
		it "throws an exception if the call returns an error" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
			dies_ok {
				$kube->list_pods;
			};
		};
		it "doesn't throw an exception if the call suceedes" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			lives_ok {
				$kube->list_pods;
			};
		};
	};
};

runtests;
