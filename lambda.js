// Based on: https://github.com/godfreyhobbs/circleci-cron-serverless/blob/master/handler.js
'use strict';
var http = require("https");

exports.handler = (event, context, callback) => {
    var options = {
        "method": "POST",
        "hostname": "circleci.com",
        "port": null,
        // example: "/api/v1.1/project/github/RobUserName117/secret-project/tree/builds"
        "path": "/api/v1.1/project/<github or bitbucket>/<organization or user name>/<project name>/tree/<branch name with scripts>" +
        "?circle-token=" + process.env.CircleCIToken,
        "headers": {
            "content-type": "application/json",
            "cache-control": "no-cache"
        }
    };

    // Make request, write out all of response
    var req = http.request(options, function (res) {
        var chunks = [];

        res.on("data", function (chunk) {
            chunks.push(chunk);
        });

        res.on("end", function () {
            var body = Buffer.concat(chunks);
            const response = body.toString();
            console.log(response);
            callback(null, response);
        });
    });

    req.write(JSON.stringify({
      "build_parameters": {
        "RUN_NIGHTLY_BUILD": "true"
      }
    }));
    req.end();
};
