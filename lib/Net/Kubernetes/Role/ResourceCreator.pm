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

=method build_secret($name, $data)

Builds a Kubernetes secret object with $name. $data is a hash reference whose keys will be keys int the created secret.

The value for each key should be either a filename (which will be slurped into
the secret), or a hashref with the keys "type" and "value".

Valid types are "JSON", "YAML" or "String" (anything other that "JSON" or
"YAML") will be assumed to be of type "String". If either "JSON" or "YAML" the
"value" will be serialized out before placing in the secret.

Note that the keys must be valid DNS subdomains (underscore is not allowed) and must be lowercase.

  my ($new_secret) = $kube->build_secret('donttell', {
    ssh-public-key => '/home/dave/.ssh/id_rsa.pub',
    super-secret-data => {
        type  => 'JSON',
        value => { username => 'Dave', password => 'Imnottelling' },
    }
  });

=cut

sub build_secret {
	my($self, $name, $data) = @_;
	return $self->create($self->_assemble_secret($name, $data));
}

sub _assemble_secret {
	my($self, $name, $data) = @_;
	my($secret) = {
		kind => 'Secret',
		apiVersion => $self->api_version,
		metadata=>{
			name => $name,
		},
		type => 'Opaque',
		id => $name,
		data => {},
		namespace=>'default',
	};
	foreach my $key (keys %$data){
		if (ref $data->{$key}) {
			my $value;
			# Handle serializing data
			if (uc($data->{$key}{type}) eq 'JSON') {
				$value = $self->json->encode($data->{$key}{value});
			}
			elsif (uc($data->{$key}{type}) eq 'YAML') {
				$value = YAML::XS::Dump($data->{$key}{value});
			}
			else{
				$value = $data->{$key}{value};
			}
			$secret->{data}{$key} = encode_base64($value, "");
		}
		else {
			# if passed a string, it should be a filename
			if (! -f $data->{$key}) {
				Net::Kubernetes::Exception->throw(message => "Failed to build secret: $data->{$key} - Not Such file.");
			}
			$secret->{data}{$key} = encode_base64(read_file($data->{$key}), "");
		}

	}
	return $secret;
}


return 42;
