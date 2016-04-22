######################################################################
######################################################################
#                                                                    #
#                      Rule file for mailagent                       #
#                                                                    #
######################################################################
######################################################################


######################################################################
######################################################################
#                                                                    #
#                          Global variables                          #
#                                                                    #
######################################################################
######################################################################

# The 'maildir' variable tells the mailagent where the folders are located.
# By default, it is set to ~/Mail (because it is a convention used by other
# mail-related programs), but the author prefers to use ~/mail.

maildir = ~/var/spool/mail;

# The 'mailfilter' variable points to the place where all the loaded files
# are stored (e.g. loaded patterns or addresses) and is used only when a
# relative path is specified.

mailfilter = ~/etc/mail;

######################################################################
######################################################################
#                                                                    #
#                      Command and server stuff                      #
#                                                                    #
######################################################################
######################################################################

X-Spam-Status: /Yes/          { REJECT SPAM };
X-CRM114-Status: /SPAM  \( -\d\d\d/
     { UNIQUE -a (SPAM); ANNOTATE -d X-RealSpam '%1'; REJECT REALSPAM;  };
<SPAM> X-Spam-Value: /([1-9]\d\.\d)/
     { UNIQUE -a (SPAM); ANNOTATE -d X-RealSpam '%1'; REJECT REALSPAM;  };
<!SPAM>  Subject: /±¤°í|ks_c_5601-|GB2312|EUC-KR/ { REJECT SPAM };
<!SPAM>  Content-Type: /charset=.*ks_c_5601-/     { REJECT SPAM };


######################################################################
######################################################################
#                                                                    #
#           Adminstrative stuff, not to be recorded below            #
#                                                                    #
######################################################################
######################################################################


# If I was just on the CC list, do not send vacation messages
<INITIAL> Cc: srivasta    { VACATION off; REJECT };

<!SPAM> From: Mailer-Daemon,
Subject: /Mail delivery failed: returning message/,
             { REJECT BOUNCED };

# The machine is called anzu
<INITIAL> From: news, From: root, To: usenet           { REJECT ADMIN };
<INITIAL> Subject: /Cron \<root\@anzu\>/               { REJECT ADMIN };
<INITIAL> Subject: /Cron \<root\@tiamat\>/             { REJECT ADMIN };
<INITIAL> From:   root, To: root                       { BEGIN ADMIN; REJECT };
<INITIAL> From: srivasta, Subject: /lurkftp output/    { REJECT ADMIN };
<INITIAL> From: /root\@.+\.internal\.golden-gryphon\.com/
                                                       { REJECT ADMIN };
<INITIAL> From: /daemon\@.+\.internal\.golden-gryphon\.com/
                                                       { REJECT ADMIN };
<INITIAL> From: /root\@golden-gryphon.com/             { REJECT ADMIN };
<INITIAL> From: /root\@ladon\.golden-gryphon.com/      { REJECT ADMIN };
<INITIAL> From: /daemon\@golden-gryphon.com/           { REJECT ADMIN };
<INITIAL> From:   Majordomo                            { REJECT ADMIN };
<INITIAL> From:   uucp                                 { REJECT ADMIN };
<INITIAL> From: /mailman-owner\@lists.sourceforge.net/ { REJECT ADMIN };
<INITIAL> From: /mailman-owner\@ks.teknowledge.com/    { REJECT ADMIN };
<INITIAL> From:   arpwatch                             { REJECT ADMIN };
From: Calamaris                                        { REJECT ADMIN };
<INITIAL> Subject: /^\s*\[SNORT\] /                     { REJECT ADMIN };
<INITIAL> From: /support\@theplanet.com/               { REJECT ADMIN };
<INITIAL> From: /scheduledmaintenance\@theplanet.com/  { REJECT ADMIN };
<INITIAL> From: /support-portal\@theplanet\.com/i      { REJECT ADMIN };
<INITIAL> From: /support\@dtccom\.net/i                { REJECT ADMIN };
To From: /nobody\@glaurung\.internal\.golden-gryphon\.com/
     { REJECT ADMIN };
To From: /daemon\@glaurung\.internal\.golden-gryphon\.com/,
   Subject: Debian security status
     { REJECT ADMIN };
<INITIAL> From: /logcheck\@ip-10-248-0-85\.us-west-2\.compute\.internal/
           { REJECT ADMIN };
From: /nobody\@(internal|ladon)\.golden-gryphon\.com/,
 From: /nobody\@glaurung\.internal\.golden-gryphon\.com/i,
 Subject: /DenyHosts Report/                  { REJECT ADMIN };

### Save this -- before getting indexed and all
<INITIAL> From: /nagios\@.+\.internal\.golden-gryphon\.com/,
          From: /nagios\@stdc\.com/,
          From: /nagios\@artemis\.stdc\.com/,
          From: /nagios\@athena\.stdc\.com/,
          From: /nagios\@smtp\.stdc\.com/
         { ASSIGN logsource 'nagios'; REJECT Logs };
<INITIAL> From: /logcheck\@.+\.internal\.golden-gryphon\.com/,
          From: /logcheck\@internal\.golden-gryphon\.com/
          From: /logcheck\@ladon\.golden-gryphon\.com/
          From: /logcheck\@ip-10-248-0-85\.us-west-2\.compute\.internal/
         { ASSIGN logsource 'logcheck'; REJECT Logs };
<INITIAL> From: /fail2ban\@internal.golden-gryphon.com/,
          From: /fail2ban\@ladon.golden-gryphon.com/,
          From: /fail2ban\@ip-10-248-0-85\.us-west-2\.compute\.internal/
           { REJECT ADMIN };
<INITIAL> From: /buildmeister\@stdc\.com/i,
          To: /manoj\.srivastava\@stdc\.com/i
         { ASSIGN logsource 'cabie'; REJECT Logs};

######################################################################
######################################################################
#                                                                    #
#                            Main Section                            #
#                                                                    #
######################################################################
######################################################################

# All that enter here get logged
All: /./        { PERL sbin/mailagent.log.pl};

<INITIAL> Subject: /Your signed PGP key 0x21BADABBBF24424C/i
          { REJECT KEYS   };

<LOST,INITIAL> From:
 /plaistedg\@erols.com/i,
 /corpcuts\@msn.com/i,
 /corpcuts\@gmail.com/i,
 /67_camaro\@charter.net/i
   { ANNOTATE -d X-List Known; REJECT ADDRESSED };


## <INITIAL> From Sender X-Mn-Key Envelope:
##  /\@(Time)customerservice\.delivery\.net/i
##  {
##    ASSIGN list 'time';
##    BOUNCE jshardo@mail.golden-gryphon.com;
##    REJECT MailingList;
##  };

<INITIAL> From Sender X-Mn-Key Envelope:
              /\@(Time)customerservice\.delivery\.net/i,
              /wesTD.undlv@customersvc.com/i,
              /TD\@customersvc.com/i
 {
   ASSIGN list 'time';
   REJECT MailingList;
 };


# New homes, automated email
<INITIAL> From Sender X-Return-Path Envelope X-Envelope-From:
 /kmartins\@mcenearney.com/i,
 Subject: /Homes in Virginia/i
 {
    ASSIGN list 'homes';
    ANNOTATE -d X-Disposition Homes;
    BOUNCE jshardo@mail.golden-gryphon.com;
    REJECT MailingList
 };
<INITIAL>  : From: /<pyxismobile\@pyxismobile.com/i   { REJECT JUNK; };

######################################################################
######################################################################
#                                                                    #
#                            Job Related                             #
#                                                                    #
######################################################################
######################################################################

## <SPAM,RETRY,INITIAL> To: /(noc)\@stdc\.com/
##  {
##    ANNOTATE -d X-Disposition Work-Mailinglist;
##    ASSIGN list '%1';
##    REJECT MailingList
##  };


## <INITIAL> From: /bacula@stdc.com/
##    { ANNOTATE -d X-Agent-list 'bacula';
##           ASSIGN list 'bacula';
##           REJECT MailingList };


## <INITIAL> From: /emailupgrade\@earthlink.net/,
##           To: /stdc\@earthlink\.net/
##    { ANNOTATE -d X-Agent-list 'earthlink notice';
##           ASSIGN list 'stdc';
##           REJECT MailingList };

## <INITIAL> From: /specialoffers\@earthlink.net/,
##           To: /stdc\@earthlink\.net/
##    { ANNOTATE -d X-Agent-list 'earthlink notice';
##           ASSIGN list 'stdc';
##           REJECT MailingList };

## <SPAM,RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere X-Mailing-List X-Loop X-MDMailing-List Resent-From Envelope:
##  /(arms)\@opengroup.org/i,
##  /discuss\@(globus).org/i,
##  /(omg-list)-errors\@amethyst\.omg\.org/i,
##  /(opendce)\@opengroup.org/i,
##  /(tangram-team)\@boozallenet\.com/i,
##  /(tangram-others)\@boozallenet\.com/i,
##  /(tangram-pmo)\@boozallenet\.com/i,
##  /(tangram-support)\@boozallenet\.com/i,
##  /(tangram-pi)\@boozallenet\.com/i
##  /(tangram)-info\@eagle-link\.org/i,
##  /(tangram)\&harm\@eagle-link\.org/i,
##  /(stdc-devel)\@nemertes\.stdc\.com/i,
##  /(stdc-devel)\@wiki\.stdc\.com/i,
##  /(ul-\w+)\@ultralog.net/i
##  {
##    ANNOTATE -d X-Agent-list '%1';
##    ANNOTATE -d X-Disposition Work-Mailinglist;
##    ASSIGN list '%1';
##    REJECT MailingList
##  };

## <RETRY,INITIAL> Subject: /\[Tangram Tracker \#/
##  {
##    ANNOTATE -d X-Agent-list 'tangram-tracker';
##    ANNOTATE -d X-Disposition Work-Mailinglist;
##    ASSIGN list 'tangram-tracker';
##    REJECT MailingList
##  };

######################################################################
######################################################################
#                                                                    #
#                            Debian                                  #
#                                                                    #
######################################################################
######################################################################
######################################################################
<INITIAL>  X-PTS-Package: /([-\w]+)/
      { ANNOTATE -d X-Agent-list 'pkg-%1';
          ASSIGN list 'pkg-%1';
          REJECT MailingList };
# X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc
<INITIAL>  X-Loop: /debian-devel-changes/i   { REJECT JUNK; };

# Do not wish to see acks for bug reports
<INITIAL> From: /owner\@bugs.debian.org/, Subject: /Bug#\d+: Acknowledgement /
       { REJECT JUNK; };

# These have little information really
<INITIAL> From: /owner\@bugs.debian.org/, Subject: /Bug#\d+: Info received/i
       { REJECT ClosedBugs };

<INITIAL>  X-Loop: /debian-bugs-dist/i        { REJECT DEBIANBUGS };
<INITIAL>  X-Loop: /owner\@bugs.debian.org/i  { REJECT DEBIANBUGS };

<INITIAL> From Envelope: /discard-all\@chiark.greenend.org.uk/
       { REJECT DEBIAN };

<INITIAL> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
 /lists.debian.org/i  { REJECT DEBIAN };

<INITIAL> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
 /debian-ctte/i  { REJECT DEBIAN };

<INITIAL> X-Loop: /deity/i  { ASSIGN list 'deity'; REJECT MailingList  };

<INITIAL> Sender From: /installer\@ftp-master.debian.org/
        { ASSIGN list 'installed'; REJECT MailingList };

<INITIAL> X-BeenThere List-Id: /lists.spi-inc.org/i  { REJECT SPI };


<INITIAL> X-BeenThere List-Id: /freestandards.org/i, /lsb-/
        { REJECT LSB };

<INITIAL> To From: /([-\w]+)-commits-(owner|bounce)\@lists.alioth.debian.org/i
        { REJECT AliothAdmin };

From:  /(calendar)-notification\@google\.com/i,
  To: /manoj\.srivastava\.1962\@gmail\.com/i
  {
    ASSIGN list 'calendar';
    REJECT MailingList;
  };

From:  /\@txt\.(voice)\.google\.com/i,
  To: /manoj\.srivastava\.1962\@gmail\.com/i
  {
    ASSIGN list 'text';
    REJECT MailingList;
  };

<INITIAL> From Sender X-Return-Path Envelope X-Envelope-From:
 /(tartan)\@hands.com/i
 {
    ASSIGN list '%1';
    REJECT MailingList
 };

######################################################################
######################################################################
#                                                                    #
#                     Handle Debian Related Mail                     #
#                                                                    #
######################################################################
######################################################################
# Handle My own bugs
<DEBIANBUGS> To Resent-CC: /Manoj Srivastava/
        { REJECT MYBUGS };

<MYBUGS> X-Debian-PR-Package: /([-\w]+)/
      { ANNOTATE -d X-Agent-list 'pkg-%1';
          ASSIGN list 'pkg-%1';
          REJECT MailingList };

# Resent-To: Manoj Srivastava is for bugs I reported
<MYBUGS> /./
        { ASSIGN list 'debian';
          ANNOTATE -d X-Agent-list unknown-bug-list;
          REJECT MailingList;
        };

#handle policy bugs
<DEBIANBUGS> X-Debian-PR-Package: /debian-policy/
        { ASSIGN list 'debian-policy';
          ANNOTATE -d X-Agent-list debian-list;
          REJECT MailingList;
        };

<DEBIANBUGS> X-Debian-PR-Package: /general/
        { ASSIGN list 'debian-devel';
          ANNOTATE -d X-Agent-list general-bugs;
          REJECT MailingList;
        };

<DEBIANBUGS> X-Debian-PR-Package: /wnpp/
        { ASSIGN list 'wnpp';
          ANNOTATE -d X-Agent-list debian-list;
          REJECT MailingList;
        };

<DEBIANBUGS> Subject: /\[proposal\]/i, X-Debian-PR-Package: /debian-policy/
        { ASSIGN list 'debian-policy';
          ANNOTATE -d X-Agent-list debian-list;
          REJECT MailingList;
        };

<DEBIANBUGS> All:  /./
        {
           ASSIGN list 'debian-bugs';
           ANNOTATE -d X-Agent-list debian-list;
           REJECT MailingList;
        };

<AliothAdmin>  All:  /./
        {
           ASSIGN list 'alioth-admin';
           ANNOTATE -d X-Agent-list alioth-list;
           REJECT MailingList;
        };

<DEBIAN> X-Loop:
  /(debian-bugs-(closed|forwarded))(-(request|dist))?\@lists.debian.org/i
   { REJECT ClosedBugs };


<DEBIAN> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc :
   /(debian-ctte+)(-(request|dist|private))?\@debian.org/gi
   { ASSIGN list '%1';
     ANNOTATE -d X-Agent-list debian-list;
     REJECT MailingList;
   };


<DEBIAN>  Subject: /CFV: Proposal/, X-Loop: /debian-vote/ { REJECT VOTE };

<DEBIAN> X-Loop: /(debian-[\w-]+)(-(request|dist))?\@lists.debian.org/gi
   { ASSIGN list '%1';
     SUBST #list /-(digest|request|dist)//gi;
     SUBST #list /devel-changes/changes/i;
     ANNOTATE -d X-Agent-list debian-list;
     REJECT MailingList;
   };

<VOTE> Body: /^\s*I vote\s+\w+\s+on/i
        { UNIQUE -a (vote); VACATION off; MESSAGE ~/etc/mail/voteack;
          REJECT VOTEACK; };
<VOTE> All:  /./  { REJECT DEBIAN };

<DEBIAN> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc :
   /(debian-[\w-]+)(-(request|dist))?\@lists.debian.org/gi
   { ASSIGN list '%1';
     SUBST #list /-(digest|request|dist)//gi;
     SUBST #list /devel-changes/changes/i;
     ANNOTATE -d X-Agent-list debian-list;
     REJECT MailingList;
   };

<DEBIAN> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
   /srivasta/ { ANNOTATE -d X-Agent-list Unknown;
                          ASSIGN list 'debian'; REJECT MailingList };

<DEBIAN>  All:  /./     { ANNOTATE -d X-Agent-list Unknown;
                          REJECT RETRY};

<ClosedBugs> {
## construct text string suitable for single-quoting
        ASSIGN temp %[From]%_=>%_%[Envelope-To]%_(%[Subject]);
        SUBST #temp /['\\\\]/\\\\$1/g;
## now write the log
        DO add_log ("[$mfile]%_".'%#temp');
        PERL sbin/mailagent.deblog.pl;
        };

<LSB>  Sender List-Id X-BeenThere: /(lsb-[\w-]+)(-(request|dist))?\@/gi
   { ASSIGN list '%1';
     SUBST #list /-(digest|request|dist)//gi;
     SUBST #list /devel-changes/changes/i;
     ANNOTATE -d X-Agent-list lsb-list;
     REJECT MailingList;
   };
<SPI>  Sender List-Id X-BeenThere: /(spi-[\w-]+)(-(request|dist))?\@/gi
   { ASSIGN list '%1';
     SUBST #list /-(digest|request|dist)//gi;
     ANNOTATE -d X-Agent-list spi-list;
     REJECT MailingList;
   };

######################################################################
######################################################################
#                                                                    #
#                 The mailing lists I subscribe to:                  #
#                                                                    #
######################################################################
######################################################################
<INITIAL> To CC Sender : /google-summer-of-code-mentors-list\@googlegroups\.com/,
           /gsoc-mentors-announce\@googlegroups.com/i
          { ANNOTATE -d X-Agent-list 'gsoc';
            ASSIGN list 'gsoc';
            REJECT MailingList };
<INITIAL> Subject: /\[Soc-coordination\]/
          { ANNOTATE -d X-Agent-list 'soc';
            ASSIGN list 'soc';
            REJECT MailingList };

<INITIAL> To Cc Sender X-Mn-Key Envelope:
        /customerservice\@mail.walgreens.com/        { REJECT MEDICAL };

<MEDICAL> Subject: /Your prescription is not ready for pick up/
         { REJECT ADDRESSED };

<MEDICAL> All: /./  { ANNOTATE -d X-Agent-list 'walgreens';
                      ASSIGN list 'walgreens';
                      REJECT MailingList };

<INITIAL> Subject: /\[Tome\]/i, To: /\@t-o-m-e.net/i
         { ANNOTATE -d X-Agent-list 'tome'; ASSIGN list 'tome';
          REJECT MailingList };
# Mailing list moved
<INITIAL> To: /PernAngband\@yahoogroups.com/i
         { REJECT SPAM };

<INITIAL> Subject: /MIGRATED to testing/
          { ANNOTATE -d X-Agent-list 'testing'; ASSIGN list 'testing';
            REJECT MailingList };
<INITIAL> To Cc Sender X-Mn-Key Envelope:
       /majordom\@aunet.org/i
       { ASSIGN list 'linux-india'; REJECT MailingList };

<INITIAL> To Cc Sender X-Mn-Key Envelope:
              /([-\w]+)@googlegroups.com/i
              { ASSIGN list '%1'; REJECT MailingList };

<INITIAL> To Cc Sender X-Mn-Key Envelope:
        /careermag.com/i,
        /geowebinc.com/i,
        /jobs\@dice\.com/i,
        /autoReply\@dice\.com/i,
        /jagent\@route\.monster\.com/i,
        /\@widenet-consulting.com/i,
        /monster\@e0.monster.com/i
        { ASSIGN list 'jobs'; REJECT MailingList };

<INITIAL> To Cc Sender X-Mn-Key Envelope:
          /lordxandor\@gmail\.com/i
        { ASSIGN list 'tome'; REJECT MailingList };

<INITIAL> From Sender X-Mn-Key Envelope:
 /(xandros)\@reply.exacttarget.com/i
 {
   ASSIGN list 'Xandros-Mailinglist';
   BOUNCE jshardo@mail.golden-gryphon.com;
   REJECT MailingList;
 };

<INITIAL> From Sender Envelope:
 /autoprocessing\@westernunionspeedpay\.com/i,
  /noreply\@nationstar-email\.com/i
          { ANNOTATE -d X-Agent-list 'nationstar';
            ASSIGN list 'nationstar';
            BOUNCE jshardo@mail.golden-gryphon.com;
            REJECT MailingList };


<RETRY,INITIAL> From Sender X-Mn-Key Envelope X-BeenThere:
 /notifications\@transautoemail\.(aetna)\.com/i,
 /deals\@(livingsocial).com/i,
 /service\@(connectyourcare).com/i,
 /(benefits)servicecenter\@ehr\.com/i,
 /BurpeeGardens\@(burpee)\.com/i,
 /burpeeseed\@List\.(burpee)\.com/i,
 /\@(time)online\.delivery\.net/i,
 /custserv\@(burpee)\.com/i
 {
    BOUNCE jshardo@mail.golden-gryphon.com;
    ASSIGN list '%1';;
    REJECT MailingList;
 };

<RETRY, INITIAL> From Sender Envelope: BizBuzz { VACATION: OFF; REJECT JUNK };
<RETRY, INITIAL> From Sender Envelope:
     /\@response\.enterprise-alerts\.com/i,
     /IDGConnect\@idgconnect-resources\.com/i,
     /IDGConnect\@idgconnect-direct\.com/i,
     /Gotham_City_Online\@mail\.vresp\.com/i
     { VACATION: OFF; REJECT JUNK };
#
# all known mailing list expression
#


# Debian Conference
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(debconf)-announce-bounces\@lists\.debconf\.org/i,
 /(debconf)-discuss-bounces\@lists\.debconf\.org/i,
 /(debconf)-discuss\@lists\.debconf\.org/i,
 /(debconf)-team\@lists\.debconf\.org/i,
 /debconf6-speaker-bounces\@lists\.(debconf)\.org/i,
 /(debianbook)-announce-bounces\@lists\.debianbook\.info/i,
 /(debianbook)-announce\@lists\.madduck\.net/i,
 /(tartan)\@hands\.com/i,
 /(dmup)\@golden-gryphon.com/i
 {
   ANNOTATE -d X-Disposition Debian-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Applications
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere List-Post:
 /(agent)-users/i, /(bbdb)-announce/i, /(bbdb)-info/i,
 /(blosxom)\@yahoogroups\.com/i, /\@(adaptiveblue)\.com/i,
 /info\@(dbvis)\.com/i,
 /(c2man)\@research/i, /owner-(c2man)/i,
 /(cryptoapi-devel)-admin\@kerneli.org/i,
 /(crm114-general)\@lists\.sourceforge\.net/i,
 /(crm114-general)-bounces\@lists\.sourceforge\.net/i,
 /(flex-announce)\@lists\.sourceforge\.net/i,
 /(flex-announce)-bounces\@lists\.sourceforge\.net/i,
 /(docbook-tools)\@bazar.conectiva.com.br/i,
 /\@(gasbuddy)email\.com/i,
 /(ding)-owner\@gnus\.org/i, /(ding)-owner\@lists\.math\.uh\.edu/i,
 /(ding)-announce-owner\@lists\.math\.uh\.edu/i, /(ding)-patches\@/i,
 /(ding)-request/i, /(ding)\@gnus\.org/i,
 /(ding)-announce\@gnus\.org/i, /(ding)\@hpc.uh.edu/i,
 /(ding)\@ifi\.uio\.no/i, /(ding)\@lists\.math\.uh\.edu/i,
 /(emacs)-pretesters\@gnu\.org/i,
 /(emacs)-devel\@gnu\.org/i,
 /(flex-help)\@lists\.sourceforge\.net/i,
 /\@(fring)\.com/i,
 /(fvwm-themes-devel)-admin\@lists.sourceforge.net/i,
 /(fvwm)-owner\@lists\.math\.uh\.edu/i, /(fvwm)\@fvwm.org/i,
 /(fvwm)\@lists\.math\.uh\.edu/i,
 /(fvwm-announce)-owner\@lists\.math\.uh\.edu/i,
 /(fvwm-announce)\@fvwm\.org/i,
 /(fvwm-announce)\@lists\.math\.uh\.edu/i,
 /(fvwm-workers)-owner\@lists\.math\.uh\.edu/i,
 /(fvwm-workers)\@fvwm.org/i, /(fvwm-workers)\@lists\.math\.uh\.edu/i,
 /owner-(fvwm)\@fvwm.org/i, /owner-(fvwm-announce)\@fvwm\.org/i,
 /owner-(fvwm-workers)\@fvwm.org/i,
 /(gnu-arch-dev)-request\@gnu.org/i, /(gnu-arch-dev)\@gnu.org/i,
 /(gnu-arch-users)-request\@gnu.org/i, /(gnu-arch-users)\@gnu.org/i,
 /newsletter\@(joomla)news\.ro/i,
 /app\@(getglue)\.com/i,
 /(listar)-announce\@listar.org/i, /(listar)-support\@listar.org/i,
 /(log4perl-devel)-admin\@lists.sourceforge.net/i,
 /(mason-devel)\@geek-speak.net/i,
 /(mason-devel)\@mail.ists.dartmouth.edu/i,
 /(mason-help)\@geek-speak.net/i,
 /(mason-help)\@mail.ists.dartmouth.edu/i,
 /owner-(mason-devel)\@geek-speak.net/i,
 /owner-(mason-help)\@geek-speak.net/i,
 /(multi-tty)-bounces\@lists\.fnord\.hu/i,
 /(pcgen)-users\@lists.sourceforge.net/i,
 /(psgml-devel)-admin\@lists.sourceforge.net/i,
 /(psgml-devel)\@lists.sourceforge.net/i,
 /(psgml-user)-admin\@lists.sourceforge.net/i,
 /(psgml-user)\@lists.sourceforge.net/i,
 /gnu\.emacs\.(vm.info)\@googlegroups\.com/i,
 /gnu\.emacs\.(vm.bug)\@googlegroups\.com/i,
 /linux-(diald)\@vger\.rutgers\.edu/i,
 /noreply\@noreply\.(calorieking)\.com/i,
 /owner-updates\@lists.(spambouncer).org/i,
 /(refpolicy)\@oss1\.tresys\.com/i,
 /(refpolicy)\@oss\.tresys\.com/i,
 /(refpolicy)-bounces\@oss1\.tresys\.com/i,
 /(refpolicy)-request\@oss1\.tresys\.com/i,
 /(mailman)-owner\@lists\.bestpractical\.com/i,
 /no-reply-(amazonpayments)\@amazon\.com/i,
 /auto-(confirm)\@amazon\.com/i,
 /order-(update)\@amazon\.com/i,
 /(ship)-confirm\@amazon\.com/i,
 /(prime)\@amazon\.com/i,
 /TrackingUpdates\@(fedex)\.com/i,
 /(r-help)-bounces\@r-project\.org/i,
 /(r-help)\@r-project\.org/i,
 /(rt-users)\@lists\.bestpractical\.com/i,
 /(rt-users)-bounces\@lists\.bestpractical\.com/i,
 /(rt-devel)\@lists\.bestpractical\.com/i,
 /(rt-devel)-bounces\@lists\.bestpractical\.com/i,
 /(selinux-commits)-request\@oss1\.tresys\.com/i,
 /support\@(cacert)\.org/i,
 /certmaster\@(startcom)\.org/i,
 /updates\@lists.(spambouncer).org/i,
 /(vdt-discuss)-request\@LISTSERV\.FNAL\.GOV/i,
 /(vdt-support)\@OPENSCIENCEGRID\.ORG/i,
 /announcement\@(normsoft)\.com/i,
 /owner-(vdt-discuss)\@OPENSCIENCEGRID\.ORG/i,
 /owner-(vdt-support)\@OPENSCIENCEGRID\.ORG/i,
 /(ddt)-announce-admin\@lists.sourceforge.net/i,
 /(ddt)-user-admin\@lists.sourceforge.net/i,
 /(latex2html)/i,
 /announce-bounces\@www1\.(codeweavers)\.com/i,
 /store\@(codeweavers)\.com/i,
 /news\@(qik)\.com/i,
 /info-(bbdb)/i,
 /(dist)-users/i,
 /owner-(dist)-users/i {
   ANNOTATE -d X-Disposition App-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Social
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(newmembers)\@batchmates\.com/i,
 /administrator\@alumni\.(iitkgp)\.ernet\.in/i,
 /all-alumni-bounces\@oit\.(umass)\.edu/i,
 /enginalumni\@(umass).edu/i,
 /giving\@(umass).edu/i,
 /alumnikgp\@alumni\.(iitkgp)\.ernet\.in/i,
 /alumni\@hijli.(iitkgp).ernet.in/i,
 /alumnet\.(iitkgp)\@gmail\.com/i,
 /\@hijli\.(iitkgp)\.ernet\.in/i,
 /(iitalum)1\@gmail\.com/i,
 /directory\@(iitfoundation).org/i,
 /do-not-reply\@(iitfoundation).org/i,
 /\@(iit)\.org/i,
 /news\@(iit)\.org/i,
 /newsletter\@(iit)\.org/i,
 /\@(iit)2013\.org/i,
 /annualfund\@admin\.(umass)\.edu/i,
 /newsletter\@(alumni)\.net/i,
 /(summer-admin)-announce-2006\@googlegroups\.com/i,
 /community\@lists\.(leastsquar)\.es/i,
 /umalumni\@admin\.(umass)\.edu/i,
 /pointsofpride\@ecs\.(umass)\.edu/i,
 /demers\@ecs\.(umass)\.edu/i,
 /alumni\@admin\.(umass)\.edu/i,
 /giving\@(umass)\.com/i,
 /noreply\@(umass)\.com/i,
 /\@engin\.(umass)\.edu/i,
 /enginalumni\@(umass)\.com/i,
 /admin\@admin\.(umass)\.edu/i
 {
   ANNOTATE -d X-Disposition Alumni-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /hi\@mail\.stackcommerce\.com/i
 {
   ANNOTATE -d X-Disposition Alumni-Mailinglist;
   ASSIGN list 'androidcommunity';
   REJECT MailingList
 };

# Trade mags
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /\@(androidcommunity)\.com/i,
 /\@(androidauthority)\.com/i,
 /\@email\.(americastestkitchen)\.com/i,
 /\@(archana)skitchen\.com/i,
 /\@(computerworld)\.com/i,
 /\@(huffingtonpost)\.com/i,
 /\@.*\.(computerworld).com/i,
 /\@(automotiveforums)\.com/i,
 /\@cwsales\.(computerworld).com/i,
 /\@cwflyris\.(computerworld)\.com/i,
 /\@cwonline\.(computerworld)\.com/i,
 /\@newsletters\.(nationalgeographic)\.com/i,
 /\@(washingtontechnology)\.org/i,
 /research\@response\.(techsurvey)research\.com/i,
 /apc\@(apc)\.chtah\.com/i,
 /newsletter\@email\.(saveur)\.com/i,
 /\@inside-(erp).com/i,
 /\@(bzmedia)\.com/i,
 /\@(developer)\.com/i,
 /\@info\.(cmptech)direct\.com/i,
 /\@online\.(cmptech)resource\.com/i,
 /\@events\.(cmptech)resource\.com/i,
 /\@(techweb)resources\.com/i,
 /\@(techweb)\.com/i,
 /overlords\@email\.(thinkgeek)\.com/i,
 /overlords\@(thinkgeek)\.com/i,
 /orders\@(thinkgeek)\.com/i,
 /\@e\.(nationalgeographic)\.com/i,
 /\@email\.(walgreens)\.com/i,
 /(software)_magazine\@mail\.vresp\.com/i,
 /info\@(software)mag\.com/i,
 /online_resources\@online\.(itwhitepapers)\.com/i,
 /\@e\.(techweb)resources\.com/i,
 /(ddj)\@newsletters\.sdmediagroup\.com/i,
 /(ddj)\@techwebnewsletters\.com/i,
 /(cmpmedia)\@newsletter\.smallbizresource\.com/i,
 /IDGConnect\@(idgconnect)-resources\.com/i,
 /(itworld)\@.*itwpub1.com/i,
 /(smithsonian)\@customersvc\.com/i,
 /\@mail\.(smithsonianmag)\.com/i,
 /newsletters\@(gamespot)\.online\.com/i,
 /\@(seekingalpha)\.com/i,
 /\@itwonline\.(itworld).com/i,
 /joel\@(joelonsoftware)\.com/i,
 /(networkworld)\@nwwsubscribe\.com/i,
 /newsletters\@response\.(eweek)\.com/i,
 /subscribe\@(eweek)-renew\.com/i,
 /subscribe\@(cioinsight)-renew\.com/i,
 /research\@(cioinsight)-zannounce\.com/i,
 /\@m\.(information-management)\.com/i,
 /(informationweek)\@whitepapers\.techwebresources\.com/i,
 /(informationweek)\@techwebwhitepapers\.com/i,
 /\@update\.(informationweek)\.com/i,
 /customerservice\@(informationweek)\.com/i,
 /(informationweek)\@subscriptions\.cmptechresource\.com/i,
 /infosecnewswire\@(scmagazine)\.com/i,
 /nwinfo\@(networkworld)\.info/i,
 /(sysadmin)magazine\@newsletters\.sdmediagroup\.com/i,
 /(sysadmin)\@promos\.sdmediagroup\.com/i,
 /(unixreview)\@newsletters\.sdmediagroup\.com/i,
 /no-reply\@mail\.(goodreads)\.com/i,
 /no-reply\@(goodreads)\.com/i,
 /wbg\@enews\.(webbuyersguide)\.com/i,
 /newsletters\@response\.(webbuyersguide)\.com/i,
 /ciominute\@enews\.(cioinsight)\.com/i,
 /\@eletters\.(whatsnewnow)\.com/i,
 /ITworld.com\@itw\.(itworld)\.com/i,
 /\@(networksolutions)\.com/i,
 /InfoWeek\@update\.(informationweek)\.com/i,
 /IK\@events\.(informationweek)\.com/i,
 /(informationweek)\@.*\.cmptechnetwork\.com/i,
 /(informationweek)\@research\.cmptechresource\.com/i,
 /(informationweek)\@online\.cmptechresource\.com/i,
 /\@.*\.(cmptech)network\.com/i,
 /NC\@events\.(networkcomputing)\.com/i,
 /newsletters\@(sfgate).com/i,
 /NetworkComputing\@update.(networkcomputing)\.com/i,
 /nwonline\@online\.(networkworld)\.info/i,
 /bestofeweek\@(eweek)-zannounce\.com/i,
 /(crn)\@onlineevents\.cmptechnetwork\.com/i,
 /subscribe\@(eweek)-info\.com/i,
 /newsletters\@(scmagazine)us\.com/i,
 /\@enews\.(eweek)\.com/i,
 /(swmg)\@e-circ\.net/i,
 /\@(eweek)-zannounce\.com/i,
 /\@newsletter\.(infoworld)\.com/i,
 /\@ifwnewsletters\.newsletters\.(infoworld)\.com/i,
 /email\@(seesmic)\.cccampaigns\.net/i,
 /(sdtimes)\@bz-direct\.com/i,
 /(softwaretest)\@bz-direct\.com/i,
 /\@ifwonline\.(infoworld)\.com/i,
 /\@ifwonline\.newsletters\.(infoworld)\.com/i,
 /\@ifnewsletters\.newsletters\.(infoworld)\.com/i,
 /enewsandviews\@enews\.(eweek)\.com/i,
 /enterprisestrategies\@newsletter\.(infoworld)\.com/i,
 /from_the_analysts\@newsletter\.(infoworld)\.com/i,
 /government\@enews\.(eweek)\.com/i,
 /\@newsletter\.(northerntool)\.com/i,
 /\@(ifw)-media\.com/i,
 /iwdaily\@newsletter\.(infoworld)\.com/i,
 /iwdaily\@newsletter\.(infoworld)\.com/i,
 /linuxreport\@newsletter\.(infoworld)\.com/i,
 /news\@(idevnews)\.com/i,
 /nwinfo\@(networkworld)\.info/i,
 /openenterprise\@newsletter\.(infoworld)\.com/i,
 /realitycheck\@newsletter\.(infoworld)\.com/i,
 /wired\@email\.(wired)\.com/i,
 /wired\@email\.(wired)magazine\.com/i,
 /subscriptions\@email\.(wired)\.com/i,
 /\@(wired)\.com/i,
 /Wired_Promotions\@(wired)\.messages2\.com/i,
 /wired\@email\.(wired)magazine\.com/i,
 /wir\@(wired)-email\.com/i,
 /voip\@enews\.(eweek)\.com/i
 {
   ANNOTATE -d X-Disposition Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

#Linux
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(linux-dce)-list\@bu.edu/i,
 /(linux-india)\@lists\.linux-india\.org/i,
 /(linux-kernel)-digest/,
 /(linux-kernel)-owner\@vger.kernel.org/,
 /(linux-kernel)/,
 /(linux-kernel)\@vger.kernel.org/,
 /(vcs-pkg)\@lists\.madduck\.net/i,
 /(vcs-pkg)-discuss\@lists\.alioth\.debian\.org/i,
 /(backports-users)\@lists\.backports\.org/i,
 /owner-(linux-india-general)\@aunet\.org/i,
 /owner-(linux-kernel)-digest\@vger.rutgers.edu/,
 /(linux-india)\@aunet\.org/i,
 /(linux-india-\w+)\@lists\.linux-india\.org/i,
 /(linux-india-general)\@aunet\.org/i,
 /owner-(linux-india)\@aunet.org/i
 {
   ANNOTATE -d X-Disposition Linux-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Security
# Cryptogram
<RETRY,INITIAL> Sender Reply-To: /schneier\@SCHNEIER.COM/i,
                                 /schneier\@COUNTERPANE.COM/i,
                        Subject: /CRYPTO-GRAM/
  {
   ANNOTATE -d X-Disposition Security-Mailinglist;
   ASSIGN list 'crypto-gram';
   REJECT MailingList
 };

<RETRY,INITIAL> From To Cc Sender List-Id X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(cert)-advisory\@.*cert\.org/i,
 /(infosec)newswire\@westcoast\.com/i,
 /\@(sans)\.org/i,
 /(crypto-gram)-list\@listserv\.modwest\.com/i,
 /(crypto-gram)-list\@schneier\.com/i,
 /(labeled-nfs)\@linux-nfs\.org/i,
 /(labeled-nfs)-bounces\@linux-nfs\.org/i,
 /(selinux-announce)-bounces\@lists\.alioth\.debian\.org/i,
 /(selinux-devel)-bounces\@lists\.alioth\.debian\.org/i,
 /(selinux-devel)\@lists\.alioth\.debian\.org/i,
 /(selinux-user)-bounces\@lists\.alioth\.debian\.org/i,
 /(selinux-user)\@lists\.alioth\.debian\.org/i,
 /owner-(selinux)\@tycho.nsa.gov/i,
 /(selinux)\@tycho\.nsa\.gov/i,
 /announce-bounces\@(selinux-symposium)\.org/i,
 /paper-committee\@(selinux-symposium)\.org/i,
 /ConsensusSecurityVulnerabilityAlert\@(sans)\.org/i,
 /security\@enews\.(eweek)\.com/i,
 /securityadviser\@newsletter\.(infoworld)\.com/i,
 /announce\@(selinux-symposium)\.org/i,
 /bounce\@mailings\.(sans)\.org/i,
 /summit-bounces\@(selinux-symposium)\.org/i,
 /summit\@(selinux-symposium)\.org/i
 {
   ANNOTATE -d X-Disposition Security-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Societies
<RETRY,INITIAL> From X-Sender To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /renewal_receipt\@(acm)\.org/i,
 /(acm)-pdc-announce\@ACM.ORG/i,
 /(acm)bulletin\@ACM\.ORG/i,
 /learning\@(acm)\.org/i,
 /\@hq.(acm)\.org/i,
 /(acm)help@electionservicescorp.com/i,
 /william\@(gslug)\.org/i,
 /gslug-announce\@(gslug)\.org/i,
 /gslug-general\@(gslug)\.org/i,
 /bagley_rep\@(acm)\.org/i,
 /pervasive\@(computer)\.org/i,
 /csconnection\@(computer)\.org/i,
 /csnews\@(computer)\.org/i,
 /membervalue\@(computer)\.org/i,
 /membernet\@hq\.(acm)\.org/i,
 /mn-subscribers\@listserv\.(acm)\.org/i,
 /(acm)-bulletin\@ACM\.ORG/i,
 /communicationssociety\@(comsoc).org/i,
 /(communications)-digital-edition@acm.org/i,
 /meetings\@(comsoc)\.org/i,
 /Reader_Survey\@(computer)\.org/i,
 /ieee-seattle\@listserv\.(ieee)\.org/i,
 /k\.mccabe\@(ieee)\.org/i,
 /\@bmsmail3\.(ieee)\.org/i,
 /orderconfirmation\@(ieee)\.org/i,
 /enotice\@(ieee)\.org/i,
 /(ieee)-enotice\@ieee\.org/i,
 /(ieee)usa\@readexsurvey\.com/i,
 /(ieee)vote\@directvote\.net/i,
 /(ieee)csvote\@directvote\.net/i,
 /pes\@(ieee)\.org/i,
 /\@(quora)\.com/i,
 /\@lists\.(sasag)\.org/i,
 /(techalert)@ieee\.org/i,
 /\@info1\.(ieee)\.org/i,
 /tialert\@(ieee)\.org/i,
 /eds-members\@listserv\.(ieee)\.org/i,
 /IEEE-Annual-Election\@(ieee)\.org/i,
 /IEEEservice\@(ieee)\.org/i,
 /IEEECBP\@info1\.(ieee)\.org/i,
 /IEEE\@info1\.(ieee)\.org/i,
 /IEEEservice\@(ieee)\.org/i,
 /\@(ieee)standards\.org/i,
 /ieee-sa-exec\@(ieee)\.org/i,
 /ieee-computervote\@(ieee)\.org/i,
 /ieee-edsvote\@(ieee)\.org/i,
 /noreply\@(ieee)\.org/i,
 /pes\@(ieee)\.org/i,
 /uce-admin\@(ieee).org/i,
 /ou-evoting\@(ieee)\.org/i,
 /(ieee)seattle4\@gmail\.com/i,
 /\@mail\.(jetsetter)\.com/i,
 /q.brown\@(ieee)\.org/i,
 /(froggodgames)\@gmail\.com/i,
 /(psppy)-announce\@meetup\.com/i,
 /(psppy)-list\@meetup\.com/i,
 /(pugetsoundpythonprogramming)-announce\@meetup.com/i,
 /(pugetsoundpythonprogramming)-list\@meetup.com/i,
 /info\@(meetup)\.com/i,
 /\@(cmg)\.org/i,
 /\@q(mags)\.com/i,
 /\@q(mags)delivery\.com/i,
 /newsletters\@(the-scientist)\.com/i,
 /\@strongmail\.(the-scientist)\.com/i,
 /buildyourcareer\@(computer)\.org/i,
 /cacs\@(cacs)2010\.org/i,
 /candidate(jobs)ite\@ieee\.org/i,
 /careernavigator\@(ieee)\.org/i,
 /computerwise\@(ieee)\.org/i,
 /computing_now\@(computer)\.org/i,
 /conference-services\@(ieee)\.org/i,
 /corporate-communications\@(ieee)\.org/i,
 /csdl-newsletter\@(computer)\.org/i,
 /ieee-career-alert\@(ieee)\.org/i,
 /ieeemdl-help\@(ieee)\.org/i,
 /l\.book\@(ieee)\.org/i,
 /no-reply\@(ieee)\.org/i,
 /owner-(ieee)-e-notice\@bmsmail3.ieee.org/i,
 /owner-(ieee-centraltn)-members\@list\.vanderbilt\.edu/i,
 /owner-ieee-e-notice\@bmsmail3.(ieee)\.org/i,
 /owner-institute-news\@boldfish\.(ieee)\.org/i,
 /owner-theinstitute-news\@bmsmail3\.(ieee)\.org/i,
 /roboticnews\@(ieee)\.org/i,
 /special-mailing\@(ieee)\.org/i,
 /techinsider\@(ieee)\.org/i,
 /the-institute\@(ieee).org/i,
 /todaysengineer\@(ieee)\.org/i,
 /visibility\@(ieee)\.org/i,
 /vtools-voting\@(ieee)\.org/i,
 /membernet\@hq\.(acm)\.org/i,
 /\@(usenix)\.org/i,
 /Rudi\.van\.Drunen\@(usenix)\.org/i,
 /Thomas].Limoncelli\@(usenix)\.org/i,
 /Clem\.Cole\@(usenix)\.org/i,
 /Wilson\.Hsieh\@(usenix)\.org/i,
 /Brent\.Hoon\.Kang\@(usenix)\.org/i,
 /anne\@(usenix)\.org/i,
 /Adam\.Moskowitz\@(usenix)\.org/i,
 /Anne\.Dickison\@(usenix)\.org/i,
 /Anne_Dickison\@(usenix)\.org/i,
 /Mike_Swift\@(usenix)\.org/i,
 /Jeff_Chase\@(usenix)\.org/i,
 /Paul_Anderson\@(usenix)\.org/i,
 /office\@(usenix)\.org/i,
 /pd\@(acm)\.org/i,
 /(technews)\@.acm\.org/i,
 /(technews)\@.*\.acm\.org/i,
 /enotice\@(ieee)\.org/i,
 /simone\.darby\@(ieee)\.org/i,
 /the-institute\@(ieee)\.org/i,
 /Erez\.Zadok\@(usenix)\.org/i,
 /Ethan\.Miller\@(usenix)\.org/i,
 /Gautam\.Singaraju\@(usenix)\.org/i,
 /C.Rowland\@(usenix)\.org/i,
 /tipservice\@(acm)\.org/i
 {
   ANNOTATE -d X-Disposition prof-soc-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Politics
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /info\@(barackobama)\.com/i,
 /\@(dailykos)\.com/i,
 /\@(voiceson)-resources\.com/i,
 /info\@(dscc)\.org/i,
 /anna\.galland\@(moveon)\.org/i,
 /\@list\.(moveon)\.org/i,
 /info\@(barackobama)\.com/i,
 /bart\.(gordon)@mail\.house\.gov/i,
 /\@(corker)\.enews\.senate\.gov/i,
 /\@(washingtoncan)\.org/i,
 /\@(povertylaw)\.org/i,
 /\@(dga)\.net/i,
 /avaaz\@(avaaz)\.org/i,
 /\imawa09@mail\.house\.(gov)/i,
 /\@(berniesanders)\.com/i,
 /\@(actblue)\.com/i,
 /info\@(hillaryclinton)\.com/i
 {
   ANNOTATE -d X-Disposition prof-soc-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Charities
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /\@the(noah)center\.org/i,
 /\@(redcross)\.org/i,
 /redcross-email\@usa\.(redcross)\.org/i,
 /redcross-email\@(redcross)\.org/i,
 /chapter\@hot-(redcross)\.org/i,
 /\@(kplu)\.org/i,
 /\@(northwestharvest)\.org/i,
 /\@(msf)\.org/i,
 /\@newyork\.(msf)\.org/i,
 /\@(kuow)\.org/i,
 /communication\@(kplu)\.org/i,
 /\@(doctorswithoutborders).org/i,
 /\@student\.(umass)\.edu/i,
 /\@(scholarshipamerica)\.org/i,
 /\@ecs\.(umass)\.edu/i,
 /\@admin\.(umass)\.edu/i,
 /sierraclub\.giving\@(sierraclub).org/i,
 /\@(givedirect)\.org/i,
 /\@(biologicaldiversity)\.org/i,
 /\@(sierraclub)\.org/i,
 /\@washington\.(sierraclub)\.org/i,
 /newsletter\@(mercycorps)\.org/i,
 /\@(feedingamerica)\.org/i,
 /\@(joslin)\.harvard\.edu/i,
 /(joslin)diabetescenter\@cmarket\.org/i,
 /MakingNoise\@(diabetes)\.org/i,
 /managing(diabetes)\@EverydayHealth\.com/i,
 /info\@(hillpac)\.com/i,
 /\@(secondharvest)\.org/i,
 /newsletter\@(tnc)\.org/i,
 /member\@(nature)\.org/i,
 /info\@(hungeraction)center\.org/i,
 /ecomments\@(wwf)us\.org/i,
 /member\@(tnc)\.org/i,
 /email\@(unicef)usa\.org/i,
 /\@email\.(unicef)usa\.org/i,
 /development\@(path)\.org/i,
 /events\@(path)\.org/i,
 /publications\@(path)\.org/i,
 /(umass)\@element\.cc/i,
 /oldchapel\@library\.(umass)\.edu/i,
 /insider\@(sierraclub).org/i
 {
   ANNOTATE -d X-Disposition prof-soc-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /showtime\@(sho)\.delivery\.net/i
 {
   ASSIGN list %1;
   BOUNCE jshardo@mail.golden-gryphon.com;
   REJECT MailingList
 };

<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /\@e\.(redbox)\.com/i, Subject: /Redbox new releases for /
 {
   ANNOTATE -d X-Disposition Services-Mailinglist;
   ASSIGN list '%1';
   BOUNCE jshardo@mail.golden-gryphon.com;
   REJECT MailingList
 };
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /\@e\.(redbox)\.com/i,
 /receipts\@(redbox)dvd\.net/i,
 /returns\@(redbox)dvd\.net/i
 {
   ANNOTATE -d X-Disposition Services-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

<INITIAL> From Sender X-Return-Path Envelope X-Envelope-From:
 /^(\S+)\@noreply.github.com/
 {
   ANNOTATE -d X-Disposition GitHub-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };


<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /notifications\@(github)\.com/i
 {
   REJECT GITHUB
 };

 <GITHUB> Subject: /^\s*\[(\S+)\] /
 {
   ANNOTATE -d X-Disposition GitHub-Mailinglist;
   ASSIGN list '%1';
   SUBST #list /^[^\/]+\///gi;
   REJECT MailingList
 };

<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /donotreply-(\S+)\@ndr.mysecurebill.com/i
 {
   ASSIGN list '%1';
   REJECT MailingList
 };

# Services
<RETRY,INITIAL> From To Cc Reply-To Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /\@(asurion)\.com/i,
 /(cash)\@square\.com/i,
 /\@(charitynavigator)\.org/i,
 /\@.*\.(alliant)creditunion\.com/i,
 /\@email-(becu)\.org/i,
 /\@(wahbexchange)\.org/i,
 /\@(wageworks)\.com/i,
 /\@e\.(hertz)usa\.brierleycrm\.com/i,
 /\@theatre\.info\.(cinemark)\.com/i,
 /Member\.experience\@survey\.(firsttech)fed\.com/i,
 /Memberexperience\@survey\.(firsttech)fed\.com/i,
 /alerts\@(firsttech)fed\.com/i,
 /\@(betterment)\.com/i,
 /\@the(cpap)shop.com/i,
 /\@(pulseservers)\.com/i,
/\@(growingwashington)\.org/i,
 /\@(a2z)-insurance\.com/i,
 /\@(firsttech)fed\.com/i,
 /member\.communications\@(firsttech)fed\.com/i,
 /memberservice\@billpayment\.(firsttech)fed\.com/i,
 /memberservice\@(firsttech)fed\.com/i,
 /\@(firsttech)fed\.com/i,
 /\@billpayment\.(firsttech)fed\.com/i,
 /\@(beamanauto)\.com/i,
 /\@(beamanauto)\.dealercrm\.com/i,
 /email\@only(mytoyota)\.com/i,
 /\@(toyota)ofbellevue\.com/i,
 /(michaelstoyota)ofbellevue\@mydealerevent\.com/i,
 /(michaelstoyota)ofbellevue\@mydealerreminder\.com/i,
 /sales\@(toyota)ofbellevue\.com/i,
 /searscardissuedby(citi)bank\@info\.searscard\.com/i,
 /searscardissuedby(citi)bank\@info[0-9]?\.searscard\.com/i,
 /info\@(fatsecret)\.com/i,
 /\@(dyne)\.com/i,
 /(aws)-marketing-email-replies\@amazon\.com/i,
 /no-reply-(aws)\@amazon\.com/i,
 /no-try-to-reply\@(amazon)\.com/i,
 /account-update\@(amazon)\.com/i,
 /\@marketplace\.(amazon)\.com/i,
 /magazine\@email\.(saveur)\.com/i,
 /spider\@(biglumber)\.com/i,
 /\@(steam)powered.com/i,
 /\@(jimmyjohns)\.com/i,
 /\@(urbanspoon)\.com/i,
 /\@(homedepot)\.com/i,
 /\@email\.(homedepot)\.com/i,
 /\@deals\.(tripadvisor)\.com/i,
 /\@e\.(tripadvisor)\.com/i,
 /\@(wallypark)\.com/i,
 /(wallypark)\@usdm\.messages2\.com/i,
 /\@go(sphero).com/i,
 /\@mail\.(synchronybank)\.com/i,
 /\@mail\.(orvis)\.com/i,
 /\@(pininterest).com/i,
 /\@(sendgrid)\.net/i,
 /(dolrenewal)reminder\@dol\.wa\.gov/i,
 /(step)-notifications\@state.gov/i,
 /support\@(steam)powered.com/i,
 /Billing\@(relianceglobalcall).com/i,
 /Customercare\@(relianceindiacall)\.com/i,
 /NRIBulkEmail\@(relianceindiacall)\.com/i,
 /customercare\@(relianceglobalcall)\.com/i,
 /customercare\@(relianceglobalcalls)\.com/i,
 /customercare\@(relianceindiacall)\.co\.uk/i,
 /customercare\@(relianceindiacall)\.com/i,
 /relianceglobalcall\@(relianceglobalcall)\.com/i,
 /webmaster\@(relianceindiacall)\.com/i,
 /\@messages\.(xoom)\.com/i,
 /\@(xoom)\.com/i,
 /\@reply\.service\.sp\.(xoom)\.com/i,
 /CSA-noreply\@(comcast)\.net/i,
 /comcast\@(comcast)\.delivery\.net/i,
 /Comcast_Paydirect\@(comcast)\.net/i,
 /CustomerSupport\@(standardparking).com/i,
 /\@alerts\.(comcast)\.net/i,
 /\@(dyn)\.com/i,
 /\@(nationstar)mail\.com/i,
 /support\@(dyn)dns\.com/i,
 /research\@(focus)\.com/i,
 /\@email\.(aetna)\.com/i,
 /\@(aetna)\.com/i,
 /email\@comms\.(dyson)\.com/i,
 /\@(mint)\.com/i,
 /\@(republicservices)\.com/i,
 /postman\@(dopplr)\.com/i,
 /technical-alerts\@(us-cert)\.gov/i,
 /\@ncas\.(us-cert)\.gov/i,
 /\@email\.(carecredit)\.com/i,
 /billpay\@(disposal)\.com/i,
 /\@ifly\.(alaskaair)\.com/i,
 /\@email\.(continental)\.com/i,
 /americanairlines\@aadvantage\.email\.(aa)\.com/i,
 /americanairlines\@email\.(aa)\.com/i,
 /\@contact\.(britishairways)\.com/i,
 /\@(britishairways)\.com/i,
 /\@my\.(ba)\.com/i,
 /\@e\.(milesandmore)\.com/i,
 /\@newsletter\.(milesandmore)\.com/i,
 /continentalairlines\@email\.(continental)\.com/i,
 /dollarrentacar\@email\.(dollar)\.com/i,
 /\@markit\.(schwab).com/i,
 /schwabalerts\.service\@(schwab)\.com/i,
 /schwabalerts\@(schwab)\.com/i,
 /\@(carezone)\.com/i,
 /online\.service\@(schwab)\.com/i,
 /\@(schwab)\.com/i,
 /\@luv\.(southwest).com/i,
 /\@(tivo)\.com/i,
 /\@email\.(glassdoor)\.com/i,
 /reply\@(glassdoor)\.com/i,
 /\@(emolument)\.com/i,
 /reply\@emails\.(lq)\.com/i,
 /reservations\@(laquinta)\.com/i,
 /tivo\@info\.(tivo)\.com/i,
 /tivo\@email\.(tivo)\.com/i,
 /tivo\@mkmail\.(tivo)\.com/i,
 /\@email\.(siriusxm)\.com/i,
 /support\@(tripit).com/i,
 /MemberUpdate\@e\.(tripadvisor)\.com/i,
 /petperks\@(petsmart)-mail\.com/i,
 /petperks\@mail01-(petsmart)\.com/i,
 /reply\.to\@(dlink)\.com/i,
 /PlayStation_Network\@(playstation)-email\.com/i,
 /DoNotReply\@ac\.(playstation)\.net/i,
 /PlayStation_Network\@(playstation)\.innovyx\.net/i,
 /dell\@dellhome\.usa\.(dell)\.com/i,
 /\@(pugetsystems)\.com/i,
 /\@smb\.(dell)\.com/i,
 /\@(dell)\.com/i,
 /dfb\@(dell)\.delivery\.net/i,
 /\@email\.(washingtonpost)\.com/i,
 /\@wellsconnect\.(wellsfargo)\.com/i,
 /\@(slavic)\.net/i,
 /\@(clicktime)\.com/i,
 /\@(hertz)\.com/i,
 /\@news\.(fileplanet)\.com/i,
 /FilePlanetWeekly\@em\.(fileplanet)\.com/i,
 /\@mail\.(etrade)financial\.com/i,
 /\@statement\.(etrade)financial\.com/i,
 /\@(etrade)\.com/i,
 /(travelinfo)\@state.gov/i,
 /fidelity\.investments\.email\@(fidelity)\.com/i,
 /\@email\.(fidelity)\.com/i,
 /\@mail\.(fidelity)\.com/i,
 /\@(Fidelity)\.com/i,
 /\@(foursquare)\.com/i,
 /nytdirect\@(nytimes)\.com/i,
 /(nytimes)\@email\.newyorktimes\.com/i,
 /support\@the(levelup)\.com/i,
 /\@(pinterest)\.com/i,
 /\@postmaster\.(twitter)\.com/i,
 /\@email\.(personalcapital)\.com/i,
 /\@(personalcapital)\.com/i,
 /\@(wealthfront)\.com/i,
 /Quicken@(intuit)\.com/i,
 /\@e\.quicken\.(intuit)\.com/i,
 /TurboTax\@renew\.(turbotax)\.com/i,
 /TurboTax\@e\.(turbotax)\.intuit\.com/i,
 /Vanguard\@(vanguard)\.com/i,
 /Participant_Education\@eonline\.e(vanguard)\.com/i,
 /ParticipantServices\@(vanguard).com/i,
 /retirementplans\@education\.(vanguard)investments\.com/i,
 /vanguard\@eonline\.e(vanguard)\.com/i,
 /vanguardinvestments\@(vanguard).com/i,
 /service\@(stumble)upon\.com/i,
 /\@(stumble)mail\.com/i,
 /\@mail\.(stumble)mail\.net/i,
 /\@online\.(costco)\.com/i,
 /\@luv\.(southwest)\.com/i,
 /service\@(kayak)\.com/i,
 /alert\@(kayak)\.com/i,
 /noreply\@email\.(driverside)\.com/i,
 /news\@news\.(kayak)\.com/i,
 /\@(kayak)\.com/i,
 /news\@email\.(kayak)\.com/i,
 /\@(pacsci)\.org/i,
 /\@alertsp\.(chase)\.com/i,
 /\@emailonline\.(chase)\.com/i,
 /\@emailinfo\.(chase)\.com/i,
 /\@email\.(chase)\.com/i,
 /\@emailnotify\.(chase)\.com/i,
 /\@notify\.(chase)\.com/i,
 /\@emails\.(chase)\.com/i,
 /\@alerts\.(chase)\.com/i,
 /\@online\.(costco)\.com/i,
 /orderstatus\@(costco).com/i,
 /customerservice\@(costco).com/i,
 /\@delivery\.(bankofamerica)\.com/i,
 /noreply\@account\.(plaxo)\.com/i,
 /noreply-(android-market)\@google\.com/i,
 /(location)-noreply\@google\.com/i,
 /noreply\@mail\.(goodreads)\.com/i,
 /news-(googleplay)\@google\.com/i,
 /(googleplay)-noreply\@google\.com/i,
 /\@(wallet)\.google\.com/i,
 /\@(accounts)\.l\.google\.com/i,
 /\@(accounts)\.google\.com/i,
 /info\@specialoffers\.(citi)cards\.com/i,
 /citicards\@(citi)bank\.delivery\.net/i,
 /citicards\@info.?\.(citi)bank\.com/i,
 /citicards\@info.?\.(citi)\.com/i,
 /citicards\@info?\.(citi)\.com/i,
 /\@info\.(citi)bank\.com/i,
 /alerts\@(citi)bank\.com/i,
 /\@info\.(sears)card\.com/i,
 /\@info2\.(sears)card\.com/i,
 /circulation\@response.(ziffdavis)enterprisecirc\.com/i,
 /\@(ontheroad)\.to/i,
 /(americanexpress)\@welcome\.aexp\.com/i,
 /\@.*\.(americanexpress).com/i,
 /(americanexpress)\@amex-email\.mar0\.net/i,
 /(creditsecure)\@exprpt.com/i,
 /(creditsecure)\@amex\.exprpt\.com
 /(protectmyid)\@exprpt\.com/i,
 /dell\@outlethome\.usa\.(dell)\.com/i,
 /\@parts\.usa\.(dell)\.com/i,
 /Cristina_Welhoelter\@(dell)\.com/i,
 /(discovercard)\@service\.discovercard\.com/i,
 /(discovercard)\@email\.discovercard\.com/i,
 /discover\@email.(discover)\.com/i,
 /discover\@service\.(discover)\.com/i,
 /eBay\@reply1\.(ebay)\.com/i,
 /\@offers.(brookstone).com/i,
 /\@.*\.(united)\.com/i,
 /\@(naymz)\.com/i,
 /\@mail\.(instagram)\.com/i,
 /\@(twitter)\.com/i,
 /\@(facebook)mail\.com/i,
 /fancast\@(fancast)\.delivery\.net/i,
 /noreply\@(identi)\.ca/i,
 /communications\@(goairportshuttle)\.com/i,
 /support\@(pragprog)\.com/i,
 /Support\@(creditsecure)\.com/i,
 /support\@(domaindiscover)\.com/i,
 /infoemail\@(theplanet)\.com/i,
 /\@(theplanet)\.com/i,
 /\@(softlayer)\.com/i,
 /\@email.(gemoney).com/i,
 /(drsimon)@websystem2\.com/i,
 /\@(fandango)\.com/i,
 /\@(pageonce)\.com/i,
 /\@email\.(opentable)\.com/i,
 /\@insider\.(opentable)\.com/i,
 /\@(opentable)\.com/i,
 /Maggianos\@(maggianos)\.fbmta\.com/i,
 /\@(nashvillezoo)\.org/i,
 /yourflyer\@(gazaro)\.com/i,
 /PalmInc\@News\.(palm)newsletters\.com/i,
 /noreply\@(github)\.com/i,
 /support\@(github)\.com/i,
 /noreply\@(sourceforge)\.net/i,
 /no-reply\@mailer\.(last)\.fm/i,
 /noreply\@(myopenid)\.com/i,
 /Directv\@(directv)\.com/i,
 /Directv\@(directv)\.quris\.net/i,
 /noreply-(orkut)\@google\.com/i,
 /\@mail\.(orkut)\.com/i,
 /ebill\@(directv)\.com/i,
 /ebpp\@(dtccom)\.net/i,
 /\@(GMACBank)\.com/i,
 /\@homewatch\.(homegain)\.com/i,
 /hiltonemail\@h\d\.(hilton)\.com/i,
 /hamptonemail\@h\d\.(hilton)\.com/i,
 /hiltonfamily\@h\d\.(hilton)\.com/i,
 /\@h\d\.(hilton)\.com/i,
 /hhonors\@h\d\.(hilton)hhonors\.com/i,
 /HHonors\@h\d\.(hilton)\.com/i,
 /hhonors\@(hilton)hhonors\.net/i,
 /hhonors\@myway\.(hilton)hhonors\.com/i,
 /hiltonhotels\@(hilton)resconfirm\.com/i,
 /\@(jdv)hotels\.com/i,
 /gpnet\@(hyatt)\.com/i,
 /\@e\.(hyatt)\.com/i,
 /mail\@(netapp)\.com/i,
 /\@(tapatalk)\.com/i,
 /news\@e\.(seesmic)\.com/i,
 /Countryinnsandsuites\@(carlsonhotels)\.rsys1\.com/i,
 /carlsonhotels\@email\.(carlsonhotels)\.com/i,
 /\@(tiaa-cref)\.org/i,
 /\@communications\.(tiaa-cref)\.org/i,
 /\@messaging\.(tiaa-cref)\.org/i,
 /(fool)\@foolsubs\.com/i,
 /\@(ProxyVote)\.com/i,
 /(googlealerts)-noreply\@google\.com/i,
 /\@mailer\.(netflix)\.com/i,
 /discship\@(netflix)\.com/i,
 /geico\@email1\.(geico)\.com/i,
 /geico_claims\@g(eico)\.com/i,
 /netflix\@email\.(netflix).com/i,
 /\@(geico)mail\.com/i,
 /\@service-email\.(geico)\.com/i
 /\@delivery\.(bankofamerica)\.com/i,
 /\@(pse)\.com/i,
 /(pse)\@email\.opower\.com/i,
 /HomeLoans\@(bankofamerica)survey\.com/i,
 /customerservice\@emcom\.(bankofamerica)\.com/i,
 /customerservice\@cards.(bankofamerica)\.com/i,
 /bankofamerica\@replies\.em\.(bankofamerica)\.com/i,
 /billpay\@billpay.(bankofamerica)\.com/i,
 /info\@(pricegrabber)\.com/i,
 /storefronts\@(pricegrabber)\.com/i,
 /coolstuff\@coolstuff\.(skymall)\.com/i,
 /(localdeals)\@amazon\.com/i,
 /\@(mercer)gov\.org/i,
 /\@(ups)\.com/i,
 /OnlineServices\@(americanexpress)\.com\.au/i,
 /\@ecerts\.(americanexpress)\.com/i,
 /\@email\.(americanexpress)\.com/i,
 /\@notifications\.(myuhc)\.com/i,
 /SiteUpdate\@(myuhc)\.1nc030\.com/i,
 /info\@(netflix)\.com/i,
 /newsletter\@my(treo)\.net/i,
 /newsletter\@(treo)central-mailings\.com/i,
 /Info\@(posterrevolution)\.com/i,
 /info\@homewatch\.(homegain)\.com/i,
 /customerservice\@servicing\.(homeagain)\.com/i,
 /\@(petdoors)\.com/i,
 /PetRescuers\@(homeagain)-email\.com/i,
 /\@petrescuers\.(homeagain)\.com/i,
 /\@(yubico)\.com/i,
 /(hometheater)mag\@email\.sourceinterlinkpubs\.com/i,
 /newsletter\@(hometheater)mag\.email\.primedia\.com/i,
 /(hometheater)mag\@sourceinterlinkpubs\.com/i,
 /(hometheater)\@primediamags\.chtah\.com/i,
 /newsletter\@(trip-journal).com/i,
 /travelercare\@(orbitz)\.com/i,
 /customercare\@(orbitz)\.com/i,
 /orbitz\@my\.(orbitz)\.com/i,
 /service\@(paypal)\.com/i,
 /paypal\@notifications\.(paypal)\.com/i,
 /paypal\@email\.(paypal)\.com/i,
 /paypal\@e\.(paypal)\.com/i,
 /service\@(paypal)\.com/i,
 /paypal\@info\.(paypal)\.com/i,
 /(voice)-noreply\@google\.com/i,
 /\@(checkout)\.l\.google\.com/i,
 /\@email\.(countrywide)\.com/i,
 /(toyota_of_bellevue)\@mail\.vresp\.com/i,
 /\@e\.(toyota)\.com/i,
 /(tripit)\@mail\.vresp\.com/i,
 /CountrywideSubscriptionServices\@(countrywide)\.com/i,
 /redbox@(redbox)\.chtah\.com/i,
 /\@(roscoebrown)\.com/i,
 /TigerDirect\@e\.(tigerdirect)\.com/i,
 /(tigerdirect)\@promo\.tigeronline\.com/i,
 /(tigerdirect)\.com\@email\.tigeronline\.com/i,
 /\@(thermador)\.wacampaign\.com/i,
 /\@mail\.(thermador)\.com/i,
 /\@(expedia)mail\.com/i,
 /\@aadvantage\.info\.(aa)\.com/i,
 /\@info\.(aa)\.com/i,
 /\@m\.(aa)-mail\.com/i,
 /\@(aa)\.com/i,
 /\@checkin\.info\.(aa)\.com/i,
 /\@checkin\.email\.(aa)\.com/i,
 /\@aadvantage\.email\.(aa)\.com/i,
 /notify\@(aa)\.globalnotifications\.com/i,
 /\@(plus).google.com/i,
 /hit-reply\@(linkedin)\.com/i,
 /news\@(linkedin)\.com/i,
 /updates\@(linkedin)\.com/i,
 /group-digests\@(linkedin)\.com/i,
 /communication\@(linkedin)\.com/i,
 /connections\@(linkedin)\.com/i,
 /messages-noreply\@bounce\.(linkedin)\.com/i,
 /messages-noreply\@(linkedin)\.com/i,
 /linkedin\@em\.(linkedin)\.com/i,
 /member\@(linkedin)\.com/i,
 /uhcenews\@(unitedhealthcare)\.rsys1\.com/i,
 /mytoyota\@(toyota)partsandservice\.com/i,
 /membership\@email\.(samsclub)\.com/i,
 /reminder\@mail\.(walgreens)\.com/i,
 /member\.service\@(firsttech)fed\.com/i,
 /\@(firsttech)fed\.com/i,
 /boom\@(oneplus)\.net/i,
 /Xfinity\@info\.(xfinity)\.com/i,
 /Xfinity\@emails\.(xfinity)\.com/i,
 /eAccountNotify\@(verizon)wireless\.com/i,
 /srivasta=ieee\.org\@postmaster\.(twitter)\.com/i,
 /srivasta=acm\.org\@postmaster\.(twitter)\.com/i,
 /(verizon)wireless\@email\.vzwshop\.com/i,
 /\@(t-mobile)-email\.com/i,
 /\@documents\.(t-mobile).com/i,
 /\@(t-mobile).com/i,
 /uhc\@(unitedhealthcare)-hmhb\.com/i,
 /\@(pandora)\.com/i,
 /\@.*\.(aetna)\.com/i,
 /\@mail\.(ally)\.com/i,
 /\@alerts\.(ally)\.com/i,
 /\@transfers\.(ally)\.com/i,
 /\@(diabetes)\.org/i,
 /support\@(mywot)\.com/i
 /newsletters\@(boston)\.com/i,
 /no-reply\@(yelp)\.com/i,
 /\@e?mail\.(zillow)\.com/i,
 /alerter\@(my-cast)\.com/i
 {
   ANNOTATE -d X-Disposition Services-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /\@welcome\.aexp\.com/i {
   ANNOTATE -d X-Disposition Services-Mailinglist;
   ASSIGN list 'americanexpress';
   REJECT MailingList
 };



# Sales
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(rediff-shopping)-noreply\@listserver\.rediff\.com/i,
 /AbtElectronics\@newsletter\.(abtelectronics)\.com/i,
 /(abtelectronics)\@newsletter\.abt\.com/i,
 /direct\@(adobesystems)\.com/i,
 /bitbucket\@(rhinosoft)\.com/i,
 /offers\@(apexhotels)\.co\.uk/i,
 /\@news(apexhotels)\.co\.uk/i,
 /\@(booking)\.com/i,
 /\@mail\.(ign)\.com/i,
 /\@(julianbakery)\.com/i,
 /americanairlines\@aadvantage\.email\.(aa)\.com/i,
 /americanairlines\@email\.(aa)\.com/i,
 /\@(zipcar)\.com/i,
 /\@et\.(uber)\.com/i,
 /\@(uber)\.com/i,
 /\@(tripcase)\.com/i,
 /\@em\.(tripcase)\.com/i,
 /apc\@email\.(apc)c\.com/i,
 /apexhotels\@communicate\.(apexhotels)\.co\.uk/i,
 /BarnesandNoble_Membership\@email\.(bn)\.com/i,
 /BarnesandNobleEmail\@e\.(bn)\.com/i,
 /BarnesandNobleEmail\@(bn)\.chtah\.com/i,
 /BarnesandNobleEmail\@email\.(bn)\.com/i,
 /BarnesandNobleEmail\@email2\.(bn)\.com/i,
 /BestBuyInfo\@emailinfo\.(bestbuy)\.com/i,
 /BestBuyRewardZone\@emailinfo\.(bestbuy)\.com/i,
 /\@emailinfo\.(bestbuy)\.com/i,
 /BOM\@(bluemoonburgers)\.com/i,
 /\@(borders)rewardsperks\.com/i,
 /Borders\@e\.(borders)stores\.com/i,
 /Borders\@e\.(borders)\.com/i,
 /\@(posterrevolution)'.com/i,
 /\@enews\.(williams-sonoma)\.com/i,
 /\@(briggs-riley)\.messages1\.com/i,
 /(briggsriley)\@reply.bronto.com/i,
 /\@mkt(dillards)\.com/i,
 /recipes\@(julianbakery)inc\.com/i,
 /News\@(cablestogo)\.com/i,
 /\@(checksunlimited)\.rsys1\.com/i,
 /\@(cafepress)\.com/i,
 /\@(bosch)\.wacampaign\.com/i,
 /\@mail\.(bosch)-home\.com/i,
 /no-reply\@(cedega)\.com/i,
 /noreply\@crossover\.(codeweavers)\.com/i,
 /cdelzer\@(codeweavers)\.com/i,
 /reply\@(glassdoor)-email\.com/i,
 /chefs\@e.(chefscatalog)\.com/i,
 /CalphalonStore\@email-store(calphalon).com/i,
 /\@email-store(calphalon)\.com/i,
 /\@(calphalon)-mail\.com/i,
 /CookingFood\.com\@email-(cooking)\.com/i,
 /CompUSA\@(compusa)online\.com/i,
 /dell\@outletbusiness\.(dell)\.com/i,
 /dell\@smallbusiness\.(dell)\.com/i,
 /Dell_Automated_Email\@(dell)\.com/i,
 /YourPartsLeader\@parts\.usa\.(dell)\.com/i,
 /Dell_Services\@services\.usa\.(dell)\.com/i,
 /dyson\@(dyson)\.messages1\.com/i,
 /Discovery\@(discovery)mail\.com/i,
 /\@(uvvu)\.com/i,
 /\@email\.store\.(discovery)\.com/i,
 /\@email-(discovery)store.com/i,
 /\@em\.(fileplanet)\.com/i,
 /\@news\.(fileplanet)\.com/i,
 /\@email\.store\.(discovery)\.com/i,
 /\@(discovery)mail.com/i,
 /\@.*\.(ebags)\.com/i,
 /(foodnetwork)store\@foodnewsletters\.com/i,
 /FoodNetworkStore\.com\@email-(foodnetwork)store\.com/i,
 /\@(giantmicrobes)\.com/i
 /\@shop\.(hammacher)\.com/i,
 /Hammacher\.custcare\@(hammacher)\.com/i,
 /hammacher\@(hammacher)\.whatcounts\.com/i,
 /firststreet\@email\.(firststreet)online\.com/i,
 /\@email\.(foodnetwork)store\.com/i,
 /email\@(firststreet)\.messages1\.com/i,
 /(harmony)\@corp\.shopharmony\.com/i,
 /(improvements)\@e\.improvementscatalog\.com/i,
 /winzip-announce\@(winzip)\.com/i,
 /\@(jos-a-bank)\.com/i,
 /specials\@email\.(officedepot)\.com/i,
 /newsletter\@(leatherup)\.com/i,
 /Lowes\@email\.(lowes)\.com/i,
 /Lowes\@e\.(lowes)\.com/i,
 /specials\@(officedepot)\.com/i,
 /support\@email\.(officedepot)\.com/i,
 /(gentleware)_AG\@mail\.vresp\.com/i,
 /Marketing\@(extendedstay)hotels\.com/i,
 /\@(extendedstay)hotels\.com/i,
 /\@em\.(extendedstayamerica)\.com/i,
 /\@(drsfostersmith)\.com/i,
 /(fogcreek)\@.*whatcounts\.com/i,
 /(homefocus)\@e.homefocuscatalog.com/i,
 /\@(profantasy)\.com/i,
 /nigel\@dl2\.(profantasy)\.com/i,
 /nigel\@(profantasy)\.com/i,
 /\@(fantasygrounds)\.com/i,
 /\@(fg-con)\.com/i,
 /support\@(officedepot).chtah.com/i,
 /\@.*\.the(planet)\.com/i,
 /hm1\@(handmark).net/i,
 /negroponte\@(laptop)\.org/i,
 /promo\@e\.(newegg)\.com/i,
 /promo\@email\.(newegg)\.com/i,
 /info\@(newegg)\.com/i,
 /mailing\@(handmark).com/i,
 /(josabank)\@shop.josbank.com/i,
 /nigel\@dl1\.(profantasy)\.com/i,
 /News\@mail\.(crutchfield)\.com/i,
 /News\@messages\.(crutchfield)\.com/i,
 /northern_tool\@newsletter\.(northerntool)\.com/i,
 /noahsbagels\@(noahsbagels)\.fbmta\.com/i,
 /(orvis)\@orvisnews\.com/i,
 /\@(target)\.bfi0\.com/i,
 /orders\@(target)\.com/i,
 /(symantec)cs\@digitalriver\.com/i,
 /\@nortonfrom(symantec)\.com/i,
 /\@(symantec)\.rsys2\.com/i,
 /greatdeals\@rent\.(thrifty)email\.net/i,
 /thriftycarrental\@email\.(thrifty)\.com/i,
 /email\@customer.(usps)\.com/i,
 /\@(livingsocial)\.com/i,
 /(Thermador)\@xmr3\.com/i,
 /StaplesEasyRebates\@(staples)easyrebates\.com/i,
 /staples\@e\.(staples)\.com/i,
 /\@(softwaremag)\.com/i,
 /williams-sonoma\@enews\.(williams-sonoma)\.com/i,
 /(zazzle)\@echo7\.bluehornet\.com/i,
 /(zazzle)\@email\.zazzle\.com/i,
 /\@.*\.(verizonwireless).com/i,
 /QuickenOnlineBackup\@(quicken)\.com/i,
 /customercare\@(quicken)\.com/i,
 /\@info\.(quicken)\.com/i,
 /\@info1\.(quicken)\.com/i,
 /no-reply\@(yelp)\.com/i,
 /TechSaver\@eletters\.(ztechsaver)\.com/i
 {
   ANNOTATE -d X-Disposition Sales-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Lugs and such
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(nashdl)\@googlegroups\.com/i,
 /(nlug)-request\@linuxlists.org/i,
 /(nlug)-talk\@googlegroups\.com/i,
 /(nlug)\@linuxlists.org/i,
 /(nlug-biz)-request\@linuxlists.org/i,
 /(nlug-biz)\@linuxlists.org/i,
 /(nlug-newbies)-request\@linuxlists.org/i,
 /(nlug-newbies)\@linuxlists.org/i,
 /(nlugsc)-request\@linuxlists.org/i,
 /(nlugsc)\@linuxlists.org/i
 {
   ANNOTATE -d X-Disposition LUG-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

# Tor
<RETRY,INITIAL> X-BeenThere List-Id: /lists.torproject.org/i  { REJECT TOR };
<TOR> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /(tor-[\w-]+)(-(bounces|request|dist))?\@lists\.torproject\.org/i
 {
   ANNOTATE -d X-Disposition TOR-Mailinglist;
   ANNOTATE -d X-Agent-list 'tor';
   ASSIGN list '%1';
   SUBST #list /-(bounces|request|dist)//gi;
   REJECT MailingList
 };

#Misc
<RETRY,INITIAL> From To Cc Sender X-Mn-Key Envelope Delivered-To X-BeenThere:
 /announce\@crossover\.(codeweavers)\.com/i,
 /announce-bounces\@crossover\.(codeweavers)\.com/i,
 /ticket-system\@(codeweavers)\.com/i,
 /mobile_(gaming)\@egroups.com/i
 {
   ANNOTATE -d X-Disposition Misc-Mailinglist;
   ASSIGN list '%1';
   REJECT MailingList
 };

<RETRY> /./  { ANNOTATE -d X-Lost Retry; REJECT LOST };

# related mails sent off the list
<INITIAL> Subject:
        /\[LIH\]/           { ASSIGN list 'linux-india-help';
                              ASSIGN subject '%s';
                              STRIP Subject;
                              RESYNC;
                              SUBST #subject /\[LIH\]/[LIH] [PERSONAL]/i;
                              RESYNC;
                              REJECT MailingList };
<INITIAL> Subject:
        /\[LIG\]/           { ASSIGN list 'linux-india-general';
                              ASSIGN subject '%s';
                              STRIP Subject;
                              RESYNC;
                              SUBST #subject /\[LIG\]/[LIG] [PERSONAL]/i;
                              RESYNC;
                              REJECT MailingList };


# Miscellaneous stuff
<INITIAL> From To Cc Sender X-Mn-Key Envelope:
        /perl5-porters/i      { ASSIGN list 'dist';     REJECT MailingList }
        /linux-alert/i        { ASSIGN list 'security'; REJECT MailingList }
        /infophil.com/i       { ASSIGN list 'misc';     REJECT MailingList }
        ;


<INITIAL> Return-Path: /ding-request/i  { ASSIGN list 'ding';
                                          REJECT MailingList };

<INITIAL>  Subject: /CFV: Proposal/ { REJECT VOTE };
<INITIAL>  Subject: /PuPy-Puget-Sound-Python-pronounced-puppy/ {
   ASSIGN list 'puppy';
   REJECT MailingList
};

<INITIAL> X-SBClass:/Admin/       { REJECT ADMIN };

<INITIAL> X-Loop: /\d+\@bugs.debian.org/i      { REJECT DEBIANBUGS };
<INITIAL> Sender: /debbugs\@master.debian.org/ { REJECT DEBIAN };

####
#### Ok, so this is not from a mailing list.
####
<INITIAL> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
 /srivasta\@debian.org/i  {  ANNOTATE -d X-Agent-list Unknown;
                          ASSIGN list 'debian'; REJECT MailingList };
<INITIAL> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
 /secretary\@debian.org/i  {  ANNOTATE -d X-Agent-list Secretary;
                              ASSIGN list 'secretary'; REJECT MailingList };
<INITIAL> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
 /\@packages.debian.org/i  {  ANNOTATE -d X-Agent-list Unknown;
                              ASSIGN list 'debian'; REJECT MailingList };

<INITIAL> X-SBClass:/Blocked/   { REJECT BLOCKED };


<INITIAL> From:   srivasta   { ANNOTATE -d X-Agent-list me; VACATION off;
                               REJECT SRIVASTA };

<SRIVASTA> Subject: /Test Vacation/i  { MESSAGE ~/etc/mail/vacation };
<SRIVASTA> Subject: /LurkFTP Output/i { REJECT ADMIN };
<SRIVASTA>                            { ASSIGN list 'outgoing';
                                        ANNOTATE -d X-Agent-list Outgoing;
                                        REJECT MailingList };

######################################################################
######################################################################
#                                                                    #
#                     All non mailing list mail                      #
#                                                                    #
######################################################################
######################################################################
<INITIAL> From:  dhaley { REJECT ADDRESSED };

<!SPAM> Subject: /get pgp key/i { MESSAGE ~/.pgpkey; REJECT ADMIN; };
<!SPAM> Subject: /get gpg key/i { MESSAGE ~/.gpgkey; REJECT ADMIN; };

<_SEEN_>        { STRIP X-Filter; REJECT post_process };

######################################################################
######################################################################
#                                                                    #
#                     Newsletters and all                            #
#                                                                    #
######################################################################
######################################################################

<INITIAL> X-Loop X-Mailing-List To Resent-From Resent-To Resent-Reply-To Cc:
 /srivasta\@ieee.org/i  {  ANNOTATE -d X-List Newsletters;
                         REJECT NEWSLETTERS };

<NEWSLETTERS,INITIAL> Relayed From Reply-To Sender:
        /AppDevTrends\@bdcimail.com/i,
        /AppDevTrends\@101communications-news\.com/i,
        /Data_Packet\@newsletters.theneteconomy.com/i,
        /Ent\@101communications-news\.com/i,
        /FareTracker.*\@faretracker.expedia.customer-email.com/i,
        /IQUpdate\@bdcimail.com/i,
        /LinuxReport\@bdcimail.com/i,
        /LinuxWorld\@emailch.com/i,
        /MSNHotOffers_\d+\@msnnewsletters.customer-email.com/i,
        /MyGarage\@AlconeMarketing.com/i,
        /news\@letters.infogate.com/i,
        /NetworkComputing\@events.cmp.netline.com/i,
        /OpenSource\@bdcimail.com/i,
        /ScoopHelp\@Bellevue.com/i,
        /SecurityAlert\@bdcimail.com/i,
        /SecurityWatch\@bdcimail.com/i,
        /SoftwareMagazine\@emailch.com/i,
        /SoftwareMagazine\@processrequest.com/i,
        /Semiconbayinfo-owner\@listbot.com/i,
        /The_InfoWorld_Scoop\@.*com/i,
        /Williams-Sonoma\@service\.williams-sonoma\.com/i,
        /\@.*\.iomega.com/i,
        /\@deerfield.com/,
        /\@directsolutionsinc.com/i,
        /\@etrade.0mm.com/i,
        /\@garden.m0.net/i,
        /\@ieee.org/i,
        /\@kgpnet.org/i,
        /\@members.clickrewards.com/i,
        /\@msgexpress.net/i,
        /\@news.clickrewards.com/i,
        /\@softwaremag.com/i,
        /\@suretrade.com/i,
        /\@travelocity.com/i,
        /\@usenix.org/i,
        /all\@dtccom.net/i,
        /barnesandnoble.com/i,
        /betweenthelines\@daily.informationweek.com/i,
        /chhedis\@kgpnet.org/i,
        /Connection\@administaff.com/i,
         /theneteconomy\@eletters1.ziffdavis.com/i,
         /cujnews\@cuj.email-publisher.com/i,
         /custserv\@burpee\.com/i,
        /developerWorks\@ibm.ihost.com/i,
        /electronics-news\@amazon\.com/i,
        /EthicsMatters\@bdcimail.com/i,
        /free\@arttoday.com/i,
        /heimdal-announce\@sics.se/i,
        /imaginemedia.com/i,
        /itnews\@.*itwpub1.com/i,
        /\@iqmailer.net/i,
        /linuxworld\@.*itwpub1.com/i,
        /members\@batchmates.com/i,
        /memberservices\@travelocity.m0.net/,
        /michael\@omg.org/i,
        /mobicon\@mobicon.org/i,
        /lw_ent\@idg.email-sr\@dsizone\d*\.net/i,
        /smail\@dsi-sigs.net/i,
        /the-institute\@ieee\.org/i,
        /tools-news\@amazon\.com/i,
        /urnews\@cmp.com/i,
        /unixreview\@dsizone\d*\.net/i,
         /urnews\@unixreview\.email-publisher\.com/i,
        /updates\@rhinosoft.com/i,
        /Williams_Sonoma\@.*\.customer-contact\.net/i,
        /vmwarenews\@vmware.m0.net/i,
        /.*travelocity.com/i,
        /sans\@sans.org/i,
        /dana\@omg.org/i,
        /SLED/i, /pppcom/i,
        /\@insider.cheaptickets.com/,
        /\@intuit\.0mm\.com/,
        /altavista-software.com/,
        /compare.net/,
        /\@TigerDirect.com/i,
        /lists.sierra.com/,
        /(rails)\.Book\.Buyers\@pragprog\.com/i,
        /news.quicken.com/,
        /InformationWeek\@update.informationweek.com/i,
        /SDonlineUpdate\@softwaredevelopment.email-publisher.com/i,
        /policyinfo\@HQ.ACM.ORG/i,
        /quicken_newsletters\@newsletter.quicken.com/i,
        /quickenmortgage/
 { ANNOTATE -d X-List Newsletters; REJECT NEWSLETTERS };

######################################################################
######################################################################
#                                                                    #
#               The rest is potentially personal mail                #
#                                                                    #
######################################################################
######################################################################
<INITIAL> To Cc Sender:
    /srivasta\@debian\.org/,
    /srivasta\@acm\.org/,
    /srivasta\@golden-gryphon\.com/,
    /srivasta\@.+\.internal\.golden-gryphon\.com/
    { ANNOTATE -d X-List Work; REJECT ADDRESSED }
        ;

# Not explicitely for me. Mail lost or bcc'ed.
<INITIAL> !To !Cc: /srivasta/i   { ANNOTATE -d X-Lost Not-me;    REJECT LOST };
#<ADDRESSED> !X-Spam-Status: /No/ { ANNOTATE -d X-Lost Addressed; REJECT LOST };

<BLOCKED,INITIAL> !X-Spam-Status: /No/            { REJECT SPAM };

# Authenticated senders are often spammers
<INITIAL> Comments: /^Authenticated sender/i      { REJECT MAY_SPAM };
<MAY_SPAM> Subject: /money/i        { ANNOTATE -d X-Spam Money; REJECT SPAM };
<MAY_SPAM> X-Uidl: /^\w+$/i         { ANNOTATE -d X-Spam X-Uidl; REJECT SPAM };
<MAY_SPAM> Precedence: /^bulk/i     { ANNOTATE -d X-Spam Bulk; REJECT SPAM };
<MAY_SPAM>                          { REJECT INITIAL };

<INITIAL> From: postmaster, mailer-daemon, uucp   { VACATION off;  REJECT BAD };

<BAD> Body: /^X-Mailer: dist/   { REJECT BAD_AGENT };
<BAD_AGENT> Body: /^Precedence: bulk/, /^Subject: .*patch/i  { REJECT JUNK };
<BAD, BAD_AGENT> !X-Spam-Status: /No/ { ANNOTATE -d X-Lost Bad; REJECT LOST };
<BAD, BAD_AGENT>        { REJECT BOUNCED };


<BOUNCED> { ASSIGN list 'bounced'; REJECT MailingList };

#<ADDRESSED> To Cc Sender:  /srivasta\@ieee.org/
#            { REJECT NEWSLETTERS };
<ADDRESSED> { REJECT IMPORTANT };


<NEWSLETTERS> !X-Spam-Status: /No/ { ANNOTATE -d X-Lost Newsletters;
                                     REJECT LOST };
<NEWSLETTERS>                      { ASSIGN list 'newsletters';
                                     REJECT MailingList };

#<ADDRESSED>  From: /spammer\@/ { MESSAGE ~/etc/mail/lamb; REJECT spam };
#<ADDRESSED> To Cc Sender:  /manoj.srivastava\@stdc.com/i,
#            From: /\@stdc.com/i
#            {
#              ASSIGN list 'stdc';
#              REJECT MailingList
#            };

######################################################################
######################################################################
#                                                                    #
#                           Dispose of Mail                          #
#                                                                    #
######################################################################
######################################################################
<JUNK> All: /./         { VACATION off;  DELETE; };
<ADMIN> All: /./        { PERL sbin/mailagent.archive.pl Admin %H %Y %m};
<ADMIN>                 { VACATION off;  SAVE admin };

<!IMPORTANT> From: /jshardo\@golden-gryphon.com/ { REJECT IMPORTANT;};


<IMPORTANT> All: /./    { PERL sbin/mailagent.archive.pl important %H %Y %m};
<IMPORTANT>             { UNIQUE -a (addressed);
                          ANNOTATE -d X-Spam Addressed;
                          SAVE important };

<BALLOT> Subject: /Acknowledgement for your vote/
                  { VACATION off; UNIQUE -a (vote); SAVE ~/mail/acks   };
<BALLOT> Subject: /Error report for your vote/
                  { VACATION off; UNIQUE -a (vote); SAVE ~/mail/nacks  };
<BALLOT> To:      /ballot\@vote.debian.org/
                  { VACATION off; UNIQUE -a (vote); SAVE ~/mail/ballot };
<VOTEACK>         { VACATION off; UNIQUE -a (vote); SAVE ~/mail/vote;  };

<KEYS>            { VACATION off; UNIQUE -a (keys); SAVE signed-keys   };
<post_process>    { VACATION off;  SAVE test; };


<MailingList> All: /./
 { TR #list /A-Z/a-z/; PERL sbin/mailagent.archive.pl %#list %H %Y %m; };
<MailingList> All: /./ { VACATION off;  TR #list /A-Z/a-z/;
                         UNIQUE -a (%#list);
                         ANNOTATE -d X-MYLIST %#list.spool; SAVE %#list.spool
 };

<REALSPAM>               { VACATION off; UNIQUE -a (SPAM); SAVE realspam;  };
<SPAM>                   { VACATION off; UNIQUE -a (SPAM); SAVE spam };
#ONCE (%r, spammessage, 1d) MESSAGE ~/etc/mail/spam;


<Logs> { VACATION off;  TR #logsource /A-Z/a-z/;
         ANNOTATE -d X-MYLOG %#logsource;
         UNIQUE -a (%#logsource); SAVE %#logsource.log };


######################################################################
######################################################################
#                                                                    #
#                     Save from lost                                 #
#                                                                    #
######################################################################
######################################################################
From To Cc Sender X-Loop:
  /\d+\@bugs.debian.org/i      { REJECT DEBIANBUGS };

######################################################################
######################################################################
#                                                                    #
#                   final default rule                               #
#                                                                    #
######################################################################
######################################################################
#probably spam
{
        ANNOTATE -d X-Lost Unknown;
        REJECT LOST
};

<LOST> Subject: /Ballot for / { UNIQUE -a; VACATION off; DELETE; };
<LOST> All: /./               { PERL sbin/mailagent.archive.pl lost %H %Y %m; };
<LOST> All: /./               { UNIQUE -a (lost); VACATION off;
                                ANNOTATE -d X-Spam lost; SAVE lost.spool };
######################################################################
######################################################################
#                                                                    #
#               End of mailagent rules                               #
#                                                                    #
######################################################################
######################################################################



######################################################################
######################################################################
#                                                                    #
#               Old rules, for use as example                        #
#                                                                    #
######################################################################
######################################################################



# Remove all the crm114 and spamassassin headers from upstream
#All:  /./
# { STRIP X-CRM114-Status X-CRM114-Version X-Spam-Value X-Spam-Status
#    X-Spam-Checker-Version; REJECT; };
#<!SPAM>  /./  { FEED /usr/bin/spamassassin -a 2>>$HOME/var/log/assassin;
#                RESYNC; REJECT; };
#All:  /./
# { FEED /usr/bin/crm114 -u $HOME/var/lib/crm114 mailfilter.crm 2>>$HOME/var/log/crm;
#   RESYNC; REJECT; };
#X-CRM114-Status: /SPAM\s+.\s+pR: \-(\d\d\d)/
# { UNIQUE -a (SPAM); ANNOTATE -d X-RealSpam '%1'; REJECT REALSPAM; };
#<!SPAM>  /./
# { FEED /usr/bin/spamc -f 2>>$HOME/var/log/assassin; RESYNC; REJECT; };

# Make sure spamassassin sees this
#<!SPAM> !X-Spam-Status: /No/
#               { ANNOTATE -d X-Spam Again;
#                 FEED /usr/bin/spamc -f 2>>$HOME/var/log/assassin2;
#                RESYNC; REJECT; };
#<!SPAM> X-Spam-Status: /Yes/            { REJECT SPAM };
#<SPAM> X-Spam-Value: /(1[5-9]\.\d)/
#       { UNIQUE -a (SPAM); ANNOTATE -d X-RealSpam '%1'; REJECT REALSPAM;  };
#<INITIAL> X-SBClass:/Spam/               { REJECT SPAM };
#<!SPAM> X-Spam-Status: /autolearn=ham/  { SAVE ham; REJECT };
#<!SPAM> X-Spam-Status: /autolearn=spam/ { REJECT REALSPAM; };
#Subject: /^[Cc]ommand\s*$/ { VACATION off; BEGIN CMD; REJECT };
#Subject: /CFV: Proposal/       { VACATION off; REJECT VOTE; };
#Body <1,3>: /^Subject:\s*[Cc]ommand\s*$/ { VACATION off; BEGIN CMD; REJECT };
#All: /^Subject:\s*[Cc]ommand/   { VACATION off; BEGIN CMD; REJECT };
#<CMD> *         { STRIP Received; PROCESS; REJECT ADMIN; };
#Subject: /glaurung: snort daily report/   { VACATION off; REJECT ADMIN };


## Just annotate the body, and stop
# All: /./        { PERL sbin/anno.pl; LEAVE } ;
# anno.pl contains
# $header{'Body'} = " --- HEADER ---\n" . $header{'Body'} . " --- FOOTER ---\n";
# $header{'All'} = $header{'Head'} . $header{'Body'}; # vital!
#
# Variaqnt using PASS
# All: /./        { PASS sbin/anno.pl; LEAVE } ;
# anno.pl contains
# #! /usr/bin/perl
# print "  --- HEADER ---\n";
# while (<>)
# {
#     print;
# }
# print "  --- FOOTER ---\n";



#
## From: /:IN/     {PURIFY ~/sbin/mailagent.decnet.pl; RESYNC; REJECT };

#<INITIAL> Envelope Relayed From Reply-To Message-Id: "KNOWN" {
#        ANNOTATE -d X-Spam Non-spam from %1;
#        REJECT ADDRESSED;
#};
#<!SPAM> X-SBClass: /Spam/i                {
#       ANNOTATE -d X-Spam Smells like spam blocked by spambounce;
#        REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: "SPAM" {
#       ANNOTATE -d X-Spam Smells like spam from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-aol" {
#       ANNOTATE -d X-Spam Smells like spam-aol from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-cyberpromo" {
#       ANNOTATE -d X-Spam Smells like spam-cyberpromo" from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-iocom" {
#       ANNOTATE -d X-Spam Smells like spam-iocom from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-llv" {
#       ANNOTATE -d X-Spam Smells like spam-llv" from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-mindspring" {
#       ANNOTATE -d X-Spam Smells like spam-mindspring from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-nancynet" {
#       ANNOTATE -d X-Spam Smells like spam-nancynet from %1;
#       REJECT SPAM };

#<!SPAM> To Envelope Relayed From Reply-To Message-Id: ".spamlist-znet" {
#       ANNOTATE -d X-Spam Smells like spam-znet from %1;
#       REJECT SPAM };

#<!SPAM>        To Envelope Relayed From Reply-To Message-Id:
#    "/var/spamdb/mailagent.sp" {
#       ANNOTATE -d X-Spam Smells like spam-db from %1;
#       REJECT SPAM };

#<!SPAM> X-[0-9]: /cyberpromo\.com/i     {
#        ANNOTATE -d X-Spam Smells like spam from cyberpromo;
#       REJECT SPAM };

#<!SPAM> X-Mailer: /floodgate/i {
#        ANNOTATE -d X-Spam Smells like spam from floodgate;
#       REJECT SPAM };


# The message id should really match this.
# Message-id: !/\@([-a-zA-Z0-9]+\.)+[a-zA-Z]{2,3}\>\s*$/ { REJECT MAY_SPAM };

#<!SPAM> Message-ID: /\<[^\@]*\>/, /\@.*\@/ {
#        ANNOTATE -d X-Spam Smells like a bogus message ID;
#       REJECT SPAM };


#<LOST> Comments: /^Authenticated sender/i       {
#        ANNOTATE -d X-Spam Smells like spam;
#        REJECT SPAM };

#<MAILAGENT> {   ASSIGN subject '%s';
#                STRIP Subject;
#                RESYNC;
#                SUBST #subject /^\(agent-users\s\d+\)//i;
#                ANNOTATE -d Subject %#subject;
#                RESYNC;
#                REJECT ML};
