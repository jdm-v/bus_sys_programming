Identification Division.
Program-id. Class10m.
Data Division.
File Section.

Working-Storage Section. 
01 game-results Picture x(80). 
01 results-code Pic X. 
		88 done-normalizing value "W". 

Procedure Division. 
PERFORM FOREVER 
	Call "Class10s" using game-results, results-code
	IF done-normalizing then 
   		EXIT PERFORM 

	IF RESULTS-CODE IS "R" THEN DISPLAY "From normalize: " game-results

	END-IF

END-PERFORM.
Stop run. 


-----------------------------------------
-----------------------------------------
-----------------------------------------


Identification Division. 
Program-id. Class10s. 
Environment Division. 
Input-Output Section. 
File-Control. 
        Select in-file 
           assign file-to-open
           organization line sequential. 
Data Division. 
File Section. 
FD in-file Global. 
    01 team-record. 
        03 record-type-flag PIC X. 
                88 team-type value "T". 
                88 game-type value "G". 
        03 team-name pic X(15). 

    01 game-record. 
        03 PIC X. *> intentional?
        03 home-score PIC 99. 
        03 opponent-score PIC 99. 
        03 opponent PIC X(15). 

Working-Storage Section. 
01 file-to-open Pic X(80) Global. 
01 records-read Pic S999 VALUE 0 Global. 
01 saved-team-name PIC X(15).
01 saved-home-score PIC 99.
01 saved-away-score PIC 99.

Linkage Section. 
01 return-record Pic X(80). 
01 done-flag Pic X. 

Procedure Division 
    Using return-record, done-flag.

    IF records-read = 0 THEN

        DISPLAY "What is the name of the file to open and store?"
        ACCEPT file-to-open

        CALL "openfile"

    END-IF.

    PERFORM FOREVER
        READ in-file
            AT END EXIT PERFORM 

            NOT AT END PERFORM FLAG-CHECK 

        END-READ
    END-PERFORM.

    MOVE "W" to done-flag.

    CALL "closefile" using file-to-open.

    Goback. *>make sure i'm returning the created string!

Stop Run.

FLAG-CHECK.
    IF record-type-flag = "T" THEN
        MOVE team-name TO saved-team-name 
    END-IF

    IF record-type-flag = "G" THEN
    	MOVE home-score TO saved-home-score
    	MOVE opponent-score TO saved-away-score

        PERFORM STR-CREATION
    END-IF.
DONE-FLAG-CHECK.

STR-CREATION.

    STRING 
    saved-team-name delimited " "
    ","

    opponent delimited by " " 
    ","

    saved-home-score
    ","

    saved-away-score delimited by "   "
    "   " delimited by size 

    INTO return-record.

    MOVE "R" TO done-flag.

    ADD 1 TO records-read.

    Goback.

    *> use this for debugging -> DISPLAY return-record.

DONE-STR-CREATION.

*>---------------------------------------

Identification Division. 
Program-id. openfile. 
Data Division. 
Working-storage Section. 

Procedure Division. 
OPEN input in-file.
Goback.
End Program openfile. 

*>---------------------------------------

Identification Division. 
Program-id. closefile. 

Procedure Division. 
    DISPLAY "Total records read: " records-read.
    CLOSE in-file. 

Goback.
End Program closefile.
*>---------------------------------------
End Program Class10s.