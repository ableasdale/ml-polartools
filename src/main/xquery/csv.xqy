xquery version "1.0-ml"; 

import module namespace csv = "http://www.example.com/csv" at "/lib-csv.xqy";

declare variable $zip := xdmp:get-server-field("zip");
declare variable $filename := "test.csv";


(xdmp:set-response-content-type("application/csv"),
xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)),

(: Content-Disposition: attachment; filename="fname.ext" :)
 csv:unzip-data($zip))
