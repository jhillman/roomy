'use strict';

var fs         = require('fs'),
    jade       = require('jade'),
    async      = require('async'),
    _          = require('lodash'),
    jsonSql    = require('json-sql')({
      dialect: 'sqlite',
      valuesPrefix: ':',
      separatedValues: true
    }),
    Freemarker = require('freemarker.js'),
    freemarker = new Freemarker({
      viewRoot: __dirname + '/templates'
    });

var helpers = {
  camelCase: function(string) {
    var result = string;
    var underscoreIndex = result.indexOf('_');

    while (underscoreIndex > -1) {
      result = result.substring(0, underscoreIndex) + 
        result.charAt(underscoreIndex + 1).toUpperCase() + 
        result.substring(underscoreIndex + 2);
      underscoreIndex = result.indexOf('_');
    }

    return result;
  },
  capitalize: function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  },
  upperCase: function(string) {
    return string.toUpperCase();
  },
  lowerCase: function(string) {
    return string.toLowerCase();
  },
  typeMap: {
    byte: 'Byte',
    short: 'Short',
    int: 'Int',
    long: 'Long',
    float: 'Float',
    double: 'Double',
    boolean: 'Boolean',
    char: 'Character',
    String: 'String'
  },
  wrappers: [
    'Byte',
    'Short',
    'Int',
    'Long',
    'Float',
    'Double',
    'Boolean',
    'Character',
    'String'
  ]
}

function addHelpers(data, cb) {
  for (var key in helpers) {
    data[key] = helpers[key];
  }

  cb();
}

function getBaseMembers(members, modelMap, model) {
  var baseModel = modelMap[model];

  if (baseModel) {
    getBaseMembers(members, modelMap, baseModel.baseClass);

    baseModel.members.forEach(function(member) {
      members.push(member);
    });
  }

  return members;
}

function writeFileWithPersistedSection(filename, template, additions, data, next, cb) {
  var persistedSectionRegExp = new RegExp(/\/\/ BEGIN PERSISTED SECTION[^\n]*\n([\S\s]*?)\n\s*\/\/ END PERSISTED SECTION/i);

  fs.exists(filename, function(exists) {
    if (exists) {
      fs.readFile(filename, function(err, fileData) {
        if (err) cb(err);

        var match = persistedSectionRegExp.exec(fileData),
            persistedSection = '';

        if (match != null) {
          persistedSection = match[1];

          if (additions) {
            additions.forEach(function(addition) {
              if (!persistedSection.match(addition.pattern)) {
                persistedSection = persistedSection + addition.text;
              }
            });
          }
        }

        data.persistedSection = persistedSection;
        freemarker.render(template, data, function(err, result, output) {
          if (err) return cb(output);
          fs.writeFile(filename, result, next);
        });
      });
    } else {
      data.persistedSection = '';
      freemarker.render(template, data, function(err, result, output) {
        if (err) return cb(output);
        fs.writeFile(filename, result, next);
      });
    }
  });
}

function Roomy() {}

Roomy.prototype.generate = function(destination, data, cb) {
  var options = {
        pretty: true
      },
      packageNames = [
        'model',
        'dao',
        'database'
      ],
      modelMap = {},
      destinationPackage;

  async.series([
    function(next) {
      var packageParts    = data.packageName.split('.'),
          lastDirectory   = destination,
          directorySeries = [];

      destinationPackage = destination + '/' + packageParts.join('/'),

      packageParts.forEach(function(packagePart) {
        directorySeries.push(function(nextDirectory) {
          var directory = lastDirectory + '/' + packagePart;
          fs.exists(directory, function(exists) {
            if (!exists) {
              fs.mkdir(directory, function(err) {
                if (err) cb(err);
                lastDirectory = lastDirectory + '/' + packagePart;
                nextDirectory();
              });
            } else {
              lastDirectory = lastDirectory + '/' + packagePart;
              nextDirectory();
            }
          });
        });
      });

      packageNames.forEach(function(packageName) {
        directorySeries.push(function(nextDirectory) {
          var directory = lastDirectory + '/' + packageName;

          fs.exists(directory, function(exists) {
            if (!exists) {
              fs.mkdir(directory, function(err) {
                if (err) cb(err);
                nextDirectory();
              });
            } else {
              nextDirectory();
            }
          });
        });
      });

      data.models.forEach(function(model) {
        directorySeries.push(function(nextDirectory) {
          var directory = lastDirectory + '/model/' + (model.package ? model.package : '');

          model.fullPackageName = data.packageName + '.model.' + (model.package ? model.package + '.' : '') + model.name;
          modelMap[model.fullPackageName] = model;

          fs.exists(directory, function(exists) {
            if (!exists) {
              fs.mkdir(directory, function(err) {
                if (err) cb(err);
                nextDirectory();
              });
            } else {
              nextDirectory();
            }
          });
        });
      });

      data.models.forEach(function(model) {
        if (_.any(model.members, function(member) {
            return member.primaryKey;
          })) {
          directorySeries.push(function(nextDirectory) {
            var directory = lastDirectory + '/dao/' + (model.package ? model.package : '');

            modelMap[data.packageName + '.dao.' + (model.package ? model.package + '.' : '') + model.name] = model;

            fs.exists(directory, function(exists) {
              if (!exists) {
                fs.mkdir(directory, function(err) {
                  if (err) cb(err);
                  nextDirectory();
                });
              } else {
                nextDirectory();
              }
            });
          });
        }
      });

      async.series(directorySeries, next);
    },
    function(next) {
      var existingModels = [];

      async.parallelLimit(data.models.map(function(model) {
        return function(next) {
          model.baseClass = model.baseClass || undefined;
          model.baseClassName = model.baseClass ? model.baseClass.substring(model.baseClass.lastIndexOf('.') + 1) : undefined;
          model.packageName = data.packageName;
          model.parcelable = model.parcelable ? model.parcelable : false;
          model.gson = model.gson ? model.gson : false;
          model.noTable = model.noTable ? model.noTable : false;
          model.primaryKeyMember = _.first(_.filter(model.members, function(member) {
            return member.primaryKey;
          })) || undefined;
          model.noTypeAdapter = model.noTypeAdapter ? model.noTypeAdapter : false;
          model.package = model.package ? model.package : undefined;

          model.relationships = data.relationships;
          model.constraints = model.constraints || [];
          model.constructors = model.constructors || [];
          model.memberMap = {};

          model.baseMembers = getBaseMembers([], modelMap, model.baseClass);

          model.members.concat(model.baseMembers).forEach(function(member) {
            model.memberMap[member.name] = member;
          });

          model.types = model.members.concat(model.baseMembers).reduce(function(types, member) {
            if (!member.noGson) {
              var type = member.class ? member.class.substring(member.class.lastIndexOf('.') + 1) : helpers.typeMap[member.type]

              type = member.type == 'class[]' ? ('List<' + type + '>') : type

              member.adapterType = type.replace(/List<(\w+)>/, '$1List');

              if (types.indexOf(type) == -1) {
                types.push(type);
              }
            }

            return types;
          }, []).map(function(type) {
            return {
              type: type,
              name: type.replace(/List<(\w+)>/, '$1List'),
              isList: type.match(/List</) != null
            };
          });

          model.constructors.forEach(function(constructor) {
            var members = [];

            constructor.members.forEach(function(memberName) {
              members.push(model.memberMap[memberName]);
            })

            constructor.members = members;
          })

          model.enumMap = {};
          model.enums = model.members.concat(model.baseMembers).filter(function(member) {
            return member.type == 'enum';
          }).map(function(member) {
            model.enumMap[member.class] = member.class.substring(member.class.lastIndexOf('.') + 1);

            return member.class;
          });

          model.dao = model.dao || {
            queries: []
          };

          model.importLists = false;
          model.importSerializable = false;
          model.classes = false;
          model.classLists = false;
          model.modelMap = {};
          model.modelNameMap = {};
          model.models = _.unique(model.members.concat(model.baseMembers).filter(function(member) {
            return member.type == 'class' || member.type == 'class[]';
          }).map(function(member) {
            var className = member.class.substring(member.class.lastIndexOf('.') + 1)

            model.modelNameMap[member.class] = className;

            if (member.type == 'class[]') {
              className = 'List<' + className + '>';
              model.importLists = true;

              if (member.serializable) {
                model.importSerializable = true;
              }

              model.classLists = true;
            } else if (member.type == 'class') {
              model.classes = true;
            }

            model.modelMap[member.name + member.class] = className;

            if (member.class.substring(0, member.class.lastIndexOf('.')) == model.packageName + '.model' + (model.package ? '.' + model.package : '')) {
              return null;
            }

            if (helpers.wrappers.indexOf(member.type) != -1) {
              return null;
            }

            return member.class;
          }).filter(function(model) {
            return model != null;
          }));

          model.imports = _.uniq(model.enums.concat(model.models).filter(function(importer) {
            return importer.indexOf('java.lang.') == -1;
          }));

          model.members = model.members.map(function(member) {
            member.memberType = model.modelMap[member.name + member.class] || model.enumMap[member.class] || member.type;
            member.memberName = helpers.camelCase(member.name);

            member.gson = member.gson ? member.gson : false;
            member.noGson = member.noGson ? member.noGson : false;
            member.primaryKey = member.primaryKey ? member.primaryKey : false;
            member.embedded = member.embedded ? member.embedded : false;
            member.ignored = member.ignored ? member.ignored : false;
            member.nullable = member.type == 'class' || member.type == 'class[]' || member.type == 'String' || member.type == 'enum';

            if (member.serializedName) {
              member.serializedName = member.serializedName.replace('$', '\\$');
            }

            if (member.type == "boolean") {
              member.default = 'false';
            } else if (member.type == 'enum') {
              member.default = 'null';
            } else if (member.type == 'String') {
              member.default = 'null';
            } else if (member.type == 'class' || member.type == 'class[]') {
              member.default = 'null';
            } else if (member.type == 'float') {
              member.default = '0f';
            } else if (member.type == 'double') {
              member.default = '0.0';
            } else {
              member.default = '0';
            }

            return member;
          });

          addHelpers(model, function() {
            var modelAdditions = model.gson && (model.classes || model.classLists) ? [
                {
                  pattern: /private Gson getGson\b/,
                  text: '    private Gson getGson() {\n        return new GsonBuilder().registerTypeAdapterFactory(ModelAdapterFactory.create()).create();\n    }'
                }
            ] : null;

            existingModels.push(model.name + '.kt');              

            model.importDate = _.any(model.members.concat(model.baseMembers), function(member) {
              return member.type == 'Date';
            });

            model.dao.models = [];

            if (model.primaryKeyMember && (model.primaryKeyMember.type === 'class' || model.primaryKeyMember.type === 'class[]' || model.primaryKeyMember.type === 'enum')) {
              model.dao.models.push(model.primaryKeyMember.class);
            }

            model.dao.queries = model.dao.queries.map(function (query) {
              var className = query.class.substring(query.class.lastIndexOf('.') + 1);

              if (query.returnType == 'class[]') {
                query.returnType = 'List<' + className + '>';
              } else {
                query.returnType = className;
              }

              query.type = query.type || 'select';
              query.table = model.name.toLowerCase();

              var sql = jsonSql.build(query);

              var paramRegex = /`(\w+)`\s*[!<>=]+\s*:(p\d+)/g;
              var paramMatch;
              
              query.sql = sql.query.replace(/"/g, '`');
              query.params = [];

              while (paramMatch = paramRegex.exec(query.sql)) {
                var member = model.memberMap[paramMatch[1]];

                query.sql = query.sql.replace(paramMatch[2], sql.getValuesObject()[paramMatch[2]]);
                query.params.push({
                  type: member.memberType,
                  name: sql.getValuesObject()[paramMatch[2]]
                });

                if (member.type === 'class' || member.type === 'class[]' || member.type === 'enum') {
                  model.dao.models.push(member.class);
                }
              }

              model.dao.models = _.unique(model.dao.models);

              return query;
            });

            console.log('Creating/updating model and DAO for ' + model.name + '...');

            writeFileWithPersistedSection(destinationPackage + '/model/' + (model.package ? (model.package + '/') : '') + model.name + '.kt', 'model.ftl', null, model, function() {
              if (model.primaryKeyMember) {
                writeFileWithPersistedSection(destinationPackage + '/dao/' + (model.package ? (model.package + '/') : '') + model.name + 'Dao.kt', 'dao.ftl', null, model, next, cb);
              } else {
                next();
              }
            }, cb);
          });          
        }
      }), 10, function() {
        fs.readdir(destinationPackage + '/model/', function(err, files) {
          if (err) cb(err);

          files.forEach(function(fileOrDirectory) {
            if (fs.lstatSync(destinationPackage + '/model/' + fileOrDirectory).isDirectory()) {
              fs.readdirSync(destinationPackage + '/model/' + fileOrDirectory).forEach(function(file) {
                if (existingModels.indexOf(file) < 0) {
                  fs.unlinkSync(destinationPackage + '/model/' + fileOrDirectory + '/' + file);
                }
              });

              if (fs.readdirSync(destinationPackage + '/model/' + fileOrDirectory).length == 0) {
                fs.rmdirSync(destinationPackage + '/model/' + fileOrDirectory);
              }
            } else if (existingModels.indexOf(fileOrDirectory) < 0 && fileOrDirectory.match(/(ModelAdapterFactory|ModelTypeAdapters)/) == null) {
              fs.unlinkSync(destinationPackage + '/model/' + fileOrDirectory);
            }
          });

          next();
        })
      }, function() {
        fs.readdir(destinationPackage + '/dao/', function(err, files) {
          if (err) cb(err);

          files.forEach(function(fileOrDirectory) {
            if (fs.lstatSync(destinationPackage + '/dao/' + fileOrDirectory).isDirectory()) {
              fs.readdirSync(destinationPackage + '/dao/' + fileOrDirectory).forEach(function(file) {
                if (existingModels.indexOf(file.replace('Dao.kt', '.kt')) < 0) {
                  fs.unlinkSync(destinationPackage + '/dao/' + fileOrDirectory + '/' + file);
                }
              });

              if (fs.readdirSync(destinationPackage + '/dao/' + fileOrDirectory).length == 0) {
                fs.rmdirSync(destinationPackage + '/dao/' + fileOrDirectory);
              }
            } else if (existingModels.indexOf(fileOrDirectory.replace('Dao.kt', '.kt')) < 0) {
              fs.unlinkSync(destinationPackage + '/dao/' + fileOrDirectory);
            }
          });

          next();
        })
      });
    },
    function(next) {
      if (_.any(data.models, function(model) {
        return model.gson;
      })) {
        data.gsonModels = data.models.filter(function(model) {
          return model.gson && !model.noTypeAdapter;
        });

        console.log('Creating/updating model adapter factory...'); 
        
        freemarker.render('adapter-factory.ftl', data, function(err, result, output) {
          if (err) return cb(output);
          fs.writeFile(destinationPackage + '/model/ModelAdapterFactory.kt', result, next);
        });
      } else {
        next();
      }
    },
    function(next) {
      if (data.modelsOnly) {
        next();
      } else {
        data.types = {
          models: [
            {
              name: "JSONObject", 
              fullPackageName: "org.json.JSONObject"
            }
          ],
          modelLists: [],
          imports: [],
          enums: []
        };

        var processedTypes = {},
            findTypes = function(model) {
              var modelPackageName = data.packageName + '.model.' + (model.package ? model.package + '.' : '') + model.name;

              if (!processedTypes[modelPackageName]) {
                processedTypes[modelPackageName] = true;

                model.enums.forEach(function(modelEnum) {
                  data.types.enums.push(modelEnum);
                });

                model.members.filter(function(member) {
                  return member.type == 'class' || member.type == 'class[]';
                }).forEach(function(member) {
                  var model = modelMap[member.class];

                  if (model) {
                    (member.type == 'class' ? data.types.models : data.types.modelLists).push(model);
                  }
                });
              }
            };

        data.entityModels = data.models.map(function(model) {
          model.primaryKeyMember = _.first(_.filter(model.members, function(member) {
            return member.primaryKey;
          })) || undefined;

          if (model.primaryKeyMember) {
            findTypes(model);
          } else {
            return null;
          }

          return model;
        }).filter(function(model) {
          return model != null;
        });

        data.types.models = _.uniq(data.types.models, function(model) {
          return model.name;
        }).map(function(model) {
          model.fullPackageName = model.fullPackageName || data.packageName + '.model.' + (model.package ? model.package + '.' : '') + model.name;

          return model;
        });

        data.types.modelLists = _.uniq(data.types.modelLists, function(model) {
          return model.name;
        }).map(function(model) {
          model.fullPackageName = model.fullPackageName || data.packageName + '.model.' + (model.package ? model.package + '.' : '') + model.name;

          return model;
        });

        data.types.imports = _.uniq(data.types.models.concat(data.types.modelLists), function(model) {
          return model.fullPackageName;
        });

        data.types.enums = _.uniq(data.types.enums).map(function(modelEnum) {
          return {
            fullPackageName: modelEnum,
            class: modelEnum,
            name: modelEnum.substring(modelEnum.lastIndexOf('.') + 1)
          }
        });

        console.log('Creating/updating database...'); 

        addHelpers(data, function() {
          async.parallel([
            function(next) {
              writeFileWithPersistedSection(destinationPackage + '/database/' + data.databasePrefix + 'Database.kt', 'database.ftl', null, data, function() {
                console.log('Creating/updating type adapters...'); 
        
                writeFileWithPersistedSection(destinationPackage + '/model/ModelTypeAdapters.kt', 'type-adapters.ftl', null, data, next, cb);
              }, cb);
            },
          ], next);
        });
      }
    }
  ], cb);
}

module.exports = Roomy;