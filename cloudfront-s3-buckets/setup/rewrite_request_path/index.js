'use strict';

exports.handler = (event, context, callback) => {
    const request = event.Records[0].cf.request;           // extract the request object
    request.uri = request.uri.replace(/^\/[^\/]+\//,'/');  // modify the URI
    return callback(null, request);                        // return control to CloudFront
};