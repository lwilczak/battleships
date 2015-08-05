# author: Łukasz Wilczak
module BattleShips
  
  class Game
  
    def initialize
      @grid = Grid.new
      @player = nil
    end
    
    def play
      ships = [
        Battleship.new,
        Destroyer.new,
        Destroyer.new,
        Destroyer.new
      ]
      ships.each { |ship| ship.place_ship(@grid) }
      puts ships.inspect
      @grid.draw_ships
            
    end    
  end
  
  
  
  class Grid
    def initialize
      @cells = Array.new(100, ".")
      @ships_cells = Array.new
    end
    
    def draw
      print " "
      10.times { |i| print " #{(i+1).to_s}" }
      print "\n"
      10.times do |y|
        print "#{(65+y).chr}"
        10.times{|x| print " #{@cells[x + y*10]}" }
        print "\n"
      end
    end
    
    def draw_ships
      print " "
      10.times { |i| print " #{(i+1).to_s}" }
      print "\n"
      10.times do |y|
        print "#{(65+y).chr}"
        10.times{|x| print @ships_cells.include?(x + y*10) ? " X" : " ." }
        print "\n"
      end
    end
    
    attr_accessor :cells, :ships_cells
  end
 
  
  class Ship
    
    attr_reader :status, :length, :positions
    
    def place_ship(grid)
      @positions = Array.new

      orientation = rand(2)
      if orientation > 0
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
      
      place_ship(grid) unless allocate(grid)
    end
    
    private
    
    def allocate(grid)
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
  
  
  
  #class HumanPlayer < Player
  #  def select_position!
  #    @game.print_board
  #    loop do
  #      print "Select your #{marker} position: "
  #     selection = gets.to_i
  #      return selection if @game.free_positions.include?(selection)
  #      puts "Position #{selection} is not available. Try again."
  #    end
  #  end
  #
  #  def to_s
  #    "Human"
  #  end
  #end
  
  
  
end

include BattleShips
Game.new.play