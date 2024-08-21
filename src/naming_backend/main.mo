import Text "mo:base/Text";
import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";

actor {
  let nameCounts = HashMap.HashMap<Text, Nat>(0, Text.equal, Text.hash);
  var totalSubmissions : Nat = 0;

  public query func greet(name : Text) : async Text {
    return "Halo, " # name # "!";
  };

  public func getNameRank(name : Text) : async Nat {
    totalSubmissions += 1;
    let currentCount = switch (nameCounts.get(name)) {
      case (null) { 1 };
      case (?count) { count + 1 };
    };
    nameCounts.put(name, currentCount);
    return currentCount;
  };

  public query func getTotalSubmissions() : async Nat {
    return totalSubmissions;
  };
};