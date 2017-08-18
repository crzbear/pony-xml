// feed.pony


use "package:collections"


interface tag FeedParserNotify
    be new_item(item: FeedItem iso)


class FeedItem
    var id: String = ""
    var title: String = ""
    var content: String = ""
    var pubdate: String = ""
    var upddate: String = ""
    var link: String = ""

    new iso create() =>
        None


type FeedParserXmlEvent is {ref (String)}

actor FeedParser
    let _event: Map[String, FeedParserXmlEvent] = Map[String, FeedParserXmlEvent].create()

    let _notify: FeedParserNotify
    let _xml: Xml

    var _item: FeedItem iso = FeedItem.create()

    new create(notify: FeedParserNotify) =>
        _notify = notify
        _xml = Xml.create(recover this~xml_notify() end)
        setup_events()

    fun tag event_string(node: XmlNode, content: String, path: String): String =>
        path + ">" + XmlNodeText(node) + ">" + if (node is XmlCData) or (node is XmlAttrVal) then "" else content end

    fun ref setup_events() =>
        _event(event_string(XmlSTag, "entry", "feed")) = this~item_start()
        _event(event_string(XmlCData, "", "feed/entry/id")) = this~item_id()
        _event(event_string(XmlCData, "", "feed/entry/title")) = this~item_title()
        _event(event_string(XmlCData, "", "feed/entry/content")) = this~item_content()
        _event(event_string(XmlCData, "", "feed/entry/published")) = this~item_pubdate()
        _event(event_string(XmlCData, "", "feed/entry/updated")) = this~item_update()
        _event(event_string(XmlAttrVal, "", "feed/entry/link#href")) = this~item_link()
        _event(event_string(XmlETag, "entry", "feed")) = this~item_done()

        _event(event_string(XmlSTag, "item", "rss/channel")) = this~item_start()
        _event(event_string(XmlCData, "", "rss/channel/item/guid")) = this~item_id()
        _event(event_string(XmlCData, "", "rss/channel/item/title")) = this~item_title()
        _event(event_string(XmlCData, "", "rss/channel/item/description")) = this~item_content()
        _event(event_string(XmlCData, "", "rss/channel/item/pubDate")) = this~item_pubdate()
        _event(event_string(XmlCData, "", "rss/channel/item/link")) = this~item_link()
        _event(event_string(XmlETag, "item", "rss/channel")) = this~item_done()

    fun ref item_start(content: String) =>
        _item = FeedItem.create()

    fun ref item_id(content: String) =>
        _item.id = content

    fun ref item_title(content: String) =>
        _item.title = content

    fun ref item_content(content: String) =>
        _item.content = content

    fun ref item_pubdate(content: String) =>
        _item.pubdate = content

    fun ref item_update(content: String) =>
        _item.upddate = content

    fun ref item_link(content: String) =>
        _item.link = content

    fun ref item_done(content: String) =>
        var it: FeedItem iso = _item = FeedItem.create()
        _notify.new_item(consume it)

    be reset() =>
        _xml.reset()
        _item = FeedItem.create()

    be parse(source: String) =>
        _xml.parse(source)

    be xml_notify(node: XmlNode, content: String, path: String) =>
        let ev_str = event_string(node, content, path)
        let ev =
        try
            _event(ev_str)?
        else
            return
        end
        ev(content)

