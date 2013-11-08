xquery version "1.0-ml";

(: 

MarkLogic loader / processor 
Converts an individual hrm (text) file into XML and inserts into ML

:)

import module namespace common = "http://www.example.com/common" at "/common.xqy";
declare namespace zip="xdmp:zip";
declare variable $zip := xdmp:get-session-field("zip");



declare function local:as-xml($item){
element PolarHrmData {
    local:get-params($item),
    local:get-heartrates($item)
}
};

declare function local:parse-date($date as xs:string) as xs:date {
    xs:date(concat(fn:substring($date, 1, 4),"-",fn:substring($date, 5, 2),"-",fn:substring($date, 7, 2)))
};

(: TODO - Script creation of xs:date and xs:time range indexes AND enable collection Lexicon! :)
declare function local:get-params($item){
    let $section := substring-before($item, "[Note]")
    return 
    for $line in common:tokenize-lines($section)
    where contains($line, "=")
    return 
    if (substring-before($line,"=") eq "Date")
    then (let $xsdate := local:parse-date(substring-after($line,"="))
    return 
    common:create-element(substring-before($line,"="), $xsdate)
    ) else if ( contains(substring-before($line,"="),"Length") or substring-before($line,"=") eq "StartTime")
    then (common:create-element(substring-before($line,"="), xs:time(substring-after($line,"=")))) 
    else (common:create-element(substring-before($line,"="),substring-after($line,"=")))
};

declare function local:get-heartrates($item){
 element HeartRateReadings {
   for $i in common:tokenize-lines(substring-after($item, "[HRData]"))
   where string-length($i) ge 1
   return common:create-element("HeartRateReading", $i)
}   
};

(: ENTRY POINT for MODULE :)
declare function local:unzip-data(){
for $x in xdmp:zip-manifest($zip)//zip:part/text()
where (fn:ends-with($x, ".hrm"))
order by $x ascending
return
(   
xdmp:document-insert(common:guid(), local:as-xml(xdmp:zip-get($zip, $x, <options xmlns="xdmp:zip-get">
	  <format>text</format>
	</options>)), (), xdmp:get-session-field("collection")
)
)
};

(: Module Main :)
(
    (: Load the zip into the stand along with everything else - these are very small files - so no bothering with Large Binaries... :)
    xdmp:document-insert(
        concat(common:guid(),".zip"), 
        $zip, 
        (), 
        xdmp:get-session-field("collection")
    ), 
    local:unzip-data(), 
    xdmp:redirect-response("/dashboard.xqy") 
)
