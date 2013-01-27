xquery version "1.0-ml"; 

import module namespace json="http://marklogic.com/xdmp/json"
 at "/MarkLogic/json/json.xqy";

declare variable $uri as xs:string := xdmp:get-request-field("id");
declare variable $output as xs:string := xdmp:get-request-field("output", "xml");

(: TODO - PDF at some stage? :)
(: xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)), :)

if($output eq "json")
then ( 
let $config := json:config("custom")
    let $_ := map:put( $config, "whitespace", "ignore" )
    let $_ := map:put( $config, "camel-case", "true" )
    let $_ := map:put( $config, "array-element-names", (xs:QName("HeartRateReading")) )    
        
return 
    
    (xdmp:set-response-content-type("application/json"), 
    json:transform-to-json( doc($uri), $config)) 
    
) else (
(xdmp:set-response-content-type("text/xml"),
doc($uri))
)
