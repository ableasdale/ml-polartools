xquery version "1.0-ml";

declare variable $filename := xdmp:get-request-field("id");

(
    xdmp:set-response-content-type("application/zip"),
    xdmp:add-response-header("Content-Disposition", fn:concat("attachment; filename=", $filename)),
    doc($filename)
)
