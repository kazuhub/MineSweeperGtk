# マインスイーパ
# 縦横の枠数と爆弾数から問題を作成。
# ms = MineSweeper.new(8 /* 縦 */, 8 /* 横 */, 10)
# レベルによって爆弾の数が変わる。(初級、中級、上級)
class MineSweeper

  LEVEL_EASY = 0.1
  LEVEL_NORMAL = 0.3
  LEVEL_HARD = 0.5

  attr_reader :x, :y, :mines

  def initialize(x, y, args = {})
    mine = args[:mine] unless args.empty?
    level = args[:level] unless args.empty?
    raise ArgumentError.new("x > 0, y > 0") if(x <= 0 || y <= 0)
    raise ArgumentError.new("0 < mine < x * y") if(mine && (mine <= 0 || (x * y) <= mine))

    @x = x
    @y = y
    @mines = mine || default_mine(level)
    @open_cnt = 0
    @miss = false
    @board = Array.new(@x){ Array.new(@y){Area.new } }
    set_mine
    set_next_mine
  end

  def areas
    @x * @y
  end

  # エリアを開く
  # 引数：x => 縦, y => 横
  # 戻り値：周辺の爆弾数。爆弾の場合はfalse
  def open(x, y)
    # 範囲外
    return nil unless inner_area?(x, y)	  
    a = self[x, y]
    return nil unless a

    unless a.open? 
      a.open

      if a.mine?
        @miss = true
      else
        # エリアを開いた件数インクリメント
        @open_cnt += 1
      end
    end

    if a.mine?
      false
    else
      a.next_mine
    end
  end

  # ゲームクリアしたかどうか。
  # (爆弾以外のすべてのエリアをひらいているか)
  def complete?
    if @miss
      false
    else
      # 全エリア - 爆弾数 == 開いた件数
      (areas - @mines) == @open_cnt
    end
  end

  # 初期状態に戻す
  # 一つのエリアもオープンしていない状態
  def clear
    @open_cnt = 0
    @miss = false
	
    # エリアのクリア
    @board.each do |x|
      x.each do |y|
        y.clear
      end
    end

    self
  end

  # 現在のボードの状態を文字列で表示
  def show
    @board.each do |x|
      x.each do |y|
	 if y.mine? 
	   print sprintf("%3s", "*")
         else
	   print sprintf("%3s", y.next_mine)
	 end
      end
      puts ""
    end
  end

  private

  def [](x, y)
    @board[x][y]
  end
 
  # エリア内か?
  def inner_area?(x, y)
    0 <= x && x < @x && 0 <= y && y < @y 
  end

  # デフォルトの爆弾数
  def default_mine(level = LEVEL_NORMAL)
    per = case level 
	  when LEVEL_EASY, LEVEL_NORMAL, LEVEL_HARD
	    level
	  else
            LEVEL_NORMAL
	  end
    m = (areas * per).truncate
    m == 0 ? 1 : m
  end

  # ボードに爆弾をランダムにセット
  def set_mine
    count = 0
    while(@mines > count) 
      a = self[rand(x), rand(y)]
      unless a.mine? 
        a.instance_variable_set(:@mine, true)
        count += 1
      end
    end
  end
  
  # 周囲の爆弾数を計算しセット
  def set_next_mine
    @board.each_with_index do |x, i|
      x.each_with_index do |y, j|
	y.next_mine = next_mine(i, j) unless y.mine?
      end
    end
  end

  # あるエリアの周囲の爆弾数計算
  # 前提：爆弾設置済
  def next_mine x, y
    count = 0
    (x - 1..x + 1).each do |ex|
      (y - 1..y + 1).each do |ey|
         if inner_area?(ex, ey) && self[ex, ey].mine?
           count += 1
	 end
      end
    end
    count
  end

  class Area    
    attr_accessor :next_mine

    def initialize(mine = false)
      @mine = mine
      @next_mine = 0
      @open = false
    end

    def mine?
      @mine
    end

    def open?
      @open
    end

    # 隣接する爆弾数
    def open
      @open = true
      @next_mine
    end

    # 初期状態に戻す
    def clear
      @open = false
    end
  end
end
