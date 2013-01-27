xquery version "1.0-ml"; 

import module namespace csv = "http://www.example.com/csv" at "/lib-csv.xqy";

declare variable $zip := xdmp:get-session-field("zip");
declare variable $filename := concat("output-",fn:current-dateTime(),".csv");


(xdmp:set-response-content-type("application/csv"),
xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)),
csv:generate-document($zip))
