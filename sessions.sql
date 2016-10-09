select sid,serial#, terminal, OSUSER, USERNAME, ACTION, LOGON_TIME from v$session
order by LOGON_TIME desc
