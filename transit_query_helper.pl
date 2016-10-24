% Prolog
stops_at(Trip, Stop) :-
  % stop_id of stop
  stop_id(Stop, StopId),
  setof(
    Trip0,
    setof(
    (StopTime, TripId), % Un-interesting free variables
    (
      % stop_id of stop_time
      stop_id(StopTime, StopId),
      trip_id(StopTime, TripId),
      trip_id(Trip0, TripId),
      Trip0 =.. [trip|_]
    ),
    _
    ),
    Trips
  ),
  member(Trip, Trips).

goes_between(StopA, StopB, Trip) :-
  stops_at(Trip, StopA),
  stops_at(Trip, StopB).

% stop_times
% (StartStop, StartTime): stop(...), time(string)
% (DestStop, DestTime): stop(...), time(string)
% (Trip, DepartureStopTime, ArrivalStopTime): Out trip(...), stop_time(...), stop_time(...)
from_to_via(
    (StartStop, StartTime),
    (DestStop, DestTime),
    (Trip, DepartureStopTime, ArrivalStopTime)
  ) :-
  % convert time to seconds for calculation
  time_second(StartTime, StartSecond),
  time_second(DestTime, DestSecond),
  % extract id's
  stop_id(StartStop, StartStopId),
  stop_id(DestStop, DestStopId),
  trip_id(Trip, TripId),
  Trip =.. [trip|_],
  % unify DepartureStopTime
  stop_id(DepartureStopTime, StartStopId),
  trip_id(DepartureStopTime, TripId),
  % departure constraints
  DepartureStopTime, % initialzied
  departure_time(DepartureStopTime, DepartureTime),
  time_second(DepartureTime, DepartureSecond),
  StartSecond =< DepartureSecond,
  % unify ArrivalStopTime
  stop_id(ArrivalStopTime, DestStopId),
  trip_id(ArrivalStopTime, TripId),
  % arrival constraints
  ArrivalStopTime, % initialized
  arrival_time(ArrivalStopTime, ArrivalTime),
  time_second(ArrivalTime, ArrivalSecond),
  DestSecond >= ArrivalSecond,
  Trip.


% stops
% (Lat, Lon): (number, number)
% Stop: Out stop(...)
nearest_stop((Lat,Lon), Stop) :-
  findall(
    Dis0 - Stop0,
    (
      stop_lat(Stop0, Lat0),
      stop_lon(Stop0, Lon0),
      Stop0,
      latlon_distance((Lat0, Lon0), (Lat, Lon), Dis0)
    ),
    DisStopMap),
  keysort(DisStopMap, [_ - Stop|_]).


% Utils
% (Lat0, Lon0): (number, number)
% (Lat1, Lon1): (number, number)
% Distance: Out number
latlon_distance((Lat0,Lon0), (Lat1, Lon1), Distance) :-
  Distance is sqrt((Lat0 - Lat1) ^ 2 + (Lon0 - Lon1) ^ 2).

% Time: string {Hour}:{Minute}:{Second} % \s will be ignored
% Second: Out integer
time_second(Time, Second) :-
  split_string(Time, ':', ' ', [Hstr, Mstr, Sstr]),
  atom_number(Hstr, H),
  atom_number(Mstr, M),
  atom_number(Sstr, S),
  Second is H * 3600 + M * 60 + S.