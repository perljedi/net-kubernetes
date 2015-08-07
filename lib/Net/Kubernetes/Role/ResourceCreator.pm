package Net::Kubernetes::Role::ResourceCreator;
# ABSTRACT: Role to allow creation of resources from either objects or files.

use Moose::Role;
use MooseX::Aliases;
require YAML::XS;
require Net::Kubernetes::Resource::Service;
require Net::Kubernetes::Resource::Pod;
require Net::Kubernetes::Resource::ReplicationController;
require Net::Kubernetes::Resource::Secret;
require Net::Kubernetes::Exception;
use File::Slurp;
use MIME::Base64 qw(encode_base64);
use syntax 'try';

with 'Net::Kubernetes::Role::ResourceFactory';

requires 'ua';
requires 'create_request';
requires 'json';

=method create({OBJECT})

Creates a new L<Net::Kubernetes::Resource> (subtype determined by $BNJECT->{kind})

=method create_from_file(PATH_TO_FILE) (accepts either JSON or YAML files)

Create from file is really just a short cut around something like:

  my $object = YAML::LoadFile(PATH_TO_FILE);
  $kube->create($object);

=cut

sub create_from_file {
	my($self, $file) = @_;
	if (! -f $file) {
		Throwable::Error->throw(message=>"Could not read file: $file");
	}

	my $object;
	if ($file =~ /\.ya?ml$/i){
		$object = YAML::XS::LoadFile($file);
	}
	else{
		$object = $self->json->decode(scalar(read_file($file)));
	}

	return $self->create($object);
}

sub create {
	my($self, $object) = @_;

	# This is an ugly hack and I am not proud of it.
	# That being said, I have bigger fish to fry right now
	# This is here because kubernetes will not accept "true"
	# and "false".
	# The other problem is that YAML will read a a boolean
	# value as 1 or 0 which json does not switch back to
	# true or false. This is not JSON's fault, but I'm not
	# sure just now how I want to solve it.
	my $content = $self->json->encode($object);
	$content =~ s/(["'])(true|false)\1/$2/g;
	# /EndHack
    my $req = $self->create_request(POST=>$self->path.'/'.lc($object->{kind}).'s', undef, $content);
	my $res = $self->ua->request($req);
	if ($res->is_success) {
		return $self->create_resource_object($self->json->decode($res->content));
	}else{
		my $message;
		try{
			my $obj = $self->json->decode($res->content);
			$message = $obj->{message};
		}
		catch($e) {
			$message = $res->message;
		}
		Net::Kubernetes::Exception->throw(code=>$res->code, message=>"Error creating resource: ".$message);
	}
}

return 42;
