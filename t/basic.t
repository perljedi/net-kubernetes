use strict;
use warnings;
use Test::Spec;
use HTTP::Request;
use HTTP::Response;
use Test::Deep;
use Test::Fatal qw(lives_ok dies_ok);
use Net::Kubernetes;
use Test::Mock::Wrapper;
use vars qw($lwpMock $sut);


describe "Net::Kubernetes" => sub {
	before sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		lives_ok {
			$sut = Net::Kubernetes->new;
		}
	};
	spec_helper "resource_lister_examples.pl";
	it "can be instantiated" => sub {
		ok($sut);
		isa_ok($sut, 'Net::Kubernetes');
	};

	it_should_behave_like "Pod Lister";
	it_should_behave_like "Replication Controller Lister";
	it_should_behave_like "Service Lister";
	it_should_behave_like "Secret Lister";

	describe "get_namespace" => sub {
		it "can get a namespace" => sub {
			can_ok($sut, 'get_namespace');
		};
		it "throws an exception if namespace is not passed in" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));
			dies_ok {
				$sut->get_namespace;
			};
		};
		it "throws an exception if the call returns an error" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
			dies_ok {
				$sut->get_namespace('foo');
			};
		};
		it "doesn't throw an exception if the call succeeds" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));
			lives_ok {
				$sut->get_namespace('myNamespace');
			};
		};
		it "returns a new Net::Kubernetes object set to the requested namespace" => sub {
			$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "metadata":{"selfLink":"/path/to/me"}}'));
			my $res = $sut->get_namespace('myNamespace');
			isa_ok($res, 'Net::Kubernetes::Namespace');
			is($res->namespace, 'myNamespace');
		};
	};
};

runtests;
