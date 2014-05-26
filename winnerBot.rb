require File.join(File.dirname(__FILE__), 'botlib')
require 'pry'

class WinnerBot

  attr_accessor :botname, :icon

  def initialize
    @botname = "Winner"
    @icon = "X"
  end

  def onTurn(lib)
    # Stuff
    vehicle = lib.getVehicle
    track = lib.getTrack
    vehicle["thrust"] = 10
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
        if lib.facing?(direction, speedUpDirection)
          puts "speed"
          nextPoint = nextSpeedUpPoint
        end
        # if nextSpeedUpPointDistance < 45
        #   puts "reduce"
        #   vehicle["thrust"] = 5
        # end
      end
    end


    # Maybe we need a wall first?
    unless nextWall.nil?
      wallDirection = lib.calcDirection(vehicle, nextWall)
      nextPointDistance = lib.calcDistance(vehicle, nextRacePoint)
      nextWallDistance = lib.calcDistance(vehicle, nextWall)
      if nextWallDistance < nextPointDistance
        # Before//Behind check
        if lib.facing?(direction, wallDirection)
          puts "wall"
          nextPoint = nextWall
          wall = true
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

    # walls = lib.getWalls
    # walls.each do |wall|
    #   if ( ((wall["x"].abs - x).abs <= 25) && ((wall["y"].abs - y).abs <= 25) )
    #     puts "hang"
    #     direction = lib.calcDirection vehicle, nextPoint
    #     direction < 270 ? (direction = direction + 35) : (direction = direction - 35)
    #     vehicle["direction"] = direction
    #     return vehicle
    #   end
    # end

    direction = lib.calcDirection vehicle, nextPoint
    vehicle["direction"] = direction.ceil

    # if track["racepoints"].length > 0
    #   targetPoint = lib.getCoordsNextRacepoint
    # end

    # if !targetPoint.nil?
    #   direction = lib.calcDirection vehicle, targetPoint
    # end

    # if !vehicle.nil?
    #   vehicle["direction"] = direction.ceil
    #   vehicle["thrust"] = 100
    # end

    return vehicle
  end

end

bot = Bot.new
bot.start(WinnerBot.new)

