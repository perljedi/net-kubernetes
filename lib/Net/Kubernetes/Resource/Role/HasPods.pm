package Net::Kubernetes::Resource::Role::HasPods;

use Moose::Role;

=head1 NAME

Net::Kubernetes::Resource::Role::HasPods

Role for resource object which might "Have Pods" ... i.e. Replication Controller or Services

=cut

with 'Net::Kubernetes::Role::APIAccess';

sub get_pods {
	my($self) = @_;
	my $uri = URI->new_abs("../pods", $self->path);
	$uri->query_form(labelSelector=>$self->_build_selector_from_hash($self->spec->{selector}));
	my $res = $self->ua->request($self->create_request(GET => $uri));
	if ($res->is_success) {
		my $pod_list = $self->json->decode($res->content);
		my(@pods)=();
		foreach my $pod (@{ $pod_list->{items}}){
			$pod->{apiVersion} = $pod_list->{apiVersion};
			my(%create_args) = %$pod;
			$create_args{api_version} = $pod->{apiVersion};
			$create_args{username} = $self->username if($self->username);
			$create_args{password} = $self->password if($self->password);
			$create_args{url} = $self->url;
			$create_args{base_path} = $pod->{metadata}{selfLink};
			push @pods, Net::Kubernetes::Resource::Pod->new(%create_args);
		}
		return wantarray ? @pods : \@pods;
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$res->message);
	}
}

sub _build_selector_from_hash {
	my($self, $select_hash) = @_;
	my(@selectors);
	foreach my $label (keys %{ $select_hash }){
		push @selectors, $label.'='.$select_hash->{$label};
	}
	return \@selectors;
}

return 42;