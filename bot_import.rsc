/system script
add name=bot owner=admin policy=read,write,test source="##\r\
    \n#\r\
    \n# Telegram_bot reply script\r\
    \n# \r\
    \n# @author  Hernan Bartoletti - hernan at bartoletti dot com dot ar\r\
    \n# @version 1\r\
    \n# @date    2017-06-10\r\
    \n# - No rights reserved. \r\
    \n# - Use it at your own risk. We accept absolutely no liability whatsoeve\
    r. \r\
    \n#   If you choose to run this script, anything bad that happens is entir\
    ely \r\
    \n#   your problem.\r\
    \n# - Please do not modify this header.\r\
    \n# - Latest version at https://github.com/hernanbartoletti/ros-telegram_b\
    ot\r\
    \n#\r\
    \n# Distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF\
    \_\r\
    \n# ANY KIND, either express or implied.\r\
    \n#\r\
    \n##\r\
    \n#\r\
    \n# This script is intended to reply telegram bot commands. \r\
    \n#\r\
    \n##\r\
    \n#\r\
    \n# WARNING! Make sure that you carefully read the whole header\r\
    \n# This script is intended to make intensive write cycles, so be aware \r\
    \n# that if you use a flash memory for that, it will be permanently damage\
    d.\r\
    \n#         ** DO NOT USE THE INTERNAL FLASH MEMORY **\r\
    \n# USE AN EXTERNAL USB DEVICE. \r\
    \n# USE PREFERABLY A NON-FLASH BASED STORAGE, OTHERWISE REPLACE IT REGULAR\
    LY\r\
    \n# \r\
    \n##\r\
    \n#\r\
    \n# Changes that you need to make:\r\
    \n#  \r\
    \n# 1. botToken\r\
    \n# 2. botTmpFolder\r\
    \n# 3. Functions/Commands area\r\
    \n# 4. Command List definition\r\
    \n# 5. Debug options\r\
    \n#\r\
    \n##\r\
    \n\r\
    \n# 1. \r\
    \n# Modify the next line to match your botToken\r\
    \n:local botToken \"NNNNNNNNN:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX\";\r\
    \n\r\
    \n# 2.\r\
    \n# Modify the botTmpFolder and define the temporary directory that you wa\
    nt to use. \r\
    \n# BE ADVISED. DO NOT USE THE INTERNAL FLASH AS TEMP DIRECTORY. \r\
    \n# THE SCRIPT IS INTENDED TO MAKE INTENSIVE WRITE CYCLES, SO THE FLASH ME\
    MORY WILL PERMANENTLY DAMAGED.\r\
    \n# USE AN EXTERNAL USB DEVICE. USE PREFERABLY A NON-FLASH BASED STORAGE, \
    OR REPLACE IT REGULARLY.\r\
    \n:local botTmpFolder \"disk1/telegram/\"\r\
    \n\r\
    \n# 3.\r\
    \n# Functions/Commands area\r\
    \n:local getWanIP do={ :local addr [/ip address get [find interface=\"pppo\
    e-out1\"] address ]; :return [:pick \$addr 0 [:find \$addr \"/\"] ]  };\r\
    \n:local WiFiON do={ [/interface wireless enable wlan1]; :return \"Wi-Fi e\
    nabled\" };\r\
    \n:local WiFiOFF do={ [/interface wireless disable wlan1]; :return \"Wi-Fi\
    \_disabled\" };\r\
    \n\r\
    \n# 4.\r\
    \n# Command List definition\r\
    \n:local cmds { \"/public ip\"=\$getWanIP \\\r\
    \n            ; \"/public_ip\"=\$getWanIP \\\r\
    \n            ; \"/wan ip\"=\$getWanIP \\\r\
    \n            ; \"/wan_ip\"=\$getWanIP \\\r\
    \n            ; \"/wifi on\"=\$WiFiON \\\r\
    \n            ; \"/wifi_on\"=\$WiFiON \\\r\
    \n            ; \"/wifi off\"=\$WiFiOFF \\\r\
    \n            ; \"/wifi_off\"=\$WiFiOFF \\\r\
    \n            };\r\
    \n\r\
    \n# 5.\r\
    \n# Debug options\r\
    \n:local dbg true;\r\
    \n:local dbgput true;\r\
    \n\r\
    \n# DO NOT MODIFY THE SCRIPT BELOW THIS LINE, UNLESS YOU KNOW WHAT YOU ARE\
    \_DOING!\r\
    \n# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\
    -=-=-=-\r\
    \n:local values { \"update_id\"=\"\" \\\r\
    \n              ; \"chat_id\"=\"\" \\\r\
    \n              ; \"message\"=\"\" \\\r\
    \n              ; \"message_id\"=\"\" \\\r\
    \n              };\r\
    \n:local date [/system clock get date]\r\
    \n:local time [/system clock get time]\r\
    \n:local dd [:pick \$date 4 6]\r\
    \n:local mm [:pick \$date 0 3]\r\
    \n:local yyyy [:pick \$date 7 11]\r\
    \n:local hh [:pick \$time 0 2]\r\
    \n:local nn [:pick \$time 3 5]\r\
    \n:local ss [:pick \$time 6 8]\r\
    \n:local rcv; \r\
    \n:local offset 1;\r\
    \n:local fetchURL;\r\
    \n:local sendURL;\r\
    \n:local sendResponse;\r\
    \n:local filename (\$botTmpFolder.\"telegram_\$yyyy\$mm\$dd_\$hh\$nn\$ss.t\
    xt\")\r\
    \n:local filenamesend (\$botTmpFolder.\"telegram_\$yyyy\$mm\$dd_\$hh\$nn\$\
    ss_send.txt\")\r\
    \n\r\
    \n:set fetchURL \"https://api.telegram.org/bot\$botToken/getUpdates\\\?off\
    set=\$offset&limit=1\";\r\
    \n:if (\$dbg) do={ :log debug \$fetchURL; };\r\
    \n:if (\$dbgput) do={ :put \$fetchURL; };\r\
    \n\r\
    \n/tool fetch url=\$fetchURL mode=http keep-result=yes dst-path=\$filename\
    \r\
    \n:delay 1;\r\
    \n:if (\$dbgput) do={ :put \"Reading \$filename file\"; };\r\
    \n:set rcv [/file get [/file find name=\$filename] contents];\r\
    \n\r\
    \n:if (\$dbg) do= { :log debug \$update; };\r\
    \n:if (\$dbgput) do= { :put \$update; };\r\
    \n\r\
    \n:if ( \$rcv=\"{\\\"ok\\\":true,\\\"result\\\":[]}\") do={ \r\
    \n  :if (\$dbg) do={ :log debug \"no messages\"; };\r\
    \n  :if (\$dbgput) do={ :put \"no messages\"; };\r\
    \n} else={ \r\
    \n  :local findfrom { \"update_id\"=\"\\\"update_id\\\":\" \\\r\
    \n                         ; \"chat_id\"=\"\\\"chat\\\":{\\\"id\\\":\" \\\
    \r\
    \n                         ; \"message\"=\"\\\"text\\\":\\\"\" \\\r\
    \n                         ; \"message_id\"=\"\\\"message_id\\\":\" \\\r\
    \n                         }; \r\
    \n  :local finduntil { \"update_id\"=\",\" \\\r\
    \n                         ; \"chat_id\"=\",\" \\\r\
    \n                         ; \"message\"=\"\\\"\" \\\r\
    \n                         ; \"message_id\"=\",\" \\\r\
    \n                         }; \r\
    \n\r\
    \n  :if (\$dbg) do={ :log debug \"new message=\$rcv\"; };\r\
    \n  :if (\$dbgput) do={ :put \"new message=\$rcv\"; };\r\
    \n\r\
    \n  :foreach k,v in=\$findfrom do={\r\
    \n    :local bf [:find \$rcv \$v 1];\r\
    \n    :local l [:len \$v];\r\
    \n    :local bu [:find \$rcv (\$finduntil->\$k) (\$bf+\$l) ];\r\
    \n    :local ss [:pick \$rcv (\$bf+\$l) (\$bu)];\r\
    \n\r\
    \n    :set (\$values->\$k) \"\$ss\";\r\
    \n    :if (\$dbg) do={ :log debug (\$k .\": \". \$ss); };\r\
    \n    :if (\$dbgput) do={ :put (\$k .\": \". \$ss); };\r\
    \n  }\r\
    \n\r\
    \n  :if (\$dbg) do={ \r\
    \n    :log debug \"rcv=\$rcv\"; \r\
    \n    :log debug \"offset=\$offset\"; \r\
    \n    :log debug \"fetchURL=\$fetchURL\"; \r\
    \n    :log debug \"filename=\$filename\"; \r\
    \n\r\
    \n    :foreach k,v in=\$values do={\r\
    \n      :log debug \"\$k => \$v\";\r\
    \n    }\r\
    \n  }\r\
    \n\r\
    \n  :if (\$dbgput) do={ \r\
    \n    :put \"rcv=\$rcv\"; \r\
    \n    :put \"offset=\$offset\"; \r\
    \n    :put \"fetchURL=\$fetchURL\"; \r\
    \n    :put \"filename=\$filename\"; \r\
    \n\r\
    \n    :foreach k,v in=\$values do={\r\
    \n      :put \"\$k => \$v\";\r\
    \n    }\r\
    \n  }\r\
    \n\r\
    \n  :foreach k,v in=\$cmds do={\r\
    \n    :if (\$dbg) do={ :log debug \"\$k => \$v\"; };\r\
    \n    :if (\$dbgput) do={ :put \"\$k => \$v\"; };\r\
    \n    :if (\$k=(\$values->\"message\")) do= { \r\
    \n      :if (\$dbg) do={ :log debug \"match comand \$k\"; };\r\
    \n      :if (\$dbgput) do={ :put \"match comand \$k\"; };\r\
    \n      :set sendResponse [\$v];\r\
    \n    }\r\
    \n  }\r\
    \n \r\
    \n  :if (\$dbg) do={ \r\
    \n    :log debug \"sendResponse <\$sendResponse>\";\r\
    \n    :log debug (\"sendResponse type=\" . ([:typeof \$sendResponse]));\r\
    \n  }\r\
    \n  :if (\$dbgput) do={ \r\
    \n    :put \"sendResponse <\$sendResponse>\";\r\
    \n    :put (\"sendResponse type=\" . ([:typeof \$sendResponse]));\r\
    \n  }\r\
    \n\r\
    \n  :if ([:typeof \$sendResponse]=\"str\") do={\r\
    \n    :set sendURL (\"https://api.telegram.org/bot\$botToken/sendMessage\\\
    \?chat_id=\".(\$values->\"chat_id\").\"&text=\$sendResponse\");\r\
    \n    :if (\$dbg) do={ :log debug \$sendURL; };\r\
    \n    :if (\$dbgput) do={ :put \$sendURL; };\r\
    \n    /tool fetch url=\$sendURL mode=http keep-result=yes dst-path=(\$file\
    namesend);  \r\
    \n  } else {\r\
    \n    :if (\$dbg) do={ :log debug (\"Discarding unknown message '\" . (\$v\
    alues->\"message\") . \"'\"); };\r\
    \n    :if (\$dbgput) do={ :put (\"Discarding unknown message '\" . (\$valu\
    es->\"message\") . \"'\"); };\r\
    \n  }\r\
    \n\r\
    \n  :local consumeLastUpdateId (tonum(\$values->\"update_id\"));\r\
    \n  :if (\$dbg) do={ :log debug (\"consumeLastUpdateId \" . \$consumeLastU\
    pdateId); };\r\
    \n  :if (\$dbgput) do={ :put (\"consumeLastUpdateId \" . \$consumeLastUpda\
    teId); };\r\
    \n  :set fetchURL (\"https://api.telegram.org/bot\$botToken/getUpdates\\\?\
    offset=\" . (1+\$consumeLastUpdateId) . \"&limit=1\");\r\
    \n  :if (\$dbg) do={ :log debug \$fetchURL; };\r\
    \n  :if (\$dbgput) do={ :put \$fetchURL; };\r\
    \n  /tool fetch url=\$fetchURL mode=http keep-result=no \r\
    \n}\r\
    \n\r\
    \n/file remove \$filename; \r\
    \n/file remove \$filenamesend; \r\
    \n\r\
    \n"

/system scheduler
add comment="Process bot commands" disabled=yes interval=30s name=bot \
    on-event="/system script run bot" policy=read,write,test 
