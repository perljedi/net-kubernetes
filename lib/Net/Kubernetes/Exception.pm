package Net::Kubernetes::Exception;
# ABSTRACT: Base class for all kubernetes exceptions.

use Moose;

extends "Throwable::Error";

has code => (
	is       => 'ro',
	isa      => 'Num',
	required => 0,
);

use Moose::Util::TypeConstraints;

subtype 'Net::Kubernetes::Exception::ClientException', as 'Net::Kubernetes::Exception', where {! defined $_->code};

subtype 'Net::Kubernetes::Exception::NotFound', as 'Net::Kubernetes::Exception', where { $_->code == 404 };

subtype 'Net::Kubernetes::Exception::Conflict', as 'Net::Kubernetes::Exception', where { $_->code == 409 };

subtype 'Net::Kubernetes::Exception::BadRequest', as 'Net::Kubernetes::Exception', where { $_->code == 400 };

no Moose::Util::TypeConstraints;


package Net::Kunbernetes::Exception::ClientException;
# ABSTRACT: Exception class for client side errors

require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';


package Net::Kunbernetes::Exception::NotFound;
# ABSTRACT: Kubernetes Not found exception (code 404)

require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';

package Net::Kunbernetes::Exception::Conflict;
# ABSTRACT: Kubernetes 'Conflict' exception (code 409)

require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';

package Net::Kunbernetes::Exception::BadRequest;
# ABSTRACT: Kubernetes 'Bad Request' exception (code 400)

require Net::Kubernetes::Exception;
use Moose;

extends 'Net::Kubernetes::Exception';
extends 'Throwable::Error';

return 42;