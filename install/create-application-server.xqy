xquery version "1.0-ml";

(:~
: Application Server Setup Module - largely incomplete 
:
: @version 1.0
:)

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
import module namespace info = "http://marklogic.com/appservices/infostudio" at "/MarkLogic/appservices/infostudio/info.xqy";

(:::::::::::::::::::::::::::)
(: Configuration Variables :)
(:::::::::::::::::::::::::::)

declare variable $PORT as xs:integer := 9995;
declare variable $FILE-PATH as xs:string := "C:\Users\YOUR-NAME-HERE\workspace\ml-polartools\src\main\xquery";
declare variable $DATABASE-NAME as xs:string := "Polar";

(: TODO - create separate Polar database for this - configure with the Collection Lexicon enabled :)
(: TODO - initial permissions (nobody) inadequate to use the application :)

(::::::::::::::::::::::::::::)
(: Module Library Functions :)
(::::::::::::::::::::::::::::)


declare function local:create-database() {
    info:database-create($DATABASE-NAME, 1)
};
  
declare function local:create-http-application-server() {
  let $config := admin:get-configuration()
  let $config := admin:http-server-create($config, admin:group-get-id($config, "Default"), concat("http-", $PORT),
        $FILE-PATH, $PORT, 0, xdmp:database($DATABASE-NAME) )
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

(local:create-database(), local:create-http-application-server())