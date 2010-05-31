require "../minesweeper.rb"
require "test/unit.rb"

class MineSweeper_test < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_initialize
    area_x = 8
    area_y = 8
    @sw = MineSweeper.new(area_x, area_y)
    assert_equal(@sw.x, area_x)
    assert_equal(@sw.y, area_y)
    assert_equal(@sw.areas, area_x * area_y)
    assert_equal(@sw.mines, (area_x * area_y * MineSweeper::LEVEL_NORMAL).truncate)
  end

  def test_initialize_mine
    area_x = 5
    area_y = 5
    mine = {:mine => 20}
    @sw = MineSweeper.new(area_x, area_y, mine)
    assert_equal(@sw.x, area_x)
    assert_equal(@sw.y, area_y)
    assert_equal(@sw.areas, area_x * area_y)
    assert_equal(@sw.mines, mine[:mine])
  end

  def test_initialize_level_easy
    area_x = 5
    area_y = 5
    mine = {:level => MineSweeper::LEVEL_EASY}
    @sw = MineSweeper.new(area_x, area_y, mine)
    assert_equal(@sw.x, area_x)
    assert_equal(@sw.y, area_y)
    assert_equal(@sw.areas, area_x * area_y)
    assert_equal(@sw.mines, (area_x * area_y * MineSweeper::LEVEL_EASY).truncate)
  end

  def test_initialize_level_normal
    area_x = 5
    area_y = 5
    mine = {:level => MineSweeper::LEVEL_NORMAL}
    @sw = MineSweeper.new(area_x, area_y, mine)
    assert_equal(@sw.x, area_x)
    assert_equal(@sw.y, area_y)
    assert_equal(@sw.areas, area_x * area_y)
    assert_equal(@sw.mines, (area_x * area_y * MineSweeper::LEVEL_NORMAL).truncate)
  end

  def test_initialize_level_hard
    area_x = 5
    area_y = 5
    mine = {:level => MineSweeper::LEVEL_HARD}
    @sw = MineSweeper.new(area_x, area_y, mine)
    assert_equal(@sw.x, area_x)
    assert_equal(@sw.y, area_y)
    assert_equal(@sw.areas, area_x * area_y)
    assert_equal(@sw.mines, (area_x * area_y * MineSweeper::LEVEL_HARD).truncate)
  end
  def test_initialize_error_x
    area_x = 0
    area_y = 1
    mine = {:mine => 1}
    assert_raise(ArgumentError) {MineSweeper.new(area_x, area_y, mine)}
  end
 
  def test_initialize_error_y
    area_x = 1
    area_y = 0
    mine = {:mine => 1}
    assert_raise(ArgumentError) {MineSweeper.new(area_x, area_y, mine)}
  end
 
  def test_initialize_error_mine
    area_x = 1
    area_y = 1
    mine = {:mine => 0}
    assert_raise(ArgumentError) {MineSweeper.new(area_x, area_y, mine)}
  end

  def test_initialize_error_mine_over
    area_x = 5
    area_y = 5
    mine = {:mine => 25}
    assert_raise(ArgumentError) {MineSweeper.new(area_x, area_y, mine)}
  end

  def test_show
    area_x = 8
    area_y = 8
    @sw = MineSweeper.new(area_x, area_y)
    puts ""
    puts "mine:#{@sw.mines}"
    @sw.show
  end
 
  def test_open
    area_x = 8
    area_y = 8
    @sw = MineSweeper.new(area_x, area_y)
    puts ""
    puts "mine:#{@sw.mines}"
    @sw.show
 
    area_x.times do |x|
      area_y.times do |y|
	p "x, y => #{x}, #{y}"
        p @sw.open(x, y)
      end
    end
  end

  def test_open_over_x
    area_x = 8
    area_y = 8
    @sw = MineSweeper.new(area_x, area_y)
    @sw.show
   
    assert_nil(@sw.open(area_x, 1))
    assert_nil(@sw.open(-1, 1))
  end

  def test_open_over_y
    area_x = 8
    area_y = 8
    @sw = MineSweeper.new(area_x, area_y)
    @sw.show
   
    assert_nil(@sw.open(1, area_y))
    assert_nil(@sw.open(1, -1))
  end
  
  def test_complete?
    area_x = 2
    area_y = 2
    @sw = MineSweeper.new(area_x, area_y)
    puts ""
    puts "mine:#{@sw.mines}"
    @sw.show
   
    area_x.times do |x|
      area_y.times do |y|
	p "x, y => #{x}, #{y}"
        p "next_mine => #{@sw.open(x, y)}"
	p "complete? #{@sw.complete?}"
      end
    end
  end

  def test_clear
    area_x = 2
    area_y = 2
    @sw = MineSweeper.new(area_x, area_y)
    mine = @sw.mines
    areas = @sw.areas
    puts ""
    puts "mine:#{@sw.mines}"
    @sw.show

    area_x.times do |x|
      area_y.times do |y|
	p "x, y => #{x}, #{y}"
        p "next_mine => #{@sw.open(x, y)}"
	p "complete? #{@sw.complete?}"
      end
    end

    @sw.clear

    assert_equal(@sw.areas, areas)
    assert_equal(@sw.mines, mine)
    assert_equal(@sw.instance_variable_get(:@open_cnt), 0)
    assert_equal(@sw.instance_variable_get(:@miss), false)

    @sw.show
  end

end
