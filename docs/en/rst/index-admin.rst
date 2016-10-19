AssignOnSeverity
################

AssignOnSeverity should be installed in the :file:`extensions/AssignOnSeverity/` directory and :file:`checksetup.pl` should have been run after the installation. This will add a configuration page to the adminstration/parameters page.

Assign On Severity allows Bugzilla to be configured to re-assign new issues automatically. Only new issues will be re-assigne upon creation. Old issues will not be re-assigned when their severity is changed.

To modify AssignOnSeverity settings open the adminstration/parameters/AssignOnSeverity page where the following settings are available:

*aos_enabled*
    On to enabled aos, off to disable aos. Default is off, checking reset will disable aos.

*aos_add_to_cc*
    On will make aos add the original assignee to the issue cc list when re-assigning the issue. Default is off, checking reset will disable add to cc.

*aos_rm_from_cc*
    On will make aos remove the new assignee from the cc list, default is off, checking reset will disable remove from cc list.

*aos_config*
    Aos configuration for re-assigning base on severity. There are three different possible configuration options:
    1. severity = login name or real name
    2. product severity = login name or real name
    3. product component severity = login name or real name

    Search order is from 3. to 1. If a name is not found from 3. 2. is searched and then 1. The issue is not re-assigned if no name is found.
    The search is case insensitive, accepts : or = and .'s or whitespace's between product/component/severity and requires one configuration per line.

    Default is no configuration, checking reset will remove all configurations.

    Click Save Changes to save the configuration.