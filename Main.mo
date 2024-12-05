import List "mo:base/List";
import Option "mo:base/Option";
import Map "mo:base/OrderedMap";
import Nat32 "mo:base/Nat32";

actor FilmScoring {

  public type FilmId = Nat32;

  public type Film = {
    title : Text;
    author : Text;
    point : Nat32;

  };

  stable var next : FilmId = 0;

  let Ops = Map.Make<FilmId>(Nat32.compare);
  stable var map : Map.Map<FilmId, Film> = Ops.empty();

  public func createFilm(film : Film) : async FilmId {
    let filmId = next;
    next += 1;
    map := Ops.put(map, filmId, film);
    return filmId
  };

  public query func getFilm(filmId : FilmId) : async ?Film {
    let result = Ops.get(map, filmId);
    return result
  };

  public func updatePoint(filmId : FilmId, newPoint : Nat32) : async Bool {
    let filmOpt = Ops.get(map, filmId);

    switch (filmOpt) {
      case (?film) {
        let updatedFilm = {
          title = film.title;
          author = film.author;
          point = newPoint
        };
        map := Ops.put(map, filmId, updatedFilm);
        return true
      };
      case null {
        return false
      }
    }
  };

  public func delete(filmId : FilmId) : async Bool {
    let (result, old_value) = Ops.remove(map, filmId);
    let exists = Option.isSome(old_value);

    if (exists) {
      map := result
    };

    return exists
  }

}
