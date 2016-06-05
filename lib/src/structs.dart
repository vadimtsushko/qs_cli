part of engine;

class MeasureDef {
  String id;
  String definition;
  String title;
  String description;
  List<String> tags;
  MeasureDef(this.id, this.definition, this.title,
  {this.description: '', this.tags:const []});

  MeasureDef.fromJson(Map from) {
    id = from['qProp']['qInfo']['qId'];
    definition = from['qProp']['qMeasure']['qDef'];
    title = from['qProp']['qMetaDef']['title'];
    description = from['qProp']['qMetaDef']['description'] ?? '';
    tags = from['qProp']['qMetaDef']['tags'] ?? [];
  }
  Map toJson() => {
        "qProp": {
          "qInfo": {"qId": id, "qType": "measure"},
          "qMeasure": {
            "qLabel": title,
            "qDef": definition,
            "qGrouping": "N",
            "qExpressions": [],
            "qActiveExpression": 0
          },
          "qMetaDef": {"title": title, "description": description, "tags": tags}
        }
      };
}

class VariableDef {
  String id;
  String name;
  String definition;
  String comment;
  List<String> tags;
  VariableDef(this.name, this.definition, this.comment,
  {this.id, this.tags: const []}) {
    if (id == null) {
      id = name;
    }
  }

  VariableDef.fromJson(Map from) {
    id = from['qProp']['qInfo']['qId'] ?? '';
    definition = from['qProp']['qDefinition'];
    name = from['qProp']['qName'];
    comment = from['qProp']['qComment'];
    tags = from['qProp']['qMetaDef']['tags'] ?? [];
  }
  Map toJson() => {
    "qProp": {
          "qInfo": {"qId": id ?? name, "qType": "variable"},
    "qMetaDef": {},
    "qName": name,
    "qComment": comment,
    "qNumberPresentation": {"qType": "U", "qnDec": 10, "qUseThou": 0},
    "qDefinition": definition,
    "tags": tags
    }
  };
}

