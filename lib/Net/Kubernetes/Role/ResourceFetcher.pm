package Net::Kubernetes::Role::ResourceFetcher;
# ABSTRACT: Role to give access to list_* methods.

use Moose::Role;
use MooseX::Aliases;
use syntax "try";
require Net::Kubernetes::Resource::Service;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;

with 'Net::Kubernetes::Role::ResourceFactory';

sub get_resource_by_name {
	my($self, $name, $type) = @_;
	my($res) = $self->ua->request($self->create_request(GET => $self->path.'/'.$type.'/'.$name));
	if ($res->is_success) {
		return $self->create_resource_object($self->json->decode($res->content));
	}
	else {
		my $message;
		try{
			my $obj = $self->json->decode($res->content);
			$message = $obj->{message};
		}
		catch($e) {
			$message = $res->message;
		}
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>$message);
	}
}

return 42;
