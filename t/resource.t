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
use File::Temp qw/tempdir/;
use File::Slurp qw/read_file/;
use File::stat;

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

shared_examples_for "Pod Container" => sub {
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
	it_should_behave_like "Pod Container";
	
	it "has a spec" => sub {
		ok($sut->spec);
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

describe "Net::Kubernetes - Secret Objects " => sub {
	before all => sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		lives_ok {
			$ns = Net::Kubernetes::Namespace->new(base_path=>'/api/v1beta3/namespaces/default');
		};
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"type":"opaque", "data":{ "readme": "VGVzdCBmaWxlIGZvciBOZXQ6Okt1YmVybmV0ZXMgdGVzdHMuICBUaGlzIGdldHMgY3JlYXRlZCB3aGVuIHRlc3RpbmcgdGhlCk5ldDo6S3ViZXJuZXRlczo6UmVzb3VyY2U6OlNlY3JldC0+cmVuZGVyIG1ldGhvZCwgYW5kIGlzIHVzZWQgdG8gY29uZmlybSB0aGF0Cml0IHdhcyB3cml0dGVuIG91dCBjb3JyZWN0bHkuCgpJdCBjYW4gYmUgc2FmZWx5IGRlbGV0ZWQuICBZb3Ugc2hvdWxkbid0IGV2ZXIgc2VlIGl0LCBhY3R1YWxseS4K", "super-secret-app-password": "Q2FyZXNzIG9mIFN0ZWVsCg==" }, "metadata":{"selfLink":"/api/v1beta3/namespaces/default/replicationcontrollers/myRc"}, "kind":"Secret", "apiVersion":"v1beta3"}'));
		$sut = $ns->get_rc('mySecret');
	};
	before sub {
		$lwpMock->resetCalls;
	};
	
	it_should_behave_like "All Resources";
	
	it "has a type" => sub {
		ok($sut->type);
	};
	it "has data" => sub {
		ok($sut->data);
	};
    describe "rendering secrets to a directory" => sub {
        my $directory = tempdir(CLEANUP => 1);

        it "should write two files" => sub {
            is($sut->render(directory => $directory), 2);
        };
        it "writes the correct contents to a file" => sub {
            my $password = read_file("$directory/super-secret-app-password");
            is($password, "Caress of Steel\n");
        };
        it "has the correct size on a larger file" => sub {
            my $stat = stat("$directory/README") or die "Can't open $directory/README : $!";
            is($stat->size, 246);
        };
        
    };
};

describe "Net::Kubernetes - Service Objects " => sub {
	before all => sub {
		$lwpMock = Test::Mock::Wrapper->new('LWP::UserAgent');
		lives_ok {
			$ns = Net::Kubernetes::Namespace->new(base_path=>'/api/v1beta3/namespaces/default');
		};
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"spec":{"selector":{"name":"myReplicates"}}, "status":{}, "metadata":{"selfLink":"/api/v1beta3/namespaces/default/replicationcontrollers/myRc"}, "kind":"Service", "apiVersion":"v1beta3"}'));
		$sut = $ns->get_rc('mySecret');
	};
	before sub {
		$lwpMock->resetCalls;
	};
	
	it_should_behave_like "All Resources";
	it_should_behave_like "Stateful Resources";
	it_should_behave_like "Pod Container";
};

runtests;
