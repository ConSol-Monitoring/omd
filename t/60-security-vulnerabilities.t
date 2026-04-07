#!/usr/bin/env perl

use warnings;
use strict;
use Test::More;
use POSIX qw(getpwuid);

BEGIN {
    use lib('t');
    require TestUtils;
    import TestUtils;
    use FindBin;
    use lib "$FindBin::Bin/lib/lib/perl5";
}

##################################################
# Security Vulnerability Regression Tests
# Based on: OMD-VULNERABILITIES.md
#
# These tests reproduce the documented exploits.
# A PASSING test means the vulnerability is FIXED.
# A FAILING test means the vulnerability is STILL PRESENT.
##################################################

my $omd_bin       = TestUtils::get_omd_bin();
my $is_docker     = TestUtils::is_docker();
my $createoptions = $is_docker ? " --no-tmpfs " : "";
my $curl_bin      = -x "/bin/curl" ? "/bin/curl" : "/usr/bin/curl";

my $site    = "vulntest";
my $site_cp = "vulncopy";

# Clean up any leftovers from previous runs
for my $s ($site, $site_cp, "vulnrestore", "vulnmoved") {
    system("$omd_bin rm --force $s >/dev/null 2>&1");
}

TestUtils::test_command({ cmd => "$omd_bin create $createoptions $site", errlike => '/^.*$/' })
    or TestUtils::bail_out_clean("Cannot create test site $site");

my $sitedir = "/omd/sites/$site";
TestUtils::test_command({ cmd => "$omd_bin stop $site 2>/dev/null", exit => undef, errlike => undef });

my $have_gcc = (-x "/usr/bin/gcc" || -x "/bin/gcc") ? 1 : 0;

# Helper: read evidence file and count root hits
sub root_hits {
    my ($file, $tag) = @_;
    return 0 unless -f $file;
    open(my $fh, "<", $file) or return 0;
    my $count = 0;
    while (<$fh>) { $count++ if /\Q$tag\E/ && /uid=0/ }
    close($fh);
    return $count;
}

# Helper: deploy a malicious binary wrapper into ~/local/bin/
sub deploy_evil_bin {
    my ($evidence, $binname, $tag, $realpath) = @_;
    $realpath = "/usr/bin/$binname" unless $realpath;
    $realpath = "/bin/$binname" unless -x $realpath;
    system("mkdir -p $sitedir/local/bin");
    open(my $fh, ">", "$sitedir/local/bin/$binname") or return 0;
    print $fh "#!/bin/bash\n";
    print $fh "echo \"$tag uid=\$(id -u)\" >> $evidence\n";
    print $fh "exec $realpath \"\$\@\"\n";
    close($fh);
    chmod(0755, "$sitedir/local/bin/$binname");
    return 1;
}

# Helper: compile an evil shared library with a constructor that logs root hits
sub deploy_evil_so {
    my ($evidence, $soname) = @_;
    return 0 unless $have_gcc;
    my $c_file = "/tmp/evil_${soname}_$$.c";
    my $so_file = "$sitedir/local/lib/evil_${soname}.so";
    system("mkdir -p $sitedir/local/lib");
    open(my $fh, ">", $c_file) or return 0;
    print $fh <<"EVIL_C";
#include <stdio.h>
#include <unistd.h>
__attribute__((constructor)) void evil_${soname}() {
    if (geteuid() == 0) {
        FILE *f = fopen("$evidence", "a");
        if (f) { fprintf(f, "${soname} uid=%d euid=%d\\n", getuid(), geteuid()); fclose(f); }
    }
}
EVIL_C
    close($fh);
    my $gcc_out = `gcc -shared -fPIC -nostartfiles -o $so_file $c_file 2>&1`;
    my $rc = $?;
    if ($rc != 0) {
        diag("deploy_evil_so($soname) failed: rc=$rc");
        diag("  gcc output: $gcc_out") if $gcc_out;
        diag("  c_file exists: " . (-f $c_file ? "yes" : "no"));
        diag("  so_file target dir: " . (-d "$sitedir/local/lib" ? "exists" : "missing"));
    }
    unlink($c_file);
    return ($rc == 0) ? $so_file : 0;
}

# Helper: run a shell command as the site user
sub su_site {
    my ($cmd) = @_;
    system("/bin/su - $site -c " . shell_quote($cmd) . " >/dev/null 2>&1");
}

# Helper: shell-quote a string (wrap in single quotes, escape inner single quotes)
sub shell_quote {
    my ($s) = @_;
    $s =~ s/'/'\\''/g;
    return "'$s'";
}

# Helper: restore ~/bin to a proper symlink if it was tampered with
sub restore_site_bin {
    su_site("if [ -d ~/bin ] && [ ! -L ~/bin ]; then rm -rf ~/bin && ln -s version/bin ~/bin; fi");
}

# Helper: clean up LD variables from ~/etc/environment
sub clean_env_file {
    system("sed -i '/^LD_/d' $sitedir/etc/environment 2>/dev/null");
    system("sed -i '/^PYTHONPATH/d' $sitedir/etc/environment 2>/dev/null");
}

##################################################
# VULN-1 / EXPLOIT A : PATH hijack — rsync
#
# set_environment() puts ~/local/bin first in PATH while
# still running as root. rsync is called via os.system()
# during omd cp (main_mv_or_cp + sync_apache_maint_page).
##################################################
{
    my $ev = "/tmp/vuln1_rsync_$$.log";
    unlink($ev);
    deploy_evil_bin($ev, "rsync", "RSYNC");
    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });
    my $hits = root_hits($ev, "RSYNC");
    ok($hits == 0, "VULN-1/A: malicious ~/local/bin/rsync must NOT execute as root during omd cp (hits=$hits)");
    diag("VULNERABLE: malicious rsync ran as root $hits time(s)") if $hits > 0;
    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($ev, "$sitedir/local/bin/rsync");
}

##################################################
# VULN-1 / PATH hijack — diff
#
# patch_skeleton_files() calls: os.system("diff -u ... | patch ...")
# diff is the first command in the pipeline.
##################################################
{
    my $ev = "/tmp/vuln1_diff_$$.log";
    unlink($ev);
    deploy_evil_bin($ev, "diff", "DIFF");
    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });
    my $hits = root_hits($ev, "DIFF");
    ok($hits == 0, "VULN-1/A: malicious ~/local/bin/diff must NOT execute as root during omd cp (hits=$hits)");
    diag("VULNERABLE: malicious diff ran as root $hits time(s)") if $hits > 0;
    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($ev, "$sitedir/local/bin/diff");
}

##################################################
# VULN-1 / PATH hijack — omd itself (via omd disable)
#
# main_disable() calls: os.system('omd stop %s' % sitename)
# The word 'omd' is resolved via the poisoned PATH.
##################################################
{
    my $ev = "/tmp/vuln1_omd_$$.log";
    unlink($ev);
    deploy_evil_bin($ev, "omd", "OMDBINARY", $omd_bin);
    TestUtils::test_command({ cmd => "$omd_bin disable $site 2>&1", exit => undef, errlike => undef });
    my $hits = root_hits($ev, "OMDBINARY");
    ok($hits == 0, "VULN-1/A: malicious ~/local/bin/omd must NOT execute as root during omd disable (hits=$hits)");
    diag("VULNERABLE: malicious omd ran as root $hits time(s) — full privilege escalation via disable") if $hits > 0;
    system("$omd_bin enable $site >/dev/null 2>&1");
    unlink($ev, "$sitedir/local/bin/omd");
}

##################################################
# VULN-1 / PATH hijack — chown (save_site_skel_backup)
#
# save_site_skel_backup() calls os.system("chown ...")
# without an absolute path.
##################################################
{
    my $ev = "/tmp/vuln1_chown_$$.log";
    unlink($ev);
    my $real_chown = -x "/bin/chown" ? "/bin/chown" : "/usr/bin/chown";
    deploy_evil_bin($ev, "chown", "CHOWN", $real_chown);
    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });
    my $hits = root_hits($ev, "CHOWN");
    ok($hits == 0, "VULN-1/A: malicious ~/local/bin/chown must NOT execute as root during omd cp (hits=$hits)");
    diag("VULNERABLE: malicious chown ran as root $hits time(s)") if $hits > 0;
    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($ev, "$sitedir/local/bin/chown");
}

##################################################
# VULN-1 / PATH hijack — rm and mkdir (save_site_skel_backup)
#
# save_site_skel_backup() also calls rm and mkdir via os.system()
##################################################
{
    my $ev_rm    = "/tmp/vuln1_rm_$$.log";
    my $ev_mkdir = "/tmp/vuln1_mkdir_$$.log";
    unlink($ev_rm, $ev_mkdir);
    my $real_rm    = -x "/bin/rm"    ? "/bin/rm"    : "/usr/bin/rm";
    my $real_mkdir = -x "/bin/mkdir" ? "/bin/mkdir" : "/usr/bin/mkdir";
    deploy_evil_bin($ev_rm,    "rm",    "RM",    $real_rm);
    deploy_evil_bin($ev_mkdir, "mkdir", "MKDIR", $real_mkdir);
    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });
    my $rm_hits    = root_hits($ev_rm,    "RM");
    my $mkdir_hits = root_hits($ev_mkdir, "MKDIR");
    ok($rm_hits == 0,    "VULN-1/A: malicious ~/local/bin/rm must NOT execute as root (hits=$rm_hits)");
    ok($mkdir_hits == 0, "VULN-1/A: malicious ~/local/bin/mkdir must NOT execute as root (hits=$mkdir_hits)");
    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($ev_rm, $ev_mkdir, "$sitedir/local/bin/rm", "$sitedir/local/bin/mkdir");
}

##################################################
# VULN-1 / EXPLOIT B : LD_PRELOAD via ~/etc/environment
#
# set_environment() reads ~/etc/environment without a blocklist.
# LD_PRELOAD causes every subprocess to load attacker's .so.
##################################################
SKIP: {
    skip("gcc not available for LD_PRELOAD test", 1) unless $have_gcc;
    my $ev = "/tmp/vuln1_ldpreload_$$.log";
    unlink($ev);
    my $so = deploy_evil_so($ev, "ldpreload");
    skip("failed to compile evil.so", 1) unless $so;

    # Inject LD_PRELOAD into ~/etc/environment
    open(my $fh, ">>", "$sitedir/etc/environment") or skip("cannot write env file", 1);
    print $fh "LD_PRELOAD=$so\n";
    close($fh);

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my $hits = root_hits($ev, "ldpreload");
    ok($hits == 0, "VULN-1/B: LD_PRELOAD from ~/etc/environment must NOT load in root processes (hits=$hits)");
    diag("VULNERABLE: LD_PRELOAD .so loaded by $hits root processes") if $hits > 0;

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    clean_env_file();
    unlink($ev, $so);
}

##################################################
# VULN-1 / LD_AUDIT via ~/etc/environment
#
# LD_AUDIT is a GNU linker audit interface — equally dangerous
# as LD_PRELOAD but less commonly blocked.
##################################################
SKIP: {
    skip("gcc not available for LD_AUDIT test", 1) unless $have_gcc;
    my $ev = "/tmp/vuln1_ldaudit_$$.log";
    unlink($ev);

    my $c_file = "/tmp/evil_ldaudit_$$.c";
    my $so_file = "$sitedir/local/lib/evil_ldaudit.so";
    system("mkdir -p $sitedir/local/lib");
    open(my $cfh, ">", $c_file) or skip("cannot write C file", 1);
    print $cfh <<"LDAUDIT_C";
#include <stdio.h>
#include <unistd.h>
#include <link.h>
unsigned int la_version(unsigned int v) {
    if (geteuid() == 0) {
        FILE *f = fopen("$ev", "a");
        if (f) { fprintf(f, "LDAUDIT uid=%d euid=%d\\n", getuid(), geteuid()); fclose(f); }
    }
    return v;
}
LDAUDIT_C
    close($cfh);
    my $gcc_rc = system("gcc -shared -fPIC -o $so_file $c_file 2>/dev/null");
    unlink($c_file);
    skip("failed to compile LD_AUDIT .so", 1) if $gcc_rc != 0;

    open(my $fh, ">>", "$sitedir/etc/environment") or skip("cannot write env file", 1);
    print $fh "LD_AUDIT=$so_file\n";
    close($fh);

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my $hits = root_hits($ev, "LDAUDIT");
    ok($hits == 0, "VULN-1/B: LD_AUDIT from ~/etc/environment must NOT load in root processes (hits=$hits)");
    diag("VULNERABLE: LD_AUDIT auditor loaded by $hits root processes") if $hits > 0;

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    clean_env_file();
    unlink($ev, $so_file);
}

##################################################
# VULN-1 / Blocklist: LD_PRELOAD and LD_AUDIT must be
# rejected from ~/etc/environment even for site-user commands.
# Defense in depth.
##################################################
{
    open(my $fh, ">>", "$sitedir/etc/environment");
    print $fh "LD_PRELOAD=/nonexistent/evil.so\n";
    print $fh "LD_AUDIT=/nonexistent/audit.so\n";
    close($fh);

    my $t = { cmd => "/bin/su - $site -c env", exit => undef, errlike => undef };
    TestUtils::test_command($t);
    my $env = $t->{'test_cmd'}->stdout() // '';

    my $ld_preload = ($env =~ /^LD_PRELOAD=/m) ? 1 : 0;
    my $ld_audit   = ($env =~ /^LD_AUDIT=/m)   ? 1 : 0;

    ok(!$ld_preload, "VULN-1 defense: LD_PRELOAD from ~/etc/environment must be blocked by set_environment()");
    ok(!$ld_audit,   "VULN-1 defense: LD_AUDIT from ~/etc/environment must be blocked by set_environment()");

    clean_env_file();
}

##################################################
# VULN-1 / Second set_environment() in main_mv_or_cp
#
# Even if the dispatch guard is fixed, main_mv_or_cp()
# calls set_environment() explicitly to switch to the new
# site's context — still as root. The malicious files get
# copied to the new site first, then the second call picks
# them up. This test detects if BOTH call sites are fixed.
##################################################
{
    my $ev = "/tmp/vuln1_2nd_setenv_$$.log";
    unlink($ev);
    deploy_evil_bin($ev, "rsync", "RSYNC2");
    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });
    my $hits = root_hits($ev, "RSYNC2");
    ok($hits == 0, "VULN-1: both set_environment() call sites must be guarded (hits=$hits)");
    diag("  hits>=2 implies the second explicit call in main_mv_or_cp is also unguarded") if $hits >= 2;
    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($ev, "$sitedir/local/bin/rsync");
}

##################################################
# VULN-2 / Root execution of site-controlled bin/patch
#
# patch_skeleton_files() resolves patch from site_dir(new)/bin/patch
# FIRST. The site user replaces the ~/bin symlink with a dir
# containing a malicious patch script.
##################################################
{
    my $ev = "/tmp/vuln2_cp_$$.log";
    unlink($ev);

    # Stage: replace ~/bin symlink with dir, malicious patch inside
    su_site("rm -f ~/bin && mkdir ~/bin");
    su_site("for f in ~/version/bin/*; do ln -s \"\$f\" ~/bin/\$(basename \"\$f\"); done");
    su_site("rm -f ~/bin/patch");

    # Write the malicious patch script
    open(my $fh, ">", "$sitedir/bin/patch") or die "cannot write malicious patch: $!";
    print $fh "#!/bin/bash\n";
    print $fh "echo \"PATCH uid=\$(id -u)\" >> $ev\n";
    print $fh "exec $sitedir/version/bin/patch \"\$\@\"\n";
    close($fh);
    chmod(0755, "$sitedir/bin/patch");
    system("chown $site:$site $sitedir/bin/patch");

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my $hits = root_hits($ev, "PATCH");
    ok($hits == 0, "VULN-2: site-controlled ~/bin/patch must NOT execute as root during omd cp (hits=$hits)");
    diag("VULNERABLE: malicious patch ran as root $hits time(s)") if $hits > 0;

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($ev);
    restore_site_bin();
}

##################################################
# VULN-2 / Same attack via omd restore
#
# A backup contains the malicious bin/patch. omd restore
# (to a different name) calls patch_skeleton_files() as root.
##################################################
{
    my $ev = "/tmp/vuln2_restore_$$.log";
    my $backup = "/tmp/vuln2_restore_$$.tar.gz";
    unlink($ev, $backup);

    # Stage malicious bin/patch
    su_site("rm -f ~/bin && mkdir ~/bin");
    su_site("for f in ~/version/bin/*; do ln -s \"\$f\" ~/bin/\$(basename \"\$f\"); done");
    su_site("rm -f ~/bin/patch");
    open(my $fh, ">", "$sitedir/bin/patch") or die "cannot write malicious patch: $!";
    print $fh "#!/bin/bash\n";
    print $fh "echo \"PATCH2 uid=\$(id -u)\" >> $ev\n";
    print $fh "exec /usr/bin/patch \"\$\@\"\n";
    close($fh);
    chmod(0755, "$sitedir/bin/patch");
    system("chown $site:$site $sitedir/bin/patch");

    # Create backup with malicious patch inside
    TestUtils::test_command({ cmd => "$omd_bin backup $site $backup 2>&1", exit => undef, errlike => undef });

    # Restore ~/bin before test
    restore_site_bin();

    # Restore to a new site name
    system("$omd_bin rm --force vulnrestore >/dev/null 2>&1");
    TestUtils::test_command({ cmd => "$omd_bin restore vulnrestore $backup 2>&1", exit => undef, errlike => undef });

    my $hits = root_hits($ev, "PATCH2");
    ok($hits == 0, "VULN-2: malicious bin/patch in backup must NOT run as root during omd restore (hits=$hits)");
    diag("VULNERABLE: malicious patch in backup ran as root $hits time(s)") if $hits > 0;

    system("$omd_bin rm --force vulnrestore >/dev/null 2>&1");
    unlink($ev, $backup);
}

##################################################
# VULN-3 / Version symlink: path traversal attempt
#
# site_version() uses .split("/")[-1] which should prevent
# path traversal. Verify a crafted version link doesn't
# escape /omd/versions/.
##################################################
{
    my $orig_target = readlink("$sitedir/version") // "";

    system("rm -f $sitedir/version");
    symlink("/omd/versions/../../tmp/evil_version", "$sitedir/version");

    my $t = { cmd => "$omd_bin status $site 2>&1", exit => undef, errlike => undef };
    TestUtils::test_command($t);
    my $out = ($t->{'test_cmd'}->stdout() // "") . ($t->{'test_cmd'}->stderr() // "");
    ok($out !~ /evil_version.*ok/i, "VULN-3: path traversal in version symlink must not exec code from outside /omd/versions/");

    # Restore
    system("rm -f $sitedir/version");
    if ($orig_target) { symlink($orig_target, "$sitedir/version") }
}

##################################################
# VULN-3 / Multiple versions installed warning
##################################################
{
    my @versions = sort glob("/omd/versions/*/");
    my $count = scalar @versions;
    ok(1, "VULN-3 info: $count OMD version(s) installed");
    if ($count > 2) {
        diag("WARNING VULN-3: $count versions installed. Old versions could be targeted by version symlink attack.");
        diag("  Mitigation: uninstall all except the current patched version.");
    }
}

##################################################
# VULN-4 / try_chown follows symlinks
#
# try_chown() uses os.chown() which follows symlinks.
# Replace a config file with a symlink to a victim file.
# After omd cp, try_chown changes ownership of the TARGET.
##################################################
{
    my $victim = "/tmp/vuln4_victim_$$.txt";
    system("echo victim_data > $victim && chown root:root $victim && chmod 600 $victim");

    # Stage: replace logrotate.conf with symlink to victim
    system("cp $sitedir/etc/logrotate.conf $sitedir/etc/logrotate.conf.bak 2>/dev/null");
    system("rm -f $sitedir/etc/logrotate.conf");
    symlink($victim, "$sitedir/etc/logrotate.conf");
    system("chown -h $site:$site $sitedir/etc/logrotate.conf 2>/dev/null");

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my @st = stat($victim);
    my $new_uid = $st[4] // 0;
    ok($new_uid == 0, "VULN-4: try_chown must NOT follow symlink and chown victim (uid=$new_uid, expected 0)");
    if ($new_uid != 0) {
        my $owner = getpwuid($new_uid) // $new_uid;
        diag("VULNERABLE: $victim chowned to '$owner' (uid=$new_uid) — attacker could target /etc/shadow");
    }

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink("$sitedir/etc/logrotate.conf");
    system("mv $sitedir/etc/logrotate.conf.bak $sitedir/etc/logrotate.conf 2>/dev/null");
    system("chown root:root $victim 2>/dev/null");
    unlink($victim);
}

##################################################
# VULN-4 / try_chown also called for .rej and .orig paths
#
# try_chown(dst + ".orig") is called after patching.
# A pre-planted .orig symlink will be followed.
##################################################
{
    my $victim = "/tmp/vuln4b_victim_$$.txt";
    system("echo orig_victim > $victim && chown root:root $victim && chmod 644 $victim");

    my $fake_orig = "$sitedir/etc/logrotate.conf.orig";
    symlink($victim, $fake_orig);
    system("chown -h $site:$site $fake_orig 2>/dev/null");

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my @st = stat($victim);
    my $new_uid = $st[4] // 0;
    ok($new_uid == 0, "VULN-4: try_chown(.orig) must NOT follow symlink (uid=$new_uid, expected 0)");
    diag("VULNERABLE: .orig symlink path also followed") if $new_uid != 0;

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    unlink($fake_orig);
    system("chown root:root $victim 2>/dev/null");
    unlink($victim);
}

##################################################
# VULN-5 / chown_tree initial os.chown follows symlinks
#
# chown_tree() starts with os.chown(dir, uid, gid) — NOT lchown.
# A symlink inside the site that points outside gets followed.
##################################################
{
    my $victim_dir = "/tmp/vuln5_victim_$$";
    system("mkdir -p $victim_dir && chown root:root $victim_dir");

    system("mkdir -p $sitedir/local/vuln5");
    symlink($victim_dir, "$sitedir/local/vuln5/escape");
    system("chown -h $site:$site $sitedir/local/vuln5/escape 2>/dev/null");

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my @st = stat($victim_dir);
    my $new_uid = $st[4] // 0;
    ok($new_uid == 0, "VULN-5: chown_tree must NOT follow symlinks outside the site (uid=$new_uid, expected 0)");
    diag("VULNERABLE: $victim_dir chowned to uid=$new_uid via symlink") if $new_uid != 0;

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    system("rm -rf $sitedir/local/vuln5");
    system("chown root:root $victim_dir 2>/dev/null");
    system("rmdir $victim_dir 2>/dev/null");
}

##################################################
# HTTP-level tests (VULN-6, VULN-7)
# Set OMD_SKIP_HTTP_TESTS=1 to skip these
##################################################
SKIP: {
    skip("HTTP tests skipped (OMD_SKIP_HTTP_TESTS is set)", 22) if $ENV{OMD_SKIP_HTTP_TESTS};

    TestUtils::test_command({ cmd => "$omd_bin start $site", exit => undef, errlike => undef });
    sleep(2);

    ##################################################
    # VULN-6 / CORS Origin Reflection — multiple origin patterns
    #
    # Thruk reflects ANY Origin in Access-Control-Allow-Origin
    # combined with Access-Control-Allow-Credentials: true.
    ##################################################
    {
        my @evil_origins = (
            "https://evil.attacker.example.com",
            "http://evil.attacker.example.com",
            "https://127.0.0.1.evil.com",
            "https://monitoring.internal.evil.com",
            "null",
        );

        for my $origin (@evil_origins) {
            my $t = { cmd => "$curl_bin -sk -H 'Origin: $origin' https://127.0.0.1/$site/thruk/ -I 2>&1", exit => undef, errlike => undef };
            TestUtils::test_command($t);
            my $hdrs = $t->{'test_cmd'}->stdout() // "";

            my $reflected = ($hdrs =~ /Access-Control-Allow-Origin:\s*\Q$origin\E/i) ? 1 : 0;
            my $creds     = $reflected && ($hdrs =~ /Access-Control-Allow-Credentials:\s*true/i);

            ok(!$reflected, "VULN-6: Thruk must NOT reflect Origin '$origin' in ACAO header");
            diag("VULNERABLE: '$origin' reflected" . ($creds ? " WITH credentials (full bypass)" : "")) if $reflected;
        }
    }

    ##################################################
    # VULN-6 / CORS preflight (OPTIONS request)
    ##################################################
    {
        my $t = { cmd => "$curl_bin -sk -X OPTIONS -H 'Origin: https://evil.attacker.example.com' -H 'Access-Control-Request-Method: GET' https://127.0.0.1/$site/thruk/r/hosts -I 2>&1", exit => undef, errlike => undef };
        TestUtils::test_command($t);
        my $hdrs = $t->{'test_cmd'}->stdout() // "";
        my $reflected = ($hdrs =~ /Access-Control-Allow-Origin:\s*https:\/\/evil\.attacker\.example\.com/i) ? 1 : 0;
        ok(!$reflected, "VULN-6: Thruk CORS preflight (OPTIONS) must NOT reflect evil Origin");
    }

    ##################################################
    # VULN-7 / Open redirect via X-Forwarded-Host
    ##################################################
    {
        my @evil_hosts = (
            "evil.attacker.example.com",
            "evil.attacker.example.com:8080",
            "EVIL.ATTACKER.EXAMPLE.COM",
        );

        for my $host (@evil_hosts) {
            my $t = { cmd => "$curl_bin -sk -H 'X-Forwarded-Host: $host' http://127.0.0.1/$site/ -I 2>&1", exit => undef, errlike => undef };
            TestUtils::test_command($t);
            my $hdrs = $t->{'test_cmd'}->stdout() // "";

            (my $clean_host = $host) =~ s/:\d+$//;
            $clean_host = lc($clean_host);
            my $redirected = ($hdrs =~ /Location:.*\Q$clean_host\E/i) ? 1 : 0;

            ok(!$redirected, "VULN-7: X-Forwarded-Host '$host' must NOT appear in redirect Location");
            if ($redirected) {
                my ($loc) = ($hdrs =~ /(Location:[^\r\n]+)/i);
                diag("VULNERABLE: open redirect to: $loc");
            }
        }
    }

    ##################################################
    # VULN-7 / Legitimate redirect still works
    ##################################################
    {
        my $t = { cmd => "$curl_bin -sk http://127.0.0.1/$site/ -I 2>&1", exit => undef, errlike => undef };
        TestUtils::test_command($t);
        my $hdrs = $t->{'test_cmd'}->stdout() // "";
        ok($hdrs =~ m{Location:.*/$site/omd/}i, "VULN-7: legitimate redirect to /$site/omd/ still works");
    }

    TestUtils::test_command({ cmd => "$omd_bin stop $site", exit => undef, errlike => undef });
}

##################################################
# VULN-8 / unmount_tmpfs follows symlinks — omd rm
#
# If ~/tmp is replaced with a symlink after unmount,
# delete_directory_contents() follows it and operates
# on the target directory.
##################################################
SKIP: {
    skip("tmpfs tests skipped on docker", 2) if $is_docker;

    my $victim_dir = "/tmp/vuln8_rm_$$";
    system("mkdir -p $victim_dir");
    system("echo DO_NOT_DELETE > $victim_dir/sentinel.txt");
    system("chown root:root $victim_dir/sentinel.txt");

    # Unmount tmpfs
    system("umount -l $sitedir/tmp 2>/dev/null");
    sleep(1);

    # Replace ~/tmp with symlink to victim
    system("rm -rf $sitedir/tmp");
    symlink($victim_dir, "$sitedir/tmp");

    system("$omd_bin rm --force $site 2>&1");

    my $sentinel_intact = -f "$victim_dir/sentinel.txt" ? 1 : 0;
    ok($sentinel_intact, "VULN-8 (omd rm): delete_directory_contents must NOT follow ~/tmp symlink");
    diag("VULNERABLE: sentinel file deleted through ~/tmp symlink") unless $sentinel_intact;

    # Root must not have created new entries in victim dir
    my @extra = grep { $_ !~ /sentinel/ } glob("$victim_dir/*");
    ok(scalar @extra == 0, "VULN-8 (omd rm): root must NOT create dirs/files in symlink-target");
    diag("VULNERABLE: root created in victim dir: " . join(", ", @extra)) if @extra;

    system("rm -rf $victim_dir");

    # Recreate site for final cleanup
    TestUtils::test_command({ cmd => "$omd_bin create $createoptions $site", errlike => '/^.*$/' });
}

##################################################
# VULN-8 / unmount_tmpfs follows symlinks — omd stop
##################################################
SKIP: {
    skip("tmpfs tests skipped on docker", 1) if $is_docker;

    my $victim_dir = "/tmp/vuln8_stop_$$";
    system("mkdir -p $victim_dir");
    system("echo STOPTEST > $victim_dir/stopfile.txt");

    system("umount -l $sitedir/tmp 2>/dev/null");
    sleep(1);
    system("rm -rf $sitedir/tmp");
    symlink($victim_dir, "$sitedir/tmp");

    # omd stop runs as the site user after privilege drop.  With ~/tmp being
    # a symlink to a root-owned directory the init scripts' "mkdir -p tmp/run"
    # will fail with Permission denied — that is expected (the attack fails)
    # but produces noisy stderr output.  Capture it so it does not pollute the
    # test log.
    system("$omd_bin stop $site >/dev/null 2>&1");

    my $file_intact = -f "$victim_dir/stopfile.txt" ? 1 : 0;
    ok($file_intact, "VULN-8 (omd stop): unmount_tmpfs must NOT follow ~/tmp symlink during stop");
    diag("VULNERABLE: stopfile deleted through symlink during omd stop") unless $file_intact;

    system("rm -rf $victim_dir");
    # Restore tmp: remove leftover symlink/dir, let omd remount tmpfs with skeleton
    system("umount -l $sitedir/tmp 2>/dev/null");
    system("rm -rf $sitedir/tmp && mkdir $sitedir/tmp && chown $site:$site $sitedir/tmp");
    system("$omd_bin mount $site 2>/dev/null");
}

##################################################
# Combined attack: VULN-1 + VULN-4
#
# Stage LD_PRELOAD AND a symlink attack simultaneously.
# Verifies fixes are independent — patching one doesn't mask the other.
##################################################
SKIP: {
    skip("gcc not available for combined test", 1) unless $have_gcc;

    my $ev_ldpreload = "/tmp/vuln_combo_ldpreload_$$.log";
    my $victim       = "/tmp/vuln_combo_victim_$$.txt";
    unlink($ev_ldpreload);
    system("echo combo_victim > $victim && chown root:root $victim");

    my $so = deploy_evil_so($ev_ldpreload, "combo");
    unless ($so) {
        # Diagnose why gcc failed
        my $c_file = "/tmp/evil_combo_diag_$$.c";
        my $so_diag = "$sitedir/local/lib/evil_combo_diag.so";
        system("mkdir -p $sitedir/local/lib");
        if (open(my $dfh, ">", $c_file)) {
            print $dfh "void dummy() {}\n";
            close($dfh);
            my $gcc_out = `gcc -shared -fPIC -nostartfiles -o $so_diag $c_file 2>&1`;
            diag("gcc diagnostic: rc=$?, output: $gcc_out");
            diag("  sitedir/local/lib exists: " . (-d "$sitedir/local/lib" ? "yes" : "no"));
            diag("  sitedir/local/lib writable: " . (-w "$sitedir/local/lib" ? "yes" : "no"));
            unlink($c_file, $so_diag);
        }
        skip("failed to compile combo .so", 1);
    }

    open(my $fh, ">>", "$sitedir/etc/environment");
    print $fh "LD_PRELOAD=$so\n";
    close($fh);

    # Stage symlink attack
    system("cp $sitedir/etc/logrotate.conf $sitedir/etc/logrotate.conf.combobak 2>/dev/null");
    system("rm -f $sitedir/etc/logrotate.conf");
    symlink($victim, "$sitedir/etc/logrotate.conf");

    TestUtils::test_command({ cmd => "$omd_bin cp $site $site_cp 2>&1", exit => undef, errlike => undef });

    my $ld_fired = root_hits($ev_ldpreload, "combo") > 0;
    my @vstats = stat($victim);
    my $victim_chowned = (($vstats[4] // 0) != 0) ? 1 : 0;

    ok(!$ld_fired && !$victim_chowned,
        "Combined VULN-1+VULN-4: both LD_PRELOAD and symlink chown must be blocked simultaneously");
    diag("LD_PRELOAD still fires as root") if $ld_fired;
    diag("Victim file chowned to uid=" . ($vstats[4]//0)) if $victim_chowned;

    system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
    clean_env_file();
    unlink("$sitedir/etc/logrotate.conf");
    system("mv $sitedir/etc/logrotate.conf.combobak $sitedir/etc/logrotate.conf 2>/dev/null");
    system("chown root:root $victim 2>/dev/null");
    unlink($ev_ldpreload, $victim, $so);
}

##################################################
# Final cleanup
##################################################
system("$omd_bin stop $site >/dev/null 2>&1");
system("$omd_bin rm --force $site >/dev/null 2>&1");
system("$omd_bin rm --force $site_cp >/dev/null 2>&1");
system("$omd_bin rm --force vulnrestore >/dev/null 2>&1");
system("$omd_bin rm --force vulnmoved >/dev/null 2>&1");

done_testing();
