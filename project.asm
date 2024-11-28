.386
.model flat, stdcall
.stack 4096
INCLUDE Irvine32.inc
ExitProcess PROTO, dwExitCode:DWORD

.data
; Define variables to store train information
trainName BYTE 50 DUP(?)
departure BYTE 50 DUP(?)
destination BYTE 50 DUP(?)
fare DWORD 100    ; Default train fare
seats DWORD 100    ; Default train seats (increased to 100)

; Define variables to store airline information
airlineName BYTE 50 DUP(?)
airlineDeparture BYTE 50 DUP(?)
airlineDestination BYTE 50 DUP(?)
airlineFare DWORD 1000    ; Default airline fare
airlineAvailSeats DWORD 100 ; Default airline seats (increased to 100)

; Define variables to store bus information
busName BYTE 50 DUP(?)
busDeparture BYTE 50 DUP(?)
busDestination BYTE 50 DUP(?)
busFare DWORD 50      ; Default bus fare
busAvailSeats DWORD 100 ; Default bus seats (increased to 100)

; Define variables to store user details
userName BYTE 50 DUP(?)
userAge DWORD ?
seatsBooked DWORD ?

; Add arrays to track seat availability (0 = available, 1 = taken)
trainSeatArray BYTE 100 DUP(0)      ; Array for train seats (increased to 100)
airlineSeatArray BYTE 100 DUP(0)    ; Array for airline seats (increased to 100)
busSeatArray BYTE 100 DUP(0)        ; Array for bus seats (increased to 100)

; Add variables to store allocated seat numbers
allocatedSeats BYTE 20 DUP(?)  ; Buffer to store seat numbers as string
tempSeat BYTE 4 DUP(?)        ; Temporary buffer for number conversion

; Msg declarations
msgWelcome BYTE "WELCOME TO Transportation Booking System", 0
msgPin BYTE "Enter your pin to continue: ", 0
msgMainMenu BYTE "PRESS 1 for User and 2 for ADMIN: ", 0
msgTrainName BYTE "Enter train name: ", 0
msgAirlineName BYTE "Enter airline name: ", 0
msgBusName BYTE "Enter bus name: ", 0
msgDeparture BYTE "Enter departure: ", 0
msgFare BYTE "Enter fare: ", 0
msgSeats BYTE "Enter seats: ", 0
msgInvalidChoice BYTE "Invalid choice. Please try again.", 0
msgPinInvalid BYTE "Invalid pin. Access denied.", 0
msgRunAgain BYTE "Do you want to run the program again? (1 for yes, 0 for no): ", 0
msgBookSeats BYTE "Enter the number of seats you want to book: ", 0
msgBookingSuccess BYTE "Booking successful!", 0
msgBookingFail BYTE "Booking failed. Not enough seats available.", 0
msgFare1 BYTE "Fare: ", 0
msgSeat1 BYTE "Seats: ", 0
msgDis BYTE "Destination: ", 0
msgDep BYTE "Departure: ", 0
msgName BYTE "Name: ", 0
msgBookingType BYTE "Select Booking Type:", 0
msgBookingOptions BYTE "1. Train", 13,10, "2. Airline", 13,10, "3. Bus", 0
msgEnterName BYTE "Enter your name: ", 0
msgEnterAge BYTE "Enter your age: ", 0
msgTicket BYTE "----- TICKET -----", 0
msgUserName BYTE "User Name: ", 0
msgUserAge BYTE "User Age: ", 0
msgTravelDetails BYTE "Travel Details:", 0
msgSeatsBooked BYTE "Seats Booked: ", 0
msgTotalPrice BYTE "Total Price: ", 0
msgSeatNumbers BYTE "Available seats: ", 0
msgAllocatedSeats BYTE "Allocated seat numbers: ", 0
msgComma BYTE ", ", 0
msgSource BYTE "Enter your source location: ", 0
msgDestination BYTE "Enter your destination: ", 0

; Add variables to store user's journey details
userSource BYTE 50 DUP(?)
userDestination BYTE 50 DUP(?)

.code
main PROC
again:
    call clrscr
    mov edx, offset msgWelcome
    call WriteString
    call Crlf
    mov edx, offset msgPin
    call WriteString
    call Crlf
    call ReadInt
    cmp eax, 69
    jne pin_error

    mov edx, offset msgMainMenu
    call WriteString 
    call Crlf
    call ReadInt
    cmp eax, 1
    je user
    cmp eax, 2
    je admin
    jmp invalid_choice

user:
    ; Select Booking Type
    call crlf
    mov edx, offset msgBookingType
    call WriteString
    call Crlf
    mov edx, offset msgBookingOptions
    call WriteString
    call Crlf
    call ReadInt
    cmp eax, 1
    je user_train
    cmp eax, 2
    je user_airline
    cmp eax, 3
    je user_bus
    jmp invalid_choice

user_train:
    ; Collect user details
    call crlf
    mov edx, offset msgEnterName
    call WriteString
    call Crlf
    mov edx, offset userName
    mov ecx, sizeof userName
    call ReadString
    call crlf

    mov edx, offset msgEnterAge
    call WriteString
    call Crlf
    call ReadInt
    mov userAge, eax
    call crlf

    ; Add source input
    mov edx, offset msgSource
    call WriteString
    call Crlf
    mov edx, offset userSource
    mov ecx, sizeof userSource
    call ReadString
    call crlf

    ; Add destination input
    mov edx, offset msgDestination
    call WriteString
    call Crlf
    mov edx, offset userDestination
    mov ecx, sizeof userDestination
    call ReadString
    call crlf

    ; Display available train data
    mov edx, offset msgName
    call WriteString
    mov edx, offset trainName
    call WriteString
    call Crlf

    mov edx, offset msgDep
    call WriteString
    mov edx, offset departure
    call WriteString
    call Crlf

    mov edx, offset msgDis
    call WriteString
    mov edx, offset destination
    call WriteString
    call Crlf

    mov edx, offset msgFare1
    call WriteString
    mov eax, fare
    call WriteDec
    call Crlf

    mov edx, offset msgSeat1
    call WriteString
    mov eax, seats
    call WriteDec
    call Crlf

    ; Display available seats
    call display_available_seats
    
    ; Ask for number of seats
    mov edx, offset msgBookSeats
    call WriteString
    call ReadInt
    mov seatsBooked, eax
    
    ; Check if enough seats are available
    mov ebx, 0          ; Count available seats
    mov ecx, 100       ; Check all available seats
    mov esi, 0
check_train_seats:
    movzx eax, BYTE PTR trainSeatArray[esi]  ; Zero extend byte to dword
    cmp eax, 0
    jne skip_train_count
    inc ebx
skip_train_count:
    inc esi
    cmp esi, 100
    jl check_train_seats
    
    cmp seatsBooked, ebx
    jg booking_failed
    
    ; Allocate seats
    call allocate_seats
    cmp eax, 0
    je booking_failed
    
    ; Display booking success message
    call crlf
    mov edx, offset msgBookingSuccess
    call WriteString
    call Crlf

    ; Print the ticket
    call print_ticket_train
    jmp done

user_airline:
    ; Collect user details
    call crlf
    mov edx, offset msgEnterName
    call WriteString
    call Crlf
    mov edx, offset userName
    mov ecx, sizeof userName
    call ReadString
    call crlf

    mov edx, offset msgEnterAge
    call WriteString
    call Crlf
    call ReadInt
    mov userAge, eax
    call crlf

    ; Add source input
    mov edx, offset msgSource
    call WriteString
    call Crlf
    mov edx, offset userSource
    mov ecx, sizeof userSource
    call ReadString
    call crlf

    ; Add destination input
    mov edx, offset msgDestination
    call WriteString
    call Crlf
    mov edx, offset userDestination
    mov ecx, sizeof userDestination
    call ReadString
    call crlf

    ; Display available airline data
    mov edx, offset msgName
    call WriteString
    mov edx, offset airlineName
    call WriteString
    call Crlf

    mov edx, offset msgDep
    call WriteString
    mov edx, offset airlineDeparture
    call WriteString
    call Crlf

    mov edx, offset msgDis
    call WriteString
    mov edx, offset airlineDestination
    call WriteString
    call Crlf

    mov edx, offset msgFare1
    call WriteString
    mov eax, airlineFare
    call WriteDec
    call Crlf

    mov edx, offset msgSeat1
    call WriteString
    mov eax, airlineAvailSeats
    call WriteDec
    call Crlf

    ; Display available seats
    call display_available_seats
    
    ; Ask for number of seats
    mov edx, offset msgBookSeats
    call WriteString
    call ReadInt
    mov seatsBooked, eax
    
    ; Check if enough seats are available
    mov ebx, 0          ; Count available seats
    mov ecx, 100       ; Check all available seats
    mov esi, 0
check_airline_seats:
    movzx eax, BYTE PTR airlineSeatArray[esi]  ; Zero extend byte to dword
    cmp eax, 0
    jne skip_airline_count
    inc ebx
skip_airline_count:
    inc esi
    cmp esi, 100
    jl check_airline_seats
    
    cmp seatsBooked, ebx
    jg booking_failed
    
    ; Allocate seats
    call allocate_seats
    cmp eax, 0
    je booking_failed
    
    ; Display booking success message
    call crlf
    mov edx, offset msgBookingSuccess
    call WriteString
    call Crlf

    ; Print the ticket
    call print_ticket_airline
    jmp done

user_bus:
    ; Collect user details
    call crlf
    mov edx, offset msgEnterName
    call WriteString
    call Crlf
    mov edx, offset userName
    mov ecx, sizeof userName
    call ReadString
    call crlf

    mov edx, offset msgEnterAge
    call WriteString
    call Crlf
    call ReadInt
    mov userAge, eax
    call crlf

    ; Add source input
    mov edx, offset msgSource
    call WriteString
    call Crlf
    mov edx, offset userSource
    mov ecx, sizeof userSource
    call ReadString
    call crlf

    ; Add destination input
    mov edx, offset msgDestination
    call WriteString
    call Crlf
    mov edx, offset userDestination
    mov ecx, sizeof userDestination
    call ReadString
    call crlf

    ; Display available bus data
    mov edx, offset msgName
    call WriteString
    mov edx, offset busName
    call WriteString
    call Crlf

    mov edx, offset msgDep
    call WriteString
    mov edx, offset busDeparture
    call WriteString
    call Crlf

    mov edx, offset msgDis
    call WriteString
    mov edx, offset busDestination
    call WriteString
    call Crlf

    mov edx, offset msgFare1
    call WriteString
    mov eax, busFare
    call WriteDec
    call Crlf

    mov edx, offset msgSeat1
    call WriteString
    mov eax, busAvailSeats
    call WriteDec
    call Crlf

    ; Display available seats
    call display_available_seats
    
    ; Ask for number of seats
    mov edx, offset msgBookSeats
    call WriteString
    call ReadInt
    mov seatsBooked, eax
    
    ; Check if enough seats are available
    mov ebx, 0          ; Count available seats
    mov ecx, 100       ; Check all available seats
    mov esi, 0
check_bus_seats:
    movzx eax, BYTE PTR busSeatArray[esi]  ; Zero extend byte to dword
    cmp eax, 0
    jne skip_bus_count
    inc ebx
skip_bus_count:
    inc esi
    cmp esi, 100
    jl check_bus_seats
    
    cmp seatsBooked, ebx
    jg booking_failed
    
    ; Allocate seats
    call allocate_seats
    cmp eax, 0
    je booking_failed
    
    ; Display booking success message
    call crlf
    mov edx, offset msgBookingSuccess
    call WriteString
    call Crlf

    ; Print the ticket
    call print_ticket_bus
    jmp done

admin:
    ; Select Booking Type
    call crlf
    mov edx, offset msgBookingType
    call WriteString
    call Crlf
    mov edx, offset msgBookingOptions
    call WriteString
    call Crlf
    call ReadInt
    cmp eax, 1
    je admin_train
    cmp eax, 2
    je admin_airline
    cmp eax, 3
    je admin_bus
    jmp invalid_choice

admin_train:
    mov edx, offset msgTrainName
    call WriteString
    call Crlf
    mov edx, offset trainName
    mov ecx, sizeof trainName
    call ReadString
    call crlf

    mov edx, offset msgDeparture
    call WriteString
    call Crlf
    mov edx, offset departure
    mov ecx, sizeof departure
    call ReadString
    call crlf

    mov edx, offset msgDestination
    call WriteString
    call Crlf
    mov edx, offset destination
    mov ecx, sizeof destination
    call ReadString
    call crlf

    mov edx, offset msgFare
    call WriteString
    call Crlf
    call ReadInt
    mov fare, eax
    call crlf

    mov edx, offset msgSeats
    call WriteString
    call Crlf
    call ReadInt
    mov seats, eax      ; Store total seats
    
    ; Reset seat array with new size
    mov ecx, 100          ; First clear existing array
    mov esi, 0
clear_train_array:
    mov trainSeatArray[esi], 0
    inc esi
    loop clear_train_array
    
    call crlf
    jmp done

admin_airline:
    mov edx, offset msgAirlineName
    call WriteString
    call Crlf
    mov edx, offset airlineName
    mov ecx, sizeof airlineName
    call ReadString
    call crlf

    mov edx, offset msgDeparture
    call WriteString
    call Crlf
    mov edx, offset airlineDeparture
    mov ecx, sizeof airlineDeparture
    call ReadString
    call crlf

    mov edx, offset msgDestination
    call WriteString
    call Crlf
    mov edx, offset airlineDestination
    mov ecx, sizeof airlineDestination
    call ReadString
    call crlf

    mov edx, offset msgFare
    call WriteString
    call Crlf
    call ReadInt
    mov airlineFare, eax
    call crlf

    mov edx, offset msgSeats
    call WriteString
    call Crlf
    call ReadInt
    mov airlineAvailSeats, eax
    
    ; Reset airline seat array
    mov ecx, 100
    mov esi, 0
clear_airline_array:
    mov airlineSeatArray[esi], 0
    inc esi
    loop clear_airline_array
    
    call crlf
    jmp done

admin_bus:
    mov edx, offset msgBusName
    call WriteString
    call Crlf
    mov edx, offset busName
    mov ecx, sizeof busName
    call ReadString
    call crlf

    mov edx, offset msgDeparture
    call WriteString
    call Crlf
    mov edx, offset busDeparture
    mov ecx, sizeof busDeparture
    call ReadString
    call crlf

    mov edx, offset msgDestination
    call WriteString
    call Crlf
    mov edx, offset busDestination
    mov ecx, sizeof busDestination
    call ReadString
    call crlf

    mov edx, offset msgFare
    call WriteString
    call Crlf
    call ReadInt
    mov busFare, eax
    call crlf

    mov edx, offset msgSeats
    call WriteString
    call Crlf
    call ReadInt
    mov busAvailSeats, eax
    
    ; Reset bus seat array
    mov ecx, 100
    mov esi, 0
clear_bus_array:
    mov busSeatArray[esi], 0
    inc esi
    loop clear_bus_array
    
    call crlf
    jmp done

pin_error:
    mov edx, offset msgPinInvalid
    call WriteString
    call Crlf
    jmp done

invalid_choice:
    mov edx, offset msgInvalidChoice
    call WriteString
    call Crlf
    jmp again

booking_failed:
    ; Display booking failed message
    mov edx, offset msgBookingFail
    call WriteString
    call Crlf
    jmp done

done:
    call Crlf
    mov edx, offset msgRunAgain
    call WriteString
    call Crlf
    call ReadInt
    cmp eax, 1
    je again

    INVOKE ExitProcess, 0

; Procedures to print tickets
print_ticket_train PROC
    call crlf
    mov edx, offset msgTicket
    call WriteString
    call crlf

    ; User Details
    mov edx, offset msgUserName
    call WriteString
    mov edx, offset userName
    call WriteString
    call crlf

    mov edx, offset msgUserAge
    call WriteString
    mov eax, userAge
    call WriteDec
    call crlf

    mov edx, offset msgTravelDetails
    call WriteString
    call crlf

    ; Source and Destination
    mov edx, offset msgDep
    call WriteString
    mov edx, offset userSource
    call WriteString
    call crlf

    mov edx, offset msgDis
    call WriteString
    mov edx, offset userDestination
    call WriteString
    call crlf

    ; Fare and Seats
    mov edx, offset msgFare1
    call WriteString
    mov eax, fare
    call WriteDec
    call crlf

    mov edx, offset msgSeatsBooked
    call WriteString
    mov eax, seatsBooked
    call WriteDec
    call crlf

    ; Total Price
    mov edx, offset msgTotalPrice
    call WriteString
    mov eax, seatsBooked
    mul fare
    call WriteDec
    call crlf

    ; Allocated Seats
    mov edx, offset msgAllocatedSeats
    call WriteString
    
    mov ecx, 100
    mov esi, 0
print_seats_loop:
    mov al, trainSeatArray[esi]
    cmp al, 1
    jne skip_print
    mov eax, esi
    inc eax
    call WriteDec
    mov edx, offset msgComma
    call WriteString
skip_print:
    inc esi
    cmp esi, 100
    jl print_seats_loop
    
    call Crlf
    ret
print_ticket_train ENDP

print_ticket_airline PROC
    call crlf
    mov edx, offset msgTicket
    call WriteString
    call crlf

    ; User Details
    mov edx, offset msgUserName
    call WriteString
    mov edx, offset userName
    call WriteString
    call crlf

    mov edx, offset msgUserAge
    call WriteString
    mov eax, userAge
    call WriteDec
    call crlf

    mov edx, offset msgTravelDetails
    call WriteString
    call crlf

    ; Source and Destination
    mov edx, offset msgDep
    call WriteString
    mov edx, offset userSource
    call WriteString
    call crlf

    mov edx, offset msgDis
    call WriteString
    mov edx, offset userDestination
    call WriteString
    call crlf

    ; Fare and Seats
    mov edx, offset msgFare1
    call WriteString
    mov eax, airlineFare
    call WriteDec
    call crlf

    mov edx, offset msgSeatsBooked
    call WriteString
    mov eax, seatsBooked
    call WriteDec
    call crlf

    ; Total Price
    mov edx, offset msgTotalPrice
    call WriteString
    mov eax, seatsBooked
    mul airlineFare
    call WriteDec
    call crlf

    ; Allocated Seats
    mov edx, offset msgAllocatedSeats
    call WriteString
    
    mov ecx, 100
    mov esi, 0
print_seats_loop:
    mov al, airlineSeatArray[esi]
    cmp al, 1
    jne skip_print
    mov eax, esi
    inc eax
    call WriteDec
    mov edx, offset msgComma
    call WriteString
skip_print:
    inc esi
    cmp esi, 100
    jl print_seats_loop
    
    call Crlf
    ret
print_ticket_airline ENDP

print_ticket_bus PROC
    call crlf
    mov edx, offset msgTicket
    call WriteString
    call crlf

    ; User Details
    mov edx, offset msgUserName
    call WriteString
    mov edx, offset userName
    call WriteString
    call crlf

    mov edx, offset msgUserAge
    call WriteString
    mov eax, userAge
    call WriteDec
    call crlf

    mov edx, offset msgTravelDetails
    call WriteString
    call crlf

    ; Source and Destination
    mov edx, offset msgDep
    call WriteString
    mov edx, offset userSource
    call WriteString
    call crlf

    mov edx, offset msgDis
    call WriteString
    mov edx, offset userDestination
    call WriteString
    call crlf

    ; Fare and Seats
    mov edx, offset msgFare1
    call WriteString
    mov eax, busFare
    call WriteDec
    call crlf

    mov edx, offset msgSeatsBooked
    call WriteString
    mov eax, seatsBooked
    call WriteDec
    call crlf

    ; Total Price
    mov edx, offset msgTotalPrice
    call WriteString
    mov eax, seatsBooked
    mul busFare
    call WriteDec
    call crlf

    ; Allocated Seats
    mov edx, offset msgAllocatedSeats
    call WriteString
    
    mov ecx, 100
    mov esi, 0
print_seats_loop:
    mov al, busSeatArray[esi]
    cmp al, 1
    jne skip_print
    mov eax, esi
    inc eax
    call WriteDec
    mov edx, offset msgComma
    call WriteString
skip_print:
    inc esi
    cmp esi, 100
    jl print_seats_loop
    
    call Crlf
    ret
print_ticket_bus ENDP

; Add new procedure to display available seats
display_available_seats PROC
    push ecx
    push esi
    
    mov edx, offset msgSeatNumbers
    call WriteString
    
    mov ecx, 100      ; Loop through all 100 seats
    mov esi, 0      ; Start with seat 1
    
display_loop:
    movzx eax, BYTE PTR trainSeatArray[esi]    ; Zero extend byte to dword
    cmp eax, 1
    je skip_seat
    
    ; Display available seat number
    mov eax, esi
    inc eax         ; Add 1 to display seat numbers starting from 1
    call WriteDec
    mov edx, offset msgComma
    call WriteString
    
skip_seat:
    inc esi
    cmp esi, 100
    jl display_loop
    
    call Crlf
    pop esi
    pop ecx
    ret
display_available_seats ENDP

; Add procedure to allocate seats
allocate_seats PROC
    push ecx
    push esi
    
    mov esi, 0          ; Index for allocatedSeats string
    mov ecx, seatsBooked
    mov ebx, 0          ; Seat counter
    
allocate_loop:
    cmp ebx, 100          ; Check if we've checked all seats
    jge allocation_failed
    
    movzx eax, BYTE PTR trainSeatArray[ebx]  ; Zero extend byte to dword
    cmp eax, 1
    je next_seat
    
    ; Allocate this seat
    mov trainSeatArray[ebx], 1
    
    ; Convert seat number to string and add to allocatedSeats
    mov eax, ebx
    inc eax             ; Seat numbers start from 1
    
    ; Add seat number to allocatedSeats
    call WriteDec       ; This will display the seat number
    mov edx, offset msgComma
    call WriteString
    
    dec ecx             ; One less seat to allocate
    cmp ecx, 0
    je allocation_done
    
next_seat:
    inc ebx
    jmp allocate_loop
    
allocation_failed:
    mov eax, 0          ; Return 0 for failure
    jmp allocate_end
    
allocation_done:
    mov eax, 1          ; Return 1 for success
    
allocate_end:
    pop esi
    pop ecx
    ret
allocate_seats ENDP

main ENDP

END main