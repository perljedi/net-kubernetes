package Net::Kubernetes::Resource::Secret;
# ABSTRACT: Object representatioon of a Kubernetes Secret

use Moose;

use File::Slurp qw(write_file);
use MIME::Base64 qw(decode_base64);

extends 'Net::Kubernetes::Resource';

has type => (
	is       => 'ro',
	isa      => 'Str',
	required => 1
);

has data => (
	is       => 'ro',
	isa      => 'HashRef',
	required => 1
);

=method render(directory => "/path/to/write/secret/files", [ force => 0/] )

Render the contents of a Kubernetes secret into the specified directory.  Will
not overwrite files unless 'force' is specified.

Returns the number of files written.

=cut

sub render {
    my $self = shift;

    my(%args);
    if (ref($_[0])) {
        %args = %{ $_[0] };
    } else {
        %args = @_;
    }

    $args{force} //= 0;

    if (! -d $args{directory}) {
        Throwable::Error->throw(message => "Directory must exist: $args{directory}");
    }

    for my $file (keys %{$self->data}) {
        write_file("$args{directory}/$file",
            {
                err_mode   => 'croak',
                no_clobber => !$args{force},
				binmode => ':raw',
            },
            decode_base64 ${$self->data}{$file}
        );
    }
    # if we didn't write them all, we better have thrown an exception.
    return scalar keys %{$self->data};
}

return 42;
