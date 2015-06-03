package Doppler::Storage::Interface::REST::Test;
use strict;
use warnings;
use Test::Spec;
use Data::Dumper;
use HTTP::Request;
use HTTP::Response;
use JSON;
use Test::Deep;
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
		it "doesn't throw an exception if the call succeeds" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			lives_ok {
				$kube->list_pods;
			};
		};
		it "returns an array of pods" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "items":[{"spec":{}, "metadata":{}, "status":{}}]}'));
			my $res = $kube->list_pods;
			isa_ok($res, 'ARRAY');
		};
		it "includes label selector in query if labels are passed in" => sub{
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "items":[{"spec":{}, "metadata":{}, "status":{}}]}'));
			$kube->list_pods(labels=>{name=>'my-pod'});
			$lwpMock->verify('request')->once;
			my $req = $lwpMock->getCallsTo('request')->[0][1];
			cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
		};
		it "includes field selector in query if fields are passed in" => sub{
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "items":[{"spec":{}, "metadata":{}, "status":{}}]}'));
			$kube->list_pods(fields=>{'status.phase'=>'Running'});
			$lwpMock->verify('request')->once;
			my $req = $lwpMock->getCallsTo('request')->[0][1];
			cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
		};
	};
	describe "get_namespace" => sub {
		my $kube;
		before sub {
			$kube = Net::Kubernetes->new;
		};
		it "can get a namespace" => sub {
			can_ok($kube, 'get_namespace');
		};
		it "throws an exception if namespace is not passed in" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			dies_ok {
				$kube->get_namespace;
			};
		};
		it "throws an exception if the call returns an error" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
			dies_ok {
				$kube->get_namespace('foo');
			};
		};
		xit "doesn't throw an exception if the call succeeds" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			lives_ok {
				$kube->list_pods;
			};
		};
		xit "returns decoded hash from the json response body on success" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			my $res = $kube->list_pods;
			cmp_deeply($res, {status=>"ok"});
		};
		xit "includes label selector in query if labels are passed in" => sub{
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			$kube->list_pods(labels=>{name=>'my-pod'});
			$lwpMock->verify('request')->once;
			my $req = $lwpMock->getCallsTo('request')->[0][1];
			cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
		};
		xit "includes field selector in query if fields are passed in" => sub{
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok"}'));
			$kube->list_pods(fields=>{'status.phase'=>'Running'});
			$lwpMock->verify('request')->once;
			my $req = $lwpMock->getCallsTo('request')->[0][1];
			cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
		};
	};
};

runtests;
