# config:utf-8

# Gtkのマインスイーパー
# ゲーム開始時にエリア(縦、横)、レベル(初級、中級、上級)を選択する。
# 爆弾を選択したらゲーム終了
# 爆弾以外をすべて開いたらゲームクリア
require "gtk2"
require "minesweeper/minesweeper"
class MineSweeperGtk

  W_WIDTH = 400
  W_HEIGHT = 400
  STATUS_NONE = 0         # ステータス：初期
  STATUS_COMPLETE = 1     # ステータス：ゲームクリア
  STATUS_GAMEOVER = 2     # ステータス：ゲームオーバー

  def initialize
    @window = Gtk::Window.new
    @window.title = "MineSweeper"
    @window.set_default_size(W_WIDTH, W_HEIGHT)
    @window.signal_connect("destroy") {Gtk.main_quit}
       
    @v_box = Gtk::VBox.new(false, 1)
    @v_box.border_width = 1
    @v_box.pack_start(menu_bar, false, true, 0)
    @window.add(@v_box)
    
    @level ||= MineSweeper::LEVEL_NORMAL
  end

  def show
    @window.show_all
    Gtk.main
  end

  def quit
    Gtk.main_quit
  end

  private
  def menu_bar
    accel_group = Gtk::AccelGroup.new
    menu_bar = Gtk::ItemFactory.new(Gtk::ItemFactory::TYPE_MENU_BAR, 
				    "<MineMain>",
 				    accel_group)
    @window.add_accel_group(accel_group)

    # ゲーム開始処理
    proc_start = Proc.new do |data, w| 
      inc = false
      @v_box.each do |c|
        if @borad && @borad == c
          @v_box.remove(@borad)
          break
	end
      end

      @v_box.pack_start(@borad = board, true, true, 0)
      @window.show_all
    end

    proc_reset = Proc.new do |data, w| 
      @v_box.each do |c|
        if @borad && @borad == c
          @borad.each {|a| a.label = ""}
          @mine_sweeper.clear
          break
	end
      end
      
      @status = STATUS_NONE
      @window.show_all
    end

    proc_end = Proc.new{|data, w| self.quit}
    proc_lev_es = Proc.new{|data, w| @level = MineSweeper::LEVEL_EASY}
    proc_lev_nm = Proc.new{|data, w| @level = MineSweeper::LEVEL_NORMAL}
    proc_lev_hd = Proc.new{|data, w| @level = MineSweeper::LEVEL_HARD}

    menus = [['/Game/Start', Gtk::ItemFactory::ITEM, nil, nil, proc_start],
	     ["/Game/Reset", Gtk::ItemFactory::ITEM, nil, nil, proc_reset],
	     ["/Game/End", Gtk::ItemFactory::ITEM, nil, nil, proc_end],
	     ["/Level/easy", Gtk::ItemFactory::ITEM, nil, nil, proc_lev_es],
	     ["/Level/normal", Gtk::ItemFactory::ITEM, nil, nil, proc_lev_nm],
	     ["/Level/hard", Gtk::ItemFactory::ITEM, nil, nil, proc_lev_hd]]
    menu_bar.create_items(menus)
    menu_bar.get_widget("<MineMain>")
  end

  # ボード生成
  # 引数 ：x => 行
  #      ：y => 列
  # 戻り値：x行y列のボタンを配置したGkt::Tableオブジェクト     
  def board(x = 8, y = 8)
    @mine_sweeper = MineSweeper.new(x, y, {:level => @level})
    @mboard = []
    @status = STATUS_NONE

    b = Gtk::Table.new(x, y)
    x.times do |i|
      y.times do |j|	     
	bt = Gtk::Button.new
	bt.set_size_request((W_WIDTH - 10) / x, (W_HEIGHT - 10) / y)
	bt.relief = Gtk::RELIEF_NORMAL

	bt.signal_connect("clicked") do
	  if @status == STATUS_NONE
            s = @mine_sweeper.open(i, j) 
	    bt.label = s ? s.to_s : "*"
  	    if s 
  	      if @mine_sweeper.complete?
	        default_dialog("ゲームクリア!!").show
	        @status = STATUS_COMPLETE
	      end
	    else
	        default_dialog("Bomb!! ゲームオーバー").show
	        @status = STATUS_GAMEOVER
	    end
	  end
	end

	b.attach_defaults(bt, j , j + 1, i , i + 1) # left, right, top, bottom
	@mboard[i] ||=[]
	@mboard[i] << bt
      end
    end

    b
  end

  def default_dialog(msg)
    d = Gtk::MessageDialog.new(@window, Gtk::Dialog::MODAL, 
     	                       Gtk::MessageDialog::INFO,
			       Gtk::MessageDialog::BUTTONS_OK,
                 	       msg)
    d.signal_connect("response") {d.destroy}
    d
  end
end

if __FILE__ == $0
  MineSweeperGtk.new.show
end
