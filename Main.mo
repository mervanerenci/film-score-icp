import List "mo:base/List";
import Option "mo:base/Option";
import Map "mo:base/OrderedMap";
import Nat32 "mo:base/Nat32";


actor FilmScoring {

  /**
   * Types
   */

  // The type of a film identifier.
  public type FilmId = Nat32;

  // The type of a film.
  public type Film = {
    title : Text;
    author : Text;
    point : Nat32
  };

  /**
   * Application State
   */

  // The next available film identifier.
  stable var next : FilmId = 0;

  // The film data store.
  let Ops = Map.Make<FilmId>(Nat32.compare);
  stable var map : Map.Map<FilmId, Film> = Ops.empty();

  /**
   * High-Level API
   */

  // Create a film.
  public func createFilm(film : Film) : async FilmId {
    let filmId = next;
    next += 1;
    map := Ops.put(map, filmId, film);
    return filmId
  };

  

  // Read a film.
  public query func getFilm(filmId : FilmId) : async ?Film {
    let result = Ops.get(map, filmId);
    return result
  };

  // Update the point of a film.
  public func updatePoint(filmId : FilmId, newPoint : Nat32) : async Bool {
    let filmOpt = Ops.get(map, filmId);
    switch (filmOpt) {
      case (?film) {
        let updatedFilm = { title = film.title; author = film.author; point = newPoint };
        map := Ops.put(map, filmId, updatedFilm);
        return true;
      };
      case null {
        return false;
      };
    }
  };

  // Delete a film.
  public func delete(filmId : FilmId) : async Bool {
    let (result, old_value) = Ops.remove(map, filmId);
    let exists = Option.isSome(old_value);
    if (exists) {
      map := result
    };
    return exists
  }
}
