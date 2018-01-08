'use strict';

const headers = {
    "any": {
        "Server":"",
        "X-Content-Type-Options": "nosniff",
        "Referrer-Policy": "no-referrer",
        "Strict-Transport-Security": "max-age=31536000; includeSubdomains; preload"
    },
    "html": {
        // Content-Security-Policy-Report-Only: https://willfarrell.report-uri.com/r/d/csp/reportOnly
        // Content-Security-Policy:             https://willfarrell.report-uri.com/r/d/csp/enforce
        "Content-Security-Policy": "default-src 'none';" +
            //" connect-src 'none';" +  // default-src
            //" font-src 'none'" + // default-src
            //" frame-src 'none'" + // default-src
            //" img-src 'none';" + // default-src
            //" manifest-src 'none'" + // default-src
            //" media-src 'none'" + // default-src
            //" object-src 'none'" + // default-src
            //" plugin-types <mime>" + // object-src 'none' to disable
            //" script-src 'none';" + // default-src
            //" style-src 'none';" + // default-src
            //" worker-src 'none':" + // script-src
            " base-uri 'none';" +
            " block-all-mixed-content;" +
            " form-action 'none';" +
            " frame-ancestors 'none';" +
            " upgrade-insecure-requests;" +
            " require-sri-for script style;"
            " report-uri https://willfarrell.report-uri.com/r/d/csp/reportOnly",
        "X-Frame-Options": "DENY",
        "X-XSS-Protection": "1; mode=block",
        "X-UA-Compatible":"ie=edge"
    }
};

// Reformat headers object for CF
function makeHeaders (headers) {
    const formattedHeaders = {};
    Object.keys(headers).forEach((key) => {
        formattedHeaders[key.toLowerCase()] = [{
            key: key,
            value: headers[key]
        }]
    });
    return formattedHeaders;
}

function getHeaders(mime) {
    return makeHeaders(headers[mime])
}

function handler (event, context, callback) {
    const request = event.Records[0].cf.request;
    const response = event.Records[0].cf.response;

    let responseHeaders = getHeaders('any');

    // Catch 304 w/o Content-Type from S3
    if (!response.headers['content-type'] && request.uri === '/') {
        response.headers['content-type'] = [{
            key:'Content-Type',
            value:'text/html; charset=utf-8'
        }];
    }

    if (response.headers['content-type'] && response.headers['content-type'][0].value.indexOf('text/html') !== -1) {
        Object.assign(responseHeaders, getHeaders('html'));
    }

    Object.assign(response.headers, responseHeaders);

    return callback(null, response);
}

module.exports = {
    makeHeaders,
    headers,
    handler
};
