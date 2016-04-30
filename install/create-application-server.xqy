xquery version "1.0-ml";

(:~
: Application Server Setup Module  
:
: NOTE - this version of the script configures the application to work with ADMIN rights and will need to be modified 
: if you need the application to be properly secured 
:
: @version 1.0
:)

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
import module namespace info = "http://marklogic.com/appservices/infostudio" at "/MarkLogic/appservices/infostudio/info.xqy";

(:::::::::::::::::::::::::::)
(: Configuration Variables :)
(:::::::::::::::::::::::::::)

declare variable $PORT as xs:integer := 9990;
declare variable $FILE-PATH as xs:string := "C:\Users\%YOUR-USER-NAME-HERE%\workspace\ml-polartools\src\main\xquery";
declare variable $DATABASE-NAME as xs:string := "PolarTools";

(::::::::::::::::::::::::::::)
(: Module Library Functions :)
(::::::::::::::::::::::::::::)


declare function local:create-database() {
    info:database-create($DATABASE-NAME, 1)
};

(: TODO (FIX) - this assumes the user is admin - so won't do anything if there isn't an admin user configured on the system... :)
declare function local:create-http-application-server() {
  let $config := admin:get-configuration()
  let $config := admin:database-set-collection-lexicon($config, xdmp:database($DATABASE-NAME), fn:true())
  let $config := admin:http-server-create($config, admin:group-get-id($config, "Default"), concat("http-", $PORT),
        $FILE-PATH, $PORT, 0, xdmp:database($DATABASE-NAME) )
  let $config := admin:appserver-set-authentication($config,
         admin:appserver-get-id($config, admin:group-get-id($config, "Default"), concat("http-", $PORT)),
         "application-level")
  let $config := admin:appserver-set-default-user($config, 
         admin:appserver-get-id($config, admin:group-get-id($config, "Default"), concat("http-", $PORT)),
	 xdmp:eval('xquery version "1.0-ml";
                  import module "http://marklogic.com/xdmp/security" 
		    at "/MarkLogic/security.xqy"; 
	          sec:uid-for-name("admin")', (),  
	   <options xmlns="xdmp:eval">
		 <database>{xdmp:security-database()}</database>
	   </options>))       
  return
  admin:save-configuration($config)
};

(::::::::::::::::::::::::::)
(: Main Module Code below :)
(::::::::::::::::::::::::::)

(: To install: copy and paste entire module into a buffer in Query Console and execute :)

(local:create-database(), local:create-http-application-server())