use Test::Spec;
use Net::Kubernetes;
use vars qw($sut $lwpMock);

shared_examples_for "Pod Lister" => sub{
	before sub {
		$sut = Net::Kubernetes->new;
	};
	it "can get a list of pods" => sub {
		can_ok($sut, 'list_pods');
	};
	it "throws an exception if the call returns an error" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
		dies_ok {
			$sut->list_pods;
		};
	};
	it "doesn't throw an exception if the call succeeds" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3"}'));
		lives_ok {
			$sut->list_pods;
		};
	};
	it "returns an array of pods" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		my $res = $sut->list_pods;
		isa_ok($res, 'ARRAY');
		isa_ok($res->[0], 'Net::Kubernetes::Resource::Pod');
	};
	it "includes label selector in query if labels are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_pods(labels=>{name=>'my-pod'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
	};
	it "includes field selector in query if fields are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_pods(fields=>{'status.phase'=>'Running'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
	};
};

shared_examples_for "Endpoint Lister" => sub{
	before sub {
		$sut = Net::Kubernetes->new;
	};
	it "can get a list of pods" => sub {
		can_ok($sut, 'list_endpoints');
	};
	it "throws an exception if the call returns an error" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
		dies_ok {
			$sut->list_endpoints;
		};
	};
	it "doesn't throw an exception if the call succeeds" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3"}'));
		lives_ok {
			$sut->list_endpoints;
		};
	};
	it "returns an array of pods" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"metadata":{"selfLink":"/path/to/me"}, "subsets":[{}]}]}'));
		my $res = $sut->list_endpoints;
		isa_ok($res, 'ARRAY');
		isa_ok($res->[0], 'Net::Kubernetes::Resource::Endpoint');
	};
	it "includes label selector in query if labels are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_endpoints(labels=>{name=>'my-pod'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
	};
	it "includes field selector in query if fields are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_endpoints(fields=>{'status.phase'=>'Running'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
	};
};

shared_examples_for "Replication Controller Lister" => sub {
	it "can get a list of pods" => sub {
		can_ok($sut, 'list_rc');
	};
	it "throws an exception if the call returns an error" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
		dies_ok {
			$sut->list_rc;
		};
	};
	it "doesn't throw an exception if the call succeeds" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3"}'));
		lives_ok {
			$sut->list_rc;
		};
	};
	it "returns an array of ReplicationControllers" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		my $res = $sut->list_rc;
		isa_ok($res, 'ARRAY');
		isa_ok($res->[0], 'Net::Kubernetes::Resource::ReplicationController');
	};
	it "includes label selector in query if labels are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_rc(labels=>{name=>'my-pod'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
	};
	it "includes field selector in query if fields are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_rc(fields=>{'status.phase'=>'Running'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
	};
};

shared_examples_for "Service Lister" => sub {
	it "can get a list of services" => sub {
		can_ok($sut, 'list_services');
	};
	it "throws an exception if the call returns an error" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
		dies_ok {
			$sut->list_services;
		};
	};
	it "doesn't throw an exception if the call succeeds" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3"}'));
		lives_ok {
			$sut->list_services;
		};
	};
	it "returns an array of Services" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		my $res = $sut->list_services;
		isa_ok($res, 'ARRAY');
		isa_ok($res->[0], 'Net::Kubernetes::Resource::Service');
	};
	it "includes label selector in query if labels are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_services(labels=>{name=>'my-pod'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
	};
	it "includes field selector in query if fields are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_services(fields=>{'status.phase'=>'Running'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
	};
};

shared_examples_for "Secret Lister" => sub {
	it "can get a list of secrets" => sub {
		can_ok($sut, 'list_secrets');
	};
	it "throws an exception if the call returns an error" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(401, "you suck"));
		dies_ok {
			$sut->list_rc;
		};
	};
	it "doesn't throw an exception if the call succeeds" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3"}'));
		lives_ok {
			$sut->list_services;
		};
	};
	it "returns an array of secrets" => sub {
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		my $res = $sut->list_services;
		isa_ok($res, 'ARRAY');
		isa_ok($res->[0], 'Net::Kubernetes::Resource::Service');
	};
	it "includes label selector in query if labels are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_services(labels=>{name=>'my-pod'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('labelSelector'));
	};
	it "includes field selector in query if fields are passed in" => sub{
		$lwpMock->addMock('request')->returns(HTTP::Response->new(200, "ok", undef, '{"status":"ok", "apiVersion":"v1beta3", "items":[{"spec":{}, "metadata":{"selfLink":"/path/to/me"}, "status":{}}]}'));
		$sut->list_services(fields=>{'status.phase'=>'Running'});
		$lwpMock->verify('request')->once;
		my $req = $lwpMock->getCallsTo('request')->[0][1];
		cmp_deeply([ $req->uri->query_form ], supersetof('fieldSelector'));
	};
};

