xquery version "1.0-ml";

declare variable $COLLECTION := xdmp:get-request-field("id", ());
declare variable $filename := concat($COLLECTION,"-",fn:current-dateTime(),".csv");

declare function local:get-largest-reading($collection as xs:string) as xs:integer {
  let $counts := for $i in collection($collection)/PolarHrmData/HeartRateReadings
  return count($i/HeartRateReading)
  return max($counts)
};

declare function local:generate-matlab-csv-row($collection as xs:string, $qname as xs:string) as xs:string* {
  for $i in collection($collection)/PolarHrmData/..
  let $row := $i/PolarHrmData/*[name()=$qname]/text()
  where $i/PolarHrmData/Length gt xs:time("00:01:00")
  order by xs:date($i/PolarHrmData/Date)
  return $row
};  

declare function local:generate-matlab-csv-line($collection as xs:string, $pos as xs:integer) as xs:string* {
  for $i in collection($collection)/PolarHrmData/..
  let $row := if (exists($i/PolarHrmData/HeartRateReadings/HeartRateReading[$pos]/text()))
  then ($i/PolarHrmData/HeartRateReadings/HeartRateReading[$pos]/text())
  else ("0")
  where $i/PolarHrmData/Length gt xs:time("00:01:00")
  order by xs:date($i/PolarHrmData/Date)
  return $row
};  

(xdmp:set-response-content-type("application/csv"),
xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)),
(string-join(local:generate-matlab-csv-row($COLLECTION, "Date"), ","),
string-join(local:generate-matlab-csv-row($COLLECTION, "StartTime"), ","),
string-join(local:generate-matlab-csv-row($COLLECTION, "Length"), ","),
for $x in 1 to local:get-largest-reading($COLLECTION)
return string-join(local:generate-matlab-csv-line($COLLECTION, $x), ","))
)