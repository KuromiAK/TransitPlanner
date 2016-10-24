% Tests
:- time_second(' 8:20:00', X), test(X, 30000).
:- latlon_distance((0,0),(1,1),X),
   compare(L, X, 1.42), test(L, <),
   compare(G, X, 1.41), test(G, >).

:- nearest_stop((0,0), Stop),
   stop_id(Stop, StopId),
   test(StopId, 9956).

:-  stop_id(StartStop, 56), StartStop =.. [stop|_],
    stop_id(DestStop, 58), DestStop =.. [stop|_], 
    bagof(
        TripId,
        Trip^D^A^(
            from_to_via(
                (StartStop, '8:21:00'),
                (DestStop, '8:25:00'),
                (Trip, D, A)
            ),
            trip_id(Trip, TripId)
        ),
        TripIds
    ),
    test(TripIds, [8199777, 8198574]).