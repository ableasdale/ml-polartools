xquery version "1.0-ml";

(:~
: Application Server Setup Module - largely incomplete 
:
: @version 1.0
:)

import module namespace admin = "http://marklogic.com/xdmp/admin"
at "/MarkLogic/admin.xqy";

 
declare variable $PORT as xs:integer := 9995;
declare variable $FILE-PATH as xs:string := "C:\Users\YOUR-NAME-HERE\workspace\ml-polartools\src\main\xquery";

(: TODO - create separate database for this - rather than Documents :)

declare function local:create-http-application-server() {
  let $config := admin:get-configuration()
  let $config := admin:http-server-create($config, admin:group-get-id($config, "Default"), concat("http-", $PORT),
        $FILE-PATH, $PORT, 0, xdmp:database("Documents") )
  let $config := admin:appserver-set-authentication($config,
         admin:appserver-get-id($config, admin:group-get-id($config, "Default"), concat("http-", $PORT)),
         "application-level")
  return
  admin:save-configuration($config)
};

(::::::::::::::::::::::::::)
(: Main Module Code below :)
(::::::::::::::::::::::::::)

(: To install: copy and paste entire module into a buffer in Query Console and execute :)

local:create-http-application-server()