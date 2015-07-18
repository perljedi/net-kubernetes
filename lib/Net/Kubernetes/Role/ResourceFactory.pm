package Net::Kubernetes::Role::ResourceFactory;
# ABSTRACT: Role to allow easy construction of Net::Kubernetes::Resouce::* objects

use Moose::Role;
use MooseX::Aliases;
require Net::Kubernetes::Resource::Service;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;
require Net::Kubernetes::Resource::Secret;
require Net::Kubernetes::Resource::Event;
require Net::Kubernetes::Resource::Node;
require Net::Kubernetes::Resource::Endpoint;

sub create_resource_object {
	my($self, $object, $kind) = @_;
	$kind ||= $object->{kind};
	my(%create_args) = %$object;
	$create_args{api_version} = $object->{apiVersion};
	$create_args{username} = $self->username if($self->username);
	$create_args{password} = $self->password if($self->password);
	$create_args{url} = $self->url;
	$create_args{base_path} = $object->{metadata}{selfLink};
	my $class = "Net::Kubernetes::Resource::".$kind;
	return $class->new(%create_args);
}


return 42;