xml parser in plain pony
------------------------

does not implement the full xml standard, nor is the code very pretty
<br/>
but considering there wasn't or maybe still isn't another parser,
<br/>
it might be useful to other people

[xml.pony](https://github.com/crzbear/pony-xml/blob/master/xml.pony), the main file
<br/>
[feed.pony](https://github.com/crzbear/pony-xml/blob/master/feed.pony), example code that extracts the basic information from rss/atom feeds
<br/>


basic usage:
<br/>

create a new <code>Xml</code> instance

then you feed your document to <code>parse</code>, which can be called multiple times with partial data
<br/>

once done with one document or if there's a need to abort parsing
<br/>
call <code>reset</code> and you can start anew
<br/>

whenever a complete xml node is available the supplied
<br/>
<code>XmlNodeNotify(node: XmlNode, content: String, path: String)</code> is called

