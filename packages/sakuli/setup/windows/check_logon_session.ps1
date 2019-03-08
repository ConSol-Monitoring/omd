<#
12/2013 Simon Meggle, ConSol Software GmbH, simon.meggle@consol.de
.SYNOPSIS
   Check logon state of a certain user
.DESCRIPTION
   For Sakuli E2E tests, it is neccessary, that the tests are running in a unlocked user session. 
   This can be either a RDP connection, or the local console. 
   Use this script to ensure that the technical e2e user is logged on
   and the tests are able to run. 
.NSClient++ configuration
   check_logon_session=powershell -NoLogo -InputFormat none -NoProfile -NonInteractive -command "&  {scripts\check_logon_session.ps1 $ARG1$; exit $lastexitcode}"
.NAGIOS call
   check_nrpe -H (IP) -c check_logon_session -a '-user simon' -t 60    
#>
	
	
	param (
        $user #(Read-Host -Prompt "Enter a User name")
    )
     

    $c = qwinsta 2>&1 | where {$_.gettype().equals([string]) }

    $starters = New-Object psobject -Property @{"SessionName" = 0; "Username" = 0; "ID" = 0; "State" = 0;};
	 
    foreach($line in $c) {
         try {
             if($line.trim().substring(0, $line.trim().indexof(" ")) -eq "SITZUNGSNAME") {
                $starters.Username = $line.indexof("BENUTZERNAME");
                $starters.ID = $line.indexof("ID");
                $starters.State = $line.indexof("STATUS");
                continue;
            }
            
			$username = $line.Substring($starters.Username, $line.IndexOf(" ", $starters.Username) - $starters.Username);
			if ($username -ne $user) {
				continue;
			}
			$sessionname = $line.trim().substring(0, $line.trim().indexof(" ")).trim(">");
			$state = $line.Substring($starters.State, $line.IndexOf(" ", $starters.State)-$starters.State).trim();
			break;
			
        } catch {
            throw $_;
            #$e = $_;
            #Write-Error -Exception $e.Exception -Message $e.PSMessageDetails;
        } 
    }
	
	if ($sessionname -eq $null) {
		Write-Host "CRITICAL: User "$user" is not logged on on this system! Not ready for E2E tests! ";
		exit 2;
	} else {
		if ($state -eq "Getr.")   {
			Write-Host "CRITICAL: User session of "$user" is detached ("$sessionname", "$state")! Not ready for E2E tests! ";	
			exit 2;
		} else {
		# active session (RDP or Console)
	    	try { 
        		if (Get-Process logonui -ComputerName localhost -ErrorAction Stop) { 
            		Write-Host "CRITICAL: User session of "$user "("$sessionname, $state") is locked! Not ready for E2E tests! ";  
					exit 2;
				} 
    		} catch {}
		Write-Host "OK: User" $user "is logged on ("$sessionname", "$state"). Ready for E2E tests.";
		exit 0;
		}
	}
