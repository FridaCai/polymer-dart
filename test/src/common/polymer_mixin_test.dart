// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@TestOn('browser')
library polymer.test.src.common.polymer_mixin_test;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:test/test.dart';

TestElement element;
SubElement subElement;

main() async {
  await initPolymer();

  setUp(() {
    element = document.createElement('test-element');
    subElement = element.$['sub'];
  });

  test('default values', () {
    expect(element.myInt, 1);
    expect(element.jsElement['myInt'], 1);
  });

  group('set', () {
    test('basic', () {
      element.set('myInt', 2);
      expect(element.myInt, 2);
      expect(element.jsElement['myInt'], 2);
    });

    test('Map', () {
      element.set('myMap.hello', 'world');
      expect(element.myMap['hello'], 'world');
      expect(element.jsElement['myMap']['hello'], 'world');
    });

    test('List', () {
      element.set('myInts', [1, 2, 3]);
      expect(element.myInts, [1, 2, 3]);
      expect(element.jsElement['myInts'], [1, 2, 3]);

      element.set('myInts.1', 4);
      expect(element.myInts, [1, 4, 3]);
      expect(element.jsElement['myInts'], [1, 4, 3]);
    });

    test('List.index', () {
      element.add('myThings', new Thing('A'));
      element.add('myThings', new Thing('B'));
      element.add('myThings', new Thing('C'));
      element.set('myThings.1.field', 'D');
      element.removeAt('myThings', 0);
      element.set('myThings.1.field', 'E');

      expect(element.myThings.map((Thing t) => t.field).toList(), ['D', 'E']);
    });

    test('List.replace', () {
      element.add('myThings', new Thing('A'));
      element.add('myThings', new Thing('B'));
      element.add('myThings', new Thing('C'));
      element.set('myThings.1', new Thing('D'));
      element.removeAt('myThings', 0);
      element.set('myThings.1', new Thing('E'));

      expect(element.myThings.map((Thing t) => t.field).toList(), ['D', 'E']);
    });

    test('JsProxy', () {
      var newModel = new Model('world');
      element.set('myModel', newModel);
      expect(element.myModel, newModel);
      expect(element.jsElement['myModel'], newModel.jsProxy);

      element.set('myModel.value', 'cool');
      expect(element.myModel.value, 'cool');
      expect(element.jsElement['myModel']['value'], 'cool');
    });
  });

  group('notifyPath', () {
    test('basic', () {
      element.myInt = 2;
      expect(element.jsElement['myInt'], 1);
      element.notifyPath('myInt', 2);
      expect(element.jsElement['myInt'], 2);
    });

    test('Map', () {
      element.myMap['hello'] = 'world';
      expect(element.get('myMap.hello'), null);
      element.notifyPath('myMap.hello', element.myMap['hello']);
      expect(element.jsElement['myMap']['hello'], 'world');
    });

    test('List', () {
      element.myInts = [1, 2, 3];
      expect(element.jsElement['myInts'], []);
      element.notifyPath('myInts', element.myInts);
      expect(element.jsElement['myInts'], [1, 2, 3]);

      element.myInts[1] = 4;
      expect(element.jsElement['myInts'], [1, 2, 3]);
      element.notifyPath('myInts.1', element.myInts[1]);
      expect(element.myInts, [1, 4, 3]);
      expect(element.jsElement['myInts'], [1, 4, 3]);
    });

    test('List.index', () {
      element.myThings = [new Thing('A'), new Thing('B'), new Thing('C')];
      element.notifyPath('myThings', element.myThings);
      element.myThings[1].field = 'D';
      element.notifyPath('myThings.1.field', element.myThings[1].field);
      element.removeAt('myThings', 0);
      element.myThings[1].field = 'E';
      element.notifyPath('myThings.1.field', element.myThings[1].field);

      expect(element.myThings.map((Thing t) => t.field).toList(), ['D', 'E']);
      expect(element.jsElement['myThings'].map((t) => t['field']).toList(),
          ['D', 'E']);
    });

    test('List.replace', () {
      element.myThings = [new Thing('A'), new Thing('B'), new Thing('C')];
      element.notifyPath('myThings', element.myThings);
      element.myThings[1] = new Thing('D');
      element.notifyPath('myThings.1', element.myThings[1]);
      element.removeAt('myThings', 0);
      element.myThings[1] = new Thing('E');
      element.notifyPath('myThings.1', element.myThings[1]);

      expect(element.myThings.map((Thing t) => t.field).toList(), ['D', 'E']);
      expect(element.jsElement['myThings'].map((t) => t['field']).toList(),
          ['D', 'E']);
    });

    test('JsProxy', () {
      element.myModel = new Model('world');
      expect(element.jsElement['myModel']['value'], 'hello');
      element.notifyPath('myModel', element.myModel);
      expect(element.jsElement['myModel']['value'], 'world');

      element.myModel.value = 'cool';
      expect(subElement.$['modelValue'].text, 'world');
      element.notifyPath('myModel.value', element.myModel.value);
      expect(subElement.$['modelValue'].text, 'cool');
    });
  });

  test('\$', () {
    expect(element.$['parent'], isNotNull);
    expect(element.$['parent'].id, 'parent');
    expect(element.$['child'], isNotNull);
    expect(element.$['child'].id, 'child');
  });

  test('root', () {
    expect(Polymer.dom(element.root), isNotNull);
    expect(Polymer.dom(element.root).children.first, element.$['parent']);
    expect(
        Polymer.dom(element.root).querySelector('#child'), element.$['child']);
  });

  group('List api: ', () {
    test('add', () {
      element.add('myInts', 1);
      expect(element.myInts, [1]);
      expect(element.jsElement['myInts'], [1]);
    });

    test('addAll', () {
      element.addAll('myInts', [1, 2, 3, 4]);
      expect(element.myInts, [1, 2, 3, 4]);
      expect(element.jsElement['myInts'], [1, 2, 3, 4]);
    });

    test('clear', () {
      element.addAll('myInts', [1, 2, 3]);
      element.clear('myInts');
      expect(element.myInts, []);
      expect(element.jsElement['myInts'], []);
    });

    test('fillRange', () {
      element.addAll('myInts', [0, 0, 0, 0, 0]);
      element.fillRange('myInts', 1, 4, 1);
      expect(element.myInts, [0, 1, 1, 1, 0]);
      expect(element.jsElement['myInts'], [0, 1, 1, 1, 0]);
    });

    test('insert', () {
      element.addAll('myInts', [0, 0]);
      element.insert('myInts', 1, 1);
      expect(element.myInts, [0, 1, 0]);
      expect(element.jsElement['myInts'], [0, 1, 0]);
    });

    test('insertAll', () {
      element.addAll('myInts', [0, 0]);
      element.insertAll('myInts', 1, [1, 2, 3]);
      expect(element.myInts, [0, 1, 2, 3, 0]);
      expect(element.jsElement['myInts'], [0, 1, 2, 3, 0]);
    });

    test('removeItem', () {
      element.addAll('myInts', [0, 1, 2]);
      element.removeItem('myInts', 1);
      expect(element.myInts, [0, 2]);
      expect(element.jsElement['myInts'], [0, 2]);
    });

    test('removeAt', () {
      element.addAll('myInts', [0, 1, 2]);
      element.removeAt('myInts', 1);
      expect(element.myInts, [0, 2]);
      expect(element.jsElement['myInts'], [0, 2]);
    });

    test('removeLast', () {
      element.addAll('myInts', [0, 1, 2]);
      element.removeLast('myInts');
      expect(element.myInts, [0, 1]);
      expect(element.jsElement['myInts'], [0, 1]);
    });

    test('removeRange', () {
      element.addAll('myInts', [0, 1, 2, 3, 4]);
      element.removeRange('myInts', 1, 4);
      expect(element.myInts, [0, 4]);
      expect(element.jsElement['myInts'], [0, 4]);
    });

    test('removeWhere', () {
      element.addAll('myInts', [0, 1, 2, 3, 4]);
      element.removeWhere('myInts', (item) => item % 2 == 0);
      expect(element.myInts, [1, 3]);
      expect(element.jsElement['myInts'], [1, 3]);
    });

    test('replaceRange', () {
      element.addAll('myInts', [0, 1, 2, 3, 4]);
      element.replaceRange('myInts', 1, 4, [5, 6, 7]);
      expect(element.myInts, [0, 5, 6, 7, 4]);
      expect(element.jsElement['myInts'], [0, 5, 6, 7, 4]);
    });

    test('retainWhere', () {
      element.addAll('myInts', [0, 1, 2, 3, 4]);
      element.retainWhere('myInts', (item) => item % 2 == 0);
      expect(element.myInts, [0, 2, 4]);
      expect(element.jsElement['myInts'], [0, 2, 4]);
    });

    test('setAll', () {
      element.addAll('myInts', [0, 1, 2, 3]);
      element.setAll('myInts', 1, [5, 6, 7]);
      expect(element.myInts, [0, 5, 6, 7]);
      expect(element.jsElement['myInts'], [0, 5, 6, 7]);
    });

    test('setRange', () {
      element.addAll('myInts', [0, 1, 2, 3, 4]);
      element.setRange('myInts', 1, 4, [-1, 5, 6, 7], 1);
      expect(element.myInts, [0, 5, 6, 7, 4]);
      expect(element.jsElement['myInts'], [0, 5, 6, 7, 4]);
    });
  });

  group('fire', () {
    test('on self', () {
      var done = new Completer();
      var detail = 'some details!';
      element.on['test-event'].take(1).listen((e) {
        e = convertToDart(e);
        expect(e.detail, detail);
        expect(e.cancelable, isTrue);
        expect(e.bubbles, isTrue);
        done.complete();
      });
      element.fire('test-event', detail: detail);
      return done;
    });

    test('on child', () {
      var done = new Completer();
      var detail = 'some details!';
      element.$['child'].on['test-event'].take(1).listen((e) {
        e = convertToDart(e);
        expect(e.detail, detail);
        done.complete();
      });
      element.fire('test-event', detail: detail, node: element.$['child']);
      return done;
    });

    test('not cancelable', () {
      var done = new Completer();
      element.on['test-event'].take(1).listen((e) {
        expect(e.cancelable, isFalse);
        done.complete();
      });
      element.fire('test-event', cancelable: false);
      return done;
    });

    test('non-bubbling', () {
      var done = new Completer();
      element.on['test-event'].take(1).listen((e) {
        expect(e.bubbles, isFalse);
        done.complete();
      });
      element.fire('test-event', canBubble: false);
      return done;
    });
  });
}

class Thing extends JsProxy {
  @reflectable
  String field;

  Thing(this.field);

  bool operator ==(var other) => other is Thing && (other.field == this.field);

  int get hashCode => field.hashCode;
}

@PolymerRegister('test-element')
class TestElement extends HtmlElement with PolymerMixin, PolymerBase {
  @property
  int myInt = 1;

  @property
  List<int> myInts = [];

  @property
  List<Thing> myThings = [];

  @property
  Map myMap = {};

  @property
  Model myModel = new Model('hello');

  TestElement.created() : super.created() {
    polymerCreated();
  }
}

@PolymerRegister('sub-element')
class SubElement extends HtmlElement with PolymerMixin, PolymerBase {
  SubElement.created() : super.created() {
    polymerCreated();
  }

  @property
  List<int> myInts;

  @property
  Map myMap;

  @property
  Model myModel;
}

class Model extends JsProxy {
  @reflectable
  String value;

  Model(this.value);
}
