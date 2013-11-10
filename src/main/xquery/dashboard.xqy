xquery version "1.0-ml";

import module namespace common = "http://www.example.com/common" at "/common.xqy";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

declare variable $collection := local:check-collection(); 

(: TODO - there is no error checking in this right now :)
declare function local:check-collection(){
if (string-length(xdmp:get-request-field("change-collection")) gt 0)
then (xdmp:set-session-field("collection", xdmp:get-request-field("change-collection")))
else (xdmp:get-session-field("collection"))
};

declare function local:original-zip() {
    element fieldset {
        element legend {"Download and Export: "},
        for $i in collection($collection)
        where ends-with(xdmp:node-uri($i), ".zip")
        return
        element p {"[ Original zip file: ", element a {attribute title {"Export the original zip file you imported to create the collection"}, attribute href {concat("/get-zip.xqy?id=", xdmp:node-uri($i))}, xdmp:node-uri($i)}, " ] [ Export data: ", element a {attribute title {"Export the data in a format suitable for Microsoft Excel (one row per record)"}, attribute href {concat("/csv.xqy?id=", xdmp:node-uri($i))}, "Excel CSV"}, " ] [ Export data: ", element a {attribute title {"Export the data in a format suitable for Matlab (one column per record)"}, attribute href {concat("/matlab-csv.xqy?id=", $collection)}, "Matlab CSV"} ," ]"}
    }    
};

(: anything less than a minute is discarded / todo - placed in another table? :)

declare function local:table(){
<table>
<tr>
<th>Date</th>
<th>Start Time</th>
<th>Length</th>
<th>Max HR</th>
<th>Resting HR</th>
<th>Weight</th>
<th>Details</th>
<th>Preview</th>
</tr>
{
for $i in collection($collection)/PolarHrmData/..
where $i/PolarHrmData/Length gt xs:time("00:01:00")
order by xs:date($i/PolarHrmData/Date)
return 
<tr>
<td>{$i/PolarHrmData/Date}</td>
<td>{$i/PolarHrmData/StartTime}</td>
<td>{$i/PolarHrmData/Length}</td>
<td>{$i/PolarHrmData/MaxHR}</td>
<td>{$i/PolarHrmData/RestHR}</td>
<td>{$i/PolarHrmData/Weight}</td>
<td>{
element a {attribute href { fn:concat("/detail.xqy?id=", xdmp:node-uri($i)) }}, "Details"
}
</td>
<td><span class="inlinesparkline">{ string-join ($i/PolarHrmData/HeartRateReadings/HeartRateReading, ",")}</span></td>
</tr>
}
</table>};

(: {fn:format-date($i/PolarHrmData/Date, "[Y01]/[M01]/[D01]")} :)
common:build-page(
element div {attribute class {"container"},
    common:html-page-header("Polar ProTrainer Tools : Dashboard"),
    element h3 {"Current Collection: ", $collection},
    element div {local:original-zip()},
    element h3 {"Exercise records:"},
    element div {local:table()},
    common:html-page-footer()
})
