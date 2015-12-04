// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library dart_qv.test;

import 'package:dart_qv/engine.dart';
import 'package:test/test.dart';

void main() {
  test('MeasureDef', () {
    var measure = new MeasureDef('M01','Sum(1)','Measure1',description: 'My first measure',tags: ['Sums','Generated']);
    Map measureMap = measure.toJson();
    expect(measureMap['qProp']['qInfo']['qId'],'M01');
    var measure2 = new MeasureDef.fromJson(measureMap);
    expect(measure2.id,measure.id);
    expect(measure2.description,measure.description);
    expect(measure2.title,measure.title);
    expect(measure2.definition,measure.definition);
    expect(measure2.tags,orderedEquals(measure.tags));
  });
  test('Variable', () {
    var variableDef = new VariableDef('vSum1','Sum(Expression1)','vSum1 comment');
    Map variableMap = variableDef.toJson();
    expect(variableMap['qProp']['qName'],'vSum1');
    var variableDef2 = new VariableDef.fromJson(variableMap);
    expect(variableDef2.id,variableDef.id);
    expect(variableDef2.name,variableDef.name);
    expect(variableDef2.comment,variableDef.comment);
    expect(variableDef2.definition,variableDef.definition);
    expect(variableDef2.tags,orderedEquals(variableDef.tags));
  });

}
