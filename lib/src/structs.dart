part of engine;

class Measure {
  String id;
  String definition;
  String title;
  String description;
  List<String> tags;
  Measure(this.id, this.definition, this.title,
      [this.description = '', this.tags = const []]);
  
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

var sample = {
  "qProp": {
    "qInfo": {"qId": "Выражение4", "qType": "measure"},
    "qMeasure": {
      "qLabel": "Выражение3",
      "qDef": "Sum(Expression99)",
      "qGrouping": "N",
      "qExpressions": [],
      "qActiveExpression": 0
    },
    "qMetaDef": {
      "title": "Выражение 4",
      "description": "Сумма по Expression3",
      "tags": ["Суммы"]
    }
  }
};
