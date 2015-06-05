package Net::Kubernetes::Role::ResourceCreator;

use Moose::Role;
use MooseX::Aliases;
require YAML;
require Net::Kubernetes::Resource::Service;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;
require Net::Kubernetes::Resource::Secret;
require Net::Kubernetes::Exception;
use Data::Dumper;

=head1 NAME

Net::Kubernetes::Role::ResoruceCreator

=cut

requires 'ua';
requires 'create_request';
requires 'json';


sub create_from_file {
	my($self, $file) = @_;
	my $object = YAML::LoadFile($file);
	return $self->create($object);
}

sub create {
	my($self, $object) = @_;
	my $req = $self->create_request(POST=>$self->url.'/'.lc($object->{kind}).'s', undef, $self->json->encode($object));
	my $res = $self->ua->request($req);
	if ($res->is_success) {
		return "Net::Kubernetes::Resource::$object->{kind}"->new($self->json->decode($res->content));
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>"Error creating resource:\n".$res->message);
	}
	
}


return 42;