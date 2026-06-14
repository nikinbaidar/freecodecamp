#!/bin/bash


if [[ $1 ]]; then
  PSQL="psql -X -U freecodecamp -d periodic_table -t --no-align -c"
  QUERY="SELECT atomic_number, symbol, name, types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types ON properties.type_id = types.type_id"

  if [[ $1 =~ ^[0-9]+$ ]]; then  
    RESULT=$($PSQL "$QUERY WHERE atomic_number = $1")
  else
    RESULT=$($PSQL "$QUERY WHERE symbol LIKE '$1' OR name LIKE '$1'")
  fi

  if [[ -z $RESULT ]]; then
    echo I could not find that element in the database.
  else  
    echo $RESULT | while IFS="|" read atomic_number symbol name type atomic_mass mpoint bpoint
    do
      echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $mpoint celsius and a boiling point of $bpoint celsius."
    done
  fi
else
  echo Please provide an element as an argument.
fi
# fix:
# feat:
#refactor:
#chore:
