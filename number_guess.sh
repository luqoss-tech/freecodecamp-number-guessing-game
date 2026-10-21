#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME

# check username in database
RESULT_USERNAME=$($PSQL "SELECT user_id, username, game_played, best_game FROM user_data WHERE username='$USERNAME'")

# query result condition
if [[ -z $RESULT_USERNAME ]]
then
  # if not found
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  # saving username to database
  INSERT_USERNAME=$($PSQL "INSERT INTO user_data(username) VALUES('$USERNAME')")
    
else
  # result found do pipe & read
  echo $RESULT_USERNAME | while IFS="|" read USER_ID NAME GAME_PLAYED BEST_GAME
  do
    # greeting old player
    echo -e "\nWelcome back, $NAME! You have played $GAME_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo $SECRET_NUMBER

# count guessing variable
NUMBER_OF_GUESSES=0

# guessing secret number
echo -e "\nGuess the secret number between 1 and 1000:"

while true
do
  read NUMBER
    
  # count guessing
  (( NUMBER_OF_GUESSES++ ))

  # check input is integer
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
  then
    # if input not integer
    echo -e "\nThat is not an integer, guess again:"
    read NUMBER
  else
      
    # if input number > secret number
    if (( NUMBER > SECRET_NUMBER ))
    then
      echo -e "\nIt's lower than that, guess again:"
    # if input number < secret number
    elif (( NUMBER < SECRET_NUMBER ))
    then
      echo -e "\nIt's higher than that, guess again:"
    # if input number matched with secret number
    else
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

      # query database
      QUERY_RESULT=$($PSQL "SELECT username, game_played, best_game FROM user_data WHERE username='$USERNAME'")
      echo $QUERY_RESULT | while IFS='|' read NAME GAME_PLAYED BEST_GAME
      do
        # +1 game history
        (( GAME_PLAYED++ ))
        # update result game played to database
        TOTAL_GAME_PLAYED=$($PSQL "UPDATE user_data SET game_played=$GAME_PLAYED WHERE username='$USERNAME'")

        # check high score
        if (( BEST_GAME == 0 || NUMBER_OF_GUESSES < BEST_GAME ))
        then
          # update result best game to database
          RESULT_NUMBER_OF_GUESSES=$($PSQL "UPDATE user_data SET best_game=$NUMBER_OF_GUESSES WHERE username='$USERNAME'")
        fi
      done
      #shut the program
      break
    fi
  fi
done
