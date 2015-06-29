package Net::Kubernetes::Exception;
use Moose;

=head1 NAME

Net::Kubernetes::Exception

=cut

extends "Throwable::Error";

has code => (
	is       => 'ro',
	isa      => 'Num',
	required => 1,
);

use Moose::Util::TypeConstraints;

subtype 'Net::Kubernetes::Exception::NotFound', as 'Net::Kubernetes::Exception', where { $_->code == 404 };

subtype 'Net::Kubernetes::Exception::Conflict', as 'Net::Kubernetes::Exception', where { $_->code == 409 };

subtype 'Net::Kubernetes::Exception::BadRequest', as 'Net::Kubernetes::Exception', where { $_->code == 400 };

no Moose::Util::TypeConstraints;


package Net::Kunbernetes::Exception::NotFound;
require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';

package Net::Kunbernetes::Exception::Conflict;
require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';

package Net::Kunbernetes::Exception::BadRequest;
require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';

return 42;