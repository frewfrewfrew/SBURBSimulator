//import '../SBURBSim.dart';// show GameEntity;  //Yep, requires whole library to compile can't just test GameEntity.
import 'dart:typed_data';
import 'dart:collection';
import 'dart:convert';
part "../GameEntities/GameEntity.dart"; //internet says "part" is functionally like saying "pretend this thing is literally line for line right here".

var testGE = null;
main() {
  print("Hello World");
  testName();
  testID();
  testStats();
}

setup() {
  testGE = new GameEntity("Firsty", 413, null);
}

testName() {
  setup();
  print(testGE.name);
  assert(testGE.name == "Firsty");
}

testID() {
  setup();
  print(testGE.id);
  assert(testGE.id == 413 ? true : throw "ID should be 413, but is: ${testGE.id}");
}

testStats() {
  setup();
  print(testGE.stats);
  assert(testGE.getStat("hp") == 0 ? true : throw "initial hp should be 0, but is: ${testGE..getStats("hp")}");
  testGE.setStatsHash({"hp": 100, "currentHP":10, "power":3, "maxLuck": 100});
  jRAssert("hp", testGE.getStat("hp"), 100);
  jRAssert("currentHP", testGE.getStat("currentHP"), 10);
  jRAssert("power", testGE.getStat("power"), 3);
  jRAssert("maxLuck", testGE.getStat("maxLuck"), 100);
  jRAssert("minLuck", testGE.getStat("minLuck"), 0);  //confirm did not change.
  jRAssert("sanity", testGE.getStat("sanity"), 0);  //confirm did not change.
  jRAssert("alchemy", testGE.getStat("alchemy"), 0);  //confirm did not change.
  jRAssert("RELATIONSHIPS", testGE.getStat("RELATIONSHIPS"), 0);  //confirm did not change.
  jRAssert("freeWill", testGE.getStat("freeWill"), 0);  //confirm did not change.
  jRAssert("mobility", testGE.getStat("mobility"), 0);  //confirm did not change.
  print(testGE.stats);
}

jRAssert(name, tested, expected)
{
  assert(tested == expected ? true : throw "${name} should be ${expected}, but is: ${tested}");
}