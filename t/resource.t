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
use vars qw($lwpMock $sut $ns);

shared_examples_for "All Resources" => sub {
	it "has a 'kind'" => sub {
		ok($sut->kind);
	};
	it "has an 'api_version'" => sub {
		ok($sut->api_version);
	};
	it "has 'metadata'" => sub {
		ok($sut->metadata);
	};
	describe "update" => sub {
		it "makes a PUT request" => sub {
			$sut->update();
			my($call) = $lwpMock->verify('request')->once->getCalls->[0];
			isa_ok($call->[1], 'HTTP::Request');
			is($call->[1]->method, 'PUT');
		};
	};
	describe "delete" => sub {
		it "makes a DELETE request" => sub {
			$sut->delete();
			my($call) = $lwpMock->verify('request')->once->getCalls->[0];
			isa_ok($call->[1], 'HTTP::Request');
			is($call->[1]->method, 'DELETE');
		};
	};
};

shared_examples_for "Stateful Resources" => sub {
	it "has a status" => sub {
		ok($sut->status);
	};
	
	describe "Refresh" => sub {
		it "Can be refreshed" => sub {
			can_ok($sut, 'refresh');
		};
		
		it "makes a GET request to its selfLink" => sub {
			$sut->refresh();
			my($call) = $lwpMock->verify('request')->once->getCalls->[0];
			isa_ok($call->[1], 'HTTP::Request');
			is($call->[1]->method, 'GET');
			ok(index($call->[1]->uri, $sut->metadata->{selfLink}) > 0);
		};
	};
};

describe "Net::Kubernetes - All Resource Objects" => sub {
	before all => sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"spec":{}, "metadata":{"selfLink":"/api/v1beta3/namespaces/default/pods/myPod"}, "status":{}, "kind":"Pod", "apiVersion":"v1beta3"}'));
		$sut = Net::Kubernetes::Resource->new(metadata=>{selfLink=>'/api/v1beta3/namespaces/default/pods/myPod'}, status => {}, kind => "Pod", api_version =>"v1beta3");
	};
	before sub {
		$lwpMock->resetCalls;
	};
	
	it_should_behave_like "All Resources";
};

describe "Net::Kubernetes - Replication Controller Objects " => sub {
	before all => sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		lives_ok {
			$ns = Net::Kubernetes::Namespace->new(base_path=>'/api/v1beta3/namespaces/default');
		};
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"spec":{"selector":{"name":"myReplicates"}}, "metadata":{"selfLink":"/api/v1beta3/namespaces/default/replicationcontrollers/myRc"}, "status":{}, "kind":"ReplicationController", "apiVersion":"v1beta3"}'));
		$sut = $ns->get_rc('myRc');
	};
	before sub {
		$lwpMock->resetCalls;
	};
	
	it_should_behave_like "All Resources";
	it_should_behave_like "Stateful Resources";
	
	it "has a spec" => sub {
		ok($sut->spec);
	};
	
	describe "Get Pods" => sub {
		it "can get a list of pods" => sub {
			can_ok($sut, 'get_pods');
		};
		it "makes a get request" => sub {
			$sut->get_pods();
			my($call) = $lwpMock->verify('request')->once->getCalls->[0];
			isa_ok($call->[1], 'HTTP::Request');
			is($call->[1]->method, 'GET');			
		};
		it "Requests relative to its 'selfLink'" => sub {
			$sut->get_pods();
			my($call) = $lwpMock->verify('request')->once->getCalls->[0];
			isa_ok($call->[1], 'HTTP::Request');
			like($call->[1]->uri, qr{/api/v1beta3/namespaces/default/pods});
		};
	};
};

describe "Net::Kubernetes - Pod Objects " => sub {
	before all => sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		lives_ok {
			$ns = Net::Kubernetes::Namespace->new(base_path=>'/api/v1beta3/namespaces/default');
		};
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"spec":{"selector":{"name":"myReplicates"}}, "metadata":{"selfLink":"/api/v1beta3/namespaces/default/replicationcontrollers/myRc"}, "status":{}, "kind":"ReplicationController", "apiVersion":"v1beta3"}'));
		$sut = $ns->get_rc('myRc');
	};
	before sub {
		$lwpMock->resetCalls;
	};
	
	it_should_behave_like "All Resources";
	it_should_behave_like "Stateful Resources";
};

runtests;
