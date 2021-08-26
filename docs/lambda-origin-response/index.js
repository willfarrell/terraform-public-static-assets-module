'use strict'

const enforce = false

const reportDomain = 'default'
const reportMethod = enforce ? 'enforce' : 'reportOnly'

const headers = {
    'any': {
        'Server': '',
        'X-Content-Type-Options': 'nosniff',    // Redundant via CSP frame-ancestors
        'Referrer-Policy': 'no-referrer',
        'Strict-Transport-Security': 'max-age=31536000; includeSubdomains; preload'
        //"Expect-CT":""
    },
    'html': {
        'Report-To':
            `{ "group": "default", "max_age": 31536000, "endpoints": [ { "url": "https://${reportDomain}.report-uri.com/a/d/g" } ], "include_subdomains": true },` +
            `{ "group": "csp", "max-age": 10886400,  "endpoints": [ { "url": "https://${reportDomain}.report-uri.com/r/d/csp/${reportMethod}" } ] },` +
            `{ "group": "hpkp", "max-age": 10886400,  "endpoints": [ { "url": "https://${reportDomain}.report-uri.com/r/d/hpkp/${reportMethod}" } ] },` +
            `{ "group": "ct", "max-age": 10886400,  "endpoints": [ { "url": "https://${reportDomain}.report-uri.com/r/d/ct/${reportMethod}" } ] },` +
            `{ "group": "staple", "max-age": 10886400,  "endpoints": [ { "url": "https://${reportDomain}.report-uri.com/r/d/staple/${reportMethod}" } ] },` +
            `{ "group": "xss", "max-age": 10886400, "endpoints": [ { "url": "https://${reportDomain}.report-uri.com/r/d/xss/${reportMethod}" } ] }`,

        // Content-Security-Policy[-Report-Only]:
        'Content-Security-Policy-Report-Only':
            `default-src 'none';` + // CSP1
            `base-uri 'none';`+   // no fallback CSP2
            //`child-src 'none';` +  // `default-src` fallback CSP2
            //`connect-src 'none';` +  // `default-src` fallback CSP1
            //`font-src 'none';` +  // `default-src` fallback CSP1
            `form-action 'none';`+  // no fallback CSP2
            `frame-ancestors 'none';` + // no fallback CSP2
            //`frame-src 'none';` + // `default-src` fallback CSP1
            //`img-src 'none';` + // `default-src` fallback CSP1
            //`manifest-src 'none';` + // `default-src` fallback CSP3
            //`media-src 'none';` + // `default-src` fallback CSP1
            //`navigate-to *;` + // no fallback CSP3
            //`object-src 'none';` + // `default-src` fallback CSP1
            `plugin-types 'none';` + // no fallback CSP2
            //`prefetch-src 'none';` + // `default-src` fallback CSP3
            `require-sri-for script style;`+ // no fallback CSP3?
            `sandbox;` + // no fallback CSP1.1
            //`script-src 'none';` + // `default-src` fallback CSP1
            //`script-src-attr 'none';` + // `script-src` fallback CSP3
            //`script-src-elem 'none';` + // `script-src` fallback CSP3
            //`style-src 'none';` + // `default-src` fallback CSP1
            //`style-src-attr 'none';` + // `style-src` fallback CSP3
            //`style-src-elem 'none';` + // `style-src` fallback CSP3
            //`worker-src 'none';` + // `script-src` fallback CSP3
            //`trusted-types *;` // DRAFT
            `upgrade-insecure-requests;` + // no fallback CSP1?
            `report-uri https://{report-uri}.report-uri.com/r/d/csp/reportOnly;` + // Deprecated by `report-to` CSP1
            `report-to csp`, // DRAFT Not fully supported yet CSP3?
        // Feature-Policy[-Report-Only]:
        'Feature-Policy-Report-Only':
            `ambient-light-sensor 'none';` +
            `autoplay 'none';` +
            `accelerometer 'none';` +
            `camera 'none';` +
            //`display-capture 'self';`+
            //`document-domain 'none';`+
            `encrypted-media 'none';` +
            `fullscreen 'self';` +
            `geolocation 'none';` +
            `gyroscope 'none';` +
            `magnetometer 'none';` +
            `microphone 'none';` +
            `midi 'none';` +
            `payment 'none';` +
            `picture-in-picture 'none';` +
            `speaker 'none';` +
            `sync-xhr 'self';` +
            `usb 'none';` +
            //`wake-lock 'none';`+
            //`webauthn 'self';`+
            `vr 'none';`,
        'NEL':`{"report_to":"default","max_age":31536000,"include_subdomains":true}`,
        //'X-Frame-Options': 'DENY',    // DEPRECATED: `frame-ancestors 'none'`
        //'X-XSS-Protection': '1; mode=block', // DEPRECATED
        //'X-UA-Compatible': 'ie=edge',
        //'Content-Encoding':'gzip'
    }
}

// Reformat headers object for CF
function makeHeaders(headers) {
    const formattedHeaders = {}
    Object.keys(headers).forEach((key) => {
        formattedHeaders[key.toLowerCase()] = [{
            key: key,
            value: headers[key]
        }]
    })
    return formattedHeaders
}

function getHeaders(mime) {
    return makeHeaders(headers[mime])
}

function handler(event, context, callback) {
    const request = event.Records[0].cf.request
    const response = event.Records[0].cf.response

    console.log(JSON.stringify(request), JSON.stringify(response))

    let responseHeaders = getHeaders('any')

    // Catch 304 w/o Content-Type from S3
    if (!response.headers['content-type'] && request.uri === '/') {
        response.headers['content-type'] = [{
            key: 'Content-Type',
            value: 'text/html; charset=utf-8'
        }]
    }

    if (response.headers['content-type'] && response.headers['content-type'][0].value.indexOf('text/html') !== -1) {
        Object.assign(responseHeaders, getHeaders('html'))
        if (enforce) {
            responseHeaders['Content-Security-Policy'] = responseHeaders['Content-Security-Policy-Report-Only']
            delete responseHeaders['Content-Security-Policy-Report-Only']
        }
    }

    // Compression
    //if (response.headers['content-type'] && response.headers['content-type'][0].value.indexOf('text/html') !== -1) {
    //  Object.assign(responseHeaders, getHeaders('html'))
    //}

    Object.assign(response.headers, responseHeaders)

    return callback(null, response)
}

module.exports = {
    handler
}
