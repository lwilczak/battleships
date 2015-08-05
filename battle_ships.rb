# author: Łukasz Wilczak

module BattleShips
  
  class Game
  
    def initialize
      puts "**************************************"
      puts "*** Battle ships by Lukasz Wilczak ***"
      puts "**************************************"
      puts "hint: to leave any time type \"exit\", to preview positions type \"show\" \n"
      
      @status = "new"
      @steps = 0
      @grid = Grid.new
      @player = nil
      # below you can add more ships to game
      @ships = [
        Battleship.new,
        Destroyer.new,
        Destroyer.new
      ]
      # below each ship will be placed to grid 
      @ships.each { |ship| ship.place_ship(@grid) }
      @grid.draw
    end
    
    def play
      # loop until game is finished. you can finish it by winning or type exit
      until @status == "finished" do
        puts "\nEnter coordinates (row, col), e.g. A5 = "
        # get the command
        input = gets.to_s.strip.upcase
        case input
          when "EXIT"  
            @status = "finished"
          when "SHOW"
            puts "\nIt's not fair, but i will show you where ships are hidden..."
            @grid.draw_ships
          else
            # first checking if coordinates are correct
            if Grid.validate_coord(input)
              #increment step and try to shot
              @steps += 1
              shot(Grid.coord_to_position(input))
            else
              puts "\nIt's not correct coordinates, try again!"
            end
            @grid.draw
        end
      end      
    end
    
    def shot(position)
      # first check on ship cells list if there is any ship under selected position
      if @grid.ships_cells.include?(position)
        @ships.each do |ship|
          #then check what ship is it, and hit it or sunk
          if ship.positions.include?(position)
            ship.hit(position)
            @grid.cells[position] = "X"
            puts ship.status == "sunk" ? "\nSunk" : "\nHit"
            # finish game if all ships are sunk
            finish_game if all_sunk?
          end
        end
      else
        puts "\nMiss"
        @grid.cells[position] = "-"
      end
    end
    
    def finish_game
      # set status to finished
      @status = "finished"
      puts "\nWell done! You completed the game in #{@steps} shots"
    end
    
    def all_sunk?
      # check if all ships are sunk
      @ships.each{|ship| return false unless ship.status == "sunk" }
    end
  end
    
  
  class Grid
    
    attr_accessor :cells, :ships_cells
    
    def initialize
      # cells is a representation of current game results. Possible values for each field
      # . means not shot
      # - means missed
      # X means hit
      @cells = Array.new(100, ".")
      # below list of all fields where ships are located
      @ships_cells = Array.new
    end
    
    def draw
      # method to draw current situation in game as grid
      print "\n "
      10.times { |i| print " #{(i+1).to_s}" }
      print "\n"
      10.times do |y|
        print "#{(65+y).chr}"
        10.times{|x| print " #{@cells[x + y*10]}" }
        print "\n"
      end
    end
    
    def draw_ships
      # method to draw all ships on grid
      print "\n "
      10.times { |i| print " #{(i+1).to_s}" }
      print "\n"
      10.times do |y|
        print "#{(65+y).chr}"
        10.times{|x| print @ships_cells.include?(x + y*10) ? " X" : " ." }
        print "\n"
      end
    end
    
    def self.coord_to_position(coord)
      # tool - method to recalculate coordinates to position in grid
      (coord[0].ord - 65).to_i * 10 + (coord[1..2].to_i) - 1
    end
    
    def self.validate_coord(coord)
      # validation of typed coordinations
      return false if coord.length < 2
      return false unless coord[0].ord.between?(65,74)
      return false unless coord[1..2].to_i.between?(1,10)
      true
    end    
    
  end
 
  class Ship
    
    attr_reader :status, :length, :positions
    
    def place_ship(grid)
      # this random first ortentation (horizontal, vertical), then random top left corner of ship
      # corner coordinates are decreased by length of ship to not out of range of grid
      @positions = Array.new
      if rand(2) > 0
        pos_x = rand(10-self.length)
        pos_y = rand(10)
        self.length.times do |i|
          @positions << pos_x + i + pos_y*10
        end
      else
        pos_x = rand(10)
        pos_y = rand(10-self.length)
        self.length.times do |i|
          @positions << (pos_x + i*10 + pos_y*10)
        end
      end
      # Below check if randomed place is free on grid, if not - try again find a place
      # here is a danger that application will make infinitive loop. when there will be more ships 
      # then place on grid. Because number of ships and their lenths are hardcoded, there will not 
      # be this kind of situation, we know there is enought place.
      place_ship(grid) unless allocate(grid)
    end
    
    def hit(position)
      # used when user hit the ship, then this cell is removed from postions of ship.
      # If all positions are deleted, then ship is sunk
      @positions.delete(position)
      @status = "sunk" if @positions.count == 0
    end
    
    private
    
    def allocate(grid)
      # try to allocate current ship. if ship can be alocated, also added postions of it to grid ship cells.
      free_space = true
      @positions.each {|p| free_space = false if grid.ships_cells.include?(p) }
      if free_space
        grid.ships_cells.concat(@positions)
        @status = "new"
        return true
      else
        return false
      end      
    end

  end
  
  class Battleship <  Ship
    def initialize
      @length = 5
    end
  end

  class Destroyer < Ship
    def initialize
      @length = 4
    end
  end
  
end

include BattleShips
Game.new.play