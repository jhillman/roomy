# roomy

A Room entity generator.

Go to your room.

## Getting Started
Install with npm:
```bash
$ npm install
```
Link the command line tool (roomy):
```bash
$ npm link
```
Run `roomy` in the directory that contains your room.json file:
```bash
$ roomy
```

Model Properties include:
```
name: String
baseClass: String
open: Boolean
package: String
members: []
contructors: []
gson: Boolean
parcelable: Boolean
noTypeAdapter: Boolean

```

Member Properties include:
```
name: String
type: primitive or `class` or `enum`
class: Class
serializable: Boolean
serializedName: String
noGson: Boolean
parcelable: Boolean
localOnly: Boolean
autoGenerate: Boolean
primaryKey: Boolean
embedded: Boolean
ignored: Boolean
default: enum or primative only
nonNull: Boolean
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style.

## License
Copyright (c) 2017 Jeff Hillman  
