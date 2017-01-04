# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# This Source Code Form is "Incompatible With Secondary Licenses", as
# defined by the Mozilla Public License, v. 2.0.

package Bugzilla::Extension::AssignOnSeverity;

use 5.14.0;
use strict;
use warnings;

use parent qw(Bugzilla::Extension);

our $VERSION = '1.0.3';

sub enabled {
    return 1;
}

sub config_add_panels {
    my ($self, $args) = @_;
    $args->{panel_modules}->{AssignOnSeverity} = "Bugzilla::Extension::AssignOnSeverity::Config";
}

# check that:
# aos_enabled is defined and true (1)
# aos_config is defined
# return if aos is disabled, not defined or not configured
# find product, component, severity
# check if product component severity has been given an assignee
# if not, check product severity
# if not, check severity
# if assignee found, update bug assigned to
# if no assignee found, do nothing
sub bug_end_of_create_validators {
    my ($self, $args) = @_;

    # 1. check aos configuration
    # check if aos is defined and enabled, if not, return
    my $aos = Bugzilla->params->{'aos_enabled'};
    # try to read aos assing_to, return if not found
    my $aos_config = Bugzilla->params->{'aos_config'};
    if (!$aos || $aos == 0 || !$aos_config) { return }
    # read not required add to cc setting and remove from cc settings
    my $aos_add_to_cc = Bugzilla->params->{'aos_add_to_cc'};
    my $aos_rm_from_cc = Bugzilla->params->{'aos_remove_from_cc'};

    # 2. set a referense to bug parameters
    my $bug_params = $args->{'params'};

    # 3. setup a database handler
    my $dbh = Bugzilla->dbh;

    # 4. find product name, component name and severity
    my $product_id = $bug_params->{product_id};
    my $component_id = $bug_params->{component_id};
    my $severity = $bug_params->{bug_severity};

    # error handling, if no product id and no component id found it will not be possible to continue
    if(!$product_id || !$component_id) {return}

    # try to read product and component names from the database
    # NOTE: this query sql is possible to autogenerate by using DBIx::Class and SQL::Abstract
    # even if it feels like overkill but may be a required updated if this extensions should support
    # both 5 and older version and 6 and newer versions of bugzilla
    my ($product_name, $component_name) = $dbh->selectrow_array("
                                    SELECT products.name, components.name
                                    FROM products, components
                                    WHERE products.id = ?
                                    and components.id = ?
                                    ", undef, $product_id, $component_id);

    # error handling, if both names not found it will not be possible to continue
    if(!$product_name || !$component_name) {return}

    # 5. search aos_config for product component severity configuration
    my ($username) = ($aos_config =~ m/^$product_name[\s|.]*$component_name[\s|.]*$severity\s*[:|=]\s*(\S+)/mi);

    if(!$username) {
        #username not found, check product severity
        ($username) = ($aos_config =~ m/^$product_name[\s|.]*$severity\s*[:|=]\s*(\S+)/mi);

        if(!$username) {
            #username not found, check severity
            ($username) = ($aos_config =~ m/^$severity\s*[:|=]\s*(\S+)/mi);
        }
    }

    # if a username found from aos_config for the given product, component, severity
    # update assigned_to with the found user userid from the profiles database
    if($username) {
        # read user userid from the user profiles table
        # NOTE: this query sql is possible to autogenerate by using DBIx::Class and SQL::Abstract
        # even if it feels like overkill but may be a required updated if this extensions should support
        # both 5 and older version and 6 and newer versions of bugzilla
        my $userid = $dbh->selectrow_array("
                                    SELECT userid
                                    FROM profiles
                                    WHERE login_name = ?
                                    or realname = ?
                                    ", undef, $username, $username);

        # update bug assigned_to parameter if a userid is found
        if($userid) {
            my $assignee_id = $bug_params->{assigned_to};
            $bug_params->{assigned_to} = $userid;

            my $cc_array = $bug_params->{cc};
            # add original assignee to cc list if aos_add_to_cc = 1 and
            # the original assignee is not already on the cc list
            if($aos_add_to_cc && $aos_add_to_cc == 1 && $assignee_id) {
                # do not add the same ID twice to the cc array or Bugzilla will
                # not be able to insert the data into the cc table as the primary key
                # is a combination of bug id and assignee id.
                if(!grep { $_ == $assignee_id } @cc_array) {
                    push @$cc_array, $assignee_id;
                }
            }
            # remove new assignee from cc list
            if($aos_rm_from_cc && $aos_rm_from_cc == 1) {
                @$cc_array = grep { $_ != $userid } @$cc_array;
            }
        }
    }
    # default assigned to is used if no user or userid is found
    return;
}

__PACKAGE__->NAME;
