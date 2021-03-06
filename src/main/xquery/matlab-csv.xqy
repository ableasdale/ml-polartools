xquery version "1.0-ml";

declare variable $COLLECTION := xdmp:get-request-field("id", ());
declare variable $filename := concat($COLLECTION,"-",fn:current-dateTime(),".csv");
declare variable $CSV-HEADERS := 3;

declare function local:date-as-unix-epoch($date as xs:date) as xs:string {
  xs:string(fn:round(( $date cast as xs:dateTime - xs:dateTime("1970-01-01T00:00:00-00:00")) div xs:dayTimeDuration('PT1S'))) 
};

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

declare function local:matlab-date($date as xs:date) {
    format-date($date, "[D01]-[MNn,*-3]-[Y]", "en", (), ())
};

declare function local:get-cell-boundaries($collection) as xs:string {
    string-join( 
        (xs:string(count(collection($collection)/PolarHrmData)), xs:string( (local:get-largest-reading($collection) + $CSV-HEADERS)))
        , ",")
};

(xdmp:set-response-content-type("application/csv"),
xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)),
(
(: let $epochs := for $y in local:generate-matlab-csv-row($COLLECTION, "Date")
let $epoch := local:date-as-epoch(xs:date($y))
return $epoch
return string-join($epochs, ","), :)
local:get-cell-boundaries($COLLECTION),
let $dates := for $y in local:generate-matlab-csv-row($COLLECTION, "Date")
let $date := local:matlab-date(xs:date($y))
return $date
return string-join($dates, ","),

(: string-join(local:generate-matlab-csv-row($COLLECTION, "Date"), ","), :) 
string-join(local:generate-matlab-csv-row($COLLECTION, "StartTime"), ","),
string-join(local:generate-matlab-csv-row($COLLECTION, "Length"), ","),
for $x in 1 to local:get-largest-reading($COLLECTION)
return string-join(local:generate-matlab-csv-line($COLLECTION, $x), ","))
)