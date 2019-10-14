'use strict'

function handler (event, context, callback) {
  const request = event.Records[0].cf.request
  // Auth handler
  return callback(null, request)
}

module.exports = {
  handler
}
