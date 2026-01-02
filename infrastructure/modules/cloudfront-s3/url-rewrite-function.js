function handler(event) {
    var request = event.request;
    var uri = request.uri;

    // URIがスラッシュで終わる場合、index.htmlを追加
    if (uri.endsWith('/')) {
        request.uri += 'index.html';
    }
    // URIにファイル拡張子がない場合もindex.htmlを追加
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
