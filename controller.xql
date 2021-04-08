xquery version "3.0";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

if ($exist:path eq '') then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{request:get-uri()}/"/>
    </dispatch>
    
else if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (matches($exist:path, "/work/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward url="{$exist:controller}/viewWork.html">
				<add-parameter name="workId" value="{$exist:resource}"/>
			</forward>
			<view>
				<forward url="{$exist:controller}/modules/view.xql">
					<add-parameter name="workId" value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
				<forward url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
else if (matches($exist:path, "/person/")) then
		<dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward url="{$exist:controller}/viewPerson.html">
				<add-parameter name="persId" value="{$exist:resource}"/>
			</forward>
			<view>
				<forward url="{$exist:controller}/modules/view.xql">
					<add-parameter name="persId" value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
				<forward url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
		(: Quasi-API-Endpoints für die Werk- und Personensuche :)
else if (matches($exist:path, "/searchWork")) then
        <dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			<forward url="{$exist:controller}/searchWork.html">
			    <!-- <forward url="{$exist:controller}/registryWorks.html"> -->
				<add-parameter name="searchterm" value="{request:get-parameter("searchTerm","")}"/>
			</forward>
			<view>
				<forward url="{$exist:controller}/modules/view.xql">
					<add-parameter name="persId" value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
				<forward url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
else if (matches($exist:path, "/searchPerson")) then
        <dispatch
			xmlns="http://exist.sourceforge.net/NS/exist">
			    <forward url="{$exist:controller}/searchPerson.html">
			    <!-- <forward url="{$exist:controller}/registryPersons.html"> -->
				<add-parameter name="searchterm" value="{request:get-parameter("searchTerm","")}"/>
			</forward>
			<view>
				<forward url="{$exist:controller}/modules/view.xql">
					<add-parameter name="persId" value="{$exist:resource}"/>
				</forward>
			</view>
			<error-handler>
				<forward url="{$exist:controller}/templates/error-page.html" method="get"/>
				<forward url="{$exist:controller}/modules/view.xql"/>
			</error-handler>
		</dispatch>
    
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="{$exist:controller}/modules/view.xql"/>
        </view>
		<error-handler>
			<forward url="{$exist:controller}/error-page.html" method="get"/>
			<forward url="{$exist:controller}/modules/view.xql"/>
		</error-handler>
    </dispatch>
(: Resource paths starting with $shared are loaded from the shared-resources app :)
else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
