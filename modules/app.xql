xquery version "3.1" encoding "UTF-8";

module namespace app="http://jannikBriefe.de/templates";

import module namespace templates="http://exist-db.org/xquery/templates";
import module namespace config="http://jannikBriefe.de/config" at "config.xqm";
import module namespace shared="http://jannikBriefe.de/shared" at "shared.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";
import module namespace http="http://expath.org/ns/http-client";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace functx = "http://www.functx.com";

declare function app:test($node as node(), $model as map(*)) {
    let $hallo := 'hallo'
    return
        $hallo
};

declare function local:test2() {
    let $works := collection('/db/apps/silcherWerkverzeichnis/data/works')
    let $list := for $work in $works
                    return
                        <p>{$work//mei:incipit}</p>
    return
        $list
};

declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 };

declare function functx:substring-before-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 };
 
 declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   replace ($arg,concat('^.*',functx:escape-for-regex($delim)),'')
 };

declare %templates:wrap function app:showFilter($node as node(), $model as map(*)) {
    let $hallo := 'hallo'
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/works')
    let $works := $collection//mei:mei[starts-with(@xml:id, 'work')]
    return
    <div class="form-row">
        <div class="form-group col-md-4 mx-4">
            <div class="form-row mb-3">
                <label for="freitextsuche">Freitextsuche nach Liedtiteln</label>
                <input type="freitext" class="form-control" id="freitextsuche"/>
            </div>
            <div class="form-row">
                <label for="dropdown">Gattungen</label>
                <select class="custom-select" id="dropdown">
                    <option value="all">Alle Gattungen</option>
                    <option value="song">Lieder mit Klavierbegleitung</option>
                    <option value="male-choir">Männerchöre</option>
                    <option value="mixed-choir">Gemischte Chöre</option>
                    <option value="canon">Kanons</option>
                    <option value="instrumental">Instrumentalwerke</option>
                </select>
            </div>
            <div class="form-row mt-4">
                <button type="button" class="btn btn-primary" id="btn-submit">Filter anwenden</button>
            </div>
            <div class="form-row" id="countScore"></div>
        </div>
        <div class="form-group col my-0 mx-5">
            <div class="row my-4">
                <!-- <div class="col-md-4">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="individualWorks" value="individualWork" name="customRadioInline1" class="custom-control-input"/>
                        <label class="custom-control-label" for="individualWorks">Einzelwerke</label>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="workCollections" value="collection" name="customRadioInline1" class="custom-control-input"/>
                        <label class="custom-control-label" for="workCollections">Sammlungen</label>
                    </div>
                </div> -->
                <div class="switch-container">
                    <label for="choose">Einzelwerke</label>
                    <label class="switch">
                        <input id="choose" type="checkbox"/>
                        <span class="slider round"></span>
                    </label>
                    <label for="choose">Werksammlungen</label>
                </div>
            </div>
            <p>Suche einschränken:</p>
            <div class="row mb-1">
                <div class="col-md-6">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="opusWorks" value="opus" name="customRadioInline2" class="custom-control-input"/>
                        <label class="custom-control-label" for="opusWorks">Opuswerke</label>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="worksWithoutOpus" value="WoO" name="customRadioInline2" class="custom-control-input"/>
                        <label class="custom-control-label" for="worksWithoutOpus">Werke ohne Opuszahl</label>
                    </div>
                </div>
            </div>
            <div class="row mb-1">
                <div class="col-md-6">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="composition" value="composer" name="customRadioInline3" class="custom-control-input"/>
                        <label class="custom-control-label" for="composition">Kompositionen Silchers</label>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="custom-control custom-radio custom-control-inline">
                        <input type="radio" id="arrangement" value="arranger" name="customRadioInline3" class="custom-control-input"/>
                        <label class="custom-control-label" for="arrangement">Bearbeitungen Silchers</label>
                    </div>
                </div>
            </div>
            <div class="custom-control custom-radio mb-1">
                <input type="radio" id="allWorks" value="allWorks" name="allWorks" class="custom-control-input"/>
                <label class="custom-control-label" for="allWorks">Keine Filter</label>
            </div>
        </div>
        
    </div>
};

declare %templates:wrap function app:viewWork($node as node(), $model as map(*)) {
    let $workId := request:get-parameter('workId','invalid')
    let $work := collection('/db/apps/silcherWerkverzeichnis/data/works')//mei:mei[@xml:id = $workId]
    let $workTitle := $work//mei:work/mei:title[@type="main"]/text()
    let $opus := shared:getOpusNumber($work)
    let $workNumber := shared:getWorkNumber($work)
    let $workType := shared:getWorkType($work)
    let $persons := collection('/db/apps/silcherWerkverzeichnis/data/persons')
    let $collection := shared:getWorkCollection($work)
    let $collectionTitle := if ($collection)
                            then (string-join($collection//mei:workList/mei:work/mei:title/string(), '. '))
                            else ('##')
    let $collectionId := if ($collection) then ($collection/@xml:id) else ()
    let $composer := if ($work//mei:work/mei:composer/mei:persName/@auth)
                        then ($persons/id($work//mei:work/mei:composer/mei:persName/@auth)/tei:persName/*[not(@type = "unused")])
                        else if ($work//mei:work/mei:composer/mei:persName/text())
                        then ($work//mei:work/mei:composer/mei:persName/text())
                        else if (normalize-space($work//mei:work/mei:composer/text()[1]) != '')
                        then ($work//mei:work/mei:composer/text())
                        else ('unbekannt')
    let $composerId := if ($work//mei:work/mei:composer/mei:persName/@auth)
                        then ($work//mei:work/mei:composer/mei:persName/@auth)
                        else ()
    let $arranger := if ($work//mei:work/mei:arranger/mei:persName/@auth)
                        then ($persons/id($work//mei:work/mei:arranger/mei:persName/@auth)/tei:persName/*[not(@type = "unused")])
                        else if ($work//mei:work/mei:arranger/mei:persName/text())
                        then ($work//mei:work/mei:arranger/mei:persName/text())
                        else if (normalize-space($work//mei:work/mei:arranger/text()[1]) != '')
                        then ($work//mei:work/mei:arranger/text())
                        else ()
    let $arrangerId := if ($work//mei:work/mei:arranger/mei:persName/@auth)
                        then ($work//mei:work/mei:arranger/mei:persName/@auth)
                        else ()
    let $lyricist := if ($work//mei:work/mei:lyricist/mei:persName/@auth)
                        then ($persons/id($work//mei:work/mei:lyricist/mei:persName/@auth)/tei:persName/*[not(@type = "unused")])
                        else if ($work//mei:work/mei:lyricist/mei:persName/text())
                        then ($work//mei:work/mei:lyricist/mei:persName/text())
                        else if (normalize-space($work//mei:work/mei:lyricist/text()[1]) != '')
                        then ($work//mei:work/mei:lyricist/text())
                        else ('unbekannt')
    let $lyricistId := if ($work//mei:work/mei:lyricist/mei:persName/@auth)
                            then ($work//mei:work/mei:lyricist/mei:persName/@auth)
                            else ()
    let $dedication := if ($work//mei:work//mei:creation/mei:dedication)
                            then (normalize-space($work//mei:work//mei:creation/mei:dedication))
                            else ()
    let $ambitus := if ($work//mei:score//mei:staffDef/mei:ambitus)
                        then (shared:getAmbitus($work//mei:score//mei:staffDef/mei:ambitus))
                        else ()
    let $perfResList := if ($work//mei:work/mei:perfMedium/mei:perfResList/mei:perfRes)
                            then ($work//mei:work/mei:perfMedium/mei:perfResList/mei:perfRes)
                            else ()
    let $perfRes := if ($perfResList)
                        then (shared:getPerfRes($perfResList, $ambitus))
                        else ('##')
    let $publicationDate := $work//mei:eventList/mei:event[@type="publication"]/mei:date/substring-before(@isodate, '-')
    let $facsimile := if ($work//mei:facsimile/mei:surface/mei:graphic/@target)
                        then (for $surface in $work//mei:facsimile/mei:surface
                                let $url := $surface/mei:graphic/@target
                                return
                                    $url
                             )
                        else ()
    let $multiplePages := if ($work//mei:facsimile/mei:surface[position() > 1])
                            then (1)
                            else (0)
    let $sourceLocation := if ($work//mei:manifestationList//mei:item/mei:physLoc)
                            then (for $item in $work//mei:manifestationList//mei:item
                                    let $corpName := $item//mei:corpName/text()
                                    let $settlement := $item//mei:settlement/text()
                                    let $shelfmark := $item//mei:identifier[@type = 'shelfmark']/text()
                                    return
                                        concat($settlement, ', ', $corpName, ' &#8211; ', $shelfmark)
                            )
                            else if($work//mei:manifestationList//mei:item[@target])
                                then (for $item in $work//mei:manifestationList//mei:item[@target]
                                        let $id := substring-after($item/@target, '#')
                                        let $docItem := $collection//id($id)
                                        let $corpName := $docItem//mei:corpName/text()
                                        let $settlement := $docItem//mei:settlement/text()
                                        let $shelfmark := $docItem//mei:identifier[@type = 'shelfmark']/text()
                                        return
                                            concat($settlement, ', ', $corpName, ' &#8211; ', $shelfmark)
                            )
                            else ()
    let $sourceLocationUri := if ($work//mei:manifestationList//mei:identifier[@type = 'urn'])
                                then ($work//mei:manifestationList//mei:identifier[@type = 'urn'])
                              else if($work//mei:manifestationList//mei:item[@target])
                                then ($collection//mei:manifestationList//mei:identifier[@type = 'urn'])
                                else ()
    let $sourceLocationLink := if ($sourceLocationUri)
                                then (<a href="{concat($sourceLocationUri/@xml:base, $sourceLocationUri/text())}" target="_blank" class="external-link">{$sourceLocationUri/text()}<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Icon_External_Link.svg/12px-Icon_External_Link.svg.png"/></a>)
                                else ()
    let $songTextNormalized := if ($work//mei:div[@type = 'songtext']//mei:lg[@type = 'poem'])
                                then ($work//mei:div[@type = 'songtext']//mei:lg[@type = 'poem'])
                                else ()
    let $headNorm := $songTextNormalized/mei:head
    let $stanzasNorm := $songTextNormalized/mei:lg[@type = 'stanza']
    let $poemBodyNorm := for $stanza in $stanzasNorm
                        let $lines := $stanza/mei:l
                        return
                            <div class="stanza">
                            {for $line in $lines
                             return
                                <p class="line">{$line}</p>
                            }
                            </div>
    let $stanzasTrans := $work//mei:staff[@n = 1]//mei:verse
    let $poemBodyTrans := for $stanza in distinct-values($stanzasTrans/@n)
                            let $text := $stanzasTrans[@n = $stanza]/mei:syl
                            let $textJoined := for $syl at $i in $text
                                return
                                    if ($syl[@wordpos = 'i'] or $syl[@wordpos = 'm'])
                                    then (<span>{concat($syl, $syl[$i + 1])}</span>)
                                    else(concat($syl, ' '))
                            return
                                <div>{$textJoined}</div>
    let $textTemplate := if ($work//mei:div[@type = 'textTemplate'])
                            then ($work//mei:div[@type = 'textTemplate']/mei:p/text())
                            else ()
    let $otherSettings := if ($work//mei:div[@type = 'otherSettings']/mei:list)
                                then ($work//mei:div[@type = 'otherSettings']/mei:list/mei:li)
                                else ()
    let $showSettings := for $setting in $otherSettings
                            return
                                <p>{transform:transform($setting, doc("../resources/xslt/styles.xsl"), ())}</p>
    let $score := if ($work//mei:music//mei:score)
                    then ($work//mei:music//mei:score)
                    else ()
    return
        (<div class="page-header">
            <h2>{$workTitle}</h2>
            <h5>{if ($opus != 'WoO' and $workNumber)
                    then(concat('Opus ', $opus, ', Nr. ', $workNumber))
                 else if ($opus != 'WoO')
                    then(concat('Opus ', $opus))
                 else if ($opus = 'WoO') then ($opus)
                 else('Fehler!')}
            </h5>
        </div>,
        <hr/>,
        <div class="container">
            <div class="row d-flex" id="work-tabs">
                <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical">
                    <a class="nav-link active px-4 py-2.5" id="v-pills-general-tab" data-toggle="pill" href="#generalInfos" role="tab" aria-controls="v-pills-home" aria-selected="true">Übersicht</a>
                    {if ($songTextNormalized)
                        then (<a class="nav-link px-4 py-2.5" id="v-pills-text-tab" data-toggle="pill" href="#songText" role="tab" aria-controls="v-pills-profile" aria-selected="false">Textvorlage</a>)
                        else (<a class="nav-link px-4 py-2.5 disabled" id="v-pills-text-tab" data-toggle="pill" href="#songText" role="tab" aria-controls="v-pills-profile" aria-selected="false">Textvorlage</a>)
                    }
                    {if ($score)
                        then (<a class="nav-link px-4 py-2.5" id="v-pills-score-tab" data-toggle="pill" href="#editedScore" role="tab" aria-controls="v-pills-profile" aria-selected="false">Partitur</a>)
                        else (<a class="nav-link px-4 py-2.5 disabled" id="v-pills-score-tab" data-toggle="pill" href="#editedScore" role="tab" aria-controls="v-pills-profile" aria-selected="false">Partitur</a>)
                    }
                    {if ($facsimile)
                        then (<a class="nav-link px-4 py-2.5" id="v-pills-facsimile-tab" data-toggle="pill" href="#facsimile" role="tab" aria-controls="v-pills-profile" aria-selected="false">Faksimile</a>)
                        else (<a class="nav-link px-4 py-2.5 disabled" id="v-pills-facsimile-tab" data-toggle="pill" href="#facsimile" role="tab" aria-controls="v-pills-profile" aria-selected="false">Faksimile</a>)
                    }
                </div>
                <div class="tab-content flex-grow-1" id="v-pills-tabContent">
                    <div class="tab-pane fade show active w-75" id="generalInfos" role="tabpanel" aria-labelledby="v-pills-home-tab">
                        <div class="container">
                            <table class="table table-bordered ml-5">
                                <tbody>
                                    <tr scope="row">
                                        <td scope="col">ID:</td>
                                        <td scope="col">{$workId}</td>
                                    </tr>
                                    {if (contains($work//mei:work/@type, 'collection'))
                                        then (<tr scope="row">{app:componentList($work)}</tr>)
                                        else()
                                    }
                                    <tr scope="row">
                                        <td scope="col">Komponist:</td>
                                        <td scope="col">{if ($composerId)
                                                            then (<a href="/exist/apps/silcherWerkverzeichnis/person/{$composerId}">{$composer}</a>)
                                                            else ($composer)}
                                        </td>
                                    </tr>
                                    {if ($arranger != '')
                                        then (<tr scope="row">
                                                <td scope="col">Bearbeiter:</td>
                                                <td scope="col"><a href="/exist/apps/silcherWerkverzeichnis/person/{$arrangerId}">{$arranger}</a></td>
                                              </tr>)
                                        else ()}
                                    <tr scope="row">
                                        <td scope="col">Textdichter:</td>
                                        <td scope="col">{if ($lyricistId)
                                                            then (<a href="/exist/apps/silcherWerkverzeichnis/person/{$lyricistId}">{$lyricist}</a>)
                                                            else ($lyricist)}
                                        </td>
                                    </tr>
                                    {if ($dedication != '')
                                        then (<tr scopr="row">
                                                <td scope="col">Widmung:</td>
                                                <td scope="col"><q>{$dedication}</q></td>
                                              </tr>)
                                        else ()}
                                    <tr scope="row">
                                        <td scope="col">Besetzung:</td>
                                        <td scope="col">{string-join($perfRes, ', ')}</td>
                                    </tr>
                                    <tr scope="row">
                                        <td scope="col">Herausgabe:</td>
                                        <td scope="col">{$publicationDate}</td>
                                    </tr>
                                    {if (not(contains($work//mei:work/@type, 'collection')))
                                        then (<tr scope="row">
                                                <td scope="col">Ausgabe:</td>
                                                <td scope="col">
                                                    <a href="{$collectionId}">{$collectionTitle}</a>
                                                </td>
                                              </tr>
                                        )
                                        else ()
                                    }
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="tab-pane fade w-100" id="songText" role="tabpanel" aria-labelledby="v-pills-profile-tab">
                        <div class="container ml-5">
                            <div class="list-group">
                                <!-- <h3 class="text-center">Liedtext</h3> -->
                                <div class="songText">
                                    <h6 class="poemHead">{$headNorm}</h6>
                                    <div class="poemBody">{$poemBodyNorm}</div>
                                </div>
                                <div class="textTemplate">
                                    <p>{$textTemplate}</p>
                                </div>
                                <div class="otherSettings">
                                    <h6 class="listHead">Parallelvertonungen anderer Komponisten:</h6>
                                    {$showSettings}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="editedScore" role="tabpanel" aria-labelledby="v-pills-profile-tab">
                        <div class="container ml-5 p-0">
                            <div class="list-group">
                                <!-- <h3 class="text-center">Edition des Notentextes</h3> -->
                                <div class="panel-body my-3">
                                    <div id="app" class="panel w-100" style="border: 1px solid lightgray; min-height: 800px"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="facsimile" role="tabpanel" aria-labelledby="v-pills-profile-tab">
                        <div class="container ml-5">
                            <div class="list-group">
                                <!-- <h3 class="text-center">Faksimile</h3> -->
                                <!-- <iframe id="iframe" src="{concat('http://localhost:8080/exist/apps/silcherWerkverzeichnis/data/', substring-after($facsimile, '/'))}" width="100%" height="600px" overflow-x="hidden"></iframe> -->
                                {if ($multiplePages = 1)
                                then (<div id="openseadragon1" class="viewer" data-url="{$facsimile}"></div>)
                                else(<div id="openseadragon2" class="viewer" data-url="{$facsimile}"></div>)
                                }
                                <div class="facsLocation">
                                {if ($sourceLocation) then (<p>Standort: {$sourceLocation}</p>) else ()}
                                {if ($sourceLocationLink) then (<p>Permalink: {$sourceLocationLink}</p>) else ()}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>)
};

declare function app:componentList($work as node()) {
    let $components := $work//mei:componentList/mei:work
    return
        (<td scope="col">Inhalt:</td>,
        <td scope="col">
            <ul class="componentList">
                {for $component in $components
                    let $componentId := $component/substring-after(@corresp, '#')
                    let $componentNumber := $component/mei:identifier[@type = 'no']
                    let $componentTitle := $component/mei:title/mei:titlePart[@type = 'main']
                    return
                        <li class="d-flex flex-row">
                            <span class="componentNumber pr-3">{concat($componentNumber, '.')}</span>
                            <span class="componentTitle flex-grow-1">{$componentTitle}</span>
                            <span class="componentId pr-3">
                            {if (collection('/db/apps/silcherWerkverzeichnis/data/works')//mei:mei[@xml:id = $componentId])
                                then (<a href="{$componentId}">{$componentId}</a>)
                                else (<a class="disabled">{$componentId}</a>)
                            }
                            </span>
                        </li>
                }
            </ul>
        </td>)
};

declare %templates:wrap function app:viewPerson($node as node(), $model as map(*)) {
    let $persId := request:get-parameter('persId', 'invalid')
    let $person := collection('/db/apps/silcherWerkverzeichnis/data/persons')//tei:person[@xml:id = $persId]
    let $persName := $person/tei:persName/*[not(@type="unused")]
    let $forename := for $name in $person/tei:persName/*[not(self::tei:surname)]
                        return string-join($name, ' ')
    let $surname := $person/tei:persName/tei:surname
    let $birth := $person/tei:birth/tei:date/@*/string()
    let $death := $person/tei:death/tei:date/@*/string()
    let $GND := $person/tei:idno[@type="GND"]
    let $GNDLink := concat($person/tei:idno/@xml:base, $GND)
    let $url := if ($GND) then (concat('https://lobid.org/gnd/', $GND, '.json')) else ()
    let $json := if ($url) then (json-doc($url)) else ()
    let $linkedWorks := shared:getWorksFromPerson($persId)
    let $countWorks := number(count($linkedWorks))
    let $worklist := for $work in $linkedWorks
            let $workId := $work/@xml:id/data()
            let $workTitle := $work//mei:work/mei:title[@type="main"]/text()
            order by $workTitle
            return
                <a href="/exist/apps/silcherWerkverzeichnis/work/{$workId}" class="list-group-item list-group-item-action d-flex">
                    <span class="flex-grow-1">{$workTitle}</span>
                    <span>
                        <code>{$workId}</code>
                    </span>
                </a>
    return
        (<div class="page-header pt-3">
            <h2>{$persName}</h2>
            <h5>ID: {$persId}</h5>
        </div>,
        <hr/>,
        <div class="container my-4">
            <div class="row">
                <div class="nav flex-column nav-pills" id="v-pills-tab" role="tablist" aria-orientation="vertical">
                    <a class="nav-link active p-2.5" id="v-pills-general-tab" data-toggle="pill" href="#generalInfos" role="tab" aria-controls="v-pills-home" aria-selected="true">Allgemein</a>
                    {if ($countWorks > 0)
                    then (<a class="nav-link p-2.5" id="v-pills-works-tab" data-toggle="pill" href="#linkedWorks" role="tab" aria-controls="v-pills-profile" aria-selected="false">Verknüpfte Werke ({$countWorks})</a>)
                    else (<a class="nav-link p-2.5 disabled" id="v-pills-works-tab" href="#linkedWorks" role="tab" aria-controls="v-pills-profile" aria-selected="false">Verknüpfte Werke ({$countWorks})</a>)}
                </div>
                <div class="tab-content w-50" id="v-pills-tabContent">
                    <div class="tab-pane fade show active" id="generalInfos" role="tabpanel" aria-labelledby="v-pills-home-tab">
                        <div class="container">
                            <table class="table ml-5">
                                <tbody>
                                    <tr scope="row">
                                        <td scope="col">Name:</td>
                                        <td scope="col">{$surname}</td>
                                    </tr>
                                    <tr scope="row">
                                        <td scope="col">Vorname:</td>
                                        <td scope="col">{$forename}</td>
                                    </tr>
                                    <tr scope="row">
                                        <td scope="col">Lebensdaten:</td>
                                        <td scope="col">* {if($birth)
                                                            then(format-date(xs:date($birth), "[D]. [MNn] [Y]", "de", (), ()))
                                                            else if ($GND)
                                                            then (format-date(xs:date($json?dateOfBirth), "[D]. [MNn] [Y]", "de", (), ()))
                                                            else('unbekannt')}
                                                            <br/>
                                                        &#8224; {if($death)
                                                                    then(format-date(xs:date($death), "[D]. [MNn] [Y]", "de", (), ()))
                                                                    else if ($GND)
                                                                    then (format-date(xs:date($json?dateOfDeath), "[D]. [MNn] [Y]", "de", (), ()))
                                                                    else('unbekannt')}
                                        </td>
                                    </tr>
                                    <tr scope="row">
                                        <td scope="col">Normdaten:</td>
                                        <td scope="col">
                                            {if ($GND) then (<a href="{$GNDLink}" target="_blank">{$GND}</a>, ' (GND)') else ()}
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="tab-pane fade" id="linkedWorks" role="tabpanel" aria-labelledby="v-pills-profile-tab">
                        <div class="container ml-5">
                            <div class="list-group">{$worklist}</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>)
};

(: Altes Template mit Tabellenzeilen :)
(:declare %templates:wrap function app:showWorks($node as node(), $model as map(*)) {:)
(:    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/works'):)
(:    let $works := $collection//mei:mei[starts-with(@xml:id, 'work')]:)
(:    let $workList := for $work in $works:)
(:                        let $workId := shared:getId($work):)
(:                        let $workTitle := $work//mei:work/mei:title[@type="main"]/text():)
(:                        let $category := shared:getWorkType($work):)
(:                        let $opus := shared:getOpusNumber($work):)
(:                        let $workNumber := shared:getWorkNumber($work):)
(:                        let $composer := if ($work//mei:composer/mei:persName/@auth) then($work//mei:composer/mei:persName/@auth/string()) else('other'):)
(:                        order by number($opus), number($workNumber):)
(:                        return:)
(:                            <tr class="{shared:setClasses($workNumber, $opus, $composer, $category)}">:)
(:                                <td>{shared:showWorkIdno($work, $opus, $workNumber)}</td>:)
(:                                <td>{$workTitle}</td>:)
(:                                <td><a href="work/{$workId}" target="_blank">{$workId}</a></td>:)
(:                            </tr>:)
(:    return:)
(:        $workList:)
(:};:)


declare %templates:wrap function app:showWorks($node as node(), $model as map(*), $searchTerm) {
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/works')
    let $works := $collection//mei:mei[starts-with(@xml:id, 'work')]
    let $workList := for $work in $works
                        let $workId := $work/@xml:id/data()
                        let $workTitle := if ($work//mei:work/mei:title[@type="main"]/text())
                                            then ($work//mei:work/mei:title[@type="main"]/text())
                                            else ('#undefined#')
                        let $category := shared:getWorkType($work)
                        let $opus := shared:getOpusNumber($work)
                        let $workNumber := shared:getWorkNumber($work)
                        let $composer := if ($work//mei:composer/mei:persName/@auth) then($work//mei:composer/mei:persName/@auth/string()) else('other')
                        let $searchName := substring-before($searchTerm, '&#38;')
                        let $collection := substring-after($searchTerm, 'collection=')
                        where if ($searchName != '')
                                then ($work//mei:title[ft:query(., $searchName)])
                                else (if ($collection = 'true') then (not(exists($workNumber))) else (exists($workNumber)))
                        order by number($opus), number($workNumber),
                                 number(functx:substring-before-last(substring-after($workId, 'work_'), '_')),
                                 number(functx:substring-after-last($workId, '_'))
                        return
                            <tr class="{shared:setClasses($workNumber, $opus, $composer, $category)}" style="display: visible">
                                <td>{shared:showWorkIdno($work, $opus, $workNumber)}</td>
                                <td>{$workTitle}</td>
                                <td><a href="work/{$workId}" target="_blank">{$workId}</a></td>
                            </tr>
    return
        $workList
};


declare %templates:wrap function app:showPersons($node as node(), $model as map(*), $searchTerm) {
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/persons')
    let $persons := $collection/tei:person[starts-with(@xml:id, 'pers')]
    let $cards := for $person in $persons
                    let $persId := $person/@xml:id/data()
                    let $persName := $person/tei:persName/child::*[not(@type="unused") and not(self::tei:addName)]
                    let $surname := $person/tei:persName/tei:surname
                    let $GND := $person/tei:idno[@type="GND"] 
                    let $url := if ($GND) then (concat('https://lobid.org/gnd/', $GND, '.json')) else ()
                    let $json := if ($url) then (json-doc($url)) else ()
                    let $birth := if ($person/tei:birth/tei:date/@*)
(:                                    then ($person/tei:birth/tei:date/format-date(@*, '[D]. [MNn] [Y]', 'de', (), ())):)
                                    then ($person/tei:birth/tei:date/@when)
                                    else if ($GND)
                                    then ($json?dateOfBirth)
                                    else ('unbekannt')
                    let $death := if ($person/tei:death/tei:date/@*)
(:                                    then ($person/tei:death/tei:date/format-date(@*, '[D]. [MNn] [Y]', 'de', (), ())):)
                                    then ($person/tei:death/tei:date/@when)
                                    else if ($GND)
                                    then ($json?dateOfDeath)
                                    else ('unbekannt')
                    let $role := if ($person/@role and $person/tei:sex/@value)
                                    then (shared:getRoleFromPerson($person/@role, $person/tei:sex/@value))
                                    else if ($GND)
                                    then (if(contains($json?gender?*?label, 'Männlich'))
                                            then (shared:getRoleFromPerson($person/@role, 'M'))
                                            else (shared:getRoleFromPerson($person/@role, 'F')))
                                    else if ($person/@role)
                                    then (concat('#', $person/@role, '#'))
                                    else ('undefined')
                    let $searchName := substring-before($searchTerm, '&#38;')
                    let $searchRelation := substring-after($searchTerm, 'relation=')
                    let $options :=
                                <options>
                                    <default-operator>and</default-operator>
                                    <phrase-slop>5</phrase-slop>
                                    <leading-wildcard>yes</leading-wildcard>
                                    <filter-rewrite>yes</filter-rewrite>
                                </options>
                    where (if ($searchName and $searchName != '')
                            then ($person/tei:persName[ft:query(., $searchName)])
                            else (exists($persId)))
                        and (if ($searchRelation != '' and $searchRelation != 'all')
                                then (contains($person/@role, $searchRelation))
                                else (exists($persId)))
                    order by $surname[1]
                    return
                        (<br/>,
                        <div class="card">
                            <div class="card-body p-3">
                                <h5 class="card-title">
                                    <a class="text-reset" href="person/{$persId}" target="_blank">{$persName}</a>
                                </h5>
                                <dl class="row">
                                    <dt class="col-sm-4 col-lg-3 text-sm-left text-muted">Lebensdaten</dt>
                                    <dd class="col-sm-8 col-lg-9 text-sm-left">{concat($birth, ' &#8211; ', $death)}</dd>
                                    <dt class="col-sm-4 col-lg-3 text-sm-left text-muted">Silcher-Bezüge</dt>
                                    <dd class="col-sm-8 col-lg-9 text-sm-left">{$role}</dd>
                                    <dt class="col-sm-4 col-lg-3 text-sm-left text-muted">Identifier</dt>
                                    <dd class="col-sm-8 col-lg-9 text-sm-left"><code>{$persId}</code></dd>
                                </dl>
                            </div>
                        </div>)
    return
        $cards
};

(:  <!--<tr>
                            <td><a href="person/{$persId}" target="_blank">{$persId}</a></td>
                            <td>{if ($persName) then ($persName) else ($persNameFull)}</td>
                            <td>{if ($birth and $death) then (concat(year-from-date($birth), '&#8211;', year-from-date($death))) else ('unbekannt')}</td>
                        </tr>--> :)

declare %templates:wrap function app:countPersons($node as node(), $model as map(*)) {
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/persons')
    let $persons := $collection/tei:person[starts-with(@xml:id, 'pers')]
    let $persCount := count($persons)
    return
        concat('Der Katalog verzeichnet derzeit ', $persCount, ' Personen.')
};

declare %templates:wrap function app:countWorks($node as node(), $model as map(*)) {
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/works')
    let $works := $collection/mei:mei[starts-with(@xml:id, 'work')]//mei:work/mei:identifier[@type = 'number']
    let $workCount := count($works)
    return
        concat('Der Katalog verzeichnet derzeit ', $workCount, ' Werke.')
};

declare function app:searchTest($node as node(), $model as map(*), $searchTerm) {
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/works')
    let $works := $collection/mei:mei[starts-with(@xml:id, 'work')]
    let $result := for $title in $works//mei:title[ft:query(., $searchTerm)]
                    let $work := $title/ancestor::mei:mei[starts-with(@xml:id, 'work')]
                    let $workId := $work/@xml:id
                    let $category := shared:getWorkType($work)
                    let $opus := shared:getOpusNumber($work)
                    let $workNumber := shared:getWorkNumber($work)
                    let $composer := if ($work//mei:composer/mei:persName/@auth) then($work//mei:composer/mei:persName/@auth/string()) else('other')
                    order by number($opus), number($workNumber)
                    return
                        <tr class="{shared:setClasses($workNumber, $opus, $composer, $category)}" style="display: visible">
                            <td>{shared:showWorkIdno($work, $opus, $workNumber)}</td>
                            <td>{$title/string()}</td>
                            <td><a href="work/{$workId}" target="_blank">{$workId}</a></td>
                        </tr>
    return
        $result
};

declare %templates:wrap function app:dropdown($node as node(), $model as map(*)) {
    let $collection := collection('/db/apps/silcherWerkverzeichnis/data/persons')
    let $persons := $collection/tei:person[starts-with(@xml:id, 'pers')]
    return
        <select class="custom-select d-flex" id="dropdown">
            <option value="all" class="d-flex"><span class="aaa">Alle</span><span> ({count($persons)})</span></option>
            <option value="friend"><span>Freund/in</span><span> ({count($persons[contains(@role, 'friend')])})</span></option>
            <option value="composer"><span>Melodiekomponist/in</span><span> ({count($persons[contains(@role, 'composer')])})</span></option>
            <option value="apprentice"><span>Schüler/in</span><span> ({count($persons[contains(@role, 'apprentice')])})</span></option>
            <option value="lyricist"><span>Textdichter/in</span><span> ({count($persons[contains(@role, 'lyricist')])})</span></option>
            <option value="publisher"><span>Verleger/in</span><span> ({count($persons[contains(@role, 'publisher')])})</span></option>
            <option value="dedicatee"><span>Widmungsträger/in</span><span> ({count($persons[contains(@role, 'dedicatee')])})</span></option>
        </select>
};

