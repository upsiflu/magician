module Country exposing (Country, Point, Vector, point, tower)

{-|-}


import Vector2d exposing (Vector2d)
import Point2d exposing (Point2d)
import Length exposing (Meters)

{-| A coordinate system where `(0, 0)` is the tower position, and positive `y` values go North, and positive `x` values go East, and distances can be calculated as if all patients were living on a plane (Euclidean distance). -}
type Country =
    Country

{-| Position relative to the tower (**in meters**, because that's the package's internal representation)-}
type alias Point =
    Point2d Meters Country


{-| Position relative to the previous point, i.e. Path Segment -}
type alias Vector =
    Vector2d Meters Country
    
{-| Lengths **in meters** -}
point : { x : Float, y : Float } -> Point
point = Point2d.fromMeters


{-|-}
tower : Point
tower = Point2d.origin
