xquery version "1.0-ml"; 

module namespace csv="http://www.example.com/csv";
import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace zip="xdmp:zip";


declare function csv:generate-document($zipfile) {
    let $original-document := csv:generate-unpadded-document($zipfile)
    return
    
    let $longest := csv:find-longest-column($original-document)
    return
    
    let $updated :=
    for $line in $original-document
    return csv:pad-line($line, count(tokenize($line, ",")), $longest)
    return $updated
    
};

declare function csv:pad-line($line as xs:string, $line-count as xs:unsignedLong, $max as xs:unsignedLong) as xs:string {
    string-join (($line, for $i in ($line-count to $max - 1) return "0,") , '')
};

declare function csv:find-longest-column($doc) as xs:unsignedLong {
   let $ordered := for $line in $doc
   return max(count(tokenize($line, ",")))
   return max($ordered)
};

declare function csv:generate-unpadded-document($zipfile) as xs:string+ {
    for $x in xdmp:zip-manifest($zipfile)//zip:part/text()
    where (fn:ends-with($x, ".hrm"))
    order by $x ascending
    return replace(string-join( (csv:process-record($zipfile, $x), csv:process-heartrates($zipfile, $x)), ","),",,", ",") 
};

declare function csv:process-record($zipfile, $x as xs:string){
  let $data := xdmp:zip-get($zipfile, $x, <options xmlns="xdmp:zip-get">
	  <format>text</format>
	</options>)
  return
  for $line in common:tokenize-lines($data)
  where csv:is-useful($line)
  return 
  substring-after($line,"=")
};

declare function csv:is-useful($arg){
     some $searchString in ("Date", "StartTime", "Length") satisfies contains($arg, $searchString)
};

declare function csv:process-heartrates($zipfile, $x as xs:string){
	tokenize(substring-after(xdmp:zip-get($zipfile, $x, <options xmlns="xdmp:zip-get">
	  <format>text</format>
	</options>), "[HRData]"),'(\r\n?|\n\r?)')
};

declare function csv:process-line($line){
    substring-after($line,"=")
};
