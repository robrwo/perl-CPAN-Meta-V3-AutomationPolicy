
use Test2::V0 -target => 'CPAN::Meta::V3::AutomationPolicy';
use Test2::Tools::Compare;

subtest "simple" => sub {

    my $pol = CPAN::Meta::V3::AutomationPolicy->new(
        code_generation         => "toolchain",
        automated_contributions => "none",
        automated_actions       => "comment",
    );

    is $pol->data,
      {
        version                 => 1,
        code_generation         => "toolchain",
        automated_contributions => "none",
        automated_actions       => "comment",
      },
      "data";

};

subtest "template" => sub {

    my $pol = CPAN::Meta::V3::AutomationPolicy->new(
        template => "human_supervised",
    );

    is $pol->data,
      {
        version                 => 1,
        code_generation         => "machine_generated",
        automated_contributions => "code_request",
        automated_actions       => "code_request",
      },
      "data";

};

subtest "template with override" => sub {

    my $pol = CPAN::Meta::V3::AutomationPolicy->new(
        template => "no_automation",
        code_generation => "external_sources",
    );

    is $pol->data,
      {
        version                 => 1,
        code_generation         => "external_sources",
        automated_contributions => "none",
        automated_actions       => "comment",
      },
      "data";

};


done_testing;
