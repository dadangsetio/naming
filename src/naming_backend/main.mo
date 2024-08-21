import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Order "mo:base/Order";
import Debug "mo:base/Debug";
import Cycles "mo:base/ExperimentalCycles";
import Blob "mo:base/Blob";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Types "Types";

actor {
  let nameCounts = HashMap.HashMap<Text, Nat>(0, Text.equal, Text.hash);
  var totalSubmissions : Nat = 0;

  public func submitName(name : Text) : async Nat {
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

  public query func getAllNames() : async [(Text, Nat)] {
    let entries = Iter.toArray(nameCounts.entries());
    return Array.sort(entries, func (a : (Text, Nat), b : (Text, Nat)) : Order.Order {
      if (a.1 > b.1) { #less } 
      else if (a.1 < b.1) { #greater } 
      else { Text.compare(a.0, b.0) }
    });
  };

  public query func getNameCount(name : Text) : async ?Nat {
    return nameCounts.get(name);
  };

  public query func transform(raw : Types.TransformArgs) : async Types.CanisterHttpResponsePayload {
      let transformed : Types.CanisterHttpResponsePayload = {
          status = raw.response.status;
          body = raw.response.body;
          headers = [
              {
                  name = "Content-Security-Policy";
                  value = "default-src 'self'";
              },
              { name = "Referrer-Policy"; value = "strict-origin" },
              { name = "Permissions-Policy"; value = "geolocation=(self)" },
              {
                  name = "Strict-Transport-Security";
                  value = "max-age=63072000";
              },
              { name = "X-Frame-Options"; value = "DENY" },
              { name = "X-Content-Type-Options"; value = "nosniff" },
          ];
      };
      transformed;
  };

  public func get_icp_usd_exchange() : async Text {
    let ic : Types.IC = actor ("aaaaa-aa");

    let ONE_MINUTE : Nat64 = 60;
    let current_time : Int = Time.now();
    let three_days_in_nanos : Int = 3 * 24 * 60 * 60 * 1_000_000_000;
    let start_timestamp : Types.Timestamp = Nat64.fromNat(Int.abs(current_time + three_days_in_nanos));
    let end_timestamp : Types.Timestamp = Nat64.fromNat(Int.abs(current_time + three_days_in_nanos + 60_000_000_000));
    let host : Text = "api.pro.coinbase.com";
    let url = "https://" # host # "/products/ICP-USD/candles?start=" # Nat64.toText(start_timestamp) # "&end=" # Nat64.toText(end_timestamp) # "&granularity=" # Nat64.toText(ONE_MINUTE);

    let request_headers = [
        { name = "Host"; value = host # ":443" },
        { name = "User-Agent"; value = "exchange_rate_canister" },
    ];

    let transform_context : Types.TransformContext = {
      function = transform;
      context = Blob.fromArray([]);
    };

    let http_request : Types.HttpRequestArgs = {
        url = url;
        max_response_bytes = null;
        headers = request_headers;
        body = null;
        method = #get;
        transform = ?transform_context;
    };

    Cycles.add(230_949_972_000);
    
    let http_response : Types.HttpResponsePayload = await ic.http_request(http_request);
    
    let response_body: Blob = Blob.fromArray(http_response.body);
    let decoded_text: Text = switch (Text.decodeUtf8(response_body)) {
        case (null) { "No value returned" };
        case (?y) { y };
    };

    decoded_text
  };
};