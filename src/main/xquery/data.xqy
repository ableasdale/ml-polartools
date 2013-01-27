xquery version "1.0-ml"; 

declare variable $uri as xs:string := xdmp:get-request-field("id");
declare variable $outpur as xs:string := xdmp:get-request-field("output", "xml");


(: xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)), :)

(xdmp:set-response-content-type("text/xml"),
doc($uri))
