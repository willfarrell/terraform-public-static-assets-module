'use strict'

const allowedLanguages = ['en']
const well_known_files = ['robots.txt', 'security.txt', 'humans.txt', 'ads.txt']

function handler(event, context, callback) {
  const request = event.Records[0].cf.request

  // Skip API calls
  //if (request.uri.indexOf('/api/') !== -1) return callback(null, request)

  const headers = request.headers

  // Set `default_root_object` on sub folders
  request.uri = request.uri.replace(/\/$/, '/index')

  // .well-known redirects, order by most likely accessed
  if (well_known_files.indexOf(request.uri.substr(1)) !== -1) {
    request.uri = `/.well-known${request.uri}`
    request.uri = uriCompression(request.uri, headers)
    return callback(null, request)
  }

  // html alias
  if (request.uri.split('.').length === 1) {
    request.uri += `.html`
  }

  // multi lang html files
  if (request.uri.indexOf('.html') !== -1) {
    request.uri = uriLanguage(request.uri)
  }

  request.uri = uriCompression(request.uri, headers)

  return callback(null, request)
}

function uriCompression(uri, headers) {
  if (headers['accept-encoding']) {
    if (headers['accept-encoding'][0].value.indexOf('br') !== -1) {
      uri = uri + '.br'
    } else if (headers['accept-encoding'][0].value.indexOf('gz') !== -1) {
      uri = uri + '.gz'
    }
  }
  return uri
}

function uriLanguage(uri) {
  if (allowedLanguages.indexOf(uri.split('/')[1]) !== -1) {
    return uri
  }
  return '/'+allowedLanguages[0]+uri
}

module.exports = {
  handler
}
