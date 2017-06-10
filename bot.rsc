##
#
# RouterOS Telegram_bot reply script
# 
# @author  Hernan Bartoletti - hernan at bartoletti dot com dot ar
# @version 1
# @date    2017-06-10
# - No rights reserved. 
# - Use it at your own risk. We accept absolutely no liability whatsoever. 
#   If you choose to run this script, anything bad that happens is entirely 
#   your problem and your responsibility.
# - Please do not modify this header.
# - Latest version at https://github.com/hernanbartoletti/ros-telegram_bot
# - If this script was helpful to you, I would be grateful to know.
#
# Distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
# ANY KIND, either express or implied.
#
##
#
# This script is intended to reply telegram bot commands. 
#
##
#
# WARNING! Make sure that you carefully read the whole header
# This script is intended to make intensive write cycles, so be aware 
# that if you use a flash memory for that, it will be permanently damaged.
#         ** DO NOT USE THE INTERNAL FLASH MEMORY **
# USE AN EXTERNAL USB DEVICE. 
# USE PREFERABLY A NON-FLASH BASED STORAGE, OTHERWISE REPLACE IT REGULARY
# 
##
#
# Changes that you need to make:
#  
# 1. botToken
# 2. botTmpFolder
# 3. Functions/Commands area
# 4. Command List definition
# 5. Debug options
#
##

# 1. 
# Modify the next line to match your botToken
:local botToken "NNNNNNNNN:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";

# 2.
# Modify the botTmpFolder and define the temporary directory that you want to use. 
# BE ADVISED. DO NOT USE THE INTERNAL FLASH AS TEMP DIRECTORY. 
# THE SCRIPT IS INTENDED TO MAKE INTENSIVE WRITE CYCLES, SO THE FLASH MEMORY WILL PERMANENTLY DAMAGED.
# USE AN EXTERNAL USB DEVICE. USE PREFERABLY A NON-FLASH BASED STORAGE, OR REPLACE IT REGULARLY.
:local botTmpFolder "disk1/telegram/"

# 3.
# Functions/Commands area
:local getWanIP do={ :local addr [/ip address get [find interface="pppoe-out1"] address ]; :return [:pick $addr 0 [:find $addr "/"] ]  };
:local WiFiON do={ [/interface wireless enable wlan1]; :return "Wi-Fi enabled" };
:local WiFiOFF do={ [/interface wireless disable wlan1]; :return "Wi-Fi disabled" };

# 4.
# Command List definition
:local cmds { "/public ip"=$getWanIP \
            ; "/public_ip"=$getWanIP \
            ; "/wan ip"=$getWanIP \
            ; "/wan_ip"=$getWanIP \
            ; "/wifi on"=$WiFiON \
            ; "/wifi_on"=$WiFiON \
            ; "/wifi off"=$WiFiOFF \
            ; "/wifi_off"=$WiFiOFF \
            };

# 5.
# Debug options
:local dbg false;
:local dbgput false;

# DO NOT MODIFY THE SCRIPT BELOW THIS LINE, UNLESS YOU KNOW WHAT YOU ARE DOING!
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
:local values { "update_id"="" \
              ; "chat_id"="" \
              ; "message"="" \
              ; "message_id"="" \
              };
:local date [/system clock get date]
:local time [/system clock get time]
:local dd [:pick $date 4 6]
:local mm [:pick $date 0 3]
:local yyyy [:pick $date 7 11]
:local hh [:pick $time 0 2]
:local nn [:pick $time 3 5]
:local ss [:pick $time 6 8]
:local rcv; 
:local offset 1;
:local fetchURL;
:local sendURL;
:local sendResponse;
:local filename ($botTmpFolder."telegram_$yyyy$mm$dd_$hh$nn$ss.txt")
:local filenamesend ($botTmpFolder."telegram_$yyyy$mm$dd_$hh$nn$ss_send.txt")

:set fetchURL "https://api.telegram.org/bot$botToken/getUpdates\?offset=$offset&limit=1";
:if ($dbg) do={ :log debug $fetchURL; };
:if ($dbgput) do={ :put $fetchURL; };

/tool fetch url=$fetchURL mode=http keep-result=yes dst-path=$filename
:delay 1;
:if ($dbgput) do={ :put "Reading $filename file"; };
:set rcv [/file get [/file find name=$filename] contents];

:if ($dbg) do= { :log debug $update; };
:if ($dbgput) do= { :put $update; };

:if ( $rcv="{\"ok\":true,\"result\":[]}") do={ 
  :if ($dbg) do={ :log debug "no messages"; };
  :if ($dbgput) do={ :put "no messages"; };
} else={ 
  :local findfrom { "update_id"="\"update_id\":" \
                  ; "chat_id"="\"chat\":{\"id\":" \
                  ; "message"="\"text\":\"" \
                  ; "message_id"="\"message_id\":" \
                  }; 
  :local finduntil { "update_id"="," \
                   ; "chat_id"="," \
                   ; "message"="\"" \
                   ; "message_id"="," \
                   }; 

  :if ($dbg) do={ :log debug "new message=$rcv"; };
  :if ($dbgput) do={ :put "new message=$rcv"; };

  :foreach k,v in=$findfrom do={
    :local bf [:find $rcv $v 1];
    :local l [:len $v];
    :local bu [:find $rcv ($finduntil->$k) ($bf+$l) ];
    :local ss [:pick $rcv ($bf+$l) ($bu)];

    :set ($values->$k) "$ss";
    :if ($dbg) do={ :log debug ($k .": ". $ss); };
    :if ($dbgput) do={ :put ($k .": ". $ss); };
  }

  :if ($dbg) do={ 
    :log debug "rcv=$rcv"; 
    :log debug "offset=$offset"; 
    :log debug "fetchURL=$fetchURL"; 
    :log debug "filename=$filename"; 

    :foreach k,v in=$values do={
      :log debug "$k => $v";
    }
  }

  :if ($dbgput) do={ 
    :put "rcv=$rcv"; 
    :put "offset=$offset"; 
    :put "fetchURL=$fetchURL"; 
    :put "filename=$filename"; 

    :foreach k,v in=$values do={
      :put "$k => $v";
    }
  }

  :foreach k,v in=$cmds do={
    :if ($dbg) do={ :log debug "$k => $v"; };
    :if ($dbgput) do={ :put "$k => $v"; };
    :if ($k=($values->"message")) do= { 
      :if ($dbg) do={ :log debug "match comand $k"; };
      :if ($dbgput) do={ :put "match comand $k"; };
      :set sendResponse [$v];
    }
  }
 
  :if ($dbg) do={ 
    :log debug "sendResponse <$sendResponse>";
    :log debug ("sendResponse type=" . ([:typeof $sendResponse]));
  }
  :if ($dbgput) do={ 
    :put "sendResponse <$sendResponse>";
    :put ("sendResponse type=" . ([:typeof $sendResponse]));
  }

  :if ([:typeof $sendResponse]="str") do={
    :set sendURL ("https://api.telegram.org/bot$botToken/sendMessage\?chat_id=".($values->"chat_id")."&text=$sendResponse");
    :if ($dbg) do={ :log debug $sendURL; };
    :if ($dbgput) do={ :put $sendURL; };
    /tool fetch url=$sendURL mode=http keep-result=yes dst-path=($filenamesend);  
  } else {
    :if ($dbg) do={ :log debug ("Discarding unknown message '" . ($values->"message") . "'"); };
    :if ($dbgput) do={ :put ("Discarding unknown message '" . ($values->"message") . "'"); };
  }

  :local consumeLastUpdateId (tonum($values->"update_id"));
  :if ($dbg) do={ :log debug ("consumeLastUpdateId " . $consumeLastUpdateId); };
  :if ($dbgput) do={ :put ("consumeLastUpdateId " . $consumeLastUpdateId); };
  :set fetchURL ("https://api.telegram.org/bot$botToken/getUpdates\?offset=" . (1+$consumeLastUpdateId) . "&limit=1");
  :if ($dbg) do={ :log debug $fetchURL; };
  :if ($dbgput) do={ :put $fetchURL; };
  /tool fetch url=$fetchURL mode=http keep-result=no 
}

/file remove $filename; 
/file remove $filenamesend; 

