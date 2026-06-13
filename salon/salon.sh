#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon -t --no-align -c"

# echo $($PSQL "TRUNCATE customers, appointments")

MAIN_MENU () {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  echo "$($PSQL "SELECT * FROM services")" | while IFS="|" read s_id s_name
  do
    echo "$s_id) $s_name"
  done

  read SERVICE_ID_SELECTED

    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
    MAIN_MENU "Enter a valid service"
    return
  fi
  
  SERVICE_EXISTS=$($PSQL "SELECT EXISTS(SELECT 1 FROM services WHERE service_id = '$SERVICE_ID_SELECTED');")
  echo $SERVICE_EXISTS

  if [[ $SERVICE_EXISTS = 'f' ]]; then
    MAIN_MENU 
  fi

  selected_service_name=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED") 

  if [[ -z $selected_service_name ]]; then
    MAIN_MENU "Choose a valid service"
    return
  fi

  echo -e "\nEnter your phone number"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'") 

  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nEnter you name:"
    read CUSTOMER_NAME
    echo $($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nEnter appointment time"
  read SERVICE_TIME


  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo $INSERT_APPOINTMENT_RESULT

  if [[ "$INSERT_APPOINTMENT_RESULT" = "INSERT 0 1" ]]; then
    echo "I have put you down for a $selected_service_name at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

MAIN_MENU
