


use Test2::V0 -target => 'CPAN::Meta::V3::AutomationPolicy';
use Test2::Tools::Compare;


my $pol = CPAN::Meta::V3::AutomationPolicy->new(
    code_generation         => "toolchain",
    automated_contributions => "none",
    automated_actions       => "comment",
);

use DDP; p $pol->json;

done_testing;
