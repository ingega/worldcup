#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo -e "\nThis is the init of the insert_data\n"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS

# first work with teams
do
# print WINNER OPPONENT with debug propouses
  echo winner $WINNER opponent $OPPONENT
  # avoid first row, because is the header
  if [[ $WINNER != "winner" ]]
  then
    # get the team name, first we can add the winner after the opponent
    NAME="$($PSQL "SELECT name FROM teams WHERE name = '$WINNER'")"
    echo name is $NAME
    if [[ -z $NAME ]]
    then
      # insert winner team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $NAME
      else
        echo $WINNER is already in database
      fi
    fi
    # insert opponent team
    NAME="$($PSQL "SELECT name FROM teams WHERE name = '$OPPONENT'")"
    echo name is $NAME
    if [[ -z $NAME ]]
    then
      # insert winner team
      INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $NAME
      else
        echo $OPPONENT is already in database
      fi
    fi
  fi
done

# let's insert games, the fields are game_id (auto) year, round, winner_id, opponent_id, winner_goals, opponent_goals
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # all teams is already inserted, first step, get the winner_id, opponent_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  # insert game
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
  then
    echo Inserted into games, $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
  fi
  
done