const test = require('tape');
const edge = require('./index.js');

function makeEvent(uri, headers) {
    return {
        Records: [
            {
                cf: {
                    request: {uri, headers}
                }
            }
        ]
    };
}

test('well known', function (t) {
    const headers = {
            accept:
                [ { key: 'accept',
                    value: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng;q=0.8,application/signed-exchange;v=b3' } ],
            'accept-encoding': [ { key: 'accept-encoding', value: 'gzip, deflate, br' } ],
            'accept-language':
                [ { key: 'accept-language', value: 'en-US,en;q=0.9,en-CA;q=0.8' } ]
    }

    edge.handler(makeEvent('/robots.txt', headers), null, (err, request) => {
        t.equal(request.uri, '/.well-known/robots.txt.br')
        t.end();
    });

});

test('compression: br', function (t) {
    const headers = {
        accept:
            [ { key: 'accept',
                value: 'text/css,*/*;q=0.1' } ],
        'accept-encoding': [ { key: 'accept-encoding', value: 'gzip, deflate, br' } ],
        'accept-language':
            [ { key: 'accept-language', value: 'en-US,en;q=0.9,en-CA;q=0.8' } ]
    }

    edge.handler(makeEvent('/css/main.min.css', headers), null, (err, request) => {
        t.equal(request.uri, '/css/main.min.css.br')
        t.end();
    });

});

test('compression: gzip', function (t) {
    const headers = {
        accept:
            [ { key: 'accept',
                value: 'text/css,*/*;q=0.1' } ],
        'accept-encoding': [ { key: 'accept-encoding', value: 'gzip, deflate' } ],
        'accept-language':
            [ { key: 'accept-language', value: 'en-US,en;q=0.9,en-CA;q=0.8' } ]
    }

    edge.handler(makeEvent('/css/main.min.css', headers), null, (err, request) => {
        t.equal(request.uri, '/css/main.min.css.gz')
        t.end();
    });

});

test('html: en', function (t) {
    const headers = {
        accept:
            [ { key: 'accept',
                value: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng;q=0.8,application/signed-exchange;v=b3' } ],
        'accept-encoding': [ { key: 'accept-encoding', value: 'gzip, deflate, br' } ],
        'accept-language':
            [ { key: 'accept-language', value: 'en-US,en;q=0.9,en-CA;q=0.8' } ]
    }

    edge.handler(makeEvent('/index', headers), null, (err, request) => {
        t.equal(request.uri, '/index.en.html.br')
        t.end();
    });

});

test('skip for API', function (t) {

    edge.handler(makeEvent('/api/status', {}), null, (err, request) => {
        t.equal(request.uri, '/api/status')
        t.end();
    });

});

test('folder index.html', function (t) {
    const headers = {
        accept:
            [ { key: 'accept',
                value: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng;q=0.8,application/signed-exchange;v=b3' } ],
        'accept-encoding': [ { key: 'accept-encoding', value: 'gzip, deflate, br' } ],
        'accept-language':
            [ { key: 'accept-language', value: 'en-US,en;q=0.9,en-CA;q=0.8' } ]
    }
    edge.handler(makeEvent('/sitemap/', headers), null, (err, request) => {
        t.equal(request.uri, '/sitemap/index.en.html.br')
        t.end();
    });

});
