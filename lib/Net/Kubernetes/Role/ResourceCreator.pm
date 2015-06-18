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
use File::Slurp;

=head1 NAME

Net::Kubernetes::Role::ResoruceCreator

=cut

with 'Net::Kubernetes::Role::ResourceFactory';

requires 'ua';
requires 'create_request';
requires 'json';


sub create_from_file {
	my($self, $file) = @_;
	if (! -f $file) {
		Throwable::Error->throw(message=>"Could not read file: $file");
	}
	
	my $object;
	if ($file =~ /\.ya?ml$/i){
		$object = YAML::LoadFile($file);
	}
	else{
		$object = $self->json->decode(read_file($file));
	}
	
	return $self->create($object);
}

sub create {
	my($self, $object) = @_;
	my $req = $self->create_request(POST=>$self->path.'/'.lc($object->{kind}).'s', undef, $self->json->encode($object));
	my $res = $self->ua->request($req);
	if ($res->is_success) {
		return $self->create_resource_object($self->json->decode($res->content));
	}else{
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>"Error creating resource:\n".$res->message);
	}
	
}


return 42;