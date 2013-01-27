xquery version "1.0-ml";

(: 

MarkLogic loader / processor 
Converts an individual hrm (text) file into XML and inserts into ML

:)

import module namespace common = "http://www.example.com/common" at "/common.xqy";
declare namespace zip="xdmp:zip";
declare variable $zip := xdmp:get-server-field("zip");



declare function local:as-xml($item){
element PolarHrmData {
    local:get-params($item),
    local:get-heartrates($item)
}
};

declare function local:get-params($item){
    let $section := substring-before($item, "[Note]")
    return 
    for $line in common:tokenize-lines($section)
    where contains($line, "=")
    return common:create-element(substring-before($line,"="),substring-after($line,"=")) 
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
for $x at $pos in xdmp:zip-manifest($zip)//zip:part/text()
where (fn:ends-with($x, ".hrm"))
order by $x ascending
return
(   
xdmp:document-insert($pos cast as xs:string, local:as-xml(xdmp:zip-get($zip, $x, <options xmlns="xdmp:zip-get">
	  <format>text</format>
	</options>))
)
)
};

( local:unzip-data(), xdmp:redirect-response("/dashboard.xqy") )
