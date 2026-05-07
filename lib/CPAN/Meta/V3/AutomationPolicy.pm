package CPAN::Meta::V3::AutomationPolicy;

use v5.24;

use Moo;

use Carp qw( croak );
use File::ShareDir qw( dist_file );
use JSON::MaybeXS;
use JSON::Schema;
use Path::Tiny qw( path );
use PerlX::Maybe qw( maybe );
use Ref::Util    qw( is_plain_hashref );
use Syntax::Keyword::Match;
use Types::Common qw( Enum InstanceOf PositiveInt NonEmptyStr );

use experimental qw( declared_refs signatures );

use namespace::autoclean;

has version => (
    is       => 'ro',
    isa      => PositiveInt,
    default  => 1,
    required => 1,
);

has description => (
    is        => 'ro',
    isa       => NonEmptyStr,
    predicate => 1,
);

has document => (
    is        => 'ro',
    isa       => NonEmptyStr,
    predicate => 1,
);

has code_generation => (
    is       => 'ro',
    isa      => Enum [qw( toolchain external_sources machine_generated )],
    required => 1,
);

has automated_contributions => (
    is       => 'ro',
    isa      => Enum [qw( none comment issue code_request )],
    required => 1,
);

has automated_actions => (
    is       => 'ro',
    isa      => Enum [qw( none comment issue code_request code_change release )],
    required => 1,
);

has filename => (
    is      => 'lazy',
    isa     => NonEmptyStr,
    default => 'automation-policy.json',
);

my $json = JSON::MaybeXS->new( utf8 => 1, pretty => 1, canonical => 1 );

my $file = path( dist_file( __PACKAGE__ =~ s/::/-/gr, "automation-policy-schema.json" ) );

my $schema = JSON::Schema->new( $json->decode( $file->slurp_raw ) );

sub data($self) {
    #<<<
    return {
        version                 => $self->version,
        maybe description       => $self->has_description ? $self->description : undef,
        maybe document          => $self->has_document    ? $self->document    : undef,
        code_generation         => $self->code_generation,
        automated_contributions => $self->automated_contributions,
        automated_actions       => $self->automated_actions,
    };
    #>>>
}

sub validate($self) {
    return $self->_validate( $self->data );
}

sub to_json($self) {
    return $json->encode( $self->data );
}

sub BUILDARGS( $class, @args ) {

    if ( @args == 1 && !is_plain_hashref( $args[0] ) ) {
        unshift @args, "template";
    }

    my %args = ( @args == 1 && is_plain_hashref( $args[0] ) ) ? $args[0]->%* : @args;

    if ( my $version = $args{version} ) {
        croak "unsupported version '${version}'"
            if PositiveInt->check($version) && $version != 1;
    }

    if ( my $template = delete $args{template} ) {

        match( $template : eq ) {

            case ("no_automation") {
                $args{code_generation}         //= "toolchain";
                $args{automated_contributions} //= "none";
                $args{automated_actions}       //= "comment";
            }

            case ("issues_only") {
                $args{code_generation}         //= "toolchain";
                $args{automated_contributions} //= "issue";
                $args{automated_actions}       //= "issue";
            }

            case ("human_supervised") {
                $args{code_generation}         //= "machine_generated";
                $args{automated_contributions} //= "code_request";
                $args{automated_actions}       //= "code_request";
            }

            case ("data_driven_updates") {
                $args{code_generation}         //= "external_sources";
                $args{automated_contributions} //= "issue";
                $args{automated_actions}       //= "release";
            }

            case ("full_automation") {
                $args{code_generation}         //= "code_generation";
                $args{automated_contributions} //= "code_request";
                $args{automated_actions}       //= "release";
            }

            default {
                croak "Unsupported template: '${template}'";
            }

        }

    }

    return \%args;
}


sub from_json( $class, @args ) {


    if ( @args == 1 && !is_plain_hashref( $args[0] ) ) {
        unshift @args, "json";
    }

    my %args = ( @args == 1 && is_plain_hashref( $args[0] ) ) ? $args[0]->%* : @args;

    croak "json is required" unless defined $args{json};

    my \$data = \$args{json};

    $data = $json->decode( $data ) unless is_plain_hashref( $data );

    if ( my $res = $schema->validate( $data ) ) {
        return $class->new( $data );
    }
    else {
        croak $_ for $res->errors;
    }

}

1;

=head1 SEE ALSO

L<https://github.com/CPAN-Security/cpan-metadata-v3/blob/main/automation-policy.md>

=cut
