*>Evaluate verb example

Working-storage section. 
01 command PIC XXXX. 

Procedure Division. 
         Display "ADD, LIST, CALC, REM, EXIT ? : " with no advancing 
           Accept command 
           Evaluate command 
                when "ADD "   Display "Adding"  
             				  Perform add-order  
                when "LIST"   Display "Listing" 
                              Perform list-all 
                when "REM"    Display "Removing" 
                              Perform remove-order 
                when "EXIT"   Display "Exiting"  
                              Close order-file 
                              Stop Run 
                when other    Display "Invalid command" 


-----------------------
*>Example ISAM program 
Identification Division. 
Program-id. isam-multikey-demo. 
Environment Division. 
Input-output section. 
file-control. 
        select  roster-file  
                assign "stuidx.dat"  
                organization indexed  
                access dynamic record key is stu-id-course 
                alternate record key is stu-course with duplicates 
                alternate record key is stu-id with duplicates.
Data Division. 
File Section. 
FD roster-file. 
01 stu-rec. 
   02 stu-id-course. 
        03 stu-id PIC xxxx. 
        03 stu-course PIC x(5). 
   02 final-grade PIC x.

Working-Storage Section. 
01 save-id PIC xxxx. 

Procedure Division. 
*> Populate Data File 
          move "X" to stu-id 
          open i-o roster-file 
          perform until stu-id = spaces 
                display "id :" with no advancing 
                accept stu-id 
                if stu-id not = spaces 
				display "course : " with no advancing accept stu-course 
                write stu-rec invalid key display "oops" stop run end-write 
                end-if 
          end-perform 
          close roster-file 

*>  Look up by student 
        open i-o roster-file 
        display "Enter Student to find: " with no advancing. accept stu-id 
        Read roster-file key is stu-id invalid key 
            Display "Student id not on file" 
        not invalid key 
            Display "lookup by student: "stu-id, " ", stu-course 
            Move stu-id to save-id 
            Perform until stu-id not = save-id 
                     Read roster-file next at end display "at end" exit perform 
                     if stu-id = save-id 
                     Display "Next Student: " stu-id, " ", stu-course end-if 
             end-perform 
        End-read 

*>  Look up by course 
        Display "Enter course to lookup: " with no advancing. 
        Accept stu-course 
        Read roster-file key is stu-course invalid key 
           Display "read-by-course: course not on file" 
        not invalid key 
           Display "Read by course" stu-id, " ", stu-course 
        End-read. 


*>  Sequential read of Indexed file 
        Close roster-file. 
        Open Input roster-file. 
        Perform forever 
             Read roster-file next at end exit perform 
             not at end 
              Display "Read next: " stu-id, " ", stu-course 
             end-read 
         end-perform 
         close roster-file 
        stop run. 

-----------------------
*>Write a program that will maintain a list of students, courses, and final grades.   


Identification Division. 
Program-id. Class11.
Environment Division. 
Input-output section. 
file-control. 
	select data-file
            assign "stuidx.dat"  
            organization indexed  
            access dynamic record key is student-id-course 
            alternate record key is student-course with duplicates 
            alternate record key is student-id with duplicates.

Data Division.
File Section.
FD data-file.
	01 student-record.
		02 student-id-course.
			03 student-id PIC XXXX.
			03 student-course PIC XXXXX.
		02 final-grade pic X. 

Working-Storage Section.
01 save-id PIC XXXX. 
01 command PIC X(6).
01 save-id-course PIC X(9).
01 new-grade PIC X.

Procedure Division. 

READ-SEQUENTIALLY.
        *>this could be the main issue!Close data-file. 
        Open Input data-file. 
        Perform forever 
             Read data-file next at end exit perform 
             not at end 
             Display "Read next: " student-id, " ", student-course 
             end-read 
         end-perform 
         close data-file. 
DONE-READ-SEQUENTIALLY.


READ-BY-COURSE.
		DISPLAY "Enter a course :" with no advancing
        Accept student-course
        open i-o data-file 
        Read data-file key is student-course invalid key 
           Display "read-by-course: course not on file" 
        not invalid key 
           Display "Read by course: " student-id, " ", student-course 
        End-read
        close data-file. 
DONE-READ-BY-COURSE.

EVAL-COMMANDS.
    Display "LIST, SHOW, ADD, UPDATE, REMOVE, EXIT ? :" with no advancing 
    Accept command. 
    Evaluate command 

        when "LIST"
        	  Display "Listing contents of entire file" 
              PERFORM list-all   *>list the whole file  

        when "SHOW" 
        	  Display "Showing all students in 67-211"
        	  PERFORM show-all *> show the students taking 67-211

        when "ADD"   
        	  Display "Adding a record"  
              PERFORM add-stu-id-course *>add new student/course

        when "UPDATE" 
        	  Display "Updating a record"
        	  PERFORM update-rec  *>read and rewrite needed?

        when "REMOVE" 
        	  Display "Removing a record" 
              PERFORM remove-order *>delete needed?

        when "EXIT"   
        	  Display "Exiting"  
              Close data-file 
              Stop Run 

        when other    
        	  Display "Invalid command"

        END-EVALUATE.
DONE-EVAL-COMMANDS. 

Stop Run.

LIST-ALL.
	OPEN i-o data-file
	PERFORM forever
		READ data-file next at end exit perform

		not at end DISPLAY student-record
		end-READ
	end-Perform
	close data-file.
DONE-LIST-ALL.

SHOW-ALL.
	OPEN i-o data-file
	PERFORM forever
		READ data-file next at end exit perform

		not at end 
		IF student-course = 67211 THEN 
		DISPLAY student-id
		END-IF
		end-READ
	end-Perform
	close data-file.
DONE-SHOW-ALL.

ADD-STU-ID-COURSE. *> adds a new record, in this case stu-id-course
	DISPLAY "Enter new student-ID-course: "
	ACCEPT save-id-course.
	MOVE save-id-course to student-id-course.

	OPEN i-o data-file.
		MOVE save-id-course TO student-id-course.

		WRITE student-record *>FROM save-id-course
			INVALID KEY DISPLAY "oops?"
			NOT INVALID KEY DISPLAY "Record Added"
		END-WRITE.
	CLOSE data-file.
DONE-ADD-STU-ID-COURSE.

UPDATE-REC. *>updates the rec
	DISPLAY "Enter the student-record you'd like to change: ".
	ACCEPT save-id-course.
	MOVE save-id-course to student-record.

	OPEN I-O data-file.
	READ data-file
		KEY IS student-record
		INVALID KEY DISPLAY "KEY DOES NOT EXIST"

	DISPLAY "Enter the new grade: ".
	ACCEPT new-grade. 

	MOVE save-id-course TO student-id-course.
	MOVE new-grade TO final-grade.

	DISPLAY "Updated student-record is: " student-record.

	REWRITE data-file from save-id-course
	END-REWRITE.
	CLOSE data-file.
DONE-UPDATE-REC.

REMOVE-ORDER.
	*> Specific record deletion isn't possible in sequential files? 
	OPEN I-O data-file.
	READ data-file
		KEY IS student-id-course
		INVALID KEY DISPLAY "KEY DOES NOT EXIST"
		DELETE data-file
		*>End-DELETE. is this really needed?
	END-READ.
	CLOSE data-file. 
DONE-REMOVE-ORDER.














