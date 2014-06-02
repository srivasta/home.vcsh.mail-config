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

mailfilter = ~/etc;

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

# Remove all the crm114 and spamassassin headers Again
All:  /./
 { STRIP X-Scanned-By X-CRM114-Score X-SA-Rep X-CRM114-Version X-CRM114-Status X-Spam-Value X-Spam-Status X-Spam-Score X-Spam-Checker-Version; REJECT; };


######################################################################
######################################################################
#                                                                    #
#           Adminstrative stuff, not to be recorded below            #
#                                                                    #
######################################################################
######################################################################


# If I was just on the CC list, do not send vacation messages
<INITIAL> Cc: jshardo    { VACATION off; REJECT };

<!SPAM> From: Mailer-Daemon,
        Subject: /Mail delivery failed: returning message/,
             { REJECT BOUNCED };


######################################################################
######################################################################
#                                                                    #
#                            Main Section                            #
#                                                                    #
######################################################################
######################################################################

# All that enter here get logged
All: /./        { PERL sbin/mailagent.log.pl};


######################################################################
######################################################################
#                                                                    #
#                            Job Related                             #
#                                                                    #
######################################################################
######################################################################

<INITIAL> Envelope Relayed From Reply-To Message-Id: "KNOWN" {
	ANNOTATE -d X-Spam Non-spam from %1;
	REJECT ADDRESSED;
};

######################################################################
######################################################################
#                                                                    #
#                 The mailing lists I subscribe to:                  #
#                                                                    #
######################################################################
######################################################################

<INITIAL> To Cc Sender X-Mn-Key Envelope:
        /careermag.com/,
	/geowebinc.com/
	{ ASSIGN list 'jobs'; REJECT MailingList };

<RETRY,INITIAL> To Cc Sender Reply-To X-Mn-Key Envelope Delivered-To X-BeenThere:
	/(abovethefold)\@ehs\.sparklist.com/i,
	/(thisgreenlife)\@nrdcaction\.org/i,
	/action\@(floridapirg)\.org/i,
	/biogemsdefenders\@savebiogems\.org/i,
	/deals\@(livingsocial)\.com/i,
	/do_not_reply\@(motherjones)\.com/i,
	/email\@email-(gardeners)\.com/i,
	/garden_expertteam\@email\.(homedepot)\.com/i,
	/hotnews\@info\.(seattletimes)\.com/i,
	/info\@(rootsaction)\.org/i,
	/kieran\@(biologicaldiversity)\.org/i,
	/mail\@e\.(groupon).com/i,
	/moveon-help\@list\.(moveon)\.org/i,
	/newsletters\@n\.(npr(.org/i,
	/noreply\@(photo)\.net/i,
	/replies\@(alternet)\.org/i,
	/sears\@value\.(sears)\.com/i,
	/store-news\@(amazon)\.com/i,
	/tiaa-cref\@messaging\.(tiaa-cref)\.org/i,
	/universalcard\@info9\.(citibank)\.com/i,
        /(abovethefold)\@ehs\.sparklist\.com/i,
        /(guildwars)\@ncsoft\.com/i,
        /(localdeals)\@amazon\.com/i,
        /(ppaction)\@ppvotesnw\.org/i,
        /(srivasta)\@ip-10-248-0-85.us-west-2\.compute\.internal/i,
        /(store-news)\@amazon\.com/i,
        /CNAH\@(cnah)\.org/i,
        /\@(ecocenter)\.org/i,
        /\@(motherjones)\.com/i,
        /\@(npr)\.org/i,
        /\@(ombwatch)\.org/i,
        /\@(rootsaction)\.org/i,
        /\@(seattletimes)\.whatcounts\.com/i,
        /\@bounce\.(homedepot)email\.com/i,
        /\@bounce\.e\.(groupon)\.com/i,
        /\@bounce\.email-(gardeners)\.com/i,
        /\@bounce\.info9\.(citibank)\.com/i,
        /\@bounces\.(amazon)\.com/i,
        /\@bounces\.(salsalabs)\.net/i,
        /\@list\.(alternet)\.org/i,
        /\@messaging\.(tiaa-cref)\.org/i,
        /\@mta-inbound\.cluster3\.(convio)\.net/i,
        /\@n\.(npr)\.org/i,
        /act\@(credoaction)\.com/i,
        /action\@(floridapirg)\.org/i,
        /alerts\@(aaas-science)\.org/i,
        /biogemsdefenders\@(savebiogems)\.org/i,
        /campaigns\@(dailykos)\.com/i,
        /deals\@(livingsocial)\.com/i,
        /email\@email-(gardeners)\.com/i,
        /garden_expertteam\@email\.(homedepot)\.com/i,
        /mail\@e\.(groupon)\.com/i,
        /newsletters\@n\.(npr)\.org/i,
        /replies\@(alternet)\.org/i,
        /hrc\@(hrc)\.org/i
        {
           ANNOTATE -d X-Disposition Addressed;
	   ASSIGN list '%1';
           ANNOTATE -d X-MYLIST %i;
           REJECT ADDRESSED;
        };
#
# big honking match all known mailing list expression
#
<RETRY,INITIAL> To Cc Sender Reply-To X-Mn-Key Envelope Delivered-To X-BeenThere:
        /(shad)\@yahoogroups.com/i,
	/(curl)-list\@jmu.edu/i,
        /owner-(dist)-users/i
        { ANNOTATE -d X-Disposition Mailinglist;
	  ASSIGN list '%1'; REJECT MailingList };

<RETRY> /./  { REJECT LOST };


####
#### Ok, so this is not from a mailing list.
####
<INITIAL> X-SBClass:/Blocked/	{ UNIQUE -a;
                                  REJECT BLOCKED };

<INITIAL> From:   jshardo   { ANNOTATE -d X-Agent-list me; VACATION off;
                               REJECT JSHARDO };

<JSHARDO> Subject: /Test Vacation/i  { MESSAGE ~/etc/mail/vacation };
<JSHARDO>                            { ASSIGN list 'outgoing';
					ANNOTATE -d X-Agent-list Outgoing;
					REJECT MailingList };


######################################################################
######################################################################
#                                                                    #
#                     All non mailing list mail                      #
#                                                                    #
######################################################################
######################################################################

#
# Put mailer daemon junk away for deferred reading
# Delete garbage generated by patsend and friends
#

<INITIAL> From: postmaster, mailer-daemon, uucp  { VACATION off;  REJECT BAD };

<BAD> Body: /^X-Mailer: dist/   { REJECT BAD_AGENT };
<BAD_AGENT> Body: /^Precedence: bulk/, /^Subject: .*patch/i     { DELETE };
# <BAD, BAD_AGENT>        { SAVE +.bounced/new/ };

######################################################################
######################################################################
#                                                                    #
#                    Now, take care of spammers.                     #
#                                                                    #
######################################################################
######################################################################
# Not explicitely for me. Mail lost or bcc'ed.
<!SPAM> !To !Cc: /jshardo/i              { REJECT LOST };

<!SPAM> Relayed From Reply-To Sender:
  /webresearch\@elsevier.dmdelivery.nl/i,
	/burpeeseed\@List.burpee.com/i,
	/memberservices\@greatergood.com/i,
	/umalumni\@admin.umass.edu/i,
	/umass-alumni\@admin.umass.edu/i,
	/FareTracker.*\@faretracker.expedia.customer-email.com/i,
	/MyGarage\@AlconeMarketing.com/i,
	/\@etrade.0mm.com/i,
	/\@garden.m0.net/i,
	/\@eb.m0.net/i,
	/\@iomega.m0.net/i,
	/\@suretrade.com/i,
	/\@travelocity.com/i,
	/MoneyPreview_Editor.@TIMEINC.COM/i,
	/MONEYPREVIEW.@LISTSERV.PATHFINDER.COM/i,
	/moneypreview\@MONEY.CUSTOMERSVC.COM/i,
	/store-news\@amazon.com/i,
	/adaptec\@ntls1.digitalriver.com/i,
	/subscriptions\@mcafee.com/i,
	/barnesandnoble.com/i,
	/aheadadm\@TIMEINC.NET/i,
	/mobicon\@mobicon.org/i,
	/postoffice.booksamillion.com/i
       	{ ANNOTATE -d X-List Newsletters; REJECT NEWSLETTERS };
######################################################################
######################################################################
#                                                                    #
#                           Dispose of Mail                          #
#                                                                    #
######################################################################
######################################################################
<MailingList> {
        VACATION off;
	UNIQUE -a;
	TR #list /A-Z/a-z/;
	ANNOTATE -d X-MYLIST %#list.spool;
        #SAVE +%#list };
        PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.%#list/new >>$HOME/var/log/save;
	DELETE
};

<ADMIN>        { VACATION off;
		 #SAVE +.admin/new/
		 PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.admin/new/>>$HOME/var/log/save;
		 DELETE
	       };


<BAD, BAD_AGENT>
   { PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.bounced/new/>>$HOME/var/log/save ;
     DELETE
   };

<NEWSLETTERS> {
	  VACATION off;
	  UNIQUE -a;
	  PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.newsletters/new/ >>$HOME/var/log/save;
	  DELETE
	};

# Authenticated senders are often spammers
<!SPAM> Comments: /^Authenticated sender/i      { REJECT MAY_SPAM };

<MAY_SPAM> Subject: /money/i        { ANNOTATE -d X-Spam Money; REJECT SPAM };
<MAY_SPAM> X-Uidl: /^\w+$/i         { ANNOTATE -d X-Spam X-Uidl; REJECT SPAM };
<MAY_SPAM> Precedence: /^bulk/i     { ANNOTATE -d X-Spam Bulk; REJECT SPAM };
<MAY_SPAM>                          { REJECT INITIAL };

<REALSPAM>               { VACATION off;
                           PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.spam/new/ >>$HOME/var/log/save;
                           DELETE
                           };
<SPAM>         { VACATION off;
                 PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.spam/new/ >>$HOME/var/log/save;
	         DELETE
	       };
#ONCE (%r, spammessage, 1d) MESSAGE ~/etc/spam;

# The rest is potentially personal mail
<INITIAL> To Cc Sender:
    /jshardo\@golden-gryphon.com/
    { ANNOTATE -d X-List Work; REJECT ADDRESSED }
	;

<BLOCKED,LOST>  X-SBNote: /FROM_DAEMON\/Listserv/
{ UNIQUE -a;
  PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.newsletters/new/>>$HOME/var/log/save;
  DELETE
};
<BLOCKED,LOST>  X-SBPass: /Legitimate Mailing List/
	{ REJECT INITIAL };

# By default, beep three times for mail ending up in my mailbox
#

{ BEEP 3; REJECT };

<ADDRESSED>   {
                UNIQUE -a;
		ANNOTATE -d X-Spam Addressed;
                PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/new/>>$HOME/var/log/save;
		DELETE
	      };



# Now, this is not addressed to me, but it got through. How?
<LOST> /./    {
                UNIQUE -a;
		VACATION off;
                ANNOTATE -d X-Spam phony-address;
	        PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.misc/new/>>$HOME/var/log/save;
		DELETE
	      };

######################################################################
######################################################################
#                                                                    #
#                   final default rule                               #
#                                                                    #
######################################################################
######################################################################
#probably spam
{
	UNIQUE -a;
        ANNOTATE X-Spam unknown-not-me;
        PIPE /usr/bin/safecat $HOME/var/tmp $HOME/Maildir/.misc/new/>>$HOME/var/log/save;
	DELETE
};

######################################################################
######################################################################
#                                                                    #
#               End of mailagent rules                               #
#                                                                    #
######################################################################
######################################################################
