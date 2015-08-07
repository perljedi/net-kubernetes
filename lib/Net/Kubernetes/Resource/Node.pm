package Net::Kubernetes::Resource::Node;
# ABSTRACT: Object representatioon of a Kubernetes Pod

use Moose;
use URI;
extends 'Net::Kubernetes::Resource';

with 'Net::Kubernetes::Resource::Role::State';
with 'Net::Kubernetes::Resource::Role::Spec';

sub get_pods {
    my($self) = shift;
    my $uri = URI->new($self->url.'/api/'.$self->api_version.'/pods');
    my $selector = {};
    if($self->api_version eq 'v1'){
        $selector->{'spec.nodeName'} = $self->metadata->{name};
    }else{
        $selector->{'spec.host'} = $self->metadata->{name};
    }
    $uri->query_form(fieldSelector=>$self->_build_selector_from_hash($selector));
    print "Query with $uri\n";
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
	return join(",", @selectors);
}

return 42;
