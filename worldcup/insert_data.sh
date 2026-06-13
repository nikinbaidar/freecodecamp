#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE games, teams;")

cat games.csv | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  if [[ $year != "year" ]]; then

    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")
  
    if [[ -z $WINNER_TEAM_ID ]]; then 
      echo $($PSQL \
      "INSERT INTO teams(name)
      VALUES ('$winner');"
      )
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner';")   
    fi

    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")

    if [[ -z $OPPONENT_TEAM_ID ]]; then 
      echo $($PSQL \
      "INSERT INTO teams(name)
      VALUES ('$opponent');"
      )
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent';")
    fi

    echo $($PSQL \
    "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES('$year', '$round', $WINNER_TEAM_ID, $OPPONENT_TEAM_ID, $winner_goals, $opponent_goals);"
    )
  fi
done
