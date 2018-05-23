// xml-pony/dump.pony


use "package:files"


interface tag Out
    be print(text: String)


actor DumpXml
    let _out: Out

    let _xml: Xml
    let _file: File iso

    let _chunksize: USize

    new create(out: Out, file: File iso) =>
        _out = out
        _xml = Xml.create(this~xml_notify())
        _file = consume file

        _chunksize = 32

        _xml.reset()
        process_chunk()

    be process_chunk() =>
        if not (_file.errno() is FileOK) then
            _file.dispose()
            return
        end

        let data: String = _file.read_string(_chunksize)
//        _out.print("read " + data.size().string())
        _xml.parse(data)

        process_chunk()

    be xml_notify(node: XmlNode, content: String, path: String) =>
        _out.print(XmlNodeText(node) + "\t" + content + "\t\t" + path)


actor Main
    let _out: OutStream

    new create(env: Env) =>
        _out = env.out
        let auth =
        try
            env.root as AmbientAuth
        else
            print("auth error")
            return
        end
        for file_name in env.args.slice(1).values() do
            dump_xml(auth, file_name)
        end

    be dump_xml(auth: AmbientAuth, filepath: String) =>
        let file: File iso =
        try 
            let caps: FileCaps iso = FileCaps.create()
            caps.clear()
            caps.set(FileStat)
            caps.set(FileRead)
            caps.set(FileSeek)

            recover File.open(FilePath.create(auth, filepath, consume caps)?) end
        else
            print("file path invalid")
            return
        end
        if not file.valid() then
            print(
                "file not open: " +
                match file.errno()
                | FilePermissionDenied => "permission denied"
                | FileBadFileNumber => "invalid descriptor"
                | FileExists => "file exists"

                | FileError => "unknown error"

                | FileEOF => "eof"
                | FileOK => "OK"
                end
            )
            return
        end

        DumpXml.create(this, consume file)

    be xml_notify(node: XmlNode, content: String, path: String) =>
        print(XmlNodeText(node) + "\t" + content + "\t\t" + path)

    be print(text: String) =>
        _out.print(text)

