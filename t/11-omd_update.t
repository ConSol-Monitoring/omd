#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use File::Temp;

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

plan skip_all => 'Author test. Set $ENV{TEST_AUTHOR} to a true value to run.' unless $ENV{TEST_AUTHOR};
plan skip_all => 'Root permissions required' unless $> == 0;

# regression test for updating a site whose etc/thruk and var/thruk are symlinks
# pointing outside the site directory (e.g. shared on a separate mount). the
# dry-run rsync must descend the symlinked dirs instead of dying with
# "Too many levels of symbolic links"
sub do_omd_update_symlinked_dirs {
    my($omd_update) = @_;
    my $omd_bin = TestUtils::get_omd_bin();
    my $site2   = TestUtils::create_test_site("testsym") or TestUtils::bail_out("no further testing without symlink site");
    my $shared  = "/omd/.shared/$site2";

    # move the two folders outside the site and symlink them back. also add a
    # "share" link in the shared dir pointing back to the site so that relative
    # symlinks inside the moved folders keep resolving, like /src/.shared/dev/
    TestUtils::test_command({ cmd => "/bin/mkdir -p $shared/etc $shared/var" });
    TestUtils::test_command({ cmd => "/bin/ln -s /omd/sites/$site2/share $shared/share" });
    TestUtils::test_command({ cmd => "/bin/mv /omd/sites/$site2/etc/thruk $shared/etc/thruk" });
    TestUtils::test_command({ cmd => "/bin/ln -s $shared/etc/thruk /omd/sites/$site2/etc/thruk" });
    TestUtils::test_command({ cmd => "/bin/mv /omd/sites/$site2/var/thruk $shared/var/thruk" });
    TestUtils::test_command({ cmd => "/bin/ln -s $shared/var/thruk /omd/sites/$site2/var/thruk" });

    TestUtils::test_command({
        cmd  => $omd_bin." -V $omd_update -n update $site2",
        like => [
                  '/DRY RUN/',
                  '/0 conflicts/',
                  '/Updated\s+etc/thruk/thruk.conf/',
                ],
    });

    TestUtils::remove_test_site($site2);
    `rm -rf /omd/.shared`;
    return;
}

# omd create must always write the tmpfs entry to /etc/fstab, using the
# canonical path (real target of /omd) and never the /omd symlink, even with
# --no-tmpfs: a site user without root privileges may later run
# "omd config set TMPFS on" and cannot add the entry himself.
sub do_omd_create_no_tmpfs {
    my $omd_bin = TestUtils::get_omd_bin();
    my $site2   = "tmpfsnt";
    my $real    = `readlink -f /omd`;
    chomp($real);
    my $mnt     = "$real/sites/$site2/tmp";
    my $errlike = scalar @{[glob('/omd/sites/*/.')]} >= 1 ? '/is in use/' : '/^\s*$/';

    TestUtils::test_command({ cmd => $omd_bin." create --no-tmpfs $site2", like => '/Created new site '.$site2.'/', errlike => $errlike })
        or TestUtils::bail_out("no further testing without --no-tmpfs site");

    # the fstab entry exists with the canonical path, the /omd form is absent
    TestUtils::test_command({ cmd => "/bin/grep -c '^tmpfs  $mnt tmpfs .*uid=$site2,' /etc/fstab", like => '/^1$/' });
    TestUtils::test_command({ cmd => "/bin/grep -c '^tmpfs  /omd/sites/$site2/tmp ' /etc/fstab", like => '/^0$/', exit => 1 });

  SKIP: {
        skip "mounting a tmpfs as site user is not possible in containers", 8 if TestUtils::is_docker();

        # TMPFS is off: starting the site must not mount the tmpfs
        TestUtils::test_command({ cmd => "/bin/su - $site2 -c 'omd start'", like => '/Starting naemon.*OK/' });
        TestUtils::test_command({ cmd => "/bin/grep -c ' $mnt tmpfs ' /proc/mounts", like => '/^0$/', exit => 1 });

        # the site user switches TMPFS on without root privileges: the tmpfs gets mounted
        TestUtils::test_command({ cmd => "/bin/su - $site2 -c 'omd stop'", like => '/Stopping naemon.*OK/' });
        TestUtils::test_command({ cmd => "/bin/su - $site2 -c 'omd config set TMPFS on'" });
        TestUtils::test_command({ cmd => "/bin/su - $site2 -c 'omd start'", like => '/Starting naemon.*OK/' });
        TestUtils::test_command({ cmd => "/bin/grep -c ' $mnt tmpfs ' /proc/mounts", like => '/^1$/' });
    }

    TestUtils::test_command({ cmd => "/bin/su - $site2 -c 'omd stop'", like => '/Stopping naemon.*OK/' });
    TestUtils::remove_test_site($site2);
    return;
}

my $omd_bin  = TestUtils::get_omd_bin();
my $site     = TestUtils::create_test_site() or TestUtils::bail_out("no further testing without site");
my $versions_test = { cmd => $omd_bin." versions"};
TestUtils::test_command($versions_test);
my @versions = $versions_test->{'stdout'} =~ m/(^[0-9\.]+)$/mxg;

# make sure all files belong to site user
TestUtils::test_command({ cmd => "/usr/bin/find /omd/sites/$site/ -user root -ls", like => '/^$/' });

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
TestUtils::test_command({ cmd => "/bin/sh -c \"echo '# test newline in thruk.conf' >> /omd/versions/$omd_update/skel/etc/thruk/thruk.conf\""});

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

# dry-run update
TestUtils::test_command({ cmd => $omd_bin." start $site",  like => '/Starting naemon/' });
TestUtils::test_command({
            cmd  => $omd_bin." -V $omd_update -n update $site",
            like => ['/Updated\s+.gitignore/',
                     '/Updated\s+.bashrc/',
                     '/Merged\s+.profile/',
                     '/Updated\s+etc/thruk/thruk.conf/',
                     '/Permissions\s+0644\s+\->\s+0755\s+.modulebuildrc/',
                     '/Vanished\s+.my.cnf/',
                     '/Installed file\s+.new_file/',
                     '/DRY RUN/',
                     '/0 conflicts/',
                     "/\QExecuting pre-update script \"omd\"...OK\E/",
                    ],
            });
TestUtils::test_command({
            cmd  => $omd_bin." -V $omd_update -n update $site -v .my.cnf",
            like => ['/DRY RUN/', '/Vanished\s+.my.cnf/', '/0 conflicts/'],
            });

# make sure all files still belong to site user
TestUtils::test_command({ cmd => "/usr/bin/find /omd/sites/$site/ -user root -ls", like => '/^$/' });

# updating a site with symlinked etc/thruk and var/thruk must not fail
do_omd_update_symlinked_dirs($omd_update);

# omd create --no-tmpfs: fstab entry present, not mounted until the site user enables TMPFS
do_omd_create_no_tmpfs();

# the migration of old entries lives in the package post-install scripts, so
# omd update must leave /etc/fstab alone
my $fstab_before = `md5sum /etc/fstab`;

# The package post-install scripts (rpm %post, debian postinst) migrate old
# /omd/sites/<site>/tmp fstab entries with a sed call. Run the very sed line
# of both scripts against a dummy fstab holding old-format entries.
for my $script ("omd.spec.in", "debian/postinst.in") {
    open(my $fh, '<', "$FindBin::Bin/../$script") or die "cannot read $script: $!";
    my($sedcmd) = grep { /^\s*sed -i -E / } <$fh>;
    close($fh);
    ok($sedcmd, "$script contains the fstab migration sed") or next;
    my $dummy = File::Temp->new();
    print $dummy join("", map { "$_\n" } (
        "tmpfs  /omd/sites/sitexy/tmp tmpfs noauto,user,mode=755,uid=sitexy,gid=sitexy,size=64M 0 0",
        "#tmpfs  /omd/sites/sitez/tmp tmpfs noauto,user,mode=755,uid=sitez,gid=sitez 0 0",
        "tmpfs  /opt/omd/sites/sitecanon/tmp tmpfs noauto,user,mode=755,uid=sitecanon,gid=sitecanon 0 0",
        "/dev/sda1 /omd/other ext4 defaults 0 0",
    ));
    close($dummy);
    my $expected = join("", map { "$_\n" } (
        "tmpfs  /opt/omd/sites/sitexy/tmp tmpfs noauto,user,mode=755,uid=sitexy,gid=sitexy,size=64M 0 0",
        "#tmpfs  /opt/omd/sites/sitez/tmp tmpfs noauto,user,mode=755,uid=sitez,gid=sitez 0 0",
        "tmpfs  /opt/omd/sites/sitecanon/tmp tmpfs noauto,user,mode=755,uid=sitecanon,gid=sitecanon 0 0",
        "/dev/sda1 /omd/other ext4 defaults 0 0",
    ));
    my $fname = $dummy->filename;
    $sedcmd =~ s|/etc/fstab|$fname|;
    for my $run (1, 2) {   # second run: idempotent
        is(system("real=/opt/omd; $sedcmd"), 0, "$script: sed run $run succeeded");
        open(my $in, '<', $fname) or die;
        my $got = do { local $/; <$in> };
        close($in);
        is($got, $expected, "$script: old mountpoints migrated, rest untouched (run $run)");
    }
}

# run update
TestUtils::test_command({ cmd => $omd_bin." stop $site",       like => '/Stopping naemon/' });
TestUtils::test_command({ cmd => $omd_bin." status $site",     like => '/Overall state:\s*stopped/', exit => 1 });
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

# omd update must not touch /etc/fstab
is(`md5sum /etc/fstab`, $fstab_before, 'omd update left /etc/fstab untouched');

# make sure all files still belong to site user
TestUtils::test_command({ cmd => "/usr/bin/find /omd/sites/$site/ -user root -ls", like => '/^$/' });

# verify changes
TestUtils::test_command({ cmd => "/bin/grep -c TESTRC /omd/sites/$site/.profile", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test newline\" /omd/sites/$site/.profile", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test newline\" /omd/sites/$site/.bashrc", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test_history\" /omd/sites/$site/.gitignore", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"test file\" /omd/sites/$site/.new_file", like => ['/^\s*1/']});
TestUtils::test_command({ cmd => "/bin/grep -c \"$site\" /omd/sites/$site/.my.cnf", like => ['/^$/'], exit => undef, errlike => ['/No such file or directory/']});

##################################################
# hot update to previous version
TestUtils::test_command({ cmd => $omd_bin." version -b $site",  like => "/^\Q$omd_update\E\$/" });
TestUtils::test_command({ cmd => $omd_bin." start $site",  like => '/Starting naemon/' });
TestUtils::test_command({
            cmd => $omd_bin." status $site",
            like => ['/apache:\s*running/',
                     '/rrdcached:\s*running/',
                     '/npcd:\s*running/',
                     '/naemon:\s*running/',
                     '/Overall state:\s*running/',
                    ]
            });
TestUtils::test_command({
            cmd  => $omd_bin." -V $omd_version -f update $site",
            like => ['/Updated\s+.gitignore/',
                     '/Updated\s+.bashrc/',
                     '/Merged\s+.profile/',
                     '/Permissions\s+0755\s+\->\s+0644\s+.modulebuildrc/',
                     '/Installed file\s+.my.cnf/',
                     '/Vanished\s+.new_file/',
                    ],
            });
TestUtils::test_command({
            cmd => $omd_bin." status $site",
            like => ['/apache:\s*running/',
                     '/rrdcached:\s*running/',
                     '/npcd:\s*running/',
                     '/naemon:\s*running/',
                     '/Overall state:\s*running/',
                    ]
            });
TestUtils::test_command({ cmd => $omd_bin." version -b $site",  like => "/^\Q$omd_version\E\$/" });

# make sure all files still belong to site user
TestUtils::test_command({ cmd => "/usr/bin/find /omd/sites/$site/ -user root -ls", like => '/^$/' });

##################################################
# omd cleanup I
TestUtils::test_command({ cmd => $omd_bin." cleanup -n 5", like => ["/DRY RUN/", "/\Q$omd_version\E.*In\ use/"], errlike => '/no path found matching pattern|^$/', exit => undef });

##################################################
# update from non-existing version
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd stop'", like => '/Stopping naemon.*OK/' });
TestUtils::test_command({ cmd => $omd_bin." status $site",        like => '/Overall state:\s*stopped/', exit => 1 });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'rm -f version'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'ln -s ../../versions/5.xxx version'", like => '/^$/' });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd update -n'", like => "/DRY RUN.*Updating site.*from version 5.xxx to \Q$omd_version\E/" });
TestUtils::test_command({ cmd => "/bin/su - $site -c 'omd update -y'", like => '/Finished update/' });

##################################################
# cleanup test site
TestUtils::remove_test_site($site);
`rm -rf /omd/versions/$omd_update`;

##################################################
# omd cleanup II
TestUtils::test_command({ cmd => $omd_bin." cleanup -n 5",       like => ["/DRY RUN/", "/\Q$omd_version\E.*Default/"] });
TestUtils::test_command({ cmd => $omd_bin." cleanup 2",          like => ["/\Q$omd_version\E.*Default/"] });
TestUtils::test_command({ cmd => $omd_bin." cleanup",            like => ["/\Q$omd_version\E.*Default/"] });
TestUtils::test_command({ cmd => $omd_bin." cleanup -n --force", like => ["/DRY RUN.*Uninstalling/"] });

done_testing();
