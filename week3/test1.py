import random
import numpy as np
# Prepare the board with ships. This function takes the board size and the list of ship sizes as parameters and returns a prepared board.

# the board is 10x10, and there are 5 ships of sizes 2, 3, 3, 4, and 5
# play_game(10, [2, 3, 3, 4, 5])
# ship can be placed horizontally or vertically, but not diagonally
# 0 = horizontal, 1 = vertical
# Ships can touch each other but two ships cannot occupy the same cell. All ships should be completely within the playing board.

# function to prepare the board with ships
def prepare_board(board_size, ship_sizes): 
    # initialize the board with empty squares
    # 'O' represents an empty square, _ is a placeholder for the index, the actual value is not used
    board = [['O' for _ in range(board_size)] for _ in range(board_size)]
    # randomly place the ships on the board
    for size in ship_sizes: # for each ship
        orientation = random.randint(0, 1) # 0 = horizontal, 1 = vertical
        x, y = random.randint(0, board_size-size), random.randint(0, board_size-size) # random starting position
        if orientation == 0: # horizontal
            for i in range(size): # place the ship
                board[x+i][y] = 'S' # 'S' represents a ship, x+i is the row, y is the column
        else:
            for i in range(size): 
                board[x][y+i] = 'S' # 'S' represents a ship, x is the row, y+i is the column
    return board # return the board with ships

# Game
# guess/hit their locations by providing row and column of the cell to hit.
# Player gets a response from the game on the result of the guess: hit or miss.
# When the player hits all parts/cells of all ships, the game is over.

# Player function might take the board size and its own version of the board with the history of past hits and misses as parameters and returns coordinates of the next guess.

# function for the player to guess the next cell
'''
def player_guess(board_size, player_board):
    # generate a random guess for the first move
    if all(cell == 'O' for row in player_board for cell in row): # if the player's board is empty
        return random.randint(0, board_size-1), random.randint(0, board_size-1) # return a random guess
    # find the best next guess based on the history of past hits and misses
    best_guess = None # (row, column)
    best_score = -1 # the score of the best guess
    for i in range(board_size):
        for j in range(board_size):
            if player_board[i][j] == 'O':
                # calculate the score for the adjacent cells that contain 'O'
                score = sum(1 for x, y in [(i+1, j), (i-1, j), (i, j+1), (i, j-1)]
                            if 0 <= x < board_size and 0 <= y < board_size and player_board[x][y] == 'O') 
                if score > best_score:
                    best_guess = (i, j) # (row, column)
                    best_score = score 
    return best_guess
'''


def player_guess(board_size, player_board): # player_board is a 2D list
    player_board = np.array(player_board) # convert the player's board to a 2D numpy array
    if np.all(player_board == 'O'): # if the player's board is empty
        return np.random.randint(0, board_size), np.random.randint(0, board_size) # return a random guess
    # find the best next guess based on the history of past hits and misses if the player's board is not empty
    best_guess = None 
    best_score = -1 
    for i in range(board_size): 
        for j in range(board_size): # iterate through the player's board
            if player_board[i, j] == 'O': # bases on the number of adjacent cells that contain 'O', calculate the score for each cell that contains 'O'
                score = np.sum(player_board[max(i-1, 0):min(i+2, board_size), j] == 'O') + np.sum(player_board[i, max(j-1, 0):min(j+2, board_size)] == 'O') # calculate the score for the adjacent cells that contain 'O'
                if score > best_score: # if the score is higher than the best score
                    best_guess = (i, j) # (row, column)
                    best_score = score 
    return best_guess # return the best guess with the highest score



# Check function takes the board and player’s guess and returns the result: hit or miss.

# function to check if the guess hits a ship
def check_guess(board, guess): # guess is a tuple of (row, column)
    row, col = guess # unpack the tuple
    if board[row][col] == 'S': # if the guess hits a ship
        board[row][col] = 'X' # 'X' represents a hit
        return "Hit!" # return "Hit!"
    else:
        board[row][col] = '-' # '-' represents a miss
        return "Miss." # return "Miss."     
  

# Last two function would run in a loop until the player hits all ships and the game is over.

# function to play the game
def play_game(board_size, ship_sizes):
    # prepare the board with ships
    board = prepare_board(board_size, ship_sizes)
    # initialize the player's board with empty squares
    player_board = [['O' for _ in range(board_size)] for _ in range(board_size)]
    # play the game until all ships are sunk
    num_guesses = 0
    while any('S' in row for row in board):
        guess = player_guess(board_size, player_board)
        result = check_guess(board, guess)
        player_board[guess[0]][guess[1]] = result[0]
        print("Guess:", guess)
        print("Result:", result) # print the result of the guess
        num_guesses += 1
    return num_guesses


# Run a simulation: repeat the game 1000 (or more) times and report statistics of how long it takes for the player to finish the game. 

# simulation to test the average number of guesses required to win the game
num_games = 1000 # number of games to play
total_guesses = 0 
for i in range(num_games): # play the game 1000 times
    num_guesses = play_game(10, [2, 3, 3, 4, 5]) # play the game
    total_guesses += num_guesses # add the number of guesses to the total number of guesses
average_guesses = total_guesses / num_games # calculate the average number of guesses
print("Average number of guesses required to win the game:", average_guesses) 

# Github copilot is used in this project.





        