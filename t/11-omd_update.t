#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};
plan skip_all => 'Root permissions required' unless $> == 0;
plan( tests => 107 );

my $omd_bin  = TestUtils::get_omd_bin();
my $site     = TestUtils::create_test_site() or TestUtils::bail_out_clean("no further testing without site");
my $versions_test = { cmd => $omd_bin." versions"};
TestUtils::test_command($versions_test);
my @versions = $versions_test->{'stdout'} =~ m/(^[0-9\.]+)$/mxg;

# create fake version to update to
my $version_test = { cmd => $omd_bin." version -b"};
TestUtils::test_command($version_test);
chomp(my $omd_version  = $version_test->{'stdout'});
my $omd_update   = $omd_version.'_update_test';
TestUtils::test_command({ cmd => "/bin/mkdir /omd/versions/".$omd_update}) or BAIL_OUT("mkdir failed");
for my $dir (split(/\n/, `ls -1 /omd/versions/$omd_version/`)) {
    next if $dir eq 'skel';
    next if $dir eq 'bin';
    TestUtils::test_command({ cmd => "/bin/ln -s /omd/versions/".$omd_version."/$dir /omd/versions/".$omd_update."/"});
}
TestUtils::test_command({ cmd => "/bin/cp -rp /omd/versions/".$omd_version."/skel /omd/versions/".$omd_update."/"});
TestUtils::test_command({ cmd => "/bin/cp -rp /omd/versions/".$omd_version."/bin /omd/versions/".$omd_update."/"});
TestUtils::test_command({ cmd => "/bin/sed -i /omd/versions/".$omd_update."/bin/omd -e 's%$omd_version%$omd_update%g'"});
TestUtils::test_command({ cmd => "/usr/bin/find /omd/versions/$omd_update/skel/ -type f -exec /bin/sed -e 's%$omd_version%$omd_update%g' -i {} \\;"});

# prepare updates in new skel
TestUtils::test_command({ cmd => "/bin/sh -c \"echo '# test newline in bashrc' >> /omd/versions/$omd_update/skel/.bashrc\""});
TestUtils::test_command({ cmd => "/bin/sed -i /omd/versions/$omd_update/skel/.gitignore -e 's%bash_history%test_history%g'"});

# prepare updates in new skel with changes in current site
TestUtils::test_command({ cmd => "/bin/sh -c \"echo '# test newline in profile' >> /omd/sites/$site/.profile\""});
TestUtils::test_command({ cmd => "/bin/sed -i /omd/versions/$omd_update/skel/.profile -e 's%MAILRC%TESTRC%g'"});

# prepare mode changes
TestUtils::test_command({ cmd => "/bin/chmod 755 /omd/sites/$site/.j4p"});
TestUtils::test_command({ cmd => "/bin/chmod 755 /omd/versions/$omd_update/skel/.modulebuildrc"});

# prepare removed files
TestUtils::test_command({ cmd => "/bin/rm /omd/versions/$omd_update/skel/.my.cnf"});

# prepare new files
TestUtils::test_command({ cmd => "/bin/sh -c \"echo '\\ntest file\\n' >> /omd/versions/$omd_update/skel/.new_file\""});

# run update
TestUtils::test_command({
            cmd  => $omd_bin." -V $omd_update -f update $site",
            like => ['/Updated\s+.gitignore/',
                     '/Updated\s+.bashrc/',
                     '/Merged\s+.profile/',
                     '/Permissions\s+0644\s+\->\s+0755\s+.modulebuildrc/',
                     '/Vanished\s+.my.cnf/',
                     '/Installed file\s+.new_file/',
                    ],
            });

# verify changes
TestUtils::test_command({ cmd => "/bin/grep -c TESTRC /omd/sites/$site/.profile", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test newline\" /omd/sites/$site/.profile", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test newline\" /omd/sites/$site/.bashrc", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test_history\" /omd/sites/$site/.gitignore", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test file\" /omd/sites/$site/.new_file", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"$site\" /omd/sites/$site/.my.cnf", like => ['/^$/'], exit => undef, errlike => ['/No such file or directory/']});

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
`rm -rf /omd/versions/$omd_update`;
