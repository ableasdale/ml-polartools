xquery version "1.0-ml"; 

module namespace csv="http://www.example.com/csv";
import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare namespace zip="xdmp:zip";

declare function csv:unzip-data($zipfile){
for $x in xdmp:zip-manifest($zipfile)//zip:part/text()
where (fn:ends-with($x, ".hrm"))
order by $x ascending
return
(   string-join( (csv:process-record($zipfile, $x), csv:process-heartrates($zipfile, $x)), ",") )
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
     some $searchString in ("StartTime", "Date") satisfies contains($arg, $searchString)
};

declare function csv:process-heartrates($zipfile, $x as xs:string){
	tokenize(substring-after(xdmp:zip-get($zipfile, $x, <options xmlns="xdmp:zip-get">
	  <format>text</format>
	</options>), "[HRData]"),'(\r\n?|\n\r?)')
};

declare function csv:process-line($line){
    substring-after($line,"=")
};
