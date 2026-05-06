package CPAN::Meta::V3::AutomationPolicy;

use v5.24;

use Feature::Compat::Class;

class CPAN::Meta::V3::AutomationPolicy {

    use Carp qw( croak );
    use JSON::MaybeXS;
    use PerlX::Maybe qw( maybe );
    use Syntax::Operator::Equ;

    field $version : param : reader : writer = 1;

    field $description : param : reader : writer = undef;

    field $document : param : reader : writer = undef;

    field $code_generation : param : reader : writer;

    field $automated_contributions : param : reader : writer;

    field $automated_actions : param : reader : writer;

    ADJUST {

        croak "only version 1 is supported" unless $version === 1;

    }

    method data {
        return {
            version                 => $version,
            maybe description       => $description,
            maybe document          => $document,
            code_generation         => $code_generation,
            automated_contributions => $automated_contributions,
            automated_actions       => $automated_actions,
        };
    }

    method json {
        state $json = JSON::MaybeXS->new( utf8 => 1, pretty => 1, canonical => 1 );
        return $json->encode( $self->data );
    }

}

use namespace::autoclean;

1;
