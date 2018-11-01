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
name: String (required)
class: Class (required)
type: class (default), class[], enum
serializable: Boolean
serializedName: String
noGson: Boolean
parcelable: Boolean
localOnly: Boolean
autoGenerate: Boolean
primaryKey: Boolean
embedded: Boolean
ignored: Boolean
default: Any
nonNull: Boolean
```

Example Model:
```
{
"name": "Address",
"package": "customer",
"members": [
  {
    "name": "id",
    "class": "kotlin.Long",
    "nonNull": true,
    "serializedName": "ID",
    "primaryKey": true
  },
  {
    "name": "name",
    "class": "kotlin.String",
    "serializedName": "Name"
  },
  {
    "name": "street1",
    "class": "kotlin.String",
    "serializedName": "Street1"
  },
  {
    "name": "street2",
    "class": "kotlin.String",
    "serializedName": "Street2"
  },
  {
    "name": "city",
    "class": "kotlin.String",
    "serializedName": "City"
  },
  {
    "name": "state",
    "class": "kotlin.String",
    "serializedName": "State"
  },
  {
    "name": "postal_code",
    "class": "kotlin.String",
    "serializedName": "PostalCode"
  },
  {
    "name": "country_code",
    "class": "kotlin.String",
    "serializedName": "CountryCode"
  },
  {
    "name": "is_default",
    "class": "kotlin.Boolean",
    "nonNull": true,
    "serializedName": "IsDefault"
  },
  {
    "name": "selected",
    "class": "kotlin.Boolean",
    "nonNull": true
  }
],
"constructors": [
  {
    "members": [
      "name",
      "street1",
      "street2",
      "city",
      "state",
      "postal_code",
      "country_code"
    ]
  }
],
"dao": {
  "orderBy": "is_default",
  "orderByDirection": "DESC",
  "queries": []
},
"gson": true,
"parcelable": true
}
 ```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style.

## License
Copyright (c) 2017 Jeff Hillman  
