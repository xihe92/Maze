class Maze

  def initialize (*size)
    @n = size[0]
    @m = size[1]
    @maze_table = Array.new(2*@m+1){Array.new(2*@n+1)}
  end

  # load a string to construct a maze
  def load (data)
    if data.size != @maze_table.size * @maze_table[0].size
      print "the string has incorrect lenghth\n"
      return
    else
      i = 0
      @maze_table.each do |row|
        (0..row.size-1).each do |index|
          row[index] = data[i]
          i += 1
        end
      end
    end
    if valid
      print "valid maze\n"
    else
      print "invalid maze\n"
    end
  end

  # determine if the maze is valid
  def valid
    for i in 0..(@n-1)
      for j in 0..(@m-1)
        return false if @maze_table[2*j+1][2*i+1] == "1"
        walls = 0
        walls += 1 if @maze_table[2*j][2*i+1] == "1"
        walls += 1 if @maze_table[2*j+2][2*i+1] == "1"
        walls += 1 if @maze_table[2*j+1][2*i+2] == "1"
        walls += 1 if @maze_table[2*j+1][2*i] == "1"
        return false if walls < 1 || walls > 3
      end
    end
    for i in 0..(@maze_table.size-1)
      return false if @maze_table[i][0] == "0" || @maze_table[i][2*@n] == "0"
    end
    for i in 0..(@maze_table[0].size-1)
      return false if @maze_table[0][i] == "0" || @maze_table[2*@m][i] == "0"
    end
    return true
  end

  # display the maze with a readable pattern
  def display ()
    @maze_table.each_with_index do |row, i|
      (0..row.size-1).each do |index|
        print "+" if row[index] == "1" && i % 2 == 0 && index % 2 == 0
        print "-" if row[index] == "1" && i % 2 == 0 && index % 2 == 1
        print "|" if row[index] == "1" && i % 2 == 1 
        print " " if row[index] == "0"
      end
      print "\n"
    end
  end

  # determine if there is a path between two cells
  def solve (begX, begY, endX, endY)
    beg_x = 2 * begY + 1
    beg_y = 2 * begX + 1
    end_x = 2 * endY + 1
    end_y = 2 * endX + 1
    @visit = Array.new(@maze_table.size){Array.new(@maze_table[0].size, false)}
    @track = []
    return scout(beg_x, beg_y, end_x, end_y)
  end

  # get the path between two cells and print each cell's coordinates through which the path passes
  def trace (begX, begY, endX, endY)
    beg_x = 2 * begY + 1
    beg_y = 2 * begX + 1
    end_x = 2 * endY + 1
    end_y = 2 * endX + 1
    @visit = Array.new(@maze_table.size){Array.new(@maze_table[0].size, false)}
    @track = []
    if scout(beg_x, beg_y, end_x, end_y)
      printf "it is a path between %s and %s \n", [begX, begY], [endX, endY]
      @track.each do |i|
        printf "Position: (%s, %s)\n", (i[1]-1)/2, (i[0]-1)/2 if i[0] % 2 ==1 && i[1] % 2 == 1
      end
    end
  end

  # a DFS to find and record the path
  def scout (x, y, endX, endY)
    if x == endX && y == endY
      @visit[x][y] = true
      @track.unshift [x, y]
      return true
    end
    return false if @maze_table[x][y] == "1"
    if !@visit[x][y]
      @visit[x][y] = true
      if scout(x, y+1, endX, endY) || scout(x, y-1, endX, endY) || scout(x+1, y, endX, endY) || scout(x-1, y, endX, endY)
        @track.unshift [x, y] 
        return true
      end
    end
    return false
  end

  # for Prim algorithm. add wall, cell and direction if the neighbor cell is not connected
  def add_neighbor(x, y)
    @waiting.push([[x-1,y], [x-2,y], "up"]) if x-1 > 1 && @maze_table[x-2][y] == "w"
    @waiting.push([[x+1,y], [x+2,y], "down"]) if x+1 < 2*@m-1 && @maze_table[x+2][y] == "w"
    @waiting.push([[x,y-1], [x,y-2], "left"]) if y-1 > 1 && @maze_table[x][y-2] == "w"
    @waiting.push([[x,y+1], [x,y+2], "right"]) if y+1 < 2*@n-1 && @maze_table[x][y+2] == "w"
  end
  
  # count a cell's walls
  def count_walls(x, y)
    walls = 0
    walls += 1 if @maze_table[x][y+1] == "1"
    walls += 1 if @maze_table[x][y-1] == "1"
    walls += 1 if @maze_table[x+1][y] == "1"
    walls += 1 if @maze_table[x-1][y] == "1"
    return walls
  end

  # redesign the maze using Prim algorithm
  def redesign
    @waiting = []
    @maze_table = Array.new(2*@m+1){Array.new(2*@n+1, "1")}
    for i in 0..2*@m
      for j in 0..2*@n
        @maze_table[i][j] = "w" if i%2==1 && j%2==1
      end
    end
    sx = 2*rand(@m)+1
    sy = 2*rand(@n)+1
    @maze_table[sx][sy] = "0"#set cell
    add_neighbor(sx, sy)
    until @waiting.empty?
      wall, cell, dir = @waiting.delete_at(rand(@waiting.length))
      pre = [cell[0]-2, cell[1]] if dir == "down"
      pre = [cell[0]+2, cell[1]] if dir == "up"
      pre = [cell[0], cell[1]-2] if dir == "right"
      pre = [cell[0], cell[1]+2] if dir == "left"
      if @maze_table[cell[0]][cell[1]] == "w" && count_walls(pre[0],pre[1]) > 1
        @maze_table[cell[0]][cell[1]] = "0"
        @maze_table[wall[0]][wall[1]] = "0"
        add_neighbor(cell[0], cell[1]) 
      end
    end
  end
end

test = Maze.new(4,4)
test.load("111111111100010001111010101100010101101110101100000101111011101100000101111111111")
test.display
test.trace(0, 0, 3, 3)

print "\n"

for i in 0..6
  test.redesign
  print "redesign...\n"
  print "maze is valid\n" if test.valid
  test.display
  print "\n"
end

