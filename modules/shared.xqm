xquery version "3.1" encoding "UTF-8";

module namespace shared="http://jannikBriefe.de/shared";

import module namespace app="http://exist-db.org/xquery/templates";
import module namespace config="http://jannikBriefe.de/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mei="http://www.music-encoding.org/ns/mei";
declare namespace functx = "http://www.functx.com";

declare variable $shared:collection := collection('/db/apps/silcherWerkverzeichnis/data/works');

declare function shared:getOpusNumber($work as node()) {
    let $opus := if ($work//mei:work/mei:identifier[@type = 'opus']/@n)
                    then ($work//mei:work/mei:identifier[@type = 'opus']/@n)
                    else ($work//mei:work/mei:identifier[@type = 'opus'])
    return
        $opus
};

declare function shared:getWorkNumber($work as node()) {
    let $number := if ($work//mei:work/mei:identifier[@type = 'number']/@n)
                    then ($work//mei:work/mei:identifier[@type = 'number']/@n)
                    else ()
    return
        $number
};

declare function shared:getWorkType($work as node()) {
    let $type := if (contains($work//mei:workList/mei:work/@type, 'instrumental'))
                    then ('instrumental')
                 else if (contains($work//mei:workList/mei:work/@type, 'vocal'))
                    then (if (tokenize($work//mei:workList/mei:work/@type)[2] != 'collection')
                            then (tokenize($work//mei:workList/mei:work/@type)[2])
                            else (''))
                 else ('Fehler in den Daten!')
    return
        $type
};

declare function shared:getWorkCollection($work as node()) {
    let $workId := $work/@xml:id
    let $collectionWork := $shared:collection//mei:mei[descendant::mei:componentList/mei:work[substring-after(@corresp, '#') = $workId]]
    return
        $collectionWork
};

declare function shared:getWorksFromPerson($persId as xs:string) {
    let $works := $shared:collection//mei:mei[descendant::mei:persName/@auth = $persId]
    return
        $works
};

declare function shared:getRoleFromPerson($roles as node(), $sex) {
    let $selectRoles := for $role in tokenize($roles)
                            return switch ($role)
                            case ('friend') return 'Freund'
                            case ('composer') return 'Komponist'
                            case ('apprentice') return 'Schüler'
                            case ('lyricist') return 'Textdichter'
                            case ('publisher') return 'Verleger'
                            case ('dedicatee') return 'Widmungsträger'
                            default return 'undefined'
    let $setGender := for $role in $selectRoles
                        let $gender := if ($sex = 'F' and $role != 'undefined') then (concat($role, 'in')) else ($role)
                        return
                            $gender
    return
        string-join($setGender, ', ')
};

declare function shared:getAmbitus($ambitus as node()) {
    let $showAmb := for $ambNote in $ambitus/*
                        let $pname := switch ($ambNote/@pname)
                                        case ('b' and not($ambNote/@accid)) return 'h'
                                        case ('b' and $ambNote/@accid = 's') return 'his'
                                        case (not('b') and $ambNote/@accid = 'f') return concat($ambNote/@pname, 'es')
                                        case ($ambNote/@accid = 's') return concat($ambNote/@pname, 'is')
                                        default return $ambNote/@pname
                        let $withOct := switch ($ambNote/@oct)
                                        case '1' return concat(upper-case($pname), '&#8217;')
                                        case '2' return upper-case($pname)
                                        case '3' return $pname
                                        case '4' return concat($pname, '&#8217;')
                                        case '5' return concat($pname, '&#8217;&#8217;')
                                        case '6' return concat($pname, '&#8217;&#8217;&#8217;')
                                        default return 'Fehler'
                        return
                            $withOct
    return
        string-join($showAmb, '&#8211;')
            
};

declare function shared:getPerfRes($perfResList as node()*, $ambitus as xs:string?) {
    let $displayPerf := for $perfRes in $perfResList
                            let $performer := if ($perfRes/@type = 'choice')
                                                then ($perfRes/*)
                                                else ($perfRes)
                            let $setAmbitus := if (starts-with($performer/@codedval, 'v') and $ambitus)
                                                then (concat(string-join($performer, '/'), ' (', $ambitus, ')'))
                                                else (string-join($performer, '/'))
                            return
                                $setAmbitus
    return
        $displayPerf
};

declare function shared:showWorkIdno($work as node(), $opus as node(), $workNumber as node()?) {
    let $idno := if ($opus = 'WoO' and not(contains($work/@type, 'collection')))
                    then (if ($workNumber) then (concat($opus, ', Nr. ', $workNumber)) else ($opus))
                    else (if ($workNumber) then (concat('Opus ', $opus, ', Nr. ', $workNumber)) else (concat('Opus ', $opus)))
    return
        $idno
};

declare function shared:setClasses($workNumber as node()?, $opus as node(), $composer as xs:string, $category as xs:string) {
    let $class1 := if ($workNumber) then ('individualWork') else ('collection')
    let $class2 := if ($opus = 'WoO') then ($opus) else ('opus')
    let $class3 := if ($composer = 'pers_00273') then ('composer') else ('arranger')
    let $class4 := $category
    return
        concat($class1, ' ', $class2, ' ', $class3, ' ', $class4)
};


