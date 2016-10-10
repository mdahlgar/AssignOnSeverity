# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::AssignOnSeverity::Config;

use 5.14.0;
use strict;
use warnings;

#use Bugzilla::Config::Common;

our $sortkey = 5000;

sub get_param_list {
    my ($class) = @_;

    my @param_list = (
        {
            name => 'aos_enabled',
            type => 'b',
            default => 0
        },
        {
            name => 'aos_add_to_cc',
            type => 'b',
            default => 0
        },
        {
            name => 'aos_remove_from_cc',
            type => 'b',
            default => 0
        },
        {
            name => 'aos_config',
            type => 'l',
            default => ""
        },
    );
    return @param_list;
}

1;