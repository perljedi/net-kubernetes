package Net::Kubernetes::Role::SecretBuilder;
# ABSTRACT: Role to allow creation of resources from either objects or files.

use Moose::Role;
use MooseX::Aliases;
require Net::Kubernetes::Resource::Secret;
require Net::Kubernetes::Exception;
use File::Slurp;
use MIME::Base64 qw(encode_base64);
use syntax 'try';

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
