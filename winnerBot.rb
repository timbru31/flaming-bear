require File.join(File.dirname(__FILE__), 'botlib')

class WinnerBot

  attr_accessor :botname, :icon

  def initialize
    @botname = "Tim"
  end

  def onTurn(lib)
    # Stuff
    vehicle = lib.getVehicle
    track = lib.getTrack
    vehicle["thrust"] = 5
    x = vehicle["x"]
    y = vehicle["y"]
    wall = false


    nextRacePoint = lib.getCoordsNextRacepoint
    nextSpeedUpPoint = lib.getCoordsNextSpeedUpPoint
    nextWall = lib.getCoordsNextWall

    # per default the next point is our racepoint
    nextPoint = nextRacePoint

    direction = vehicle["direction"]

    # Maybe we need a speedpoint first?
    unless nextSpeedUpPoint.nil?
      speedUpDirection = lib.calcDirection(vehicle, nextSpeedUpPoint)
      nextRacePointDistance = lib.calcDistance(vehicle, nextRacePoint)
      nextSpeedUpPointDistance = lib.calcDistance(vehicle, nextSpeedUpPoint)
      if nextSpeedUpPointDistance < nextRacePointDistance
        if facing?(direction, speedUpDirection) && (nextRacePointDistance - nextSpeedUpPointDistance > 30)
          nextPoint = nextSpeedUpPoint
        end
      end
    end

    # Find fastest way with corners
    nextPointCorners = lib.getPointWithCorners nextPoint
    nextPointCorners.each do | point |
      if (lib.calcDistance(vehicle, point) < lib.calcDistance(vehicle, nextPoint))
        nextPoint = point
      end
    end

    walls = lib.getWalls
    walls.each do |wall|
      if ( ((wall["x"].abs - x).abs <= 50) && ((wall["y"].abs - y).abs <= 50) )
        nextPointDistance = lib.calcDistance(vehicle, nextPoint)
        direction = lib.calcDirection vehicle, nextPoint
        if nextPointDistance > 90 && (direction.ceil <= 95 && direction.ceil >= 85)
          bump = 45
        else
          nextPointDistance < 50 ? bump = 30 : bump = 40
          nextPointDistance < 40 ? bump = 25 : bump
        end
        direction > 270 ?  direction = direction - bump : direction = direction + bump
        vehicle["direction"] = direction.ceil
        return vehicle
      end
    end

    direction = lib.calcDirection vehicle, nextPoint
    vehicle["direction"] = direction.ceil

    return vehicle
  end


  def facing?(vehicleDirection, pointDirection)
    (vehicleDirection.abs - pointDirection).abs <= 25
  end

end

address = "127.0.0.1"
port = 8124

if ARGV.length == 1
  address = ARGV[0]
end

if ARGV.length == 2
  address = ARGV[0]
  port = ARGV[1]
end

bot = Bot.new
bot.start(WinnerBot.new, address, port)
