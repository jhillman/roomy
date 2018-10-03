#! /usr/bin/env node

'use strict';

var fs              = require('fs'),
    Roomy           = require('./lib'),
    argv            = require('optimist').argv,
    destinationPath = process.cwd(),
    roomConfig      = process.cwd() + '/room.json',
    roomy           = new Roomy(),
    data,
    usage;

function processData(destination, data) {
  var dataJson;

  if (argv.data) {
    if (fs.existsSync(argv.data)) {
      dataJson = require(process.cwd() + '/' + argv.data);
    } else {
      dataJson = JSON.parse(argv.data);
    }

    for (var key in dataJson) {
      data[key] = dataJson[key];
    }
  }

  if (!data.relationships) {
    data.relationships = [];
  }

  if (data.modelFiles) {
    if (!data.models) {
      data.models = [];
    }

    data.modelFiles.forEach(function (modelFile) {
      data.models = data.models.concat(require(process.cwd() + '/' + modelFile));
    });
  }

  roomy.generate(destination, data, function(err) {
    if (err) return console.log('roomy error: ' + err);

    console.log('roomy has completed successfully!');
  });
};

usage = function() {
  console.log('\nroomy usage:\n\n' + 
              'Run from a directory that contains a room.json config file\n' +
              'or provide the path as an argument:\n' +
              '  roomy --path <relative path to room config file>\n\n' +
              'You may also provide the destination directory as an argument:\n' +
              '  roomy --dest <relative path to the destination directory>\n\n' +
              'Finally, you may also override or provide additional template \n' +
              'data with the data parameter:\n' +
              '  roomy --data \'{"packageName": "com.something.great"}\'\n'+
              '  roomy --data <relative path to .json file>');
  process.exit(1);
};

if (argv.path) {
  roomConfig = process.cwd() + '/' + argv.path;
}

if (argv.dest) {
  destinationPath = process.cwd() + '/' + argv.dest;
}

fs.exists(roomConfig, function(exists) {
  if (exists) {
    data = require(roomConfig);

    processData(destinationPath, data);
  } else {
    usage();
  }
});