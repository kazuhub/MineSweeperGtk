# �}�C���X�C�[�p
# �c���̘g���Ɣ��e����������쐬�B
# ms = MineSweeper.new(8 /* �c */, 8 /* �� */, 10)
# ���x���ɂ���Ĕ��e�̐����ς��B(�����A�����A�㋉)
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

  # �G���A���J��
  # �����Fx => �c, y => ��
  # �߂�l�F���ӂ̔��e���B���e�̏ꍇ��false
  def open(x, y)
    # �͈͊O
    return nil unless inner_area?(x, y)	  
    a = self[x, y]
    return nil unless a

    unless a.open? 
      a.open

      if a.mine?
        @miss = true
      else
        # �G���A���J���������C���N�������g
        @open_cnt += 1
      end
    end

    if a.mine?
      false
    else
      a.next_mine
    end
  end

  # �Q�[���N���A�������ǂ����B
  # (���e�ȊO�̂��ׂẴG���A���Ђ炢�Ă��邩)
  def complete?
    if @miss
      false
    else
      # �S�G���A - ���e�� == �J��������
      (areas - @mines) == @open_cnt
    end
  end

  # ������Ԃɖ߂�
  # ��̃G���A���I�[�v�����Ă��Ȃ����
  def clear
    @open_cnt = 0
    @miss = false
	
    # �G���A�̃N���A
    @board.each do |x|
      x.each do |y|
        y.clear
      end
    end

    self
  end

  # ���݂̃{�[�h�̏�Ԃ𕶎���ŕ\��
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
 
  # �G���A����?
  def inner_area?(x, y)
    0 <= x && x < @x && 0 <= y && y < @y 
  end

  # �f�t�H���g�̔��e��
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

  # �{�[�h�ɔ��e�������_���ɃZ�b�g
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
  
  # ���͂̔��e�����v�Z���Z�b�g
  def set_next_mine
    @board.each_with_index do |x, i|
      x.each_with_index do |y, j|
	y.next_mine = next_mine(i, j) unless y.mine?
      end
    end
  end

  # ����G���A�̎��͂̔��e���v�Z
  # �O��F���e�ݒu��
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

    # �אڂ��锚�e��
    def open
      @open = true
      @next_mine
    end

    # ������Ԃɖ߂�
    def clear
      @open = false
    end
  end
end
